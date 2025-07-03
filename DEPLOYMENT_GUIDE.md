# 🚀 Daily Stock Manager - デプロイメントガイド

このガイドでは、Daily Stock Managerアプリをデプロイする方法を説明します。

## 📋 デプロイメント構成

- **フロントエンド（Flutter Web）**: Firebase Hosting - firebase deploy
- **バックエンド（FastAPI）**: Google App Engine - gcloud app deploy
- **データベース**: Supabase

## 🗄️ 1. Supabaseでデータベースを設定

### 1.1 Supabaseアカウント作成
1. [Supabase](https://supabase.com)にアクセス
2. GitHubアカウントでサインアップ
3. 新しいプロジェクトを作成

### 1.2 データベース接続情報を取得
1. プロジェクトダッシュボードで「Settings」→「Database」
2. 「Connection string」をコピー
3. パスワードを設定済みのものに置換

例:
```
postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres
```

### 1.3 テーブル作成（SQL Editor）
```sql
-- ユーザーテーブル
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 日用品テーブル
CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    current_quantity INTEGER DEFAULT 0,
    minimum_threshold INTEGER DEFAULT 1,
    unit VARCHAR(50) DEFAULT '個',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 消費記録テーブル
CREATE TABLE consumption_records (
    id SERIAL PRIMARY KEY,
    item_id INTEGER REFERENCES items(id),
    consumed_quantity INTEGER NOT NULL,
    consumption_date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🔧 2. Google App Engineでバックエンドをデプロイ

### 2.1 Google Cloud Projectの準備
1. [Google Cloud Console](https://console.cloud.google.com/)にアクセス
2. 新しいプロジェクトを作成するか、既存のプロジェクトを選択
3. App Engine APIを有効化
4. 課金アカウントを設定（必要に応じて）

### 2.2 gcloud CLIのインストールと認証
1. [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)をインストール
2. `gcloud auth login` で認証
3. `gcloud config set project [YOUR-PROJECT-ID]` でプロジェクトを設定

### 2.3 app.yamlの設定確認
`backend/app.yaml`ファイルが以下の内容になっていることを確認:

```yaml
runtime: python39

env_variables:
  DATABASE_URL: "postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres"
  SECRET_KEY: "[自動生成されたキー]"
  ALGORITHM: "HS256"
  ACCESS_TOKEN_EXPIRE_MINUTES: 1440
  ENVIRONMENT: "production"
  DEBUG: "false"
  FRONTEND_URL: "https://[YOUR-PROJECT-ID].web.app"

handlers:
- url: /.*
  script: auto
```

### 2.4 デプロイ実行
```bash
cd backend
gcloud app deploy
```

## 🌐 3. Firebase Hostingでフロントエンドをデプロイ

### 3.1 Firebase プロジェクトの準備
1. [Firebase Console](https://console.firebase.google.com/)にアクセス
2. 新しいプロジェクトを作成するか、既存のプロジェクトを選択
3. Hostingを有効化

### 3.2 Firebase CLIのインストール
```bash
npm install -g firebase-tools
firebase login
```

### 3.3 Firebase プロジェクトの初期化
```bash
cd frontend
firebase init hosting
```

以下の設定を選択:
- Project: 作成したFirebaseプロジェクトを選択
- Public directory: `build/web`
- Single-page app: `Yes`
- Overwrite index.html: `No`

### 3.4 Flutter Webのビルドとデプロイ
```bash
cd frontend
flutter build web --release --dart-define=API_BASE_URL=https://[YOUR-PROJECT-ID].appspot.com
firebase deploy
```

### 3.5 firebase.jsonの設定確認
`frontend/firebase.json`ファイルが以下の内容になっていることを確認:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

## ✅ 4. デプロイメント確認

### 4.1 API確認
1. Google App Engineのバックエンドが正常に起動していることを確認
2. `https://[YOUR-PROJECT-ID].appspot.com/health`にアクセス
3. `{"status": "healthy"}`が返されることを確認

### 4.2 フロントエンド確認
1. Firebase Hostingのフロントエンドにアクセス
2. `https://[YOUR-PROJECT-ID].web.app`でアプリが正常に表示されることを確認
3. API通信が正常に動作することをテスト

## 🔄 5. 継続的デプロイメント

### 手動デプロイメント
- バックエンド: `gcloud app deploy` コマンドで手動デプロイ
- フロントエンド: `firebase deploy` コマンドで手動デプロイ

### 自動デプロイメント（オプション）
GitHub Actionsを使用して自動デプロイを設定することも可能です。

## 💰 料金について

### 料金体系

**Google App Engine:**
- 無料枠: 月28時間のインスタンス時間
- 従量制課金（使用した分だけ）

**Firebase Hosting:**
- 無料枠: 月10GB転送量、月125,000回の閲覧
- 無料枠を超えた場合は従量制課金

**Supabase (無料プラン):**
- 500MB データベース容量
- 50MB ファイルストレージ
- 月200万API呼び出し

## 🛠️ トラブルシューティング

### よくある問題

1. **App Engineデプロイエラー**
   - 解決: `gcloud auth login`で認証を確認し、プロジェクトIDが正しく設定されているか確認

2. **CORS エラー**
   - 解決: バックエンドの`FRONTEND_URL`環境変数をFirebase HostingのURLに正しく設定

3. **データベース接続エラー**
   - 解決: Supabaseの接続文字列とパスワードを確認

4. **Flutter Webビルドエラー**
   - 解決: `flutter build web`がローカルで成功することを確認

5. **Firebase デプロイエラー**
   - 解決: `firebase login`で認証を確認し、プロジェクトが正しく選択されているか確認

## 📞 サポート

デプロイメントで問題が発生した場合は、各サービスのドキュメントを参照してください:

- [Google App Engine Documentation](https://cloud.google.com/appengine/docs)
- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)
- [Supabase Documentation](https://supabase.com/docs)

---

**🎉 おめでとうございます！**
これでDaily Stock Managerアプリがデプロイされました。 