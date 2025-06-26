from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from typing import List, Optional, Dict
from datetime import datetime, date, timedelta
import httpx
import os
import json
import logging
from consumption_analyzer import ConsumptionAnalyzer
from recommendation_engine import RecommendationEngine
from market_data_service import MarketDataService

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Daily Stock AI Service", version="1.0.0")

# Initialize services
consumption_analyzer = ConsumptionAnalyzer()
recommendation_engine = RecommendationEngine()
market_data_service = MarketDataService()

# Pydantic models
class ConsumptionData(BaseModel):
    item_id: int
    item_name: str
    consumption_records: List[Dict]
    current_quantity: int
    minimum_threshold: int

class RecommendationRequest(BaseModel):
    user_id: int
    item_data: ConsumptionData
    target_stock_level: Optional[int] = None

class RecommendationResponse(BaseModel):
    item_id: int
    item_name: str
    user_consumption_pace: float
    market_consumption_pace: float
    recommended_action: str
    urgency_level: str
    estimated_days_remaining: int
    recommendation_message: str
    confidence_score: float

class HealthResponse(BaseModel):
    status: str
    service: str
    timestamp: str

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """AI サービスのヘルスチェック"""
    return HealthResponse(
        status="healthy",
        service="daily_stock_ai_service",
        timestamp=datetime.now().isoformat()
    )

@app.post("/analyze/consumption-pace", response_model=Dict)
async def analyze_consumption_pace(consumption_data: ConsumptionData):
    """ユーザーの消費ペースを分析"""
    try:
        user_pace = consumption_analyzer.calculate_user_consumption_pace(
            consumption_data.consumption_records
        )
        
        return {
            "item_id": consumption_data.item_id,
            "item_name": consumption_data.item_name,
            "consumption_pace_per_day": user_pace,
            "analysis_period_days": len(consumption_data.consumption_records),
            "current_quantity": consumption_data.current_quantity,
            "estimated_days_remaining": consumption_data.current_quantity / user_pace if user_pace > 0 else float('inf')
        }
    except Exception as e:
        logger.error(f"Error analyzing consumption pace: {str(e)}")
        raise HTTPException(status_code=500, detail=f"分析エラー: {str(e)}")

@app.post("/market-data/search", response_model=Dict)
async def search_market_consumption_data(item_name: str):
    """世間の消費ペースデータを検索"""
    try:
        market_data = await market_data_service.search_consumption_pace(item_name)
        return market_data
    except Exception as e:
        logger.error(f"Error searching market data: {str(e)}")
        raise HTTPException(status_code=500, detail=f"市場データ検索エラー: {str(e)}")

@app.post("/recommendations/generate", response_model=RecommendationResponse)
async def generate_recommendation(request: RecommendationRequest):
    """消費推奨を生成"""
    try:
        # ユーザーの消費ペースを計算
        user_pace = consumption_analyzer.calculate_user_consumption_pace(
            request.item_data.consumption_records
        )
        
        # 市場の消費ペースを取得
        market_data = await market_data_service.search_consumption_pace(
            request.item_data.item_name
        )
        market_pace = market_data.get("average_consumption_per_day", user_pace)
        
        # 推奨を生成
        recommendation = recommendation_engine.generate_recommendation(
            user_pace=user_pace,
            market_pace=market_pace,
            current_quantity=request.item_data.current_quantity,
            minimum_threshold=request.item_data.minimum_threshold,
            target_stock_level=request.target_stock_level
        )
        
        return RecommendationResponse(
            item_id=request.item_data.item_id,
            item_name=request.item_data.item_name,
            user_consumption_pace=user_pace,
            market_consumption_pace=market_pace,
            **recommendation
        )
        
    except Exception as e:
        logger.error(f"Error generating recommendation: {str(e)}")
        raise HTTPException(status_code=500, detail=f"推奨生成エラー: {str(e)}")

@app.post("/recommendations/batch", response_model=List[RecommendationResponse])
async def generate_batch_recommendations(requests: List[RecommendationRequest]):
    """複数商品の推奨を一括生成"""
    try:
        recommendations = []
        for request in requests:
            try:
                recommendation = await generate_recommendation(request)
                recommendations.append(recommendation)
            except Exception as e:
                logger.error(f"Error processing item {request.item_data.item_id}: {str(e)}")
                # 個別エラーをスキップして処理を続行
                continue
        
        return recommendations
        
    except Exception as e:
        logger.error(f"Error in batch processing: {str(e)}")
        raise HTTPException(status_code=500, detail=f"バッチ処理エラー: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)