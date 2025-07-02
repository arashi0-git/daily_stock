# 日用品管理アプリ セットアップガイド

## バックエンドの起動方法

### 前提条件
- Python 3.8以上
- PostgreSQL データベース

### 1. 依存関係のインストール
```bash
cd backend
pip install -r requirements.txt
```

### 2. データベース設定
PostgreSQLデータベースを起動し、以下の環境変数を設定してください：
```bash
export DATABASE_URL="postgresql://daily_stock_user:daily_stock_password@localhost:5432/daily_stock"
export SECRET_KEY="your-secret-key"
export ALGORITHM="HS256"
export ACCESS_TOKEN_EXPIRE_MINUTES=1440
```

### 3. バックエンドサーバーの起動
```bash
cd backend
python main.py
```

サーバーは http://localhost:8000 で起動します。

### 4. ヘルスチェック
```bash
curl http://localhost:8000/health
```

## フロントエンドの設定

フロントエンドは現在 `http://localhost:8000` に接続するよう設定されています。
バックエンドが異なるポートやURLで動作している場合は、
`frontend/lib/config/api_config.dart` を編集してください。

## Dockerを使用する場合

```bash
docker-compose up -d
```

この場合、以下のサービスが起動します：
- Frontend: http://localhost:3000
- Backend: http://localhost:8000
- Database: localhost:5432

## トラブルシューティング

### 消費記録ページでエラーが発生する場合

1. バックエンドサーバーが起動しているか確認
   ```bash
   curl http://localhost:8000/health
   ```

2. データベースが起動しているか確認

3. API設定が正しいか確認
   - `frontend/lib/config/api_config.dart`の`baseUrl`を確認

4. 認証トークンが有効か確認
   - アプリからログアウトして再ログインしてみる