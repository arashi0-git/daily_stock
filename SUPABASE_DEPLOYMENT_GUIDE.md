# 🗄️ Supabase PostgreSQL本番デプロイメントガイド

## 📋 概要

このガイドでは、提供されたSupabase PostgreSQLデータベースを使用して、完全無料で本番環境をデプロイする方法を説明します。

**使用するSupabaseデータベース:**
```
postgresql://postgres.ixnkwlzlmrkfyrswccpl:Y.arashi0408@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres
```

## 🚀 デプロイメント手順

### **1. Render（バックエンド）- 推奨**

#### 1.1 Renderでの設定
1. [Render](https://render.com)にログイン
2. 「New Web Service」をクリック
3. GitHubリポジトリを選択

#### 1.2 基本設定
```
Name: daily-stock-backend
Environment: Python
Region: Oregon (US West)
Branch: main
Root Directory: backend
Build Command: pip install -r requirements.txt
Start Command: uvicorn main:app --host 0.0.0.0 --port $PORT
```

#### 1.3 環境変数設定
「Environment Variables」で以下を設定：

```bash
DATABASE_URL=postgresql://postgres.ixnkwlzlmrkfyrswccpl:Y.arashi0408@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres
SECRET_KEY=m18bnhrN36S7nBrrOL9UbRVNh7cdU7dJqCnP5GRi1Ov8CNQkAS6Dib0fQPvZPYi6YJvJmWO4WpHRJV2_dtLKBw
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
ENVIRONMENT=production
DEBUG=false
FRONTEND_URL=https://your-netlify-app.netlify.app
```

### **2. Cloud Run（GCP）- 代替案**

#### 2.1 デプロイコマンド
```bash
gcloud run deploy daily-stock-backend \
  --image gcr.io/PROJECT_ID/daily-stock-backend:latest \
  --region asia-northeast1 \
  --platform managed \
  --allow-unauthenticated \
  --memory 1Gi \
  --cpu 1 \
  --max-instances 10 \
  --set-env-vars DATABASE_URL="postgresql://postgres.ixnkwlzlmrkfyrswccpl:Y.arashi0408@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres" \
  --set-env-vars SECRET_KEY="m18bnhrN36S7nBrrOL9UbRVNh7cdU7dJqCnP5GRi1Ov8CNQkAS6Dib0fQPvZPYi6YJvJmWO4WpHRJV2_dtLKBw" \
  --set-env-vars ENVIRONMENT="production" \
  --set-env-vars DEBUG="false"
```

### **3. Firebase Hosting（フロントエンド）- 既存設定**

#### 3.1 Firebase Hosting設定（設定済み）
✅ **既存環境で使用中**
- Firebase プロジェクト: `daily-store-app`
- 自動デプロイ: GitHub Actions設定済み
- URL: `https://daily-store-app.web.app`

#### 3.2 バックエンドURL設定
フロントエンドは自動的にApp EngineのURLに接続されます

## ✅ デプロイメント確認

### **1. バックエンド動作確認**
```bash
# ヘルスチェック
curl https://your-backend-url.onrender.com/health

# 期待される応答
{"status": "healthy"}
```

### **2. データベース接続確認**
- デプロイ時のログで「✅ 本番環境データベース初期化が完了しました」を確認
- エラーがある場合は「🔄 接続を再試行します...」の後の状態を確認

### **3. フロントエンド確認**
- Firebase Hostingアプリが正常に表示されることを確認
- API通信が正常に動作することをテスト

## 🔧 自動化された機能

### **起動時データベース初期化**
- アプリケーション起動時に自動的にテーブルが作成されます
- `ENVIRONMENT=production` 設定により本番環境用の処理が実行されます
- エラー時は自動的に再試行されます

### **テーブル構造**
以下のテーブルが自動作成されます：
- `users` - ユーザー管理
- `categories` - カテゴリ管理
- `daily_items` - 日用品管理
- `consumption_records` - 消費記録
- `replenishment_records` - 補充記録
- `notifications` - 通知管理
- `consumption_recommendations` - AI推奨

## 💰 コスト構成（完全無料）

| サービス | プラン | 制限 |
|---------|-------|-----|
| **Supabase** | 無料 | 500MB DB, 月200万API呼び出し |
| **App Engine** | 無料 | 1日28時間, 1GB送信データ |
| **Firebase Hosting** | 無料 | 月10GB転送量, 1GBストレージ |

## 🛠️ トラブルシューティング

### **1. データベース接続エラー**
```
ERROR: 接続を確立できませんでした
```
**解決方法:**
- DATABASE_URLが正しく設定されているか確認
- Supabaseプロジェクトがアクティブか確認
- ネットワークアクセスが制限されていないか確認

### **2. 起動時エラー**
```
ERROR: DATABASE_URL環境変数が設定されていません
```
**解決方法:**
- デプロイ環境で環境変数が正しく設定されているか確認
- 環境変数名のスペルミスがないか確認

### **3. CORS エラー**
```
Access to fetch at 'https://api...' from origin 'https://app...' has been blocked by CORS policy
```
**解決方法:**
- `FRONTEND_URL` を正しいNetlifyのURLに設定
- HTTPSを使用していることを確認

## 🔄 継続的デプロイメント

- GitHubの`main`ブランチにプッシュで自動デプロイ
- データベーススキーマ変更は自動的に反映
- 新機能の追加もシームレスにデプロイ

---

**🎉 これで完全無料のSupabase本番環境が構築されました！** 