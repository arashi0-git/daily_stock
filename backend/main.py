from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session
import uvicorn

from database import get_db
from routers import auth, items, consumption, recommendations, ai
from models import Base
from database import engine

# データベーステーブルを作成
Base.metadata.create_all(bind=engine)

# FastAPIアプリケーション初期化
app = FastAPI(
    title="Daily Stock Manager API",
    description="日用品管理システムのAPI",
    version="1.0.0"
)

# CORS設定
import os

origins = [
    "http://localhost:3000",
    "http://localhost:8080",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:8080",
]

# 本番環境用のCORS設定
frontend_url = os.getenv("FRONTEND_URL")
if frontend_url:
    origins.append(frontend_url)
    origins.append(frontend_url.replace("http://", "https://"))  # HTTPS版も追加

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# セキュリティ設定
security = HTTPBearer()

# ルーター登録
app.include_router(auth.router, prefix="/api/v1/auth", tags=["認証"])
app.include_router(items.router, prefix="/api/v1/items", tags=["日用品"])
app.include_router(consumption.router, prefix="/api/v1/consumption", tags=["消費記録"])
app.include_router(recommendations.router, prefix="/api/v1/recommendations", tags=["消費推奨"])
app.include_router(ai.router, prefix="/api/v1/ai", tags=["AI分析"])

@app.get("/")
async def root():
    """ルートエンドポイント"""
    return {"message": "Daily Stock Manager API", "version": "1.0.0"}

@app.get("/health")
async def health_check():
    """ヘルスチェックエンドポイント"""
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port,
        reload=True
    ) 