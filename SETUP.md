# 日用品管理アプリ セットアップガイド

## プロジェクト概要
Flutter と Python FastAPI を使用した日用品管理アプリケーションです。

## 必要な環境

### バックエンド
- Python 3.9以上
- PostgreSQL 12以上
- Redis（オプション）

### フロントエンド
- Flutter SDK 3.0以上（`Users/Yaras/src_flutter/flutter`にインストール済み）
- Android Studio または VS Code
- Android/iOS エミュレータまたは実機

## セットアップ手順

### 1. データベースセットアップ

```bash
# Docker Composeを使用してPostgreSQLとRedisを起動
docker-compose up -d
```

### 2. 全サービス起動（推奨）

```bash
# 全サービス（データベース、Redis、バックエンド）をDockerで起動
docker-compose up -d

# ログを確認
docker-compose logs -f backend

# サービス状態確認
docker-compose ps
```

### 2-b. バックエンドのみローカル開発（オプション）

```bash
# データベースとRedisのみDockerで起動
docker-compose up -d postgres redis

# バックエンドディレクトリに移動
cd backend

# 仮想環境を作成（推奨）
python -m venv venv

# 仮想環境を有効化
# Windows
venv\Scripts\activate
# macOS/Linux
source venv/bin/activate

# 依存関係をインストール
pip install -r requirements.txt

# APIサーバーを起動
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 3. フロントエンドセットアップ

```bash
# Flutterパスを設定（カスタムインストール場所）
export PATH="$PATH:/mnt/c/Users/Yaras/src_flutter/flutter/bin"

# Flutterが正しく設定されているか確認
flutter doctor

# フロントエンドディレクトリに移動
cd frontend

# 依存関係をインストール
flutter pub get

# JSONモデルクラスを生成
flutter packages pub run build_runner build

# アプリを起動（エミュレータまたは実機が接続されている必要があります）
flutter run
```

**注意**: WSL環境の場合、以下の設定が必要な場合があります：
```bash
# ~/.bashrc または ~/.zshrc にFlutterパスを永続的に追加
echo 'export PATH="$PATH:/mnt/c/Users/Yaras/src_flutter/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

## 主な機能

### 現在実装済み
- ✅ ユーザー認証システム（登録・ログイン）
- ✅ JWT トークンベース認証
- ✅ 基本的なAPIエンドポイント
- ✅ Flutter アプリケーションの基本構造

### 今後実装予定
- 📱 日用品登録・管理機能
- 📊 消費記録機能
- 🔄 在庫自動更新
- 🔔 在庫切れ通知
- 🤖 AI による消費予測
- 📈 統計・分析機能

## API エンドポイント

### 認証
- `POST /api/v1/auth/register` - ユーザー登録
- `POST /api/v1/auth/login` - ログイン
- `GET /api/v1/auth/me` - 現在のユーザー情報取得
- `GET /api/v1/auth/verify-token` - トークン検証

### 日用品（実装予定）
- `GET /api/v1/items/` - 日用品一覧取得
- `POST /api/v1/items/` - 日用品登録
- `GET /api/v1/items/{id}` - 特定の日用品取得
- `PUT /api/v1/items/{id}` - 日用品更新
- `DELETE /api/v1/items/{id}` - 日用品削除

### 消費記録（実装予定）
- `GET /api/v1/consumption/` - 消費記録一覧取得
- `POST /api/v1/consumption/` - 消費記録作成
- `GET /api/v1/consumption/{id}` - 特定の消費記録取得
- `DELETE /api/v1/consumption/{id}` - 消費記録削除

## 開発ツール

### バックエンド開発
```bash
# APIドキュメント確認（Swagger UI）
# http://localhost:8000/docs

# データベース管理
# pgAdminまたはお好みのPostgreSQLクライアント
```

### フロントエンド開発
```bash
# Flutterパスを設定（毎回必要な場合）
export PATH="$PATH:/mnt/c/Users/Yaras/src_flutter/flutter/bin"

# ホットリロード開発
flutter run

# ビルド（Android）
flutter build apk

# ビルド（iOS）
flutter build ios
```

## トラブルシューティング

### よくある問題

#### 1. データベース接続エラー
```bash
# Dockerコンテナが起動しているか確認
docker-compose ps

# PostgreSQL接続確認
psql -h localhost -U daily_stock_user -d daily_stock
```

#### 2. Flutter依存関係エラー
```bash
# Flutterパスを設定
export PATH="$PATH:/mnt/c/Users/Yaras/src_flutter/flutter/bin"

# キャッシュをクリア
flutter clean
flutter pub get
```

#### 3. API接続エラー
- バックエンドサーバーが起動しているか確認
- ファイアウォール設定を確認
- APIのベースURLが正しいか確認

## ライセンス
このプロジェクトはMITライセンスの下で公開されています。 