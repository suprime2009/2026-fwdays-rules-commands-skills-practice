#!/bin/bash

# Content Management Commands for Slidev Presentation Project
# Usage: ./scripts/content-manager.sh <command> [options]

set -e

SLIDES_FILE="slides.md"
DOC_DIR="doc"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

log_step() {
    echo -e "${PURPLE}🔸 $1${NC}"
}

# Count total slides
count_slides() {
    grep -c "^---" "$SLIDES_FILE" || echo "0"
}

# Get slide titles
get_slide_titles() {
    grep "^#" "$SLIDES_FILE" | sed 's/^#* //' | nl -v1
}

# Backup current content
backup_content() {
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_DIR="backups/$TIMESTAMP"

    mkdir -p "$BACKUP_DIR"
    cp "$SLIDES_FILE" "$BACKUP_DIR/"
    cp -r "$DOC_DIR" "$BACKUP_DIR/"

    log_success "Резервна копія створена: $BACKUP_DIR"
    echo "$BACKUP_DIR"
}

# Add new slide
add_slide() {
    TITLE="$1"
    if [ -z "$TITLE" ]; then
        log_error "Вкажіть заголовок слайду: ./scripts/content-manager.sh add-slide 'Заголовок слайду'"
        exit 1
    fi

    log_info "Додавання нового слайду: '$TITLE'"

    # Create slide content
    SLIDE_CONTENT="---

# $TITLE

<v-clicks>

- Пункт 1
- Пункт 2
- Пункт 3

</v-clicks>

<!-- Додайте ваш контент тут -->

---"

    # Append to slides file
    echo "$SLIDE_CONTENT" >> "$SLIDES_FILE"

    SLIDE_COUNT=$(count_slides)
    log_success "Слайд додано! Загальна кількість слайдів: $SLIDE_COUNT"
}

# Update documentation
update_docs() {
    log_info "Оновлення документації..."

    # Update slide count in documentation
    SLIDE_COUNT=$(count_slides)

    # Update README.md
    sed -i.bak "s/Презентація містить [0-9]* слайдів/Презентація містить $SLIDE_COUNT слайдів/" README.md

    # Update doc files
    sed -i.bak "s/Презентація містить [0-9]* слайдів/Презентація містить $SLIDE_COUNT слайдів/" "$DOC_DIR/README.md"
    sed -i.bak "s/Презентація містить [0-9]* слайдів/Презентація містить $SLIDE_COUNT слайдів/" "$DOC_DIR/getting-started.md"

    # Clean up backup files
    rm -f README.md.bak "$DOC_DIR/README.md.bak" "$DOC_DIR/getting-started.md.bak"

    log_success "Документація оновлена (загальна кількість слайдів: $SLIDE_COUNT)"
}

# Generate slide overview
generate_overview() {
    OUTPUT_FILE="${1:-slide-overview.md}"
    log_info "Генерація огляду слайдів: $OUTPUT_FILE"

    {
        echo "# Огляд слайдів презентації"
        echo ""
        echo "**Загальна кількість слайдів:** $(count_slides)"
        echo ""
        echo "**Дата генерації:** $(date)"
        echo ""
        echo "## Зміст слайдів:"
        echo ""
        get_slide_titles
        echo ""
        echo "---"
        echo ""
        echo "*Згенеровано автоматично скриптом content-manager.sh*"
    } > "$OUTPUT_FILE"

    log_success "Огляд слайдів створено: $OUTPUT_FILE"
}

# Check for broken links in markdown
check_links() {
    log_info "Перевірка посилань у Markdown файлах..."

    BROKEN_LINKS=0

    # Check all markdown files
    find . -name "*.md" -type f | while read -r file; do
        log_step "Перевірка: $file"

        # Check for broken internal links
        grep -n "\[.*\](\.\./.*)" "$file" | while read -r line; do
            LINK_PATH=$(echo "$line" | grep -o "\[.*\](\.\./[^)]*)" | sed 's/.*(\.\././' | sed 's/).*//')
            if [ ! -f "$LINK_PATH" ] && [ ! -d "$LINK_PATH" ]; then
                log_warning "Можливо неіснуюче посилання в $file (рядок $(echo "$line" | cut -d: -f1)): $LINK_PATH"
                BROKEN_LINKS=$((BROKEN_LINKS + 1))
            fi
        done
    done

    if [ $BROKEN_LINKS -eq 0 ]; then
        log_success "Всі посилання коректні"
    else
        log_warning "Знайдено $BROKEN_LINKS потенційно некоректних посилань"
    fi
}

# Generate presentation stats
stats() {
    log_info "Статистика презентації:"

    SLIDE_COUNT=$(count_slides)
    WORD_COUNT=$(wc -w < "$SLIDES_FILE")
    LINE_COUNT=$(wc -l < "$SLIDES_FILE")
    DOC_FILES=$(find "$DOC_DIR" -name "*.md" | wc -l)
    DOC_WORDS=$(find "$DOC_DIR" -name "*.md" -exec cat {} \; | wc -w)

    echo ""
    echo "📊 Статистика презентації:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📄 Слайди:         $SLIDE_COUNT слайдів"
    echo "📝 Слова в слайдах: $WORD_COUNT слів"
    echo "📏 Рядків у слайдах: $LINE_COUNT рядків"
    echo "📚 Документаційних файлів: $DOC_FILES файлів"
    echo "📖 Слів у документації: $DOC_WORDS слів"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Calculate average words per slide
    if [ $SLIDE_COUNT -gt 0 ]; then
        AVG_WORDS=$((WORD_COUNT / SLIDE_COUNT))
        echo "📈 Середня кількість слів на слайд: $AVG_WORDS"
    fi
}

# Main commands
case "$1" in
    "add-slide")
        add_slide "$2"
        update_docs
        ;;

    "backup")
        backup_content
        ;;

    "update-docs")
        update_docs
        ;;

    "overview")
        generate_overview "$2"
        ;;

    "check-links")
        check_links
        ;;

    "stats")
        stats
        ;;

    "slides")
        log_info "Список слайдів:"
        echo ""
        get_slide_titles
        ;;

    "help"|*)
        echo "Content Management Commands for Slidev Presentation"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  add-slide <title>    - Додати новий слайд"
        echo "  backup               - Створити резервну копію"
        echo "  update-docs          - Оновити документацію"
        echo "  overview [file]       - Згенерувати огляд слайдів"
        echo "  check-links          - Перевірити посилання"
        echo "  stats                - Показати статистику"
        echo "  slides               - Показати список слайдів"
        echo "  help                 - Показати цю допомогу"
        echo ""
        echo "Examples:"
        echo "  $0 add-slide 'Новий слайд про IDE'"
        echo "  $0 backup"
        echo "  $0 overview my-overview.md"
        echo "  $0 stats"
        ;;
esac