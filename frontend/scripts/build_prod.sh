#!/bin/bash

echo "🏗️ Building Daily Stock App for Production"
echo "API will connect to production server"

# 本番環境用にビルド
flutter build web --release --base-href="/" --dart-define=API_BASE_URL=https://daily-store-app.an.r.appspot.com

echo "✅ Build completed! Files are in build/web/"
echo "You can now deploy to Firebase Hosting or Netlify" 