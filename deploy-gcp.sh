#!/bin/bash

# GCP プロジェクトID（必須）
PROJECT_ID=${1:-"your-project-id"}

if [ "$PROJECT_ID" = "your-project-id" ]; then
    echo "使用方法: ./deploy-gcp.sh YOUR_PROJECT_ID"
    echo "例: ./deploy-gcp.sh my-daily-stock-project"
    exit 1
fi

echo "🚀 GCP Cloud Run へのデプロイを開始します..."
echo "プロジェクトID: $PROJECT_ID"

# 必要なAPIを有効化
echo "📋 必要なAPIを有効化中..."
gcloud services enable cloudbuild.googleapis.com --project=$PROJECT_ID
gcloud services enable run.googleapis.com --project=$PROJECT_ID
gcloud services enable containerregistry.googleapis.com --project=$PROJECT_ID

# プロジェクトを設定
gcloud config set project $PROJECT_ID

# Dockerイメージをビルド
echo "🔨 Dockerイメージをビルド中..."
docker build -t gcr.io/$PROJECT_ID/daily-stock-backend:latest .

# Container Registryにプッシュ
echo "📤 Container Registryにプッシュ中..."
docker push gcr.io/$PROJECT_ID/daily-stock-backend:latest

# Cloud Runにデプロイ
echo "🚀 Cloud Runにデプロイ中..."
gcloud run deploy daily-stock-backend \
    --image gcr.io/$PROJECT_ID/daily-stock-backend:latest \
    --region asia-northeast1 \
    --platform managed \
    --allow-unauthenticated \
    --memory 1Gi \
    --cpu 1 \
    --max-instances 10 \
    --set-env-vars ENVIRONMENT=production,DEBUG=false \
    --project $PROJECT_ID

echo "✅ デプロイが完了しました！"
echo ""
echo "📝 次の手順:"
echo "1. Cloud SQL インスタンスを作成"
echo "2. Secret Manager でデータベース接続情報を設定"
echo "3. service.yaml の PROJECT_ID を実際の値に変更"
echo "4. フロントエンドのURLを設定"
echo ""
echo "🌐 サービスURL:"
gcloud run services describe daily-stock-backend --region=asia-northeast1 --format='value(status.url)' --project=$PROJECT_ID 