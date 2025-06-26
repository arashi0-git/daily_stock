from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime

from database import get_db
from models import ConsumptionRecommendation, DailyItem, User
from schemas import (
    ConsumptionRecommendation as ConsumptionRecommendationSchema,
    ConsumptionAnalysisRequest,
    ConsumptionAnalysisResponse,
    RecommendationRequest,
    BatchRecommendationResponse,
    MessageResponse
)
from routers.auth import get_current_user
from ai_client import consumption_analysis_service

router = APIRouter()

@router.get("/", response_model=List[ConsumptionRecommendationSchema])
async def get_user_recommendations(
    skip: int = 0,
    limit: int = 100,
    active_only: bool = True,
    urgency_level: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """ユーザーの推奨一覧を取得"""
    query = db.query(ConsumptionRecommendation).filter(
        ConsumptionRecommendation.user_id == current_user.id
    )
    
    if active_only:
        query = query.filter(ConsumptionRecommendation.is_active == True)
    
    if urgency_level:
        query = query.filter(ConsumptionRecommendation.urgency_level == urgency_level)
    
    recommendations = query.order_by(
        ConsumptionRecommendation.urgency_level.desc(),
        ConsumptionRecommendation.created_at.desc()
    ).offset(skip).limit(limit).all()
    
    # 関連するアイテム情報も含める
    for recommendation in recommendations:
        if recommendation.item:
            db.refresh(recommendation.item)
    
    return recommendations

@router.post("/analyze/{item_id}", response_model=ConsumptionAnalysisResponse)
async def analyze_item_consumption(
    item_id: int,
    request: ConsumptionAnalysisRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """特定商品の消費パターンを分析"""
    try:
        # 商品が存在し、ユーザーが所有しているかチェック
        item = db.query(DailyItem).filter(
            DailyItem.id == item_id,
            DailyItem.user_id == current_user.id
        ).first()
        
        if not item:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="指定された商品が見つかりません"
            )
        
        # AI サービスで分析を実行
        analysis_result = await consumption_analysis_service.analyze_user_consumption_pattern(
            current_user.id, item_id, db
        )
        
        return ConsumptionAnalysisResponse(**analysis_result)
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"消費分析エラー: {str(e)}"
        )

@router.post("/generate/{item_id}", response_model=ConsumptionRecommendationSchema)
async def generate_item_recommendation(
    item_id: int,
    request: RecommendationRequest,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """特定商品の推奨を生成・保存"""
    try:
        # 商品が存在し、ユーザーが所有しているかチェック
        item = db.query(DailyItem).filter(
            DailyItem.id == item_id,
            DailyItem.user_id == current_user.id
        ).first()
        
        if not item:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="指定された商品が見つかりません"
            )
        
        # AI サービスで推奨を生成
        recommendation_data = await consumption_analysis_service.generate_item_recommendation(
            current_user.id, item_id, db, request.target_stock_level
        )
        
        # 既存の推奨を非アクティブ化
        db.query(ConsumptionRecommendation).filter(
            ConsumptionRecommendation.user_id == current_user.id,
            ConsumptionRecommendation.item_id == item_id,
            ConsumptionRecommendation.is_active == True
        ).update({"is_active": False})
        
        # 新しい推奨を保存
        db_recommendation = ConsumptionRecommendation(
            user_id=current_user.id,
            item_id=item_id,
            recommendation_type=recommendation_data["recommended_action"],
            urgency_level=recommendation_data["urgency_level"],
            user_consumption_pace=recommendation_data["user_consumption_pace"],
            market_consumption_pace=recommendation_data["market_consumption_pace"],
            estimated_days_remaining=recommendation_data["estimated_days_remaining"],
            recommendation_message=recommendation_data["recommendation_message"].format(item_name=item.name),
            confidence_score=recommendation_data["confidence_score"],
            additional_info=recommendation_data.get("additional_info", {})
        )
        
        db.add(db_recommendation)
        db.commit()
        db.refresh(db_recommendation)
        
        # バックグラウンドで通知を作成
        background_tasks.add_task(
            _create_recommendation_notification,
            db_recommendation.id, db
        )
        
        return db_recommendation
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"推奨生成エラー: {str(e)}"
        )

@router.post("/generate-all", response_model=BatchRecommendationResponse)
async def generate_all_recommendations(
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """ユーザーの全商品の推奨を一括生成"""
    try:
        # AI サービスで一括推奨を生成
        recommendations_data = await consumption_analysis_service.generate_user_recommendations(
            current_user.id, db
        )
        
        if not recommendations_data:
            return BatchRecommendationResponse(
                recommendations=[],
                total_count=0,
                high_priority_count=0
            )
        
        # 全ての既存推奨を非アクティブ化
        db.query(ConsumptionRecommendation).filter(
            ConsumptionRecommendation.user_id == current_user.id,
            ConsumptionRecommendation.is_active == True
        ).update({"is_active": False})
        
        # 新しい推奨を保存
        saved_recommendations = []
        high_priority_count = 0
        
        for rec_data in recommendations_data:
            # 商品名を取得
            item = db.query(DailyItem).filter(DailyItem.id == rec_data["item_id"]).first()
            item_name = item.name if item else "不明な商品"
            
            db_recommendation = ConsumptionRecommendation(
                user_id=current_user.id,
                item_id=rec_data["item_id"],
                recommendation_type=rec_data["recommended_action"],
                urgency_level=rec_data["urgency_level"],
                user_consumption_pace=rec_data["user_consumption_pace"],
                market_consumption_pace=rec_data["market_consumption_pace"],
                estimated_days_remaining=rec_data["estimated_days_remaining"],
                recommendation_message=rec_data["recommendation_message"].format(item_name=item_name),
                confidence_score=rec_data["confidence_score"],
                additional_info=rec_data.get("additional_info", {})
            )
            
            db.add(db_recommendation)
            saved_recommendations.append(db_recommendation)
            
            # 高優先度のカウント
            if rec_data["urgency_level"] in ["high", "critical"]:
                high_priority_count += 1
        
        db.commit()
        
        # 推奨をリフレッシュして関連データを取得
        for rec in saved_recommendations:
            db.refresh(rec)
        
        # バックグラウンドで通知を作成
        for rec in saved_recommendations:
            if rec.urgency_level in ["high", "critical"]:
                background_tasks.add_task(
                    _create_recommendation_notification,
                    rec.id, db
                )
        
        return BatchRecommendationResponse(
            recommendations=saved_recommendations,
            total_count=len(saved_recommendations),
            high_priority_count=high_priority_count
        )
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"一括推奨生成エラー: {str(e)}"
        )

@router.put("/{recommendation_id}/acknowledge", response_model=MessageResponse)
async def acknowledge_recommendation(
    recommendation_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """推奨を確認済みとしてマーク"""
    recommendation = db.query(ConsumptionRecommendation).filter(
        ConsumptionRecommendation.id == recommendation_id,
        ConsumptionRecommendation.user_id == current_user.id
    ).first()
    
    if not recommendation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="推奨が見つかりません"
        )
    
    recommendation.acknowledged_at = datetime.now()
    db.commit()
    
    return MessageResponse(message="推奨を確認済みとしてマークしました")

@router.delete("/{recommendation_id}", response_model=MessageResponse)
async def deactivate_recommendation(
    recommendation_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """推奨を非アクティブ化"""
    recommendation = db.query(ConsumptionRecommendation).filter(
        ConsumptionRecommendation.id == recommendation_id,
        ConsumptionRecommendation.user_id == current_user.id
    ).first()
    
    if not recommendation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="推奨が見つかりません"
        )
    
    recommendation.is_active = False
    db.commit()
    
    return MessageResponse(message="推奨を非アクティブ化しました")

@router.get("/summary", response_model=dict)
async def get_recommendations_summary(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """推奨の要約情報を取得"""
    recommendations = db.query(ConsumptionRecommendation).filter(
        ConsumptionRecommendation.user_id == current_user.id,
        ConsumptionRecommendation.is_active == True
    ).all()
    
    summary = {
        "total_recommendations": len(recommendations),
        "critical_count": len([r for r in recommendations if r.urgency_level == "critical"]),
        "high_count": len([r for r in recommendations if r.urgency_level == "high"]),
        "medium_count": len([r for r in recommendations if r.urgency_level == "medium"]),
        "low_count": len([r for r in recommendations if r.urgency_level == "low"]),
        "urgent_items": [
            {
                "item_id": r.item_id,
                "item_name": r.item.name if r.item else "不明",
                "days_remaining": r.estimated_days_remaining,
                "urgency_level": r.urgency_level
            }
            for r in recommendations 
            if r.urgency_level in ["critical", "high"]
        ][:5]  # 最大5件の緊急アイテム
    }
    
    return summary

async def _create_recommendation_notification(recommendation_id: int, db: Session):
    """推奨に基づく通知を作成（バックグラウンドタスク）"""
    try:
        from models import Notification
        
        recommendation = db.query(ConsumptionRecommendation).filter(
            ConsumptionRecommendation.id == recommendation_id
        ).first()
        
        if not recommendation or recommendation.urgency_level not in ["high", "critical"]:
            return
        
        # 通知メッセージを作成
        if recommendation.urgency_level == "critical":
            notification_type = "urgent_stock_alert"
            message = f"🚨 {recommendation.item.name if recommendation.item else '商品'}の在庫が非常に少なくなっています！"
        else:
            notification_type = "stock_alert"
            message = f"⚠️ {recommendation.item.name if recommendation.item else '商品'}の購入を検討してください。"
        
        # 通知を作成
        notification = Notification(
            user_id=recommendation.user_id,
            item_id=recommendation.item_id,
            notification_type=notification_type,
            message=message,
            scheduled_date=datetime.now()
        )
        
        db.add(notification)
        db.commit()
        
    except Exception as e:
        print(f"通知作成エラー: {str(e)}")
        db.rollback()