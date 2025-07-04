from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date
import logging

from database import get_db
from models import ConsumptionRecord, DailyItem, User
from schemas import ConsumptionRecord as ConsumptionRecordSchema, ConsumptionRecordCreate, ConsumptionRecordUpdate
from routers.auth import get_current_user

router = APIRouter()

@router.get("/", response_model=List[ConsumptionRecordSchema])
async def get_consumption_records(
    skip: int = 0,
    limit: int = 100,
    item_id: Optional[int] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """消費記録一覧を取得"""
    query = db.query(ConsumptionRecord).filter(
        ConsumptionRecord.user_id == current_user.id
    )
    
    if item_id:
        query = query.filter(ConsumptionRecord.item_id == item_id)
    
    records = query.order_by(ConsumptionRecord.consumption_date.desc()).offset(skip).limit(limit).all()
    
    # 関連するアイテム情報も含める
    for record in records:
        if record.item:
            # アイテム情報を明示的にロード
            db.refresh(record.item)
    
    return records

@router.post("/", response_model=ConsumptionRecordSchema, status_code=status.HTTP_201_CREATED)
async def create_consumption_record(
    record: ConsumptionRecordCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """消費記録を作成"""
    # デバッグ用ログを追加
    logger = logging.getLogger(__name__)
    logger.info(f"🔍 消費記録作成リクエスト受信:")
    logger.info(f"  - item_id: {record.item_id}")
    logger.info(f"  - consumed_quantity: {record.consumed_quantity}")
    logger.info(f"  - consumption_date: {record.consumption_date}")
    logger.info(f"  - notes: {record.notes}")
    
    # 日用品が存在し、ユーザーが所有しているかチェック
    item = db.query(DailyItem).filter(
        DailyItem.id == record.item_id,
        DailyItem.user_id == current_user.id
    ).first()
    
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="指定された日用品が見つかりません"
        )
    
    # 消費後の残り個数を計算
    new_quantity = max(0, item.current_quantity - record.consumed_quantity)
    
    # 消費記録を作成
    db_record = ConsumptionRecord(
        user_id=current_user.id,
        item_id=record.item_id,
        consumed_quantity=record.consumed_quantity,
        consumption_date=record.consumption_date or date.today(),
        remaining_quantity=new_quantity,
        notes=record.notes
    )
    
    # 日用品の現在個数を更新
    item.current_quantity = new_quantity
    
    db.add(db_record)
    db.commit()
    db.refresh(db_record)
    
    logger.info(f"✅ 消費記録作成成功: ID={db_record.id}")
    return db_record

@router.get("/{record_id}", response_model=ConsumptionRecordSchema)
async def get_consumption_record(
    record_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """特定の消費記録を取得"""
    record = db.query(ConsumptionRecord).filter(
        ConsumptionRecord.id == record_id,
        ConsumptionRecord.user_id == current_user.id
    ).first()
    
    if record is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="消費記録が見つかりません"
        )
    return record

@router.put("/{record_id}", response_model=ConsumptionRecordSchema)
async def update_consumption_record(
    record_id: int,
    record_update: ConsumptionRecordUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """消費記録を更新"""
    record = db.query(ConsumptionRecord).filter(
        ConsumptionRecord.id == record_id,
        ConsumptionRecord.user_id == current_user.id
    ).first()
    
    if record is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="消費記録が見つかりません"
        )
    
    # 消費量が変更される場合、在庫数を調整
    if record_update.consumed_quantity is not None and record_update.consumed_quantity != record.consumed_quantity:
        item = db.query(DailyItem).filter(DailyItem.id == record.item_id).first()
        if item:
            # 元の消費量を在庫に戻し、新しい消費量を差し引く
            quantity_diff = record.consumed_quantity - record_update.consumed_quantity
            item.current_quantity += quantity_diff
            item.current_quantity = max(0, item.current_quantity)
            
            # 残り個数も更新
            record.remaining_quantity = item.current_quantity
    
    # 更新するフィールドのみを適用
    update_data = record_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(record, field, value)
    
    db.commit()
    db.refresh(record)
    return record

@router.delete("/{record_id}")
async def delete_consumption_record(
    record_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """消費記録を削除"""
    record = db.query(ConsumptionRecord).filter(
        ConsumptionRecord.id == record_id,
        ConsumptionRecord.user_id == current_user.id
    ).first()
    
    if record is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="消費記録が見つかりません"
        )
    
    # 削除前に、対応する日用品の在庫を元に戻す
    item = db.query(DailyItem).filter(DailyItem.id == record.item_id).first()
    if item:
        item.current_quantity += record.consumed_quantity
    
    db.delete(record)
    db.commit()
    return {"message": "消費記録が削除されました"}

@router.get("/item/{item_id}/history", response_model=List[ConsumptionRecordSchema])
async def get_item_consumption_history(
    item_id: int,
    skip: int = 0,
    limit: int = 50,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """特定の日用品の消費履歴を取得"""
    # 日用品が存在し、ユーザーが所有しているかチェック
    item = db.query(DailyItem).filter(
        DailyItem.id == item_id,
        DailyItem.user_id == current_user.id
    ).first()
    
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="指定された日用品が見つかりません"
        )
    
    records = db.query(ConsumptionRecord).filter(
        ConsumptionRecord.item_id == item_id,
        ConsumptionRecord.user_id == current_user.id
    ).order_by(ConsumptionRecord.consumption_date.desc()).offset(skip).limit(limit).all()
    
    return records 