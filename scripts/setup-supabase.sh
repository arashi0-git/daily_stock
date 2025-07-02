#!/bin/bash

# 🗄️ Supabase本番環境セットアップスクリプト
# このスクリプトはSupabase本番環境のセットアップを支援します

echo "🚀 Supabase本番環境セットアップスクリプト"
echo "=============================================="
echo ""

# 色付きテキスト用の関数
print_info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

print_warning() {
    echo -e "\033[33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

# 必要なツールの確認
check_requirements() {
    print_info "必要なツールを確認中..."
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3が見つかりません。インストールしてください。"
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        print_error "curlが見つかりません。インストールしてください。"
        exit 1
    fi
    
    print_success "必要なツールが確認できました"
}

# SECRET_KEY生成
generate_secret_key() {
    print_info "SECRET_KEYを生成中..."
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(64))")
    print_success "SECRET_KEYが生成されました"
    echo "SECRET_KEY: $SECRET_KEY"
    echo ""
}

# Supabase情報の入力
get_supabase_info() {
    print_info "Supabase接続情報を入力してください"
    echo ""
    
    read -p "Supabase Project Reference (例: ixnkwlzlmrkfyrswccpl): " PROJECT_REF
    read -s -p "Supabaseデータベースパスワード: " DB_PASSWORD
    echo ""
    read -p "フロントエンドURL (例: https://your-app.netlify.app): " FRONTEND_URL
    echo ""
    
    if [[ -z "$PROJECT_REF" || -z "$DB_PASSWORD" || -z "$FRONTEND_URL" ]]; then
        print_error "すべての項目を入力してください"
        exit 1
    fi
    
    DATABASE_URL="postgresql://postgres:${DB_PASSWORD}@db.${PROJECT_REF}.supabase.co:5432/postgres"
}

# 環境変数設定の表示
show_env_vars() {
    print_success "環境変数設定"
    echo "=============================================="
    echo "DATABASE_URL=$DATABASE_URL"
    echo "SECRET_KEY=$SECRET_KEY"
    echo "ALGORITHM=HS256"
    echo "ACCESS_TOKEN_EXPIRE_MINUTES=1440"
    echo "ENVIRONMENT=production"
    echo "DEBUG=false"
    echo "FRONTEND_URL=$FRONTEND_URL"
    echo "=============================================="
    echo ""
}

# マイグレーション実行
run_migration() {
    print_info "マイグレーションを実行しますか？ (y/N)"
    read -p "選択: " run_migration_choice
    
    if [[ "$run_migration_choice" =~ ^[Yy]$ ]]; then
        print_info "マイグレーションを実行中..."
        
        export DATABASE_URL="$DATABASE_URL"
        export ENVIRONMENT="production"
        
        cd backend
        
        if python3 migrate.py; then
            print_success "マイグレーションが正常に完了しました"
        else
            print_error "マイグレーションに失敗しました"
        fi
        
        cd ..
    fi
}

# デプロイメント手順の表示
show_deployment_steps() {
    print_info "次の手順"
    echo "=============================================="
    echo "1. Renderダッシュボードで環境変数を設定"
    echo "2. Netlifyで FRONTEND_URL を設定"
    echo "3. アプリケーションをデプロイ"
    echo ""
    echo "詳細手順: DEPLOYMENT_GUIDE.md を参照"
    echo "環境変数ガイド: SUPABASE_ENV_TEMPLATE.md を参照"
    echo "=============================================="
}

# メイン実行
main() {
    check_requirements
    generate_secret_key
    get_supabase_info
    show_env_vars
    
    print_warning "⚠️  重要：上記の環境変数をコピーして、デプロイ環境に設定してください"
    print_warning "⚠️  データベースパスワードは絶対にGitにコミットしないでください"
    echo ""
    
    run_migration
    show_deployment_steps
    
    print_success "🎉 セットアップが完了しました！"
}

# スクリプト実行
main 