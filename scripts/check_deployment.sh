#!/bin/bash

# デプロイメント確認スクリプト
set -e

echo "🔍 Checking deployment status..."

# Backend health check (Railway)
BACKEND_URL="${BACKEND_URL:-https://your-app-name.up.railway.app}"
echo "Checking backend: $BACKEND_URL/health"

if curl -f -s "$BACKEND_URL/health" > /dev/null; then
    echo "✅ Backend is healthy"
else
    echo "❌ Backend health check failed"
    exit 1
fi

# Frontend check (Firebase Hosting)
FRONTEND_URL="${FRONTEND_URL:-https://daily-store-app.web.app}"
echo "Checking frontend: $FRONTEND_URL"

if curl -f -s "$FRONTEND_URL" > /dev/null; then
    echo "✅ Frontend is accessible"
else
    echo "❌ Frontend check failed"
    exit 1
fi

echo "🎉 All services are running successfully!" 