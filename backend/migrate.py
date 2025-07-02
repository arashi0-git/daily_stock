"""
データベースマイグレーション管理スクリプト
"""
import os
import sys
from alembic.config import Config
from alembic import command
import logging

# ログ設定
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def run_migrations():
    """
    Alembicマイグレーションを実行
    """
    try:
        # Alembic設定ファイルのパス
        alembic_cfg = Config(os.path.join(os.path.dirname(__file__), "alembic.ini"))
        
        # データベースURLを設定
        database_url = os.getenv("DATABASE_URL")
        if not database_url:
            raise ValueError("DATABASE_URL環境変数が設定されていません")
        
        logger.info("🔄 マイグレーションを開始します...")
        logger.info(f"接続先: {database_url.split('@')[-1] if '@' in database_url else 'Unknown'}")
        
        # マイグレーションを最新まで実行
        command.upgrade(alembic_cfg, "head")
        
        logger.info("✅ マイグレーションが正常に完了しました")
        return True
        
    except Exception as e:
        logger.error(f"❌ マイグレーション中にエラーが発生しました: {str(e)}")
        return False

def create_initial_migration():
    """
    初回マイグレーションファイルを作成
    """
    try:
        alembic_cfg = Config(os.path.join(os.path.dirname(__file__), "alembic.ini"))
        
        logger.info("📝 初期マイグレーションファイルを作成します...")
        command.revision(alembic_cfg, autogenerate=True, message="Initial migration")
        
        logger.info("✅ 初期マイグレーションファイルが作成されました")
        return True
        
    except Exception as e:
        logger.error(f"❌ マイグレーションファイル作成中にエラーが発生しました: {str(e)}")
        return False

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "init":
        # 初期マイグレーション作成
        create_initial_migration()
    else:
        # マイグレーション実行
        success = run_migrations()
        sys.exit(0 if success else 1) 