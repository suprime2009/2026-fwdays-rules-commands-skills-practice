#!/bin/bash

# Git Workflow Commands for Slidev Presentation Project
# Usage: ./scripts/git-workflow.sh <command> [options]

set -e

PROJECT_NAME="2026-fwdays-rules-commands-skills-practice"
BRANCH_PREFIX="feature/slide"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in a git repository
check_git() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Не в Git репозиторії"
        exit 1
    fi
}

# Get current branch name
get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# Check if working directory is clean
is_clean() {
    [ -z "$(git status --porcelain)" ]
}

# Main commands
case "$1" in
    "status")
        check_git
        log_info "Перевірка статусу репозиторію..."
        git status --short --branch
        if ! is_clean; then
            log_warning "Робоча директорія має незакомічені зміни"
        else
            log_success "Робоча директорія чиста"
        fi
        ;;

    "commit")
        check_git
        if is_clean; then
            log_warning "Немає змін для коміту"
            exit 0
        fi

        MESSAGE="${2:-"feat: оновлення презентації"}"
        log_info "Коміт змін з повідомленням: '$MESSAGE'"

        git add .
        git commit -m "$MESSAGE"
        log_success "Зміни закомічено"
        ;;

    "push")
        check_git
        BRANCH=$(get_current_branch)
        log_info "Публікація гілки '$BRANCH'..."

        # Check if branch exists on remote
        if git ls-remote --heads origin "$BRANCH" | grep -q "$BRANCH"; then
            git push origin "$BRANCH"
        else
            log_info "Створення нової віддаленої гілки..."
            git push -u origin "$BRANCH"
        fi

        log_success "Гілка опублікована"
        ;;

    "branch")
        check_git
        SLIDE_TOPIC="$2"
        if [ -z "$SLIDE_TOPIC" ]; then
            log_error "Вкажіть тему слайду: ./scripts/git-workflow.sh branch 'назва-теми'"
            exit 1
        fi

        BRANCH_NAME="$BRANCH_PREFIX-$SLIDE_TOPIC"
        log_info "Створення нової гілки: '$BRANCH_NAME'"

        git checkout -b "$BRANCH_NAME"
        log_success "Гілка створена та переключена"
        ;;

    "sync")
        check_git
        BRANCH=$(get_current_branch)
        log_info "Синхронізація з віддаленим репозиторієм..."

        # Fetch latest changes
        git fetch origin

        # If on main/master, pull latest
        if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
            git pull origin "$BRANCH"
            log_success "Основна гілка оновлена"
        else
            log_info "Перевірка конфліктів з основною гілкою..."
            if git diff --quiet "origin/main..HEAD" 2>/dev/null; then
                log_success "Гілка синхронізована"
            else
                log_warning "Можливі конфлікти. Рекомендується rebase або merge"
            fi
        fi
        ;;

    "clean")
        check_git
        log_info "Очищення непотрібних файлів..."

        # Remove untracked files (be careful!)
        echo "Ця команда видалить всі незавершені файли. Продовжити? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            git clean -fd
            log_success "Непотрібні файли видалено"
        else
            log_info "Операція скасована"
        fi
        ;;

    "log")
        check_git
        COUNT="${2:-5}"
        log_info "Останні $COUNT комітів:"
        git log --oneline -n "$COUNT" --decorate
        ;;

    "help"|*)
        echo "Git Workflow Commands for $PROJECT_NAME"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  status              - Перевірити статус репозиторію"
        echo "  commit [message]    - Закомітити всі зміни"
        echo "  push                - Опублікувати поточну гілку"
        echo "  branch <topic>      - Створити нову гілку для слайду"
        echo "  sync                - Синхронізувати з віддаленим репозиторієм"
        echo "  clean               - Очистити непотрібні файли"
        echo "  log [count]         - Показати історію комітів"
        echo "  help                - Показати цю допомогу"
        echo ""
        echo "Examples:"
        echo "  $0 status"
        echo "  $0 commit 'feat: додати слайд про правила'"
        echo "  $0 branch 'agentic-ide-rules'"
        echo "  $0 push"
        ;;
esac