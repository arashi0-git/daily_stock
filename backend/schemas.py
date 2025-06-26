from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime, date

# ユーザー関連スキーマ
class UserBase(BaseModel):
    username: str
    email: EmailStr

class UserCreate(UserBase):
    password: str

class UserLogin(BaseModel):
    username: str
    password: str

class User(UserBase):
    id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

# カテゴリ関連スキーマ
class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None

class CategoryCreate(CategoryBase):
    pass

class Category(CategoryBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True

# 日用品関連スキーマ
class DailyItemBase(BaseModel):
    name: str
    description: Optional[str] = None
    current_quantity: int = 0
    unit: str = "個"
    minimum_threshold: int = 1
    estimated_consumption_days: int = 30
    purchase_url: Optional[str] = None
    price: Optional[float] = None
    category_id: Optional[int] = None

class DailyItemCreate(DailyItemBase):
    pass

class DailyItemUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    current_quantity: Optional[int] = None
    unit: Optional[str] = None
    minimum_threshold: Optional[int] = None
    estimated_consumption_days: Optional[int] = None
    purchase_url: Optional[str] = None
    price: Optional[float] = None
    category_id: Optional[int] = None

class DailyItem(DailyItemBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime
    category: Optional[Category] = None
    
    class Config:
        from_attributes = True

# 消費記録関連スキーマ
class ConsumptionRecordBase(BaseModel):
    consumed_quantity: int
    consumption_date: Optional[date] = None
    remaining_quantity: Optional[int] = None
    notes: Optional[str] = None

class ConsumptionRecordCreate(ConsumptionRecordBase):
    item_id: int

class ConsumptionRecordUpdate(BaseModel):
    consumed_quantity: Optional[int] = None
    consumption_date: Optional[date] = None
    remaining_quantity: Optional[int] = None
    notes: Optional[str] = None

class ConsumptionRecord(ConsumptionRecordBase):
    id: int
    user_id: int
    item_id: int
    created_at: datetime
    item: Optional[DailyItem] = None
    
    class Config:
        from_attributes = True

# 補充記録関連スキーマ
class ReplenishmentRecordBase(BaseModel):
    replenished_quantity: int
    replenishment_date: Optional[date] = None
    cost: Optional[float] = None
    supplier: Optional[str] = None

class ReplenishmentRecordCreate(ReplenishmentRecordBase):
    item_id: int

class ReplenishmentRecord(ReplenishmentRecordBase):
    id: int
    user_id: int
    item_id: int
    created_at: datetime
    item: Optional[DailyItem] = None
    
    class Config:
        from_attributes = True

# 通知関連スキーマ
class NotificationBase(BaseModel):
    notification_type: str
    message: str
    scheduled_date: Optional[datetime] = None

class NotificationCreate(NotificationBase):
    item_id: Optional[int] = None

class Notification(NotificationBase):
    id: int
    user_id: int
    item_id: Optional[int] = None
    is_read: bool
    sent_at: Optional[datetime] = None
    created_at: datetime
    item: Optional[DailyItem] = None
    
    class Config:
        from_attributes = True

# レスポンス用スキーマ
class MessageResponse(BaseModel):
    message: str

class DashboardSummary(BaseModel):
    total_items: int
    low_stock_items: int
    recent_consumptions: List[ConsumptionRecord]
    upcoming_notifications: List[Notification]

# 消費推奨関連スキーマ
class ConsumptionRecommendationBase(BaseModel):
    recommendation_type: str
    urgency_level: str
    user_consumption_pace: float
    market_consumption_pace: Optional[float] = None
    estimated_days_remaining: int
    recommendation_message: str
    confidence_score: float
    additional_info: Optional[dict] = None

class ConsumptionRecommendationCreate(ConsumptionRecommendationBase):
    item_id: int

class ConsumptionRecommendation(ConsumptionRecommendationBase):
    id: int
    user_id: int
    item_id: int
    is_active: bool
    acknowledged_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    item: Optional[DailyItem] = None
    
    class Config:
        from_attributes = True

# AI サービス関連スキーマ
class ConsumptionAnalysisRequest(BaseModel):
    item_id: int
    target_stock_level: Optional[int] = None

class ConsumptionAnalysisResponse(BaseModel):
    analysis: dict
    market_data: dict
    item_info: dict

class RecommendationRequest(BaseModel):
    item_id: int
    target_stock_level: Optional[int] = None

class BatchRecommendationResponse(BaseModel):
    recommendations: List[ConsumptionRecommendation]
    total_count: int
    high_priority_count: int 