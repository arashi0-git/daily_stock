from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

# データベースURL設定
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:Y.arashi0408@db.ixnkwlzlmrkfyrswccpl.supabase.co:5432/postgres"
)

# SQLAlchemyエンジン作成
engine = create_engine(DATABASE_URL)

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