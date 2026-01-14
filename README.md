# Презентація: Правила, команди та навички для Агентних IDE

[![Deploy to GitHub Pages](https://github.com/suprime2009/2026-fwdays-rules-commands-skills-practice/actions/workflows/deploy.yml/badge.svg)](https://github.com/suprime2009/2026-fwdays-rules-commands-skills-practice/actions/workflows/deploy.yml)
[![Quality Check](https://github.com/suprime2009/2026-fwdays-rules-commands-skills-practice/actions/workflows/quality-check.yml/badge.svg)](https://github.com/suprime2009/2026-fwdays-rules-commands-skills-practice/actions/workflows/quality-check.yml)

Презентація створена за допомогою [Slidev](https://sli.dev/) на тему "Правила, команди та навички для Агентних IDE".

## ✅ Статус

Презентація створена та готова до використання!

## 📚 Документація

Вся документація проекту знаходиться в папці [`doc/`](doc/):

- **[Головна документація](doc/README.md)** - загальна інформація про проект
- **[Швидкий старт](doc/getting-started.md)** - як встановити та запустити презентацію
- **[Гайд по Slidev](doc/slidev-guide.md)** - детальна інформація про використання Slidev
- **[Структура проекту](doc/project-structure.md)** - опис структури файлів та організації

## 🚀 Швидкий старт

1. Встановіть залежності:
   ```bash
   npm install
   ```

2. Запустіть презентацію:
   ```bash
   npm run dev
   ```

3. Відкрийте `http://localhost:3030` у браузері

**⚠️ Важливо**: Потрібен Node.js версії 18 або вище. Детальніше - в [doc/getting-started.md](doc/getting-started.md).

## 📁 Основні файли

- `slides.md` - основний вміст презентації (13 слайдів)
- `slidev.config.ts` - конфігурація Slidev
- `package.json` - залежності та скрипти
- `presentation.html` - альтернативна HTML версія (для перегляду без Node.js)
- `scripts/` - автоматизація Git та управління контентом
- `doc/` - повна документація проекту

## 🎯 Основні команди

### Розробка
```bash
npm run dev      # Запуск презентації (localhost:3030)
npm run build    # Збірка статичної версії
npm run preview  # Перегляд зібраної версії
```

### Управління контентом
```bash
npm run slide:add     # Додати новий слайд
npm run slide:stats   # Статистика презентації
npm run docs:update   # Оновити документацію
```

### Git та якість
```bash
npm run git:status    # Статус репозиторію
npm run validate      # Перевірка якості
npm test             # Повний тест проекту
```

### Детальніше
Повний список команд дивіться в [doc/getting-started.md](doc/getting-started.md)

## 🎨 Генерація зображень з OpenAI API

Презентація включає **11 нових слайдів** про генерацію зображень з використанням OpenAI DALL-E API:

- **API налаштування** - отримання ключа та конфігурація
- **Код приклади** - Python та JavaScript для генерації
- **Технічні промпти** - ефективні промпти українською
- **Slidev інтеграція** - синтаксис для зображень
- **Кращі практики** - оптимізація та продуктивність
- **Альтернативи** - Stable Diffusion, Midjourney

### Швидкий старт з зображеннями:
```bash
# Налаштувати API ключ
echo "OPENAI_API_KEY=sk-your-key" > .env

# Згенерувати зображення
npm run images:generate ai-concept images/slides/ai-concept.png

# Або всі зображення одразу
npm run images:batch
```

## 🤖 Правила для Cursor IDE

Правила для роботи з проектом через Cursor IDE знаходяться в файлі [`.cursorrules`](.cursorrules). Правила посилаються на документацію в `doc/` замість її дублювання.

## 🚀 GitHub Actions & Pages

Проект використовує GitHub Actions для автоматизації процесу розробки та деплою:

### 📋 Доступні Workflows

#### **1. Deploy to GitHub Pages** (`deploy.yml`)
Автоматично публікує презентацію на GitHub Pages при push в `main` гілку.

#### **2. Deploy PDF Export** (`deploy-pdf.yml`)
Генерує PDF та зображення презентації, створює GitHub releases з assets.

#### **3. Preview PR** (`preview.yml`)
Створює preview deployment для pull requests (якщо налаштовано Netlify).

#### **4. Quality Check** (`quality-check.yml`)
Перевіряє якість коду, будує презентацію та завантажує артефакти.

### 🌐 Демо презентації

Після деплою презентація буде доступна на: **https://[username].github.io/[repo-name]**

### 🔧 Налаштування GitHub Pages

1. **Увімкнути Pages** в Settings → Pages
2. **Вибрати джерело:** "GitHub Actions"
3. **Workflow** автоматично деплоїть при push в main

### 📄 PDF Export та Releases

Для створення PDF версії презентації та інших експортів:

#### **Автоматичний експорт:**
```bash
# Запустити PDF експорт вручну
# Перейти до Actions → Deploy PDF Export → Run workflow
```

#### **Що генерується:**
- **presentation.pdf** - повна PDF версія презентації
- **title-slide.png** - знімок титульного слайду
- **presentation.html** - автономна HTML версія
- **presentation-assets.tar.gz** - архів з усіма assets

### 📊 Статус CI/CD

Перевіряйте статус workflows в закладці **Actions** репозиторію.

### 📦 Releases

При створенні release через **Deploy PDF Export** workflow автоматично:
- Генеруються всі експортні файли
- Створюється GitHub release з assets
- Додається опис з статистикою презентації

## 📖 Зміст презентації

Презентація містить 27 слайдів, що охоплюють:
- Вступ в Агентні IDE
- Основні правила роботи з AI-помічниками
- Команди та інструменти
- Навички та найкращі практики
- Приклади та висновки

Детальний список слайдів - в [doc/getting-started.md](doc/getting-started.md).
