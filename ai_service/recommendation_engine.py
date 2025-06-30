from typing import Dict, List, Optional
from datetime import datetime, timedelta
from dataclasses import dataclass
from enum import Enum
import logging
import math

logger = logging.getLogger(__name__)

class UrgencyLevel(Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

class RecommendationAction(Enum):
    MONITOR = "monitor"
    PREPARE = "prepare"
    PURCHASE_SOON = "purchase_soon"
    PURCHASE_NOW = "purchase_now"
    URGENT_PURCHASE = "urgent_purchase"

@dataclass
class RecommendationResult:
    """推奨結果を格納するデータクラス"""
    recommended_action: str
    urgency_level: str
    estimated_days_remaining: int
    recommendation_message: str
    confidence_score: float
    additional_info: Optional[Dict] = None

class RecommendationEngine:
    """消費推奨エンジン"""
    
    def __init__(self):
        # 推奨設定パラメータ
        self.urgency_thresholds = {
            UrgencyLevel.CRITICAL: 1,  # 1日以下
            UrgencyLevel.HIGH: 3,      # 3日以下
            UrgencyLevel.MEDIUM: 7,    # 7日以下
            UrgencyLevel.LOW: 14       # 14日以下
        }
        
        # 市場との比較閾値
        self.consumption_variance_threshold = 0.5  # 50%以上の差がある場合
        
        # 推奨メッセージテンプレート
        self.message_templates = {
            RecommendationAction.MONITOR: {
                "template": "{item_name}の在庫は十分です。現在の消費ペースでは約{days}日間持続します。",
                "advice": "定期的な在庫チェックを継続してください。"
            },
            RecommendationAction.PREPARE: {
                "template": "{item_name}の購入準備を始めましょう。約{days}日後に補充が必要になる見込みです。",
                "advice": "価格比較や購入計画を立てることをお勧めします。"
            },
            RecommendationAction.PURCHASE_SOON: {
                "template": "{item_name}の購入時期が近づいています。{days}日以内の購入を推奨します。",
                "advice": "特売情報をチェックして、お得なタイミングで購入しましょう。"
            },
            RecommendationAction.PURCHASE_NOW: {
                "template": "{item_name}の購入をお勧めします。残り{days}日程度で在庫切れの可能性があります。",
                "advice": "早めの購入で在庫切れを防ぎましょう。"
            },
            RecommendationAction.URGENT_PURCHASE: {
                "template": "⚠️ {item_name}の緊急購入が必要です！残り{days}日以下で在庫切れになります。",
                "advice": "今すぐ購入することを強く推奨します。"
            }
        }
    
    def generate_recommendation(
        self,
        user_pace: float,
        market_pace: float,
        current_quantity: int,
        minimum_threshold: int,
        target_stock_level: Optional[int] = None
    ) -> Dict:
        """
        総合的な推奨を生成
        
        Args:
            user_pace: ユーザーの消費ペース（1日あたり）
            market_pace: 市場の消費ペース（1日あたり）
            current_quantity: 現在の在庫数
            minimum_threshold: 最小在庫閾値
            target_stock_level: 目標在庫レベル（オプション）
            
        Returns:
            Dict: 推奨結果
        """
        try:
            # 基本計算
            effective_pace = max(user_pace, 0.01)  # ゼロ除算防止
            usable_quantity = max(current_quantity - minimum_threshold, 0)
            days_remaining = usable_quantity / effective_pace
            
            # 緊急度レベルを決定
            urgency_level = self._determine_urgency_level(days_remaining)
            
            # 推奨アクションを決定
            recommended_action = self._determine_recommended_action(
                days_remaining, urgency_level, user_pace, market_pace
            )
            
            # 信頼度スコアを計算
            confidence_score = self._calculate_confidence_score(
                user_pace, market_pace, current_quantity, days_remaining
            )
            
            # 推奨メッセージを生成
            message_data = self._generate_recommendation_message(
                recommended_action, days_remaining, user_pace, market_pace
            )
            
            # 追加情報を生成
            additional_info = self._generate_additional_info(
                user_pace, market_pace, current_quantity, minimum_threshold,
                days_remaining, target_stock_level
            )
            
            return {
                "recommended_action": recommended_action.value,
                "urgency_level": urgency_level.value,
                "estimated_days_remaining": max(int(days_remaining), 0),
                "recommendation_message": message_data["message"],
                "confidence_score": confidence_score,
                "additional_info": additional_info
            }
            
        except Exception as e:
            logger.error(f"推奨生成エラー: {str(e)}")
            return self._get_default_recommendation()
    
    def _determine_urgency_level(self, days_remaining: float) -> UrgencyLevel:
        """残り日数から緊急度レベルを決定"""
        for level, threshold in self.urgency_thresholds.items():
            if days_remaining <= threshold:
                return level
        return UrgencyLevel.LOW
    
    def _determine_recommended_action(
        self,
        days_remaining: float,
        urgency_level: UrgencyLevel,
        user_pace: float,
        market_pace: float
    ) -> RecommendationAction:
        """推奨アクションを決定"""
        # 緊急度による基本判定
        if urgency_level == UrgencyLevel.CRITICAL:
            return RecommendationAction.URGENT_PURCHASE
        elif urgency_level == UrgencyLevel.HIGH:
            return RecommendationAction.PURCHASE_NOW
        elif urgency_level == UrgencyLevel.MEDIUM:
            return RecommendationAction.PURCHASE_SOON
        elif days_remaining <= 21:  # 3週間以内
            return RecommendationAction.PREPARE
        else:
            return RecommendationAction.MONITOR
    
    def _calculate_confidence_score(
        self,
        user_pace: float,
        market_pace: float,
        current_quantity: int,
        days_remaining: float
    ) -> float:
        """推奨の信頼度スコアを計算"""
        try:
            confidence_factors = []
            
            # ユーザーペースと市場ペースの一致度
            if market_pace > 0:
                pace_similarity = 1 - abs(user_pace - market_pace) / max(user_pace, market_pace)
                confidence_factors.append(pace_similarity * 0.3)
            else:
                confidence_factors.append(0.1)  # 市場データがない場合の低信頼度
            
            # 在庫量による信頼度（多すぎず少なすぎずが理想）
            if current_quantity > 0:
                stock_confidence = min(1.0, math.log(current_quantity + 1) / math.log(10))
                confidence_factors.append(stock_confidence * 0.2)
            else:
                confidence_factors.append(0.0)
            
            # 残り日数による信頼度（極端でない値が理想）
            if 0 < days_remaining < 365:
                days_confidence = 1 - abs(days_remaining - 30) / 365
                confidence_factors.append(max(days_confidence, 0.1) * 0.3)
            else:
                confidence_factors.append(0.1)
            
            # ユーザーペースの妥当性（極端でない値が理想）
            if 0.001 < user_pace < 10:
                pace_confidence = 1 - abs(math.log10(user_pace)) / 4
                confidence_factors.append(max(pace_confidence, 0.1) * 0.2)
            else:
                confidence_factors.append(0.1)
            
            # 総合信頼度を計算
            total_confidence = sum(confidence_factors)
            return max(min(total_confidence, 1.0), 0.1)  # 0.1-1.0の範囲に制限
            
        except Exception as e:
            logger.error(f"信頼度スコア計算エラー: {str(e)}")
            return 0.5  # デフォルト値
    
    def _generate_recommendation_message(
        self,
        action: RecommendationAction,
        days_remaining: float,
        user_pace: float,
        market_pace: float
    ) -> Dict:
        """推奨メッセージを生成"""
        try:
            template_data = self.message_templates.get(action, self.message_templates[RecommendationAction.MONITOR])
            
            # メッセージをフォーマット
            days_text = f"{int(days_remaining)}" if days_remaining >= 1 else "1未満"
            message = template_data["template"].format(
                item_name="{item_name}",  # 後でフロントエンドで置換
                days=days_text
            )
            
            # 市場との比較情報を追加
            pace_comparison = ""
            if market_pace > 0:
                pace_ratio = user_pace / market_pace
                if pace_ratio > 1.5:
                    pace_comparison = "あなたの消費ペースは一般的な消費ペースより約{:.0f}%高いです。".format((pace_ratio - 1) * 100)
                elif pace_ratio < 0.5:
                    pace_comparison = "あなたの消費ペースは一般的な消費ペースより約{:.0f}%低いです。".format((1 - pace_ratio) * 100)
                else:
                    pace_comparison = "あなたの消費ペースは一般的な範囲内です。"
            
            full_message = message
            if pace_comparison:
                full_message += f" {pace_comparison}"
            
            if template_data.get("advice"):
                full_message += f" {template_data['advice']}"
            
            return {"message": full_message, "action_advice": template_data.get("advice", "")}
            
        except Exception as e:
            logger.error(f"メッセージ生成エラー: {str(e)}")
            return {"message": "推奨メッセージの生成に失敗しました。", "action_advice": ""}
    
    def _generate_additional_info(
        self,
        user_pace: float,
        market_pace: float,
        current_quantity: int,
        minimum_threshold: int,
        days_remaining: float,
        target_stock_level: Optional[int]
    ) -> Dict:
        """追加情報を生成"""
        try:
            info = {
                "consumption_analysis": {
                    "user_daily_consumption": round(user_pace, 3),
                    "market_daily_consumption": round(market_pace, 3),
                    "consumption_ratio": round(user_pace / market_pace, 2) if market_pace > 0 else None,
                    "consumption_category": self._categorize_consumption_pace(user_pace, market_pace)
                },
                "inventory_status": {
                    "current_stock": current_quantity,
                    "minimum_threshold": minimum_threshold,
                    "usable_quantity": max(current_quantity - minimum_threshold, 0),
                    "days_until_threshold": int(days_remaining)
                },
                "purchase_suggestions": {
                    "optimal_purchase_timing": self._calculate_optimal_purchase_timing(days_remaining),
                    "suggested_quantity": self._calculate_suggested_purchase_quantity(
                        user_pace, current_quantity, minimum_threshold, target_stock_level
                    ),
                    "budget_impact": self._estimate_budget_impact(user_pace, market_pace)
                },
                "trends": {
                    "consumption_trend": "stable",  # 実装時は実際のトレンド分析結果を使用
                    "market_trend": "stable",
                    "seasonal_factor": 1.0
                }
            }
            
            return info
            
        except Exception as e:
            logger.error(f"追加情報生成エラー: {str(e)}")
            return {"error": "追加情報の生成に失敗しました"}
    
    def _categorize_consumption_pace(self, user_pace: float, market_pace: float) -> str:
        """消費ペースをカテゴリ化"""
        if market_pace <= 0:
            return "unknown"
        
        ratio = user_pace / market_pace
        if ratio > 1.8:
            return "very_high"
        elif ratio > 1.3:
            return "high"
        elif ratio > 0.7:
            return "normal"
        elif ratio > 0.3:
            return "low"
        else:
            return "very_low"
    
    def _calculate_optimal_purchase_timing(self, days_remaining: float) -> str:
        """最適な購入タイミングを計算"""
        if days_remaining <= 1:
            return "immediate"
        elif days_remaining <= 3:
            return "within_24_hours"
        elif days_remaining <= 7:
            return "within_week"
        elif days_remaining <= 14:
            return "within_2_weeks"
        else:
            return "monitor_for_now"
    
    def _calculate_suggested_purchase_quantity(
        self,
        user_pace: float,
        current_quantity: int,
        minimum_threshold: int,
        target_stock_level: Optional[int]
    ) -> int:
        """推奨購入数量を計算"""
        try:
            # 目標在庫レベルが設定されている場合
            if target_stock_level:
                needed_quantity = max(target_stock_level - current_quantity, 0)
                return needed_quantity
            
            # デフォルト：30日分の在庫を目標とする
            monthly_consumption = user_pace * 30
            target_quantity = int(monthly_consumption + minimum_threshold)
            needed_quantity = max(target_quantity - current_quantity, 0)
            
            return needed_quantity
            
        except Exception as e:
            logger.error(f"推奨購入数量計算エラー: {str(e)}")
            return 1  # デフォルト値
    
    def _estimate_budget_impact(self, user_pace: float, market_pace: float) -> str:
        """予算への影響を推定"""
        if market_pace <= 0:
            return "unknown"
        
        ratio = user_pace / market_pace
        if ratio > 1.5:
            return "higher_than_average"
        elif ratio > 0.8:
            return "average"
        else:
            return "lower_than_average"
    
    def _get_default_recommendation(self) -> Dict:
        """デフォルト推奨を返す"""
        return {
            "recommended_action": RecommendationAction.MONITOR.value,
            "urgency_level": UrgencyLevel.LOW.value,
            "estimated_days_remaining": 30,
            "recommendation_message": "商品の状況を定期的に確認してください。",
            "confidence_score": 0.3,
            "additional_info": {
                "note": "データ不足により、デフォルト推奨を表示しています。"
            }
        }
    
    def batch_generate_recommendations(self, items_data: List[Dict]) -> List[Dict]:
        """複数商品の推奨を一括生成"""
        recommendations = []
        
        for item_data in items_data:
            try:
                recommendation = self.generate_recommendation(
                    user_pace=item_data.get("user_pace", 1.0),
                    market_pace=item_data.get("market_pace", 1.0),
                    current_quantity=item_data.get("current_quantity", 0),
                    minimum_threshold=item_data.get("minimum_threshold", 1),
                    target_stock_level=item_data.get("target_stock_level")
                )
                recommendation["item_id"] = item_data.get("item_id")
                recommendation["item_name"] = item_data.get("item_name", "不明")
                recommendations.append(recommendation)
                
            except Exception as e:
                logger.error(f"商品 {item_data.get('item_id', 'unknown')} の推奨生成エラー: {str(e)}")
                # エラーが発生した商品はスキップ
                continue
        
        return recommendations