from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

# データベースURL設定（セキュリティ強化：ハードコーディングされた認証情報を削除）
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError(
        "DATABASE_URL環境変数が設定されていません。\n"
        "開発環境の場合: docker-compose.ymlで設定済み\n"
        "本番環境の場合: Supabaseの接続URLを環境変数に設定してください"
    )

# SQLAlchemyエンジン作成（Supabase最適化設定）
engine = create_engine(
    DATABASE_URL,
    pool_size=5,
    max_overflow=10,
    pool_pre_ping=True,
    pool_recycle=300
)

# セッションメーカー作成
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# ベースクラス作成
Base = declarative_base()

# データベースセッション依存関数
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close() 