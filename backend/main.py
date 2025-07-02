from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session
import uvicorn

from database import get_db
from routers import auth, items, consumption, recommendations, ai
from models import Base
from database import engine
import logging
import os

# ログ設定
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 起動時マイグレーション実行
def run_startup_migrations():
    """起動時にマイグレーションを実行"""
    try:
        logger.info("🚀 アプリケーション起動時データベース初期化を開始...")
        
        # 環境変数チェック
        environment = os.getenv("ENVIRONMENT", "development")
        
        if environment == "production":
            # 本番環境：SQLAlchemyでテーブル作成（Supabase対応）
            logger.info("🗄️ 本番環境：Supabaseデータベースにテーブルを作成中...")
            Base.metadata.create_all(bind=engine)
            logger.info("✅ 本番環境データベース初期化が完了しました")
        else:
            # 開発環境：従来のSQLAlchemy方式
            logger.info("📊 開発環境：SQLAlchemyでテーブルを作成中...")
            Base.metadata.create_all(bind=engine)
            logger.info("✅ 開発環境データベース初期化が完了しました")
            
    except Exception as e:
        logger.error(f"❌ データベース初期化中にエラーが発生しました: {str(e)}")
        logger.info("🔄 接続を再試行します...")
        try:
            # 再試行
            Base.metadata.create_all(bind=engine)
            logger.info("✅ 再試行でデータベース初期化が完了しました")
        except Exception as retry_error:
            logger.error(f"❌ 再試行も失敗しました: {str(retry_error)}")
            if environment == "production":
                logger.error("🚨 本番環境での初期化に失敗したため、アプリケーションを終了します")
                exit(1)

# 起動時マイグレーション実行
run_startup_migrations()

# FastAPIアプリケーション初期化
app = FastAPI(
    title="Daily Stock Manager API",
    description="日用品管理システムのAPI",
    version="1.0.0"
)

# CORS設定
origins = [
    "http://localhost:3000",
    "http://localhost:8080",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:8080",
    "https://daily-store-app.web.app",  # Firebase Hosting URL
    "https://daily-store-app.firebaseapp.com",  # Firebase alternative URL
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
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allow_headers=[
        "Accept",
        "Accept-Language", 
        "Content-Language",
        "Content-Type",
        "Authorization",
        "X-Requested-With",
        "Origin",
        "Access-Control-Request-Method",
        "Access-Control-Request-Headers",
    ],
    expose_headers=["*"],
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
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port,
        reload=True
    ) 