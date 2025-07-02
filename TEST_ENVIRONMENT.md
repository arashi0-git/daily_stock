# 🧪 テスト環境セットアップガイド

このガイドでは、フロントエンドとバックエンドの両方をDockerでテストする環境の構築方法を説明します。

## 📋 前提条件

- Docker Desktop がインストールされていること
- Docker Compose が利用可能であること
- 8000番、3000番、5433番ポートが利用可能であること

## 🚀 クイックスタート

### 1. テスト環境の起動

```bash
# テスト環境を起動
./scripts/test-env.sh start
```

### 2. アクセス先

起動後、以下のURLでアクセス可能です：

| サービス | URL | 説明 |
|---------|-----|------|
| 📱 フロントエンド | http://localhost:3000 | Flutter Webアプリ |
| 🔧 バックエンドAPI | http://localhost:8000 | FastAPI サーバー |
| 📚 API文書 | http://localhost:8000/docs | Swagger UI |
| 🗄️ データベース | localhost:5433 | PostgreSQL (テスト用) |

### 3. テスト環境の停止

```bash
# テスト環境を停止
./scripts/test-env.sh stop
```

## 🛠️ 詳細なコマンド

### 基本コマンド

```bash
# ヘルプを表示
./scripts/test-env.sh help

# テスト環境を起動
./scripts/test-env.sh start

# テスト環境を停止
./scripts/test-env.sh stop

# テスト環境を再起動
./scripts/test-env.sh restart

# ログをリアルタイム表示
./scripts/test-env.sh logs

# サービスの状態を確認
./scripts/test-env.sh status
```

### トラブルシューティング

```bash
# テスト環境を完全にリセット（データも削除）
./scripts/test-env.sh reset

# バックエンドコンテナのシェルに入る
./scripts/test-env.sh shell
```

## 🔧 設定ファイル

### 環境固有の設定

| ファイル | 用途 | 説明 |
|---------|------|------|
| `docker-compose.test.yml` | テスト環境 | 独立したテスト用設定 |
| `frontend/Dockerfile.dev` | フロントエンド開発用 | テスト環境向けビルド |
| `frontend/lib/config/api_config.dart` | API設定 | 環境別エンドポイント |

### ポート設定

テスト環境は本番環境と競合しないポートを使用：

| サービス | テスト環境 | 本番環境 |
|---------|-----------|----------|
| フロントエンド | 3000 | 443 (HTTPS) |
| バックエンド | 8000 | 443 (HTTPS) |
| PostgreSQL | 5433 | 6543 |
| Redis | 6380 | 6379 |

## 🧪 テストデータ

### 初期データの投入

```bash
# バックエンドコンテナに接続
./scripts/test-env.sh shell

# データベースマイグレーション（必要に応じて）
alembic upgrade head

# テストユーザーの作成
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"testpass123"}'
```

### データベースのリセット

```bash
# 全データを削除して環境をリセット
./scripts/test-env.sh reset
```

## 🔍 デバッグ

### ログの確認

```bash
# 全サービスのログを表示
./scripts/test-env.sh logs

# 特定のサービスのログのみ表示
docker-compose -f docker-compose.test.yml -p daily-stock-test logs frontend
docker-compose -f docker-compose.test.yml -p daily-stock-test logs backend
```

### サービスの状態確認

```bash
# サービスの起動状態を確認
./scripts/test-env.sh status

# ヘルスチェック
curl http://localhost:8000/health
```

## 🔄 開発ワークフロー

### 1. コード変更後のテスト

```bash
# バックエンドの変更（Hot reload有効）
# ファイルを保存するだけで自動的に反映

# フロントエンドの変更
./scripts/test-env.sh restart
```

### 2. 本番環境との比較

```bash
# テスト環境
curl http://localhost:8000/api/v1/auth/register

# 本番環境
curl https://daily-store-app.an.r.appspot.com/api/v1/auth/register
```

## ⚠️ 注意事項

1. **ポートの競合**: 8000, 3000, 5433番ポートが他のサービスで使用されていないか確認してください
2. **データの分離**: テスト環境のデータは本番環境と完全に分離されています
3. **リソース使用量**: Docker Desktopに十分なメモリ（4GB以上推奨）を割り当ててください
4. **ネットワーク**: フロントエンドはブラウザ経由でlocalhostのバックエンドにアクセスします

## 🚨 トラブルシューティング

### よくある問題

#### ポートが既に使用されている
```bash
# 使用中のポートを確認
netstat -tulpn | grep :8000
netstat -tulpn | grep :3000

# Docker環境をクリーンアップ
docker system prune -a
```

#### フロントエンドがバックエンドに接続できない
```bash
# バックエンドが起動していることを確認
curl http://localhost:8000/health

# CORS設定を確認
./scripts/test-env.sh logs backend
```

#### データベース接続エラー
```bash
# PostgreSQLコンテナの状態を確認
docker-compose -f docker-compose.test.yml -p daily-stock-test ps postgres

# データベースログを確認
docker-compose -f docker-compose.test.yml -p daily-stock-test logs postgres
``` 