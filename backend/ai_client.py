import httpx
import logging
from typing import List, Dict, Optional
from datetime import datetime
import json
import os

logger = logging.getLogger(__name__)

class AIServiceClient:
    """AI サービスとの通信を担当するクライアント"""
    
    def __init__(self, ai_service_url: str = None):
        self.ai_service_url = ai_service_url or os.getenv("AI_SERVICE_URL", "http://ai_service:8001")
        self.timeout = 30.0
        
    async def _make_request(self, method: str, endpoint: str, data: Optional[Dict] = None) -> Dict:
        """AI サービスへのHTTPリクエストを実行"""
        try:
            url = f"{self.ai_service_url}{endpoint}"
            
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                if method.upper() == "GET":
                    response = await client.get(url, params=data)
                elif method.upper() == "POST":
                    response = await client.post(url, json=data)
                else:
                    raise ValueError(f"サポートされていないHTTPメソッド: {method}")
                
                response.raise_for_status()
                return response.json()
                
        except httpx.TimeoutException:
            logger.error(f"AI サービスへのリクエストがタイムアウトしました: {endpoint}")
            raise Exception("AI サービスの応答がタイムアウトしました")
        except httpx.HTTPError as e:
            logger.error(f"AI サービスへのリクエストエラー: {e}")
            raise Exception(f"AI サービスとの通信エラー: {str(e)}")
        except Exception as e:
            logger.error(f"予期しないエラー: {e}")
            raise Exception(f"AI サービス呼び出しエラー: {str(e)}")
    
    async def check_health(self) -> Dict:
        """AI サービスのヘルスチェック"""
        return await self._make_request("GET", "/health")
    
    async def analyze_consumption_pace(self, consumption_data: Dict) -> Dict:
        """消費ペース分析を実行"""
        return await self._make_request("POST", "/analyze/consumption-pace", consumption_data)
    
    async def search_market_data(self, item_name: str) -> Dict:
        """市場データを検索"""
        return await self._make_request("POST", "/market-data/search", {"item_name": item_name})
    
    async def generate_recommendation(self, request_data: Dict) -> Dict:
        """推奨を生成"""
        return await self._make_request("POST", "/recommendations/generate", request_data)
    
    async def generate_batch_recommendations(self, requests_data: List[Dict]) -> List[Dict]:
        """複数商品の推奨を一括生成"""
        return await self._make_request("POST", "/recommendations/batch", requests_data)

class ConsumptionAnalysisService:
    """消費分析サービス"""
    
    def __init__(self, ai_client: AIServiceClient = None):
        self.ai_client = ai_client or AIServiceClient()
    
    async def analyze_user_consumption_pattern(self, user_id: int, item_id: int, db) -> Dict:
        """ユーザーの消費パターンを分析"""
        try:
            from models import ConsumptionRecord, DailyItem
            
            # 商品情報を取得
            item = db.query(DailyItem).filter(
                DailyItem.id == item_id,
                DailyItem.user_id == user_id
            ).first()
            
            if not item:
                raise Exception("指定された商品が見つかりません")
            
            # 消費記録を取得
            consumption_records = db.query(ConsumptionRecord).filter(
                ConsumptionRecord.item_id == item_id,
                ConsumptionRecord.user_id == user_id
            ).order_by(ConsumptionRecord.consumption_date.desc()).limit(100).all()
            
            if not consumption_records:
                raise Exception("消費記録が見つかりません")
            
            # 消費記録をAIサービス用フォーマットに変換
            records_data = []
            for record in consumption_records:
                records_data.append({
                    "consumption_date": record.consumption_date.isoformat(),
                    "consumed_quantity": record.consumed_quantity,
                    "remaining_quantity": record.remaining_quantity,
                    "notes": record.notes
                })
            
            # AIサービスでの分析データを準備
            consumption_data = {
                "item_id": item_id,
                "item_name": item.name,
                "consumption_records": records_data,
                "current_quantity": item.current_quantity,
                "minimum_threshold": item.minimum_threshold
            }
            
            # AIサービスで消費ペースを分析
            analysis_result = await self.ai_client.analyze_consumption_pace(consumption_data)
            
            # 市場データも取得
            market_data = await self.ai_client.search_market_data(item.name)
            
            return {
                "analysis": analysis_result,
                "market_data": market_data,
                "item_info": {
                    "id": item.id,
                    "name": item.name,
                    "current_quantity": item.current_quantity,
                    "minimum_threshold": item.minimum_threshold,
                    "unit": item.unit
                }
            }
            
        except Exception as e:
            logger.error(f"消費パターン分析エラー: {str(e)}")
            raise
    
    async def generate_item_recommendation(self, user_id: int, item_id: int, db, target_stock_level: Optional[int] = None) -> Dict:
        """商品の推奨を生成"""
        try:
            from models import ConsumptionRecord, DailyItem
            
            # 商品情報を取得
            item = db.query(DailyItem).filter(
                DailyItem.id == item_id,
                DailyItem.user_id == user_id
            ).first()
            
            if not item:
                raise Exception("指定された商品が見つかりません")
            
            # 消費記録を取得
            consumption_records = db.query(ConsumptionRecord).filter(
                ConsumptionRecord.item_id == item_id,
                ConsumptionRecord.user_id == user_id
            ).order_by(ConsumptionRecord.consumption_date.desc()).limit(50).all()
            
            # 消費記録をフォーマット
            records_data = []
            for record in consumption_records:
                records_data.append({
                    "consumption_date": record.consumption_date.isoformat(),
                    "consumed_quantity": record.consumed_quantity,
                    "remaining_quantity": record.remaining_quantity,
                    "notes": record.notes
                })
            
            # 推奨生成用のリクエストデータを作成
            request_data = {
                "user_id": user_id,
                "item_data": {
                    "item_id": item_id,
                    "item_name": item.name,
                    "consumption_records": records_data,
                    "current_quantity": item.current_quantity,
                    "minimum_threshold": item.minimum_threshold
                },
                "target_stock_level": target_stock_level
            }
            
            # AIサービスで推奨を生成
            recommendation = await self.ai_client.generate_recommendation(request_data)
            
            return recommendation
            
        except Exception as e:
            logger.error(f"推奨生成エラー: {str(e)}")
            raise
    
    async def generate_user_recommendations(self, user_id: int, db) -> List[Dict]:
        """ユーザーの全商品に対する推奨を生成"""
        try:
            from models import DailyItem, ConsumptionRecord
            
            # ユーザーの全商品を取得
            items = db.query(DailyItem).filter(DailyItem.user_id == user_id).all()
            
            if not items:
                return []
            
            # 各商品の推奨リクエストデータを準備
            batch_requests = []
            for item in items:
                # 各商品の消費記録を取得
                consumption_records = db.query(ConsumptionRecord).filter(
                    ConsumptionRecord.item_id == item.id,
                    ConsumptionRecord.user_id == user_id
                ).order_by(ConsumptionRecord.consumption_date.desc()).limit(30).all()
                
                # 消費記録をフォーマット
                records_data = []
                for record in consumption_records:
                    records_data.append({
                        "consumption_date": record.consumption_date.isoformat(),
                        "consumed_quantity": record.consumed_quantity,
                        "remaining_quantity": record.remaining_quantity,
                        "notes": record.notes
                    })
                
                # リクエストデータを作成
                request_data = {
                    "user_id": user_id,
                    "item_data": {
                        "item_id": item.id,
                        "item_name": item.name,
                        "consumption_records": records_data,
                        "current_quantity": item.current_quantity,
                        "minimum_threshold": item.minimum_threshold
                    }
                }
                
                batch_requests.append(request_data)
            
            # AIサービスでバッチ推奨を生成
            recommendations = await self.ai_client.generate_batch_recommendations(batch_requests)
            
            return recommendations
            
        except Exception as e:
            logger.error(f"バッチ推奨生成エラー: {str(e)}")
            raise

# サービスのシングルトンインスタンス
consumption_analysis_service = ConsumptionAnalysisService()