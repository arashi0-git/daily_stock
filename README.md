# 日用品管理アプリケーション (Daily Stock Manager)

## プロジェクト概要
日用品の在庫を管理し、なくなりそうなタイミングで通知するアプリケーションです。
AIを活用してユーザーの消費パターンを学習し、適切なタイミングで補充を提案します。

## 技術スタック
- **Frontend**: Flutter Web
- **Backend**: Python FastAPI (AI統合)
- **Database**: PostgreSQL (Supabase)
- **AI/ML**: Python (scikit-learn, pandas, numpy)

## プロジェクト構造
```
daily_stock/
├── backend/          # FastAPI バックエンド（AI統合済み）
├── frontend/         # Flutter Web フロントエンド
├── database/         # データベース設定
├── backend/app.yaml  # Google App Engine デプロイ設定
└── DEPLOYMENT_GUIDE.md  # デプロイメントガイド
```

## 機能
- ユーザー認証（登録・ログイン）
- 日用品の登録・管理
- 消費記録の追跡
- AI による消費予測
- 市場データとの比較
- インテリジェントな購入推奨

## 🚀 デプロイメント

### デプロイ環境
- **フロントエンド（Flutter Web）**: Firebase Hosting - firebase deploy
- **バックエンド（FastAPI）**: Google App Engine - gcloud app deploy
- **データベース**: Supabase

### デプロイ手順
詳細なデプロイ手順については、[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) をご参照ください。


## 🧪 テスト環境（Docker）

### 完全ローカルテスト環境
フロントエンドとバックエンドの両方をDockerで独立してテストできます：

```bash
# テスト環境を起動
./scripts/test-env.sh start

# アクセス先
# フロントエンド: http://localhost:3000
# バックエンドAPI: http://localhost:8000
# API文書: http://localhost:8000/docs

# テスト環境を停止
./scripts/test-env.sh stop
```

**特徴:**
- ✅ 本番環境と完全に分離されたテスト環境
- ✅ フロントエンドとバックエンドの統合テスト
- ✅ 独立したテスト用データベース
- ✅ ホットリロード対応（バックエンド）

詳細は [TEST_ENVIRONMENT.md](TEST_ENVIRONMENT.md) をご参照ください。

## セットアップ

### 前提条件
- Python 3.9+
- Flutter SDK
- Git

### 🐳 Docker環境（ローカル開発）
1. リポジトリをクローン
2. 全サービスを起動: `docker-compose up -d`
3. フロントエンド確認: http://localhost:3000
4. バックエンドAPI: http://localhost:8000/docs

### 🔧 ローカル開発環境
1. データベースを起動: `docker-compose up -d postgres redis`
2. バックエンドAPIを起動: `cd backend && uvicorn main:app --reload`
3. Flutterアプリを起動: `cd frontend && flutter run -d web`

## API エンドポイント

### 認証
- `POST /api/v1/auth/register` - ユーザー登録
- `POST /api/v1/auth/login` - ログイン
- `GET /api/v1/auth/me` - ユーザー情報取得

### 日用品管理
- `GET /api/v1/items` - 日用品一覧取得
- `POST /api/v1/items` - 日用品作成
- `PUT /api/v1/items/{id}` - 日用品更新
- `DELETE /api/v1/items/{id}` - 日用品削除

### AI分析（統合済み）
- `POST /api/v1/ai/analyze/consumption-pace` - 消費ペース分析
- `POST /api/v1/ai/market-data/search` - 市場データ検索
- `POST /api/v1/ai/recommendations/generate` - 推奨生成
- `POST /api/v1/ai/recommendations/batch` - 一括推奨生成

## 開発状況
- [x] プロジェクト構造作成
- [x] AIサービス統合
- [x] デプロイメント設定
- [x] 無料デプロイ対応
- [ ] 認証機能実装
- [ ] 日用品登録機能
- [ ] 消費記録機能
- [ ] フロントエンドUI実装
- [ ] プッシュ通知機能

## 🎯 次のステップ
1. [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) を参照してデプロイ
2. フロントエンドとバックエンドの連携テスト
3. 認証機能の実装
4. 日用品管理機能の実装

## 📞 サポート
- GitHub Issues でバグ報告・機能要求
- デプロイメントガイドでトラブルシューティング

---

**🌟 クラウドでホスティング可能！**
Firebase Hosting + Google App Engine + Supabase を活用 