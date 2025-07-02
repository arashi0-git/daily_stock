# 🗄️ Supabase本番環境用 環境変数設定ガイド

## 📋 必要な環境変数

```bash
# データベース設定（Supabase）
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres

# 認証設定
SECRET_KEY=[ランダムな64文字以上のシークレットキー]
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440

# 環境設定
ENVIRONMENT=production
DEBUG=false

# フロントエンド設定
FRONTEND_URL=https://daily-store-app.web.app
```

## 🔧 設定手順

### 1. Supabaseの接続情報を取得
1. [Supabase Dashboard](https://app.supabase.com)にログイン
2. プロジェクトを選択
3. `Settings` → `Database` → `Connection string`
4. パスワードを実際に設定したものに置換

### 2. SECRET_KEYを生成
```bash
python -c "import secrets; print(secrets.token_urlsafe(64))"
```

### 3. 各デプロイ環境での設定方法

#### **Render（推奨）**
1. Renderダッシュボードで Web Service を選択
2. `Environment Variables` セクション
3. 上記の環境変数を追加

#### **Firebase Hosting（フロントエンド）**
✅ **設定不要** - 既存の環境で動作中
- Firebase プロジェクト: `daily-store-app`
- 自動デプロイ: GitHub Actions設定済み

#### **Cloud Run（GCP）**
```bash
gcloud run deploy daily-stock-backend \
  --set-env-vars DATABASE_URL="postgresql://postgres:..." \
  --set-env-vars SECRET_KEY="..." \
  --set-env-vars ENVIRONMENT="production" \
  --set-env-vars DEBUG="false"
```

## ⚠️ セキュリティ上の注意

1. **パスワードを絶対にGitにコミットしない**
2. **本番環境では必ず強力なSECRET_KEYを使用**
3. **DATABASE_URLは環境変数でのみ管理**
4. **定期的にパスワードとSECRET_KEYをローテーション**

## 💰 Supabaseの無料プラン制限

- **データベース容量**: 500MB
- **API呼び出し**: 月200万回
- **ストレージ**: 50MB
- **同時接続数**: 60
- **Row Level Security**: 利用可能

制限を超える場合は有料プランを検討してください。 