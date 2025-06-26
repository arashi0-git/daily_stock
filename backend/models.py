from sqlalchemy import Column, Integer, String, Text, DateTime, Date, Boolean, ForeignKey, Float, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

Base = declarative_base()

class User(Base):
    """ユーザーモデル"""
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # リレーション
    daily_items = relationship("DailyItem", back_populates="user")
    consumption_records = relationship("ConsumptionRecord", back_populates="user")
    replenishment_records = relationship("ReplenishmentRecord", back_populates="user")
    notifications = relationship("Notification", back_populates="user")

class Category(Base):
    """カテゴリモデル"""
    __tablename__ = "categories"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # リレーション
    daily_items = relationship("DailyItem", back_populates="category")

class DailyItem(Base):
    """日用品モデル"""
    __tablename__ = "daily_items"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    category_id = Column(Integer, ForeignKey("categories.id"))
    name = Column(String(100), nullable=False)
    description = Column(Text)
    current_quantity = Column(Integer, default=0)
    unit = Column(String(20), default="個")
    minimum_threshold = Column(Integer, default=1)
    estimated_consumption_days = Column(Integer, default=30)
    purchase_url = Column(Text)
    price = Column(Float)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # リレーション
    user = relationship("User", back_populates="daily_items")
    category = relationship("Category", back_populates="daily_items")
    consumption_records = relationship("ConsumptionRecord", back_populates="item")
    replenishment_records = relationship("ReplenishmentRecord", back_populates="item")
    notifications = relationship("Notification", back_populates="item")

class ConsumptionRecord(Base):
    """消費記録モデル"""
    __tablename__ = "consumption_records"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    item_id = Column(Integer, ForeignKey("daily_items.id"), nullable=False)
    consumed_quantity = Column(Integer, nullable=False)
    consumption_date = Column(Date, server_default=func.current_date())
    remaining_quantity = Column(Integer)
    notes = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # リレーション
    user = relationship("User", back_populates="consumption_records")
    item = relationship("DailyItem", back_populates="consumption_records")

class ReplenishmentRecord(Base):
    """補充記録モデル"""
    __tablename__ = "replenishment_records"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    item_id = Column(Integer, ForeignKey("daily_items.id"), nullable=False)
    replenished_quantity = Column(Integer, nullable=False)
    replenishment_date = Column(Date, server_default=func.current_date())
    cost = Column(Float)
    supplier = Column(String(100))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # リレーション
    user = relationship("User", back_populates="replenishment_records")
    item = relationship("DailyItem", back_populates="replenishment_records")

class Notification(Base):
    """通知モデル"""
    __tablename__ = "notifications"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    item_id = Column(Integer, ForeignKey("daily_items.id"))
    notification_type = Column(String(50), nullable=False)
    message = Column(Text, nullable=False)
    is_read = Column(Boolean, default=False)
    scheduled_date = Column(DateTime(timezone=True))
    sent_at = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # リレーション
    user = relationship("User", back_populates="notifications")
    item = relationship("DailyItem", back_populates="notifications")

class ConsumptionRecommendation(Base):
    """消費推奨モデル"""
    __tablename__ = "consumption_recommendations"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    item_id = Column(Integer, ForeignKey("daily_items.id"), nullable=False)
    recommendation_type = Column(String(50), nullable=False)  # monitor, prepare, purchase_soon, purchase_now, urgent_purchase
    urgency_level = Column(String(20), nullable=False)  # low, medium, high, critical
    user_consumption_pace = Column(Float, nullable=False)
    market_consumption_pace = Column(Float)
    estimated_days_remaining = Column(Integer, nullable=False)
    recommendation_message = Column(Text, nullable=False)
    confidence_score = Column(Float, nullable=False)
    additional_info = Column(JSON)  # 追加情報をJSONで保存
    is_active = Column(Boolean, default=True)
    acknowledged_at = Column(DateTime(timezone=True))  # ユーザーが確認した日時
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # リレーション
    user = relationship("User")
    item = relationship("DailyItem") 