import { defineConfig } from 'slidev/config'

export default defineConfig({
  title: 'Правила, команди та навички для Агентних IDE',
  titleTemplate: '%s - FWDays 2026',
  theme: 'default',
  fonts: {
    sans: 'Inter',
    mono: 'Fira Code',
  },
  highlighter: 'shiki',
  colorSchema: 'auto',
  routerMode: 'history',
  remoteAssets: false,
  remote: 'dev',
  presenter: true,
  download: true,
  plantUmlServer: 'https://www.plantuml.com/plantuml',
  htmlAttrs: {
    lang: 'uk'
  },
  markdown: {
    toc: true,
  },
  slideOptions: {
    transition: 'slide-left'
  }
})