from typing import List, Dict, Optional
from datetime import datetime, date, timedelta
import numpy as np
import pandas as pd
from dataclasses import dataclass
import logging

logger = logging.getLogger(__name__)

@dataclass
class ConsumptionPattern:
    """消費パターンを表現するデータクラス"""
    average_daily_consumption: float
    consumption_variance: float
    trend_direction: str  # 'increasing', 'decreasing', 'stable'
    seasonal_pattern: Optional[str] = None
    confidence_score: float = 0.0

class ConsumptionAnalyzer:
    """ユーザーの消費パターンを分析するクラス"""
    
    def __init__(self):
        self.min_data_points = 3  # 最小データポイント数
        self.trend_threshold = 0.1  # トレンド判定閾値
    
    def calculate_user_consumption_pace(self, consumption_records: List[Dict]) -> float:
        """
        ユーザーの消費ペースを計算
        
        Args:
            consumption_records: 消費記録のリスト
            
        Returns:
            float: 1日あたりの平均消費量
        """
        try:
            if not consumption_records or len(consumption_records) < self.min_data_points:
                logger.warning("消費記録が不足しています")
                return 1.0  # デフォルト値
            
            # 消費記録をDataFrameに変換
            df = pd.DataFrame(consumption_records)
            
            # 日付カラムを日付型に変換
            if 'consumption_date' in df.columns:
                df['consumption_date'] = pd.to_datetime(df['consumption_date'])
                df = df.sort_values('consumption_date')
            else:
                logger.error("consumption_date カラムが見つかりません")
                return 1.0
            
            # 日別消費量を集計
            daily_consumption = df.groupby('consumption_date')['consumed_quantity'].sum()
            
            if len(daily_consumption) < 2:
                # データが不足している場合は総消費量を期間で割る
                total_consumption = df['consumed_quantity'].sum()
                if len(df) > 0:
                    first_date = df['consumption_date'].min()
                    last_date = df['consumption_date'].max()
                    days_diff = (last_date - first_date).days + 1
                    return total_consumption / max(days_diff, 1)
                return 1.0
            
            # 期間を計算
            start_date = daily_consumption.index.min()
            end_date = daily_consumption.index.max()
            total_days = (end_date - start_date).days + 1
            
            # 総消費量
            total_consumption = daily_consumption.sum()
            
            # 平均日消費量を計算
            average_daily_consumption = total_consumption / total_days
            
            return max(average_daily_consumption, 0.1)  # 最小値を設定
            
        except Exception as e:
            logger.error(f"消費ペース計算エラー: {str(e)}")
            return 1.0  # エラー時のデフォルト値
    
    def analyze_consumption_pattern(self, consumption_records: List[Dict]) -> ConsumptionPattern:
        """
        詳細な消費パターン分析
        
        Args:
            consumption_records: 消費記録のリスト
            
        Returns:
            ConsumptionPattern: 分析結果
        """
        try:
            if not consumption_records or len(consumption_records) < self.min_data_points:
                return ConsumptionPattern(
                    average_daily_consumption=1.0,
                    consumption_variance=0.0,
                    trend_direction='stable',
                    confidence_score=0.3
                )
            
            # DataFrame作成
            df = pd.DataFrame(consumption_records)
            df['consumption_date'] = pd.to_datetime(df['consumption_date'])
            df = df.sort_values('consumption_date')
            
            # 日別消費量を集計
            daily_consumption = df.groupby('consumption_date')['consumed_quantity'].sum()
            
            # 基本統計
            avg_consumption = self.calculate_user_consumption_pace(consumption_records)
            variance = daily_consumption.var() if len(daily_consumption) > 1 else 0.0
            
            # トレンド分析
            trend_direction = self._analyze_trend(daily_consumption)
            
            # 信頼度スコア計算
            confidence_score = self._calculate_confidence_score(consumption_records)
            
            # 季節性分析（データが十分にある場合）
            seasonal_pattern = self._analyze_seasonality(daily_consumption) if len(daily_consumption) > 30 else None
            
            return ConsumptionPattern(
                average_daily_consumption=avg_consumption,
                consumption_variance=variance,
                trend_direction=trend_direction,
                seasonal_pattern=seasonal_pattern,
                confidence_score=confidence_score
            )
            
        except Exception as e:
            logger.error(f"消費パターン分析エラー: {str(e)}")
            return ConsumptionPattern(
                average_daily_consumption=1.0,
                consumption_variance=0.0,
                trend_direction='stable',
                confidence_score=0.3
            )
    
    def _analyze_trend(self, daily_consumption: pd.Series) -> str:
        """消費トレンドを分析"""
        try:
            if len(daily_consumption) < 3:
                return 'stable'
            
            # 線形回帰で傾きを計算
            x = np.arange(len(daily_consumption))
            y = daily_consumption.values
            
            # 最小二乗法で傾きを計算
            slope = np.polyfit(x, y, 1)[0]
            
            if slope > self.trend_threshold:
                return 'increasing'
            elif slope < -self.trend_threshold:
                return 'decreasing'
            else:
                return 'stable'
                
        except Exception as e:
            logger.error(f"トレンド分析エラー: {str(e)}")
            return 'stable'
    
    def _calculate_confidence_score(self, consumption_records: List[Dict]) -> float:
        """分析の信頼度スコアを計算"""
        try:
            data_points = len(consumption_records)
            
            # データポイント数による基本スコア
            if data_points < 3:
                base_score = 0.3
            elif data_points < 10:
                base_score = 0.6
            elif data_points < 30:
                base_score = 0.8
            else:
                base_score = 0.9
            
            # データの期間による調整
            df = pd.DataFrame(consumption_records)
            if 'consumption_date' in df.columns:
                df['consumption_date'] = pd.to_datetime(df['consumption_date'])
                date_range = (df['consumption_date'].max() - df['consumption_date'].min()).days
                
                # 期間が長いほど信頼度が高い
                if date_range > 90:
                    period_bonus = 0.1
                elif date_range > 30:
                    period_bonus = 0.05
                else:
                    period_bonus = 0.0
                
                return min(base_score + period_bonus, 1.0)
            
            return base_score
            
        except Exception as e:
            logger.error(f"信頼度スコア計算エラー: {str(e)}")
            return 0.5
    
    def _analyze_seasonality(self, daily_consumption: pd.Series) -> Optional[str]:
        """季節性を分析（簡易版）"""
        try:
            if len(daily_consumption) < 30:
                return None
            
            # 月別の平均消費量を計算
            monthly_avg = daily_consumption.groupby(daily_consumption.index.month).mean()
            
            if len(monthly_avg) < 3:
                return None
            
            # 変動係数を計算
            cv = monthly_avg.std() / monthly_avg.mean()
            
            if cv > 0.3:
                return "high_seasonal_variation"
            elif cv > 0.1:
                return "moderate_seasonal_variation"
            else:
                return "low_seasonal_variation"
                
        except Exception as e:
            logger.error(f"季節性分析エラー: {str(e)}")
            return None
    
    def predict_future_consumption(self, consumption_records: List[Dict], days_ahead: int) -> Dict:
        """将来の消費量を予測"""
        try:
            pattern = self.analyze_consumption_pattern(consumption_records)
            
            # 基本的な線形予測
            daily_consumption = pattern.average_daily_consumption
            predicted_total = daily_consumption * days_ahead
            
            # トレンドを考慮した調整
            trend_factor = 1.0
            if pattern.trend_direction == 'increasing':
                trend_factor = 1.1
            elif pattern.trend_direction == 'decreasing':
                trend_factor = 0.9
            
            adjusted_prediction = predicted_total * trend_factor
            
            return {
                "days_ahead": days_ahead,
                "predicted_consumption": round(adjusted_prediction, 2),
                "daily_average": round(daily_consumption, 3),
                "trend_factor": trend_factor,
                "confidence_score": pattern.confidence_score
            }
            
        except Exception as e:
            logger.error(f"消費予測エラー: {str(e)}")
            return {
                "days_ahead": days_ahead,
                "predicted_consumption": days_ahead * 1.0,
                "daily_average": 1.0,
                "trend_factor": 1.0,
                "confidence_score": 0.3
            } 