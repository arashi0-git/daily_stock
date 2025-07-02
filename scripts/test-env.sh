#!/bin/bash

# テスト環境管理スクリプト
set -e

COMPOSE_FILE="docker-compose.test.yml"
PROJECT_NAME="daily-stock-test"

# 色付きの出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_help() {
    echo -e "${BLUE}Daily Stock Test Environment Manager${NC}"
    echo ""
    echo "使用方法: $0 <command>"
    echo ""
    echo "コマンド:"
    echo "  start     - テスト環境を起動"
    echo "  stop      - テスト環境を停止"
    echo "  restart   - テスト環境を再起動"
    echo "  reset     - テスト環境をリセット（データベース含む）"
    echo "  logs      - ログを表示"
    echo "  status    - 各サービスの状態を表示"
    echo "  shell     - バックエンドコンテナのシェルに入る"
    echo "  help      - このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 start    # テスト環境を起動"
    echo "  $0 logs     # ログをリアルタイム表示"
}

check_requirements() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker がインストールされていません${NC}"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}Error: Docker Compose がインストールされていません${NC}"
        exit 1
    fi
}

start_services() {
    echo -e "${GREEN}🚀 テスト環境を起動しています...${NC}"
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME up -d
    
    echo -e "${YELLOW}⏳ サービスの起動を待機中...${NC}"
    sleep 10
    
    echo -e "${GREEN}✅ テスト環境が起動しました！${NC}"
    echo ""
    echo "📱 フロントエンド: http://localhost:3000"
    echo "🔧 バックエンドAPI: http://localhost:8000"
    echo "📚 API文書: http://localhost:8000/docs"
    echo "🗄️ データベース: localhost:5433"
}

stop_services() {
    echo -e "${YELLOW}🛑 テスト環境を停止しています...${NC}"
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME down
    echo -e "${GREEN}✅ テスト環境を停止しました${NC}"
}

restart_services() {
    echo -e "${YELLOW}🔄 テスト環境を再起動しています...${NC}"
    stop_services
    start_services
}

reset_environment() {
    echo -e "${RED}⚠️  テスト環境をリセットします（全データが削除されます）${NC}"
    read -p "続行しますか？ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🗑️ データを削除しています...${NC}"
        docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME down -v
        docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME up -d --build
        echo -e "${GREEN}✅ テスト環境をリセットしました${NC}"
    else
        echo -e "${BLUE}操作をキャンセルしました${NC}"
    fi
}

show_logs() {
    echo -e "${BLUE}📋 テスト環境のログを表示しています...${NC}"
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME logs -f
}

show_status() {
    echo -e "${BLUE}📊 テスト環境の状態:${NC}"
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME ps
}

backend_shell() {
    echo -e "${BLUE}🐚 バックエンドコンテナのシェルに接続しています...${NC}"
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME exec backend bash
}

# メイン処理
case "${1:-help}" in
    start)
        check_requirements
        start_services
        ;;
    stop)
        check_requirements
        stop_services
        ;;
    restart)
        check_requirements
        restart_services
        ;;
    reset)
        check_requirements
        reset_environment
        ;;
    logs)
        check_requirements
        show_logs
        ;;
    status)
        check_requirements
        show_status
        ;;
    shell)
        check_requirements
        backend_shell
        ;;
    help|--help|-h)
        print_help
        ;;
    *)
        echo -e "${RED}Error: 不明なコマンド '$1'${NC}"
        echo ""
        print_help
        exit 1
        ;;
esac 