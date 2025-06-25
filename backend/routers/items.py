from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from models import DailyItem, Category, User
from schemas import DailyItem as DailyItemSchema, DailyItemCreate, DailyItemUpdate, Category as CategorySchema
from routers.auth import get_current_user

router = APIRouter()

@router.get("/", response_model=List[DailyItemSchema])
async def get_user_items(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """ユーザーの日用品一覧を取得"""
    items = db.query(DailyItem).filter(
        DailyItem.user_id == current_user.id
    ).offset(skip).limit(limit).all()
    return items

@router.post("/", response_model=DailyItemSchema, status_code=status.HTTP_201_CREATED)
async def create_item(
    item: DailyItemCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """新しい日用品を登録"""
    db_item = DailyItem(
        **item.dict(),
        user_id=current_user.id
    )
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item

@router.get("/{item_id}", response_model=DailyItemSchema)
async def get_item(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """特定の日用品を取得"""
    item = db.query(DailyItem).filter(
        DailyItem.id == item_id,
        DailyItem.user_id == current_user.id
    ).first()
    
    if item is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="日用品が見つかりません"
        )
    return item

@router.put("/{item_id}", response_model=DailyItemSchema)
async def update_item(
    item_id: int,
    item_update: DailyItemUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """日用品を更新"""
    item = db.query(DailyItem).filter(
        DailyItem.id == item_id,
        DailyItem.user_id == current_user.id
    ).first()
    
    if item is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="日用品が見つかりません"
        )
    
    # 更新するフィールドのみを適用
    update_data = item_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(item, field, value)
    
    db.commit()
    db.refresh(item)
    return item

@router.delete("/{item_id}")
async def delete_item(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """日用品を削除"""
    item = db.query(DailyItem).filter(
        DailyItem.id == item_id,
        DailyItem.user_id == current_user.id
    ).first()
    
    if item is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="日用品が見つかりません"
        )
    
    db.delete(item)
    db.commit()
    return {"message": "日用品が削除されました"}

@router.get("/low-stock/", response_model=List[DailyItemSchema])
async def get_low_stock_items(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """在庫が少ない日用品を取得"""
    items = db.query(DailyItem).filter(
        DailyItem.user_id == current_user.id,
        DailyItem.current_quantity <= DailyItem.minimum_threshold
    ).all()
    return items

@router.get("/categories/", response_model=List[CategorySchema])
async def get_categories(db: Session = Depends(get_db)):
    """カテゴリ一覧を取得"""
    categories = db.query(Category).all()
    return categories 