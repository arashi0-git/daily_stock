# 🚀 日用品管理アプリ クイックスタート

このプロジェクトをすぐに起動するための手順です。

## 前提条件
- Python 3.9+ がインストール済み
- Docker がインストール済み
- Flutter が `/mnt/c/Users/Yaras/src_flutter/flutter` にインストール済み

## 🔧 1分で起動する手順

### 1. Flutterパスを設定（一度だけ実行）
```bash
# Flutterパスを永続的に追加
echo 'export PATH="$PATH:/mnt/c/Users/Yaras/src_flutter/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Flutter設定確認
flutter doctor
```

### 2. 全サービス起動（データベース + バックエンド）
```bash
# プロジェクトルートで実行（全サービスをDockerで起動）
docker-compose up -d

# ログを確認（オプション）
docker-compose logs -f backend
```

### 3. フロントエンド起動
```bash
# 新しいターミナルでフロントエンドを起動
cd frontend
flutter pub get
flutter run
```

## ✅ 確認方法

### バックエンドAPI確認
- ブラウザで `http://localhost:8000/docs` を開く
- Swagger UIでAPIドキュメントが表示される

### データベース確認
```bash
# PostgreSQL接続テスト
docker exec -it daily_stock_db psql -U daily_stock_user -d daily_stock -c "\dt"
```

### フロントエンド確認
- エミュレータでアプリが起動
- ログイン画面が表示される

## 🛠 トラブル対応

### Flutterコマンドが見つからない場合
```bash
# パスを再設定
export PATH="$PATH:/mnt/c/Users/Yaras/src_flutter/flutter/bin"
flutter doctor
```

### データベース接続エラー
```bash
# Dockerコンテナ状態確認
docker-compose ps

# 再起動
docker-compose down
docker-compose up -d

# バックエンドのログ確認
docker-compose logs backend
```

### バックエンドサービスエラー
```bash
# バックエンドコンテナを再ビルド
docker-compose build backend
docker-compose up -d backend

# コンテナ内でデバッグ
docker-compose exec backend bash
```

## 📱 初回使用方法

1. アプリ起動後、ログイン画面で「新規登録」をタップ
2. ユーザー名、メールアドレス、パスワードを入力
3. 登録完了後、自動的にログインされる
4. ホーム画面で日用品の管理を開始

## 🎯 主要な機能
- ✅ ユーザー登録・ログイン
- 🔄 日用品の登録・管理（実装中）
- 📊 消費記録の追跡（実装中）
- 🔔 在庫切れ通知（予定）

---
**💡 ヒント**: 開発中はバックエンド、フロントエンドを別々のターミナルで起動すると、ログを確認しやすくなります。 