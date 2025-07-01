# Python 3.11のスリムイメージを使用
FROM python:3.11-slim

# 作業ディレクトリを設定
WORKDIR /app

# システムの依存関係をインストール
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Pythonの依存関係ファイルをコピー（プロジェクトルートから）
COPY requirements.txt .

# Python依存関係をインストール
RUN pip install --no-cache-dir -r requirements.txt

# バックエンドのソースコードをコピー
COPY backend/ ./

# 環境変数を設定
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Cloud Runのポート環境変数を使用（デフォルト8080）
ENV PORT=8080
EXPOSE $PORT

# 非rootユーザーでの実行（セキュリティベストプラクティス）
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# ヘルスチェック用エンドポイントの確認
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get(f'http://localhost:{os.environ.get(\"PORT\", 8080)}/health', timeout=10)" || exit 1

# Cloud Run用の起動コマンド
CMD exec uvicorn main:app --host 0.0.0.0 --port ${PORT} --workers 1 