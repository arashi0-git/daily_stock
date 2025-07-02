#!/bin/bash

echo "🚀 Starting Daily Stock App in Development Mode"
echo "API will connect to localhost:8000"

# 開発環境用にローカルのAPIサーバーに接続
flutter run -d web --dart-define=API_BASE_URL=http://localhost:8000 