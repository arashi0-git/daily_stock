# 🐳 Docker コマンド集

## 基本操作

### 全サービス起動
```bash
# 全サービスをバックグラウンドで起動
docker-compose up -d

# 全サービスを起動（ログを表示）
docker-compose up
```

### サービス状態確認
```bash
# 起動中のサービス一覧
docker-compose ps

# サービスの詳細情報
docker-compose ps --services

# ヘルスチェック状態も含めて確認
docker ps
```

### ログ確認
```bash
# 全サービスのログ
docker-compose logs

# 特定のサービスのログ
docker-compose logs backend
docker-compose logs postgres
docker-compose logs redis

# リアルタイムでログを表示
docker-compose logs -f backend
```

### サービス停止・削除
```bash
# サービス停止
docker-compose stop

# サービス停止＋コンテナ削除
docker-compose down

# ボリュームも含めて削除（データベースデータも削除される）
docker-compose down -v

# イメージも削除
docker-compose down --rmi all
```

## 開発用コマンド

### バックエンド開発
```bash
# バックエンドのみ再起動
docker-compose restart backend

# バックエンドを再ビルド
docker-compose build backend

# バックエンドコンテナ内でコマンド実行
docker-compose exec backend bash
docker-compose exec backend python -c "print('Hello from container')"

# バックエンドのリアルタイムログ
docker-compose logs -f backend
```

### データベース操作
```bash
# PostgreSQLに接続
docker-compose exec postgres psql -U daily_stock_user -d daily_stock

# データベース内のテーブル一覧表示
docker-compose exec postgres psql -U daily_stock_user -d daily_stock -c "\dt"

# SQLファイルを実行
docker-compose exec postgres psql -U daily_stock_user -d daily_stock -f /docker-entrypoint-initdb.d/init.sql
```

### Redis操作
```bash
# Redisに接続
docker-compose exec redis redis-cli

# Redis内のキー一覧
docker-compose exec redis redis-cli KEYS "*"

# Redis情報確認
docker-compose exec redis redis-cli INFO
```

## トラブルシューティング

### キャッシュクリア
```bash
# Docker イメージキャッシュをクリア
docker system prune -a

# 使用されていないボリュームを削除
docker volume prune

# 全ての停止中コンテナを削除
docker container prune
```

### 完全リセット
```bash
# 全て停止・削除
docker-compose down -v --rmi all

# 再構築
docker-compose build --no-cache
docker-compose up -d
```

### 個別サービス再構築
```bash
# バックエンドのみ再構築
docker-compose build --no-cache backend
docker-compose up -d backend

# 特定のサービスのみ起動
docker-compose up -d postgres redis
```

## 本番環境用

### 本番環境での起動
```bash
# 本番用設定で起動
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 本番環境での状態確認
docker-compose -f docker-compose.yml -f docker-compose.prod.yml ps
```

### ログ管理
```bash
# ログサイズ確認
docker-compose exec backend du -sh /var/log/

# ログローテーション設定確認
docker-compose logs --no-color backend | wc -l
```

## パフォーマンス監視

### リソース使用量確認
```bash
# コンテナのリソース使用量をリアルタイム表示
docker stats

# 特定のコンテナのみ
docker stats daily_stock_backend daily_stock_db daily_stock_redis
```

### コンテナ内部確認
```bash
# プロセス一覧
docker-compose exec backend ps aux

# ディスク使用量
docker-compose exec backend df -h

# メモリ使用量
docker-compose exec backend free -h
```

## 便利なエイリアス設定

以下を `~/.bashrc` または `~/.zshrc` に追加すると便利です：

```bash
# Docker Compose エイリアス
alias dc='docker-compose'
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dcps='docker-compose ps'
alias dclogs='docker-compose logs'
alias dcbuild='docker-compose build'

# 日用品管理アプリ専用
alias daily-up='docker-compose up -d'
alias daily-down='docker-compose down'
alias daily-logs='docker-compose logs -f backend'
alias daily-db='docker-compose exec postgres psql -U daily_stock_user -d daily_stock'
``` 