# 🗄️ Supabase + App Engine + Firebase Hosting セットアップ

## 📋 構成

- **フロントエンド**: Firebase Hosting (既存設定済み)
- **バックエンド**: App Engine (Supabase環境変数追加)
- **データベース**: Supabase PostgreSQL

## 🚀 デプロイ手順

### **1. App Engine環境変数設定**

`backend/app.yaml`に以下が設定済み：

```yaml
env_variables:
  DATABASE_URL: "postgresql://postgres.ixnkwlzlmrkfyrswccpl:Y.arashi0408@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres"
  SECRET_KEY: "m18bnhrN36S7nBrrOL9UbRVNh7cdU7dJqCnP5GRi1Ov8CNQkAS6Dib0fQPvZPYi6YJvJmWO4WpHRJV2_dtLKBw"
  ALGORITHM: "HS256"
  ACCESS_TOKEN_EXPIRE_MINUTES: "1440"
  ENVIRONMENT: "production"
  DEBUG: "false"
  FRONTEND_URL: "https://daily-store-app.web.app"
```

### **2. App Engineデプロイ**

```bash
cd backend
gcloud app deploy app.yaml
```

### **3. 自動機能**

- ✅ 起動時自動テーブル作成
- ✅ Supabase接続設定
- ✅ Firebase Hosting自動デプロイ

## ✅ 確認

### **バックエンド**
```bash
curl https://[PROJECT-ID].uc.r.appspot.com/health
```

### **フロントエンド**
```bash
curl https://daily-store-app.web.app
```

---

**🎉 Firebase + App Engine + Supabase構成完了！** 