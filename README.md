# 日用品管理アプリケーション (Daily Stock Manager)

## プロジェクト概要
日用品の在庫を管理し、なくなりそうなタイミングで通知するアプリケーションです。
AIを活用してユーザーの消費パターンを学習し、適切なタイミングで補充を提案します。

## 技術スタック
- **Frontend**: Flutter
- **Backend**: Python FastAPI
- **Database**: PostgreSQL
- **AI/ML**: Python (scikit-learn, pandas)

## プロジェクト構造
```
daily_stock/
├── backend/          # FastAPI バックエンド
├── frontend/         # Flutter フロントエンド
├── ai_service/       # AI/ML サービス
├── database/         # データベース設定
└── docker-compose.yml
```

## 機能
- ユーザー認証（登録・ログイン）
- 日用品の登録・管理
- 消費記録の追跡
- AI による消費予測
- プッシュ通知機能

## セットアップ

### 前提条件
- Python 3.9+
- Flutter SDK
- Docker & Docker Compose
- PostgreSQL

### 起動手順

### 🐳 Docker環境（推奨）
1. リポジトリをクローン
2. 全サービスを起動: `docker-compose up -d`
3. Flutterアプリを起動: `cd frontend && flutter run`

### 🔧 ローカル開発環境
1. データベースを起動: `docker-compose up -d postgres redis`
2. バックエンドAPIを起動: `cd backend && uvicorn main:app --reload`
3. Flutterアプリを起動: `cd frontend && flutter run`

詳細な手順は [QUICK_START.md](QUICK_START.md) を参照してください。

## 開発状況
- [x] プロジェクト構造作成
- [ ] 認証機能
- [ ] 日用品登録機能
- [ ] 消費記録機能
- [ ] AI予測機能
- [ ] 通知機能 