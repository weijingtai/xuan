# Eight Characters Card Feature - Product Requirements Document (PRD)

## 1. Overview

This document outlines the features and requirements for a highly configurable and reusable BaZi (Eight Characters) chart display component. The goal is to create a flexible UI that can display various types of astrological pillars (natal, luck cycle, etc.) and allow the user to customize the data shown.

## 2. Core Features

### 2.1. Dual Card Display
- The UI will feature two independent card components displayed side-by-side.
- One card will be used for the Natal Chart (本命盘).
- The other card will be used for dynamic charts, such as the Luck Cycle (流运盘).

### 2.2. Generic and Reusable Card Component
- The underlying card widget shall be generic, capable of displaying any given set of pillars.

### 2.3. Customizable Pillar Display
- **Card-Specific Controls:** Each card will have its own set of controls to toggle the visibility of specific pillars.
  - The Natal card will have toggles for pillars like '胎元' (Tai Yuan) and '刻柱' (Ke Zhu).
  - The Luck Cycle card will have toggles for pillars like '流月' (Liu Yue), '流日' (Liu Ri), and '流时' (Liu Shi).
- **Pillar Presets:** A "Combination Adjustment" (组合调整) feature will allow users to quickly switch between predefined sets of pillars, such as:
  - 四柱八字 (Standard Four Pillars)
  - 古禄命法 (Ancient Lu Ming Method)
  - 现代五柱 (Modern Five Pillars)
  - 流运 (Standard Luck Cycle)
  - 小限 (Small Limit)

### 2.4. Customizable Data Row Display
- **Shared Controls:** The visibility of data rows (e.g., 十神, 纳音, 空亡, 藏干) will be controlled by a single set of global options that affect both cards simultaneously.
- **Available Rows:** The user can choose to display:
  - Ten Gods (十神)
  - Na Yin (纳音)
  - Kong Wang (空亡)
  - Xun Shou (旬首)
  - Hidden Stems (藏干) and their corresponding Ten Gods, with granular control over each (Main, Middle, Remaining Qi).

### 2.5. Layout Customization and Persistence
- **Drag-and-Drop Reordering:** In an "Adjust Order" mode, users can reorder both the rows and the pillars.
  - Row order changes will be synchronized across both cards.
  - Pillar order changes will be specific to each card.
- **Layout Saving:** The user's complete layout configuration, including pillar visibility, row visibility, and custom orders, will be saved and loaded automatically between sessions.

### 2.6. Dynamic and Responsive UI
- **Dynamic Width:** The Luck Cycle card will dynamically resize its width based on the number of pillars currently displayed.
- **Styling:** The Natal card will display a gender-specific title ('乾造' for male, '坤造' for female) with a distinct style.
- **Animations:** Adding or removing rows will be accompanied by a smooth animation.
- **Title Visibility:** The leftmost column containing row titles will be hidden when no optional data rows are active to save space.
