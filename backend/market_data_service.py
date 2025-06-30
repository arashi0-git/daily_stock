import httpx
import json
import logging
from typing import Dict, Optional
from datetime import datetime
import asyncio
import random

logger = logging.getLogger(__name__)

class MarketDataService:
    """市場の消費ペースデータを検索・提供するサービス"""
    
    def __init__(self):
        self.base_consumption_data = {
            # 食品関連
            "米": {"average_consumption_per_day": 0.15, "category": "staple_food", "unit": "kg"},
            "パン": {"average_consumption_per_day": 0.3, "category": "staple_food", "unit": "個"},
            "牛乳": {"average_consumption_per_day": 0.2, "category": "dairy", "unit": "L"},
            "卵": {"average_consumption_per_day": 1.5, "category": "protein", "unit": "個"},
            "肉": {"average_consumption_per_day": 0.08, "category": "protein", "unit": "kg"},
            "野菜": {"average_consumption_per_day": 0.3, "category": "vegetables", "unit": "kg"},
            
            # 日用品
            "トイレットペーパー": {"average_consumption_per_day": 0.08, "category": "hygiene", "unit": "ロール"},
            "シャンプー": {"average_consumption_per_day": 0.01, "category": "hygiene", "unit": "ml"},
            "石鹸": {"average_consumption_per_day": 0.02, "category": "hygiene", "unit": "個"},
            "歯磨き粉": {"average_consumption_per_day": 0.005, "category": "hygiene", "unit": "g"},
            "洗剤": {"average_consumption_per_day": 0.03, "category": "cleaning", "unit": "ml"},
            "ティッシュ": {"average_consumption_per_day": 3.0, "category": "hygiene", "unit": "枚"},
            
            # 調味料
            "塩": {"average_consumption_per_day": 0.01, "category": "seasoning", "unit": "g"},
            "砂糖": {"average_consumption_per_day": 0.02, "category": "seasoning", "unit": "g"},
            "醤油": {"average_consumption_per_day": 0.015, "category": "seasoning", "unit": "ml"},
            "味噌": {"average_consumption_per_day": 0.02, "category": "seasoning", "unit": "g"},
            "油": {"average_consumption_per_day": 0.025, "category": "seasoning", "unit": "ml"},
            
            # 飲み物
            "コーヒー": {"average_consumption_per_day": 0.01, "category": "beverage", "unit": "g"},
            "茶": {"average_consumption_per_day": 0.005, "category": "beverage", "unit": "g"},
            "ジュース": {"average_consumption_per_day": 0.15, "category": "beverage", "unit": "L"},
            
            # その他
            "電池": {"average_consumption_per_day": 0.05, "category": "electronics", "unit": "個"},
            "マスク": {"average_consumption_per_day": 1.2, "category": "hygiene", "unit": "枚"},
            "タオル": {"average_consumption_per_day": 0.02, "category": "textile", "unit": "枚"}
        }
        
        # カテゴリ別のデフォルト消費ペース
        self.category_defaults = {
            "staple_food": 0.2,
            "dairy": 0.15,
            "protein": 0.1,
            "vegetables": 0.25,
            "hygiene": 0.08,
            "cleaning": 0.03,
            "seasoning": 0.01,
            "beverage": 0.05,
            "electronics": 0.02,
            "textile": 0.01
        }
    
    async def search_consumption_pace(self, item_name: str) -> Dict:
        """
        商品名から市場の消費ペースを検索
        
        Args:
            item_name: 商品名
            
        Returns:
            Dict: 市場消費データ
        """
        try:
            # まず直接マッチを試行
            market_data = self._direct_search(item_name)
            
            if market_data:
                logger.info(f"直接マッチで市場データを取得: {item_name}")
                return self._format_market_data(market_data, item_name, "direct_match")
            
            # 部分マッチを試行
            market_data = self._fuzzy_search(item_name)
            
            if market_data:
                logger.info(f"部分マッチで市場データを取得: {item_name}")
                return self._format_market_data(market_data, item_name, "fuzzy_match")
            
            # 外部APIを模擬（実際の実装では本物のAPIを使用）
            market_data = await self._simulate_external_api_search(item_name)
            
            if market_data:
                logger.info(f"外部API模擬で市場データを取得: {item_name}")
                return self._format_market_data(market_data, item_name, "external_api")
            
            # デフォルト値を返す
            logger.warning(f"市場データが見つからないため、デフォルト値を使用: {item_name}")
            return self._get_default_data(item_name)
            
        except Exception as e:
            logger.error(f"市場データ検索エラー: {str(e)}")
            return self._get_default_data(item_name)
    
    def _direct_search(self, item_name: str) -> Optional[Dict]:
        """直接マッチング検索"""
        return self.base_consumption_data.get(item_name)
    
    def _fuzzy_search(self, item_name: str) -> Optional[Dict]:
        """あいまい検索（部分マッチ）"""
        item_name_lower = item_name.lower()
        
        for key, data in self.base_consumption_data.items():
            if (key.lower() in item_name_lower or 
                item_name_lower in key.lower()):
                return data
        
        return None
    
    async def _simulate_external_api_search(self, item_name: str) -> Optional[Dict]:
        """
        外部APIの検索を模擬
        実際の実装では、OpenAI API、Google Search API、
        または専門の消費データAPIを使用
        """
        try:
            # API呼び出しをシミュレート
            await asyncio.sleep(0.1)  # ネットワーク遅延をシミュレート
            
            # カテゴリを推測して、それに基づいてデータを生成
            estimated_category = self._estimate_category(item_name)
            base_consumption = self.category_defaults.get(estimated_category, 0.05)
            
            # ランダムに変動させる（±30%）
            variation = random.uniform(0.7, 1.3)
            estimated_consumption = base_consumption * variation
            
            return {
                "average_consumption_per_day": round(estimated_consumption, 4),
                "category": estimated_category,
                "unit": "個",  # デフォルト単位
                "confidence": 0.6,  # 推定データの信頼度
                "source": "estimated"
            }
            
        except Exception as e:
            logger.error(f"外部API模擬エラー: {str(e)}")
            return None
    
    def _estimate_category(self, item_name: str) -> str:
        """商品名からカテゴリを推定"""
        # 簡単なキーワードマッチング
        hygiene_keywords = ["シャンプー", "石鹸", "歯磨き", "タオル", "ティッシュ", "マスク"]
        food_keywords = ["米", "パン", "肉", "魚", "野菜", "果物"]
        cleaning_keywords = ["洗剤", "漂白剤", "柔軟剤"]
        seasoning_keywords = ["塩", "砂糖", "醤油", "味噌", "油", "酢"]
        
        item_name_lower = item_name.lower()
        
        for keyword in hygiene_keywords:
            if keyword in item_name_lower:
                return "hygiene"
        
        for keyword in food_keywords:
            if keyword in item_name_lower:
                return "staple_food"
        
        for keyword in cleaning_keywords:
            if keyword in item_name_lower:
                return "cleaning"
        
        for keyword in seasoning_keywords:
            if keyword in item_name_lower:
                return "seasoning"
        
        return "staple_food"  # デフォルト
    
    def _format_market_data(self, market_data: Dict, item_name: str, search_method: str) -> Dict:
        """市場データを標準フォーマットに変換"""
        return {
            "item_name": item_name,
            "average_consumption_per_day": market_data.get("average_consumption_per_day", 0.05),
            "category": market_data.get("category", "general"),
            "unit": market_data.get("unit", "個"),
            "confidence_score": market_data.get("confidence", 0.8),
            "data_source": search_method,
            "last_updated": datetime.now().isoformat(),
            "market_trend": "stable",  # デフォルトトレンド
            "regional_variation": 0.1,  # 地域変動係数
            "sample_size": market_data.get("sample_size", 1000)  # 推定サンプルサイズ
        }
    
    def _get_default_data(self, item_name: str) -> Dict:
        """デフォルトデータを生成"""
        estimated_category = self._estimate_category(item_name)
        default_consumption = self.category_defaults.get(estimated_category, 0.05)
        
        return {
            "item_name": item_name,
            "average_consumption_per_day": default_consumption,
            "category": estimated_category,
            "unit": "個",
            "confidence_score": 0.4,
            "data_source": "default",
            "last_updated": datetime.now().isoformat(),
            "market_trend": "stable",
            "regional_variation": 0.1,
            "sample_size": 100
        }
    
    async def get_category_consumption_data(self, category: str) -> Dict:
        """カテゴリ別の消費データを取得"""
        try:
            category_items = {
                item_name: data for item_name, data in self.base_consumption_data.items()
                if data.get("category") == category
            }
            
            if not category_items:
                return {
                    "category": category,
                    "items_count": 0,
                    "average_consumption": self.category_defaults.get(category, 0.05),
                    "items": []
                }
            
            total_consumption = sum([data["average_consumption_per_day"] for data in category_items.values()])
            average_consumption = total_consumption / len(category_items)
            
            return {
                "category": category,
                "items_count": len(category_items),
                "average_consumption": round(average_consumption, 4),
                "items": list(category_items.keys())
            }
            
        except Exception as e:
            logger.error(f"カテゴリデータ取得エラー: {str(e)}")
            return {
                "category": category,
                "items_count": 0,
                "average_consumption": 0.05,
                "items": []
            }
    
    async def update_market_data(self, item_name: str, consumption_data: Dict) -> Dict:
        """市場データを更新（将来の機能拡張用）"""
        try:
            # 実際の実装では、データベースやキャッシュに保存
            logger.info(f"市場データ更新（模擬）: {item_name}")
            
            return {
                "item_name": item_name,
                "status": "updated",
                "timestamp": datetime.now().isoformat(),
                "message": "市場データが更新されました（模擬）"
            }
            
        except Exception as e:
            logger.error(f"市場データ更新エラー: {str(e)}")
            return {
                "item_name": item_name,
                "status": "error",
                "message": str(e)
            } 