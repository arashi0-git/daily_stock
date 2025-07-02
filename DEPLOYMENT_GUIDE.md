# 🚀 Daily Stock Manager - 完全無料デプロイメントガイド

このガイドでは、完全無料でDaily Stock Managerアプリをデプロイする方法を説明します。

## 📋 デプロイメント構成

- **フロントエンド**: Netlify (無料)
- **バックエンド**: Render (無料プラン)
- **データベース**: Supabase (無料プラン)

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

### 1.3 データベース初期化方法

**🔄 方法1: 自動マイグレーション（推奨）**
1. バックエンドデプロイ時に自動的にテーブルが作成されます
2. `ENVIRONMENT=production` 設定により、Alembicマイグレーションが実行されます
3. 手動でのSQL実行は不要です

**📝 方法2: 手動SQL実行（必要な場合のみ）**
Supabase SQL Editorで以下を実行:

```sql
-- ⚠️ 注意：自動マイグレーションを使用する場合、この手動実行は不要です

-- ユーザーテーブル
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- カテゴリテーブル
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 日用品テーブル
CREATE TABLE IF NOT EXISTS daily_items (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES categories(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    current_quantity INTEGER DEFAULT 0,
    unit VARCHAR(20) DEFAULT '個',
    minimum_threshold INTEGER DEFAULT 1,
    estimated_consumption_days INTEGER DEFAULT 30,
    purchase_url TEXT,
    price DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 詳細なテーブル構造は database/init.sql を参照
```

**🔧 マイグレーション管理**
- 新しいテーブルやカラムの追加は自動的に処理されます
- スキーマ変更履歴は `alembic/versions/` で管理されます
- ロールバックが必要な場合は、開発チームにお問い合わせください

## 🔧 2. Renderでバックエンドをデプロイ

### 2.1 Renderアカウント作成
1. [Render](https://render.com)にアクセス
2. GitHubアカウントでサインアップ

### 2.2 GitHubリポジトリを接続
1. 「New Web Service」をクリック
2. GitHubリポジトリを選択
3. 以下の設定を入力:

**Basic Settings:**
- Name: `daily-stock-backend`
- Environment: `Python`
- Region: `Oregon (US West)`
- Branch: `main`

**Build & Deploy:**
- Root Directory: `backend`
- Build Command: `pip install -r requirements.txt`
- Start Command: `uvicorn main:app --host 0.0.0.0 --port $PORT`

### 2.3 環境変数を設定
「Environment Variables」セクションで以下を追加:

```
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres
SECRET_KEY=[64文字以上のランダムキー]
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
ENVIRONMENT=production
DEBUG=false
FRONTEND_URL=https://[YOUR-NETLIFY-APP].netlify.app
```

**⚠️ 重要な注意点:**
- `[YOUR-PASSWORD]` と `[YOUR-PROJECT-REF]` は実際の値に置換してください
- `SECRET_KEY` は以下のコマンドで生成: `python -c "import secrets; print(secrets.token_urlsafe(64))"`
- **絶対にパスワードをGitリポジトリにコミットしないでください**

### 2.4 デプロイ実行
「Create Web Service」をクリックしてデプロイを開始

## 🌐 3. Netlifyでフロントエンドをデプロイ

### 3.1 Netlifyアカウント作成
1. [Netlify](https://netlify.com)にアクセス
2. GitHubアカウントでサインアップ

### 3.2 サイトをデプロイ
1. 「New site from Git」をクリック
2. GitHubリポジトリを選択
3. 以下の設定を入力:

**Build Settings:**
- Base directory: `frontend`
- Build command: `flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL`
- Publish directory: `frontend/build/web`

### 3.3 環境変数を設定
「Site settings」→「Environment variables」で追加:

```
API_BASE_URL=https://daily-stock-backend.onrender.com
```

### 3.4 Flutter Webの依存関係確保
Netlifyでのビルドが失敗する場合は、以下を確認:

1. `frontend`ディレクトリに`netlify.toml`があることを確認
2. Flutter SDKが正しくインストールされるよう設定

## ✅ 4. デプロイメント確認

### 4.1 API確認
1. Renderのバックエンドが正常に起動していることを確認
2. `https://[YOUR-BACKEND].onrender.com/health`にアクセス
3. `{"status": "healthy"}`が返されることを確認

### 4.2 フロントエンド確認
1. Netlifyのフロントエンドにアクセス
2. アプリが正常に表示されることを確認
3. API通信が正常に動作することをテスト

## 🔄 5. 継続的デプロイメント

### 自動デプロイメント
- GitHub `main`ブランチにプッシュすると自動的にデプロイされます
- バックエンド: Render
- フロントエンド: Netlify

## 💰 料金について

### 無料プランの制限

**Render (無料プラン):**
- 月750時間（31日間フル稼働可能）
- スリープ機能あり（非アクティブ時）
- 512MB RAM

**Netlify (無料プラン):**
- 月100GB帯域幅
- 月300分ビルド時間
- 無制限サイト数

**Supabase (無料プラン):**
- 500MB データベース容量
- 50MB ファイルストレージ
- 月200万API呼び出し

## 🛠️ トラブルシューティング

### よくある問題

1. **バックエンドがスリープしている**
   - 解決: 数回アクセスして起動を待つ（初回は1-2分かかる場合があります）

2. **CORS エラー**
   - 解決: バックエンドの`FRONTEND_URL`環境変数を正しく設定

3. **データベース接続エラー**
   - 解決: Supabaseの接続文字列とパスワードを確認

4. **Flutter Webビルドエラー**
   - 解決: `flutter build web`がローカルで成功することを確認

## 📞 サポート

デプロイメントで問題が発生した場合は、各サービスのドキュメントを参照してください:

- [Render Documentation](https://render.com/docs)
- [Netlify Documentation](https://docs.netlify.com)
- [Supabase Documentation](https://supabase.com/docs)

---

**🎉 おめでとうございます！**
これで完全無料でDaily Stock Managerアプリがデプロイされました。 