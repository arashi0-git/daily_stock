#!/bin/bash

echo "🌐 Starting Daily Stock App in Production Mode"
echo "API will connect to production server"

# 本番環境のAPIサーバーに接続
flutter run -d web --dart-define=API_BASE_URL=https://daily-store-app.an.r.appspot.com 