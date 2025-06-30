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
├── render.yaml       # Render デプロイ設定
└── DEPLOYMENT_GUIDE.md  # デプロイメントガイド
```

## 機能
- ユーザー認証（登録・ログイン）
- 日用品の登録・管理
- 消費記録の追跡
- AI による消費予測
- 市場データとの比較
- インテリジェントな購入推奨

## 🚀 デプロイメント（完全無料）

### デプロイ済みアプリ
- **フロントエンド**: Netlify でホスティング
- **バックエンド**: Render でホスティング
- **データベース**: Supabase でホスティング

### デプロイ手順
詳細なデプロイ手順については、[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) をご参照ください。

### クイックデプロイ
1. **Supabase**: データベース設定
2. **Render**: バックエンドデプロイ
3. **Netlify**: フロントエンドデプロイ

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

**🌟 完全無料でホスティング可能！**
Netlify + Render + Supabase の無料プランを活用 