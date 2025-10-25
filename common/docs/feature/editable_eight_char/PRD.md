# Product Requirements Document: EditableFourZhuCard

## Document Information

| Field | Value |
|-------|-------|
| Document Version | 1.0 |
| Created Date | 2025-10-23 |
| Product | Xuan (玄学) - Chinese Divination App |
| Module | Common (Shared Components) |
| Feature | EditableFourZhuCard - Interactive Eight Characters Card |
| Author | Product Team |
| Status | Draft |

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Problem Statement](#problem-statement)
3. [Goals & Success Metrics](#goals--success-metrics)
4. [Target Users & Personas](#target-users--personas)
5. [User Stories](#user-stories)
6. [Functional Requirements](#functional-requirements)
7. [Non-Functional Requirements](#non-functional-requirements)
8. [Technical Specifications](#technical-specifications)
9. [UI/UX Design](#uiux-design)
10. [Data Models](#data-models)
11. [Implementation Plan](#implementation-plan)
12. [Testing Strategy](#testing-strategy)
13. [Dependencies & Integration](#dependencies--integration)
14. [Risks & Mitigation](#risks--mitigation)
15. [Release Criteria](#release-criteria)
16. [Future Enhancements](#future-enhancements)
17. [Appendix](#appendix)

---

## Executive Summary

The **EditableFourZhuCard** is a comprehensive, self-contained Flutter widget that provides both display and editing capabilities for Chinese Eight Characters (八字/BaZi) analysis. This component addresses the critical UX gap in the current architecture where display and editing functionalities are separated, requiring multiple wrapper components and creating friction in the user experience.

### Key Objectives
- Create a unified component that handles both view and edit modes
- Eliminate the need for external container components (ReorderableListView, DragTarget)
- Provide bidirectional drag-and-drop capabilities (horizontal pillars, vertical rows)
- Maintain backward compatibility with existing FourZhuEightCharsCard

### Business Value
- **Improved Developer Experience**: Reduce implementation complexity by 60% (from 3+ components to 1)
- **Enhanced User Experience**: Seamless editing with intuitive drag-and-drop
- **Accelerated Feature Development**: Faster iteration on layout customization features
- **Reduced Maintenance Overhead**: Single component to maintain instead of distributed logic

### Scope
**In Scope:**
- Editable card component with dual-mode operation
- Built-in drag-and-drop for pillars and rows
- Row visibility and reordering controls
- Pillar addition, deletion, and reordering
- Integration with existing pillar_palette.dart
- Theme support (light/dark mode)

**Out of Scope:**
- Migration of existing FourZhuEightCharsCard usage sites (backward compatibility maintained)
- Backend persistence logic (component only handles UI state)
- Advanced pillar computation logic (uses existing EightChars model)
- Multi-card selection or bulk operations

---

## Problem Statement

### Current State Pain Points

#### 1. Architectural Complexity
**Problem:** The current architecture requires developers to combine multiple components to achieve editing functionality:
- `FourZhuEightCharsCard` (display only)
- External `ReorderableListView` wrapper
- Manual `DragTarget` implementation
- Custom state management logic

**Impact:**
- High cognitive load for developers
- Code duplication across different editor pages
- Inconsistent editing behaviors across the app

#### 2. Limited Interactivity
**Problem:** `FourZhuEightCharsCard` is purely presentational with no built-in interactive capabilities.

**Evidence from codebase:**
```dart
// Current FourZhuEightCharsCard is StatelessWidget with no user interaction
class FourZhuEightCharsCard extends StatelessWidget {
  final EightChars eightChars;
  final bool showTaiYuan;
  final bool showXunShou;
  final bool showNaYin;
  // ... only display flags, no editing callbacks
}
```

**Impact:**
- Cannot be used directly in layout editors
- Requires wrapping in LayoutEditorPage (lines 108-153 in layout_editor_page.dart)
- Poor code reusability

#### 3. Inflexible Row Management
**Problem:** Row visibility is controlled by boolean flags (`showTaiYuan`, `showXunShou`, `showNaYin`), making dynamic row addition/removal difficult.

**Impact:**
- Cannot dynamically show/hide rows without widget recreation
- No support for custom row ordering
- Limited user customization

#### 4. Drag-and-Drop Limitations
**Problem:** `ReorderableListView` only supports single-axis reordering (horizontal pillars OR vertical rows, not both).

**Evidence:**
```dart
// layout_editor_page.dart lines 112-134
ReorderableListView(
  scrollDirection: Axis.horizontal, // Only horizontal
  children: <Widget>[...],
  onReorder: (int oldIndex, int newIndex) {...},
)
```

**Impact:**
- Cannot reorder rows while also reordering pillars
- Requires complex workarounds or separate editing modes
- Suboptimal user experience

### Opportunity

By creating a unified, self-contained editable component, we can:
- **Reduce Development Time**: From ~3-4 hours to implement an editor page to ~30 minutes
- **Improve Consistency**: Single source of truth for editing behavior
- **Enable Advanced Features**: Bidirectional drag-and-drop, dynamic row management
- **Enhance Flexibility**: Pluggable into any page without boilerplate code

---

## Goals & Success Metrics

### Primary Goals

| Goal | Description | Success Metric |
|------|-------------|----------------|
| **G1: Unified Component** | Create single component for both display and editing | 100% feature parity with current FourZhuEightCharsCard + editing capabilities |
| **G2: Developer Experience** | Reduce implementation complexity | ≤ 50 lines of code to integrate vs current 150+ lines |
| **G3: User Experience** | Intuitive editing with visual feedback | User testing: 90% task completion rate for pillar reordering |
| **G4: Backward Compatibility** | No breaking changes to existing code | 0 regression failures in existing tests |

### Secondary Goals

| Goal | Description | Success Metric |
|------|-------------|----------------|
| **G5: Performance** | Smooth drag-and-drop animations | 60 FPS during drag operations on mid-range devices |
| **G6: Flexibility** | Support diverse layout configurations | Support 4-8 pillars, 4-15 rows without performance degradation |
| **G7: Accessibility** | Keyboard and screen reader support | WCAG 2.1 AA compliance for editing operations |

### Key Performance Indicators (KPIs)

#### Development Metrics
- **Code Reduction**: Target 60% reduction in editor page implementation code
- **Time to Market**: Reduce new layout editor page development from 1 day to 2 hours

#### Quality Metrics
- **Test Coverage**: ≥ 85% unit test coverage for EditableFourZhuCard
- **Bug Rate**: < 2 critical bugs per month post-release

#### Usage Metrics (Post-Release)
- **Adoption Rate**: 80% of layout editor pages use EditableFourZhuCard within 3 months
- **User Engagement**: 30% increase in custom layout creation

---

## Target Users & Personas

### Primary Persona: Advanced Divination Practitioner

**Name:** Li Wei (李薇)
**Age:** 45
**Occupation:** Professional BaZi Consultant
**Technical Proficiency:** Medium

**Goals:**
- Create custom layout templates for different divination scenarios
- Quickly modify pillar order during client consultations
- Show/hide specific rows based on analysis focus

**Pain Points:**
- Current editing requires too many taps and navigation
- Cannot reorder pillars on-the-fly during live sessions
- Wants to create "preset layouts" for common use cases

**Use Cases:**
- Creates "Da Yun Analysis" layout with Year, Month, Day, Luck Cycle pillars
- Hides NaYin row when focusing on Ten Gods analysis
- Reorders pillars to emphasize Day pillar (日柱) for destiny analysis

### Secondary Persona: Casual User

**Name:** Chen Ming (陈明)
**Age:** 28
**Occupation:** Software Engineer
**Technical Proficiency:** High

**Goals:**
- Explore different BaZi visualization layouts
- Learn Chinese metaphysics through experimentation
- Customize UI to personal preferences

**Pain Points:**
- Wants to try different configurations without complex menus
- Expects drag-and-drop like modern design tools
- Frustrated by static, non-configurable layouts

**Use Cases:**
- Experiments with showing Tai Yuan (胎元) pillar
- Removes "Kong Wang" row to reduce visual clutter
- Creates minimalist layout with only TianGan and DiZhi rows

### Tertiary Persona: App Developer

**Name:** Zhang Qiang (张强)
**Age:** 32
**Occupation:** Flutter Developer on Xuan team
**Technical Proficiency:** Expert

**Goals:**
- Quickly implement layout editor pages for new divination modules
- Minimize boilerplate code
- Maintain consistency across different editors

**Pain Points:**
- Current architecture requires understanding multiple components
- Code duplication across qimendunjia, qizhengsiyu, daliuren modules
- Difficult to extend with new features

**Use Cases:**
- Implements new layout editor for Tai Yi Shen Shu module in < 1 hour
- Adds custom row type without modifying multiple files
- Integrates with existing state management (Provider)

---

## User Stories

### Epic 1: Basic Display & Editing

#### US-1.1: Toggle Edit Mode
**As a** divination practitioner
**I want to** toggle between view mode and edit mode
**So that** I can view my layout normally and switch to editing when needed

**Acceptance Criteria:**
- [ ] Given the component is in view mode, when I tap an "Edit" button, then the component switches to edit mode
- [ ] Given the component is in edit mode, when I tap a "Done" button, then the component switches to view mode
- [ ] Edit mode shows visual affordances (drag handles, delete buttons)
- [ ] View mode hides all editing controls
- [ ] Mode transition is animated smoothly (< 300ms)

**Priority:** Must-have
**Complexity:** Medium (5 story points)

---

#### US-1.2: Display Four Pillars
**As a** user viewing a BaZi chart
**I want to** see the standard four pillars (Year, Month, Day, Hour)
**So that** I can analyze the eight characters

**Acceptance Criteria:**
- [ ] Component displays 4 pillars by default: 年(Year), 月(Month), 日(Day), 时(Hour)
- [ ] Each pillar shows TianGan (天干) and DiZhi (地支)
- [ ] Colors are applied according to Five Elements mapping in AppColors
- [ ] Layout matches design mockup (card_template.png)
- [ ] Component is responsive and adapts to screen width (240px - 420px)

**Priority:** Must-have
**Complexity:** Small (3 story points)

---

#### US-1.3: Display Customizable Rows
**As a** user
**I want to** see configurable rows of information (TianGan, DiZhi, Ten Gods, NaYin, etc.)
**So that** I can focus on relevant analysis dimensions

**Acceptance Criteria:**
- [ ] Default visible rows: TianGan, DiZhi, ShiShen (Ten Gods), NaYin
- [ ] Each row has a label in the leftmost column
- [ ] Row visibility is controlled by configuration
- [ ] Hidden rows do not occupy space in the layout
- [ ] Minimum 4 rows, maximum 15 rows supported

**Priority:** Must-have
**Complexity:** Medium (5 story points)

---

### Epic 2: Pillar Management

#### US-2.1: Reorder Pillars via Drag-and-Drop
**As a** divination practitioner
**I want to** drag pillars horizontally to reorder them
**So that** I can emphasize important pillars (e.g., move Day pillar to the front)

**Acceptance Criteria:**
- [ ] In edit mode, each pillar shows a drag handle
- [ ] Dragging a pillar displays a translucent feedback widget following the cursor
- [ ] Other pillars shift to show potential drop position
- [ ] Releasing the drag commits the reorder
- [ ] Pillar order is reflected in the component's state
- [ ] Animation is smooth (60 FPS on mid-range devices)
- [ ] Works on both touch and mouse/trackpad inputs

**Priority:** Must-have
**Complexity:** Large (8 story points)

**Dependencies:** Custom Draggable + DragTarget implementation (ReorderableListView insufficient)

---

#### US-2.2: Add New Pillar
**As a** user
**I want to** add additional pillars (Tai Yuan, Da Yun, Liu Nian, Ke)
**So that** I can create comprehensive analysis layouts

**Acceptance Criteria:**
- [ ] A "+" button appears in edit mode at the rightmost position
- [ ] Tapping "+" shows a picker/menu of available pillar types
- [ ] Selecting a pillar type adds it to the layout
- [ ] Alternatively, pillars can be dragged from PillarPalette sidebar
- [ ] Newly added pillar appears at the rightmost position
- [ ] Maximum 8 pillars can be added
- [ ] Visual feedback when drag enters the card area

**Priority:** Must-have
**Complexity:** Medium (5 story points)

---

#### US-2.3: Delete Pillar
**As a** user
**I want to** remove unnecessary pillars
**So that** I can simplify the layout for specific analysis

**Acceptance Criteria:**
- [ ] In edit mode, each pillar shows a delete (X) button in the top-right corner
- [ ] Tapping delete button removes the pillar immediately
- [ ] A confirmation dialog appears if the pillar contains custom data
- [ ] Minimum 1 pillar must remain (cannot delete all)
- [ ] Deletion is animated (fade-out + shrink, duration < 300ms)
- [ ] Undo functionality available (via parent component's state management)

**Priority:** Must-have
**Complexity:** Small (3 story points)

---

#### US-2.4: Drag Pillar from Sidebar
**As a** user
**I want to** drag pillar templates from the sidebar palette into the card
**So that** I can quickly build layouts

**Acceptance Criteria:**
- [ ] PillarPalette sidebar shows draggable pillar templates
- [ ] Dragging from sidebar to card area shows visual drop target
- [ ] Dropping pillar inserts it at the nearest valid position
- [ ] Invalid drop areas (outside card bounds) are indicated clearly
- [ ] Dragging does not remove pillar from sidebar (clone behavior)
- [ ] Works seamlessly with existing pillar_palette.dart component

**Priority:** Must-have
**Complexity:** Medium (5 story points)

**Dependencies:** Integration with existing PillarPalette component

---

### Epic 3: Row Management

#### US-3.1: Reorder Rows via Drag-and-Drop
**As a** user
**I want to** drag rows vertically to change their display order
**So that** I can prioritize important information (e.g., Ten Gods above NaYin)

**Acceptance Criteria:**
- [ ] In edit mode, each row shows a drag handle (☰ icon) in the leftmost column
- [ ] Dragging a row displays translucent feedback following cursor
- [ ] Other rows shift vertically to indicate drop position
- [ ] Releasing drag commits the reorder
- [ ] Row order is persisted in configuration state
- [ ] Smooth animation during drag (60 FPS)

**Priority:** Should-have
**Complexity:** Large (8 story points)

**Dependencies:** Custom bidirectional drag-and-drop system

---

#### US-3.2: Show/Hide Row
**As a** user
**I want to** toggle row visibility
**So that** I can reduce visual clutter and focus on relevant data

**Acceptance Criteria:**
- [ ] In edit mode, each row has an eye icon toggle button
- [ ] Tapping eye icon hides the row (icon changes to slashed eye)
- [ ] Hidden rows are collapsed with fade-out animation (< 200ms)
- [ ] Tapping slashed eye icon shows the row again
- [ ] Hidden rows are remembered in configuration
- [ ] Minimum 2 rows must remain visible (cannot hide all)

**Priority:** Should-have
**Complexity:** Small (3 story points)

---

#### US-3.3: Add Custom Row
**As a** advanced user
**I want to** add custom row types (e.g., Hidden Stems, Xun Shou)
**So that** I can include specialized analysis data

**Acceptance Criteria:**
- [ ] A "+" button appears below the last row in edit mode
- [ ] Tapping "+" shows a menu of available row types (from RowType enum)
- [ ] Selecting a row type adds it to the layout
- [ ] New row appears at the bottom by default
- [ ] Maximum 15 rows can be added
- [ ] Already visible rows are disabled in the menu

**Priority:** Could-have
**Complexity:** Medium (5 story points)

---

### Epic 4: Dividers & Visual Structure

#### US-4.1: Insert Pillar Divider
**As a** user
**I want to** insert visual dividers between pillar groups
**So that** I can separate base pillars from luck cycle pillars

**Acceptance Criteria:**
- [ ] Divider is a special pillar type (PillarType.separator)
- [ ] Divider can be added from PillarPalette or "+" menu
- [ ] Divider displays as a vertical line spanning the full card height
- [ ] Divider can be reordered like regular pillars
- [ ] Divider has a subtle label area showing "｜" character
- [ ] Divider respects theme colors (uses theme.dividerColor)

**Priority:** Could-have
**Complexity:** Small (3 story points)

---

#### US-4.2: Customize Row Separator
**As a** user
**I want to** configure row separator style (solid, dashed, dotted, none)
**So that** I can match my aesthetic preferences

**Acceptance Criteria:**
- [ ] Row configuration includes `borderType` field (from BorderType enum)
- [ ] Supported types: solid, dashed, dotted, none
- [ ] In edit mode, tapping a row separator opens style picker
- [ ] Changing style updates immediately with animation
- [ ] Default style is solid (1px, theme.dividerColor)

**Priority:** Won't-have (Future Enhancement)
**Complexity:** Small (2 story points)

---

### Epic 5: Theme & Styling

#### US-5.1: Apply Five Elements Color Scheme
**As a** user
**I want to** see TianGan and DiZhi colored according to Five Elements
**So that** I can quickly identify elemental relationships

**Acceptance Criteria:**
- [ ] TianGan colors use AppColors.zodiacGanColors mapping
- [ ] DiZhi colors use AppColors.zodiacZhiColors mapping
- [ ] Color mapping follows existing FourZhuEightCharsCard implementation
- [ ] Colors are accessible (WCAG AA contrast ratio against background)

**Priority:** Must-have
**Complexity:** Small (2 story points)

---

#### US-5.2: Support Light/Dark Theme
**As a** user
**I want to** use the component in both light and dark themes
**So that** it matches my system preferences

**Acceptance Criteria:**
- [ ] Component respects Theme.of(context) for all colors
- [ ] Background, text, and divider colors use theme values
- [ ] Edit mode controls (drag handles, buttons) are visible in both themes
- [ ] Five Elements colors maintain sufficient contrast in both themes
- [ ] No hardcoded color values (except Five Elements semantic colors)

**Priority:** Must-have
**Complexity:** Small (3 story points)

---

### Epic 6: State Management & Persistence

#### US-6.1: Expose Configuration State
**As a** developer
**I want to** access the current layout configuration
**So that** I can save it to database or sync to cloud

**Acceptance Criteria:**
- [ ] Component exposes `EditableFourZhuCardConfig` data class
- [ ] Config includes: pillarConfigs (List<PillarConfig>), rowConfigs (List<RowConfig>)
- [ ] Config is JSON-serializable for easy persistence
- [ ] onChange callback provides updated config on every modification
- [ ] Config can be passed as initial state to component constructor

**Priority:** Must-have
**Complexity:** Medium (5 story points)

---

#### US-6.2: Restore from Configuration
**As a** user
**I want to** my custom layouts to be remembered
**So that** I don't have to recreate them every time

**Acceptance Criteria:**
- [ ] Component accepts initialConfig parameter
- [ ] On mount, component restores pillar order, row order, visibility from config
- [ ] Invalid configurations (e.g., unknown pillar types) are handled gracefully
- [ ] Default configuration is used if initialConfig is null
- [ ] Configuration validation happens on initialization

**Priority:** Must-have
**Complexity:** Small (3 story points)

---

## Functional Requirements

### FR-1: Component Modes

| ID | Requirement | Priority | Validation |
|----|-------------|----------|------------|
| FR-1.1 | Component MUST support two modes: View Mode and Edit Mode | Must-have | Unit test: mode switching |
| FR-1.2 | Mode MUST be controlled by `isEditable` boolean parameter from parent | Must-have | Integration test |
| FR-1.3 | View Mode MUST hide all editing controls (drag handles, delete buttons, add buttons) | Must-have | Widget test: no edit controls visible |
| FR-1.4 | Edit Mode MUST show drag handles on pillars and rows | Must-have | Widget test: drag handles present |
| FR-1.5 | Edit Mode MUST show delete button on each pillar | Must-have | Widget test: delete buttons present |
| FR-1.6 | Edit Mode MUST show "+" button for adding pillars | Must-have | Widget test: add button present |

---

### FR-2: Pillar Management

| ID | Requirement | Priority | Validation |
|----|-------------|----------|------------|
| FR-2.1 | Component MUST support 1-8 pillars simultaneously | Must-have | Unit test: pillar count validation |
| FR-2.2 | Default pillars MUST be: Year, Month, Day, Hour (in that order) | Must-have | Unit test: default config |
| FR-2.3 | Component MUST allow horizontal reordering of pillars via drag-and-drop | Must-have | Widget test: drag simulation |
| FR-2.4 | Component MUST allow deletion of pillars (minimum 1 pillar retained) | Must-have | Widget test: delete action |
| FR-2.5 | Component MUST allow addition of pillars from predefined types | Must-have | Widget test: add action |
| FR-2.6 | Supported pillar types MUST include: year, month, day, hour, ke, taiMeta, taiMonth, taiDay, lifeHouse, luckCycle, annual, monthly, daily, hourly, separator | Must-have | Unit test: enum coverage |
| FR-2.7 | Pillar drag feedback MUST follow cursor/touch position | Must-have | Widget test: feedback position |
| FR-2.8 | Pillar drop MUST snap to nearest valid slot | Must-have | Unit test: snap logic |
| FR-2.9 | Component MUST accept pillars dragged from external PillarPalette | Must-have | Integration test: external drag |

---

### FR-3: Row Management

| ID | Requirement | Priority | Validation |
|----|-------------|----------|------------|
| FR-3.1 | Component MUST support 2-15 rows simultaneously | Must-have | Unit test: row count validation |
| FR-3.2 | Default visible rows MUST be: TianGan, DiZhi, ShiShen (Ten Gods), NaYin | Must-have | Unit test: default config |
| FR-3.3 | Component MUST allow vertical reordering of rows via drag-and-drop | Should-have | Widget test: row drag |
| FR-3.4 | Component MUST allow toggling row visibility | Should-have | Widget test: visibility toggle |
| FR-3.5 | Hidden rows MUST NOT occupy layout space | Should-have | Widget test: layout constraints |
| FR-3.6 | Supported row types MUST include all values in RowType enum | Must-have | Unit test: enum coverage |
| FR-3.7 | Each row MUST display a label in the leftmost column | Must-have | Widget test: label presence |
| FR-3.8 | Row data MUST adapt to current pillar count (values repeated per pillar) | Must-have | Unit test: data binding |

---

### FR-4: Visual Dividers

| ID | Requirement | Priority | Validation |
|----|-------------|----------|------------|
| FR-4.1 | Component MUST support PillarType.separator as a vertical divider | Could-have | Widget test: separator rendering |
| FR-4.2 | Separator MUST span full card height | Could-have | Widget test: height measurement |
| FR-4.3 | Separator MUST be reorderable like regular pillars | Could-have | Widget test: separator drag |
| FR-4.4 | Separator MUST use theme.dividerColor | Could-have | Unit test: color validation |

---

### FR-5: Styling & Theming

| ID | Requirement | Priority | Validation |
|----|-------------|----------|------------|
| FR-5.1 | TianGan characters MUST use colors from AppColors.zodiacGanColors | Must-have | Widget test: color mapping |
| FR-5.2 | DiZhi characters MUST use colors from AppColors.zodiacZhiColors | Must-have | Widget test: color mapping |
| FR-5.3 | Component MUST respect Theme.of(context) for backgrounds, text, dividers | Must-have | Widget test: theme integration |
| FR-5.4 | Component MUST support both light and dark themes without modification | Must-have | Widget test: theme switching |
| FR-5.5 | TianGan MUST use GoogleFonts.zhiMangXing (fontSize: 28) | Must-have | Widget test: font validation |
| FR-5.6 | DiZhi MUST use GoogleFonts.longCang (fontSize: 28) | Must-have | Widget test: font validation |
| FR-5.7 | Component MUST maintain minimum width of 240px, maximum 420px | Must-have | Widget test: constraints |

---

### FR-6: Data Integration

| ID | Requirement | Priority | Validation |
|----|-------------|----------|------------|
| FR-6.1 | Component MUST accept EightChars model as primary data input | Must-have | Unit test: data binding |
| FR-6.2 | Component MUST compute row values from EightChars model (NaYin, KongWang, XunShou) | Must-have | Unit test: derived values |
| FR-6.3 | Component MUST accept optional TaiYuanModel for Tai Yuan pillar | Must-have | Unit test: optional data |
| FR-6.4 | Component MUST accept optional JiaZi for Ke pillar | Must-have | Unit test: optional data |
| FR-6.5 | Component MUST expose onChange callback with EditableFourZhuCardConfig | Must-have | Integration test: callback |
| FR-6.6 | Component MUST accept initialConfig for restoration | Must-have | Unit test: initialization |

---

### FR-7: Interaction Behaviors

| ID | Requirement | Priority | Validation |
|----|-------------|----------|------------|
| FR-7.1 | Drag operations MUST show translucent feedback widget | Must-have | Widget test: feedback opacity |
| FR-7.2 | Drop targets MUST show visual highlights (border or background change) | Must-have | Widget test: highlight state |
| FR-7.3 | Invalid drop areas MUST show clear rejection (red border or icon) | Must-have | Widget test: rejection state |
| FR-7.4 | All animations MUST complete within 300ms | Must-have | Performance test |
| FR-7.5 | Component MUST maintain 60 FPS during drag operations | Must-have | Performance test |
| FR-7.6 | Component MUST support both touch and mouse/trackpad input | Must-have | Integration test: input methods |
| FR-7.7 | Component MUST prevent drag beyond card boundaries | Must-have | Widget test: boundary constraints |

---

### FR-8: Accessibility

| ID | Requirement | Priority | Validation |
|----|-------------|----------|------------|
| FR-8.1 | All interactive elements MUST have minimum 48x48 dp touch target | Should-have | Widget test: semantics |
| FR-8.2 | Drag handles MUST have semantic labels (e.g., "Reorder pillar") | Should-have | Widget test: semantics |
| FR-8.3 | Delete buttons MUST have confirmation dialogs for destructive actions | Should-have | Widget test: confirmation |
| FR-8.4 | Component MUST support keyboard navigation (tab, arrow keys) | Could-have | Integration test: keyboard |

---

## Non-Functional Requirements

### NFR-1: Performance

| ID | Requirement | Target | Measurement Method |
|----|-------------|--------|-------------------|
| NFR-1.1 | Component initialization MUST complete within 100ms | < 100ms | Performance profiling |
| NFR-1.2 | Drag-and-drop operations MUST maintain 60 FPS | ≥ 60 FPS | Flutter DevTools frame rate |
| NFR-1.3 | Memory usage MUST NOT exceed 20MB per component instance | < 20MB | Memory profiler |
| NFR-1.4 | Component rebuild MUST complete within 16ms (1 frame) | < 16ms | Timeline analysis |

### NFR-2: Compatibility

| ID | Requirement | Details |
|----|-------------|---------|
| NFR-2.1 | Component MUST support Flutter SDK 3.0.2+ | Minimum version constraint |
| NFR-2.2 | Component MUST work on Android 5.0+ (API 21+) | Platform compatibility |
| NFR-2.3 | Component MUST work on iOS 11.0+ | Platform compatibility |
| NFR-2.4 | Component MUST work on web (Chrome, Firefox, Safari) | Web platform support |
| NFR-2.5 | Component MUST NOT introduce new dependencies | Use existing common module deps |

### NFR-3: Maintainability

| ID | Requirement | Details |
|----|-------------|---------|
| NFR-3.1 | Code MUST follow Flutter/Dart style guide | flutter analyze passes |
| NFR-3.2 | All public APIs MUST have documentation comments | dartdoc coverage ≥ 90% |
| NFR-3.3 | Component MUST have unit test coverage ≥ 85% | Unit tests for all logic |
| NFR-3.4 | Component MUST have widget tests for all interactions | Golden tests for visual regression |
| NFR-3.5 | Complex logic MUST be extracted to testable utility functions | Single Responsibility Principle |

### NFR-4: Scalability

| ID | Requirement | Details |
|----|-------------|---------|
| NFR-4.1 | Component MUST handle 8 pillars without performance degradation | Stress test |
| NFR-4.2 | Component MUST handle 15 rows without performance degradation | Stress test |
| NFR-4.3 | Component MUST support rendering multiple instances on one screen (≥ 3) | Integration test |

### NFR-5: Usability

| ID | Requirement | Details |
|----|-------------|---------|
| NFR-5.1 | Editing operations MUST have < 2 second learning curve | User testing |
| NFR-5.2 | Error states MUST provide clear, actionable messages | Error message review |
| NFR-5.3 | Component MUST provide haptic feedback on drag start/end (mobile) | UX testing |

---

## Technical Specifications

### Architecture

```
EditableFourZhuCard (StatefulWidget)
│
├── EditableFourZhuCardState
│   ├── _pillars: List<PillarConfig>
│   ├── _rows: List<RowConfig>
│   ├── _draggedPillarIndex: int?
│   ├── _draggedRowIndex: int?
│   └── _hoverIndex: int?
│
├── View Mode Rendering
│   └── _buildViewMode()
│       ├── _buildPillarHeaders()
│       ├── _buildRows()
│       └── _buildRow(RowConfig)
│
└── Edit Mode Rendering
    └── _buildEditMode()
        ├── _buildDraggablePillarHeaders()
        ├── _buildDraggableRows()
        ├── _buildPillarDragTarget()
        ├── _buildRowDragTarget()
        └── _buildAddPillarButton()
```

### Key Components

#### 1. EditableFourZhuCard (Main Widget)

```dart
class EditableFourZhuCard extends StatefulWidget {
  /// Primary data source for eight characters
  final EightChars eightChars;

  /// Optional Tai Yuan data
  final TaiYuanModel? taiYuan;

  /// Optional Ke (quarter hour) data
  final JiaZi? keZhu;

  /// Controls edit mode vs view mode
  final bool isEditable;

  /// Initial layout configuration
  final EditableFourZhuCardConfig? initialConfig;

  /// Callback when configuration changes
  final void Function(EditableFourZhuCardConfig config)? onConfigChanged;

  /// Theme customization
  final TextStyle? tianGanTextStyle;
  final TextStyle? diZhiTextStyle;
  final TextStyle? labelTextStyle;

  const EditableFourZhuCard({
    Key? key,
    required this.eightChars,
    this.taiYuan,
    this.keZhu,
    this.isEditable = false,
    this.initialConfig,
    this.onConfigChanged,
    this.tianGanTextStyle,
    this.diZhiTextStyle,
    this.labelTextStyle,
  }) : super(key: key);
}
```

#### 2. EditableFourZhuCardConfig (Configuration Model)

```dart
@JsonSerializable()
class EditableFourZhuCardConfig extends Equatable {
  final List<PillarConfig> pillars;
  final List<RowConfig> rows;

  const EditableFourZhuCardConfig({
    required this.pillars,
    required this.rows,
  });

  factory EditableFourZhuCardConfig.fromJson(Map<String, dynamic> json) =>
      _$EditableFourZhuCardConfigFromJson(json);

  Map<String, dynamic> toJson() => _$EditableFourZhuCardConfigToJson(this);

  /// Default configuration (Year, Month, Day, Hour pillars + 4 standard rows)
  factory EditableFourZhuCardConfig.standard() {
    return EditableFourZhuCardConfig(
      pillars: [
        PillarConfig(id: 'year', type: PillarType.year, order: 0, isVisible: true),
        PillarConfig(id: 'month', type: PillarType.month, order: 1, isVisible: true),
        PillarConfig(id: 'day', type: PillarType.day, order: 2, isVisible: true),
        PillarConfig(id: 'hour', type: PillarType.hour, order: 3, isVisible: true),
      ],
      rows: [
        RowConfig(id: 'tianGan', type: RowType.heavenlyStem, order: 0, isVisible: true, showLabel: true),
        RowConfig(id: 'diZhi', type: RowType.earthlyBranch, order: 1, isVisible: true, showLabel: true),
        RowConfig(id: 'shiShen', type: RowType.tenGod, order: 2, isVisible: true, showLabel: true),
        RowConfig(id: 'naYin', type: RowType.naYin, order: 3, isVisible: true, showLabel: true),
      ],
    );
  }

  @override
  List<Object?> get props => [pillars, rows];
}
```

#### 3. PillarConfig (Pillar Configuration)

```dart
@JsonSerializable()
class PillarConfig extends Equatable {
  final String id; // Unique identifier (e.g., "year", "dayun_1")
  final PillarType type;
  final int order; // Display order (0-indexed)
  final bool isVisible;
  final JiaZi? jiaZi; // Optional override for custom pillars

  const PillarConfig({
    required this.id,
    required this.type,
    required this.order,
    this.isVisible = true,
    this.jiaZi,
  });

  factory PillarConfig.fromJson(Map<String, dynamic> json) =>
      _$PillarConfigFromJson(json);

  Map<String, dynamic> toJson() => _$PillarConfigToJson(this);

  PillarConfig copyWith({
    String? id,
    PillarType? type,
    int? order,
    bool? isVisible,
    JiaZi? jiaZi,
  }) {
    return PillarConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
      jiaZi: jiaZi ?? this.jiaZi,
    );
  }

  @override
  List<Object?> get props => [id, type, order, isVisible, jiaZi];
}
```

#### 4. RowConfig (Row Configuration)

```dart
@JsonSerializable()
class RowConfig extends Equatable {
  final String id;
  final RowType type;
  final int order;
  final bool isVisible;
  final bool showLabel; // Whether to show row label
  final TextStyle? textStyle; // Optional custom styling
  final BorderType? borderType; // Row separator style

  const RowConfig({
    required this.id,
    required this.type,
    required this.order,
    this.isVisible = true,
    this.showLabel = true,
    this.textStyle,
    this.borderType,
  });

  factory RowConfig.fromJson(Map<String, dynamic> json) =>
      _$RowConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RowConfigToJson(this);

  RowConfig copyWith({
    String? id,
    RowType? type,
    int? order,
    bool? isVisible,
    bool? showLabel,
    TextStyle? textStyle,
    BorderType? borderType,
  }) {
    return RowConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
      showLabel: showLabel ?? this.showLabel,
      textStyle: textStyle ?? this.textStyle,
      borderType: borderType ?? this.borderType,
    );
  }

  @override
  List<Object?> get props => [id, type, order, isVisible, showLabel, textStyle, borderType];
}
```

### Drag-and-Drop Implementation

#### Problem: ReorderableListView Limitation
`ReorderableListView` only supports single-axis reordering. We need bidirectional dragging:
- Horizontal: Pillar reordering
- Vertical: Row reordering

#### Solution: Custom Draggable + DragTarget System

```dart
// Pillar Drag Implementation
Widget _buildDraggablePillar(PillarConfig pillar, int index) {
  return DragTarget<PillarDragData>(
    onWillAccept: (data) => data != null,
    onAccept: (data) {
      _handlePillarReorder(data.fromIndex, index);
    },
    builder: (context, candidateData, rejectedData) {
      return LongPressDraggable<PillarDragData>(
        data: PillarDragData(pillar: pillar, fromIndex: index),
        feedback: _buildPillarFeedback(pillar),
        childWhenDragging: _buildPillarPlaceholder(),
        onDragStarted: () => _onDragStart(index, DragAxis.horizontal),
        onDragEnd: (details) => _onDragEnd(),
        child: _buildPillarColumn(pillar, index),
      );
    },
  );
}

// Row Drag Implementation
Widget _buildDraggableRow(RowConfig row, int index) {
  return DragTarget<RowDragData>(
    onWillAccept: (data) => data != null,
    onAccept: (data) {
      _handleRowReorder(data.fromIndex, index);
    },
    builder: (context, candidateData, rejectedData) {
      return LongPressDraggable<RowDragData>(
        data: RowDragData(row: row, fromIndex: index),
        feedback: _buildRowFeedback(row),
        childWhenDragging: _buildRowPlaceholder(),
        onDragStarted: () => _onDragStart(index, DragAxis.vertical),
        onDragEnd: (details) => _onDragEnd(),
        child: _buildRowContent(row, index),
      );
    },
  );
}

// Drag data classes
class PillarDragData {
  final PillarConfig pillar;
  final int fromIndex;
  const PillarDragData({required this.pillar, required this.fromIndex});
}

class RowDragData {
  final RowConfig row;
  final int fromIndex;
  const RowDragData({required this.row, required this.fromIndex});
}

enum DragAxis { horizontal, vertical }
```

### State Management

```dart
class _EditableFourZhuCardState extends State<EditableFourZhuCard> {
  late List<PillarConfig> _pillars;
  late List<RowConfig> _rows;

  int? _draggedPillarIndex;
  int? _draggedRowIndex;
  DragAxis? _currentDragAxis;

  @override
  void initState() {
    super.initState();
    _initializeConfiguration();
  }

  void _initializeConfiguration() {
    final config = widget.initialConfig ?? EditableFourZhuCardConfig.standard();
    _pillars = List.from(config.pillars);
    _rows = List.from(config.rows);
  }

  void _handlePillarReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex--;
      final pillar = _pillars.removeAt(oldIndex);
      _pillars.insert(newIndex, pillar);
      _updatePillarOrders();
      _notifyConfigChanged();
    });
  }

  void _handleRowReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex--;
      final row = _rows.removeAt(oldIndex);
      _rows.insert(newIndex, row);
      _updateRowOrders();
      _notifyConfigChanged();
    });
  }

  void _updatePillarOrders() {
    for (int i = 0; i < _pillars.length; i++) {
      _pillars[i] = _pillars[i].copyWith(order: i);
    }
  }

  void _updateRowOrders() {
    for (int i = 0; i < _rows.length; i++) {
      _rows[i] = _rows[i].copyWith(order: i);
    }
  }

  void _notifyConfigChanged() {
    widget.onConfigChanged?.call(
      EditableFourZhuCardConfig(pillars: _pillars, rows: _rows),
    );
  }
}
```

### Integration with PillarPalette

```dart
// In EditableFourZhuCard, accept external pillar drops
Widget _buildEditMode() {
  return DragTarget<PillarData>(
    onWillAccept: (data) => data != null && _pillars.length < 8,
    onAccept: (pillarData) {
      _handleExternalPillarAdd(pillarData);
    },
    builder: (context, candidateData, rejectedData) {
      return Container(
        decoration: BoxDecoration(
          border: candidateData.isNotEmpty
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: _buildCardContent(),
      );
    },
  );
}

void _handleExternalPillarAdd(PillarData pillarData) {
  setState(() {
    final newPillar = PillarConfig(
      id: '${pillarData.pillarId}_${DateTime.now().millisecondsSinceEpoch}',
      type: _pillarTypeFromId(pillarData.pillarId),
      order: _pillars.length,
      jiaZi: pillarData.jiaZi,
    );
    _pillars.add(newPillar);
    _notifyConfigChanged();
  });
}

PillarType _pillarTypeFromId(String pillarId) {
  // Map pillar IDs to PillarType enum
  switch (pillarId) {
    case 'year': return PillarType.year;
    case 'month': return PillarType.month;
    case 'day': return PillarType.day;
    case 'time': return PillarType.hour;
    case 'taiyuan': return PillarType.taiMeta;
    case 'dayun': return PillarType.luckCycle;
    case 'liunian': return PillarType.annual;
    default: return PillarType.year; // fallback
  }
}
```

### File Structure

```
lib/widgets/
├── editable_four_zhu_card.dart              # Main component
├── editable_four_zhu_card_config.dart       # Configuration model
├── editable_four_zhu_card_config.g.dart     # Generated JSON serialization
├── pillar_config.dart                       # Pillar configuration model
├── pillar_config.g.dart                     # Generated JSON serialization
├── row_config.dart                          # Row configuration model
├── row_config.g.dart                        # Generated JSON serialization
└── editable_four_zhu_card/                  # Internal components
    ├── pillar_column.dart                   # Pillar column rendering
    ├── row_renderer.dart                    # Row rendering logic
    ├── drag_feedback_widgets.dart           # Drag feedback visuals
    └── pillar_add_menu.dart                 # Add pillar menu

lib/utils/
└── eight_chars_helpers.dart                 # Utility functions for row data extraction
```

---

## UI/UX Design

### Visual Layout

#### View Mode
```
┌─────────────────────────────────────────────────┐
│                     四柱                         │
├─────────────────────────────────────────────────┤
│              年      月      日      时           │
├─────────────────────────────────────────────────┤
│  天干        甲      乙      丙      丁           │
│  地支        子      丑      寅      卯           │
│  十神        正官    偏印    食神    劫财         │
│  纳音        海中金  炉中火  大溪水  沙中土       │
└─────────────────────────────────────────────────┘
```

#### Edit Mode
```
┌─────────────────────────────────────────────────┐
│  [☰] 四柱        [年]   [月]   [日]   [时]   [+] │ ← Title row with add button
├─────────────────────────────────────────────────┤
│  [👁] [☰] 天干   甲     乙     丙     丁     [x]  │ ← Eye toggle, drag handle, delete
│  [👁] [☰] 地支   子     丑     寅     卯     [x]  │
│  [👁] [☰] 十神   正官   偏印   食神   劫财   [x]  │
│  [👁] [☰] 纳音   海中金 炉中火 大溪水 沙中土 [x]  │
└─────────────────────────────────────────────────┘
                                               ↑
                                        Delete pillar button
```

### Interaction States

#### 1. Pillar Drag States

**Idle State:**
- Normal card appearance
- Drag handle visible but subtle (gray)

**Hover State (mouse only):**
- Drag handle changes color to primary
- Cursor changes to grab hand

**Dragging State:**
- Dragged pillar shows translucent feedback (80% opacity)
- Original position shows placeholder (dashed border box)
- Other pillars shift horizontally to indicate drop zones
- Drop zones show highlight (light primary color background)

**Drop Success:**
- Pillar animates to new position (cubic ease-out, 250ms)
- Haptic feedback on mobile (medium impact)

**Drop Rejection:**
- Pillar animates back to original position (spring animation)
- Red flash on invalid drop area

#### 2. Row Drag States

Similar to pillar drag, but vertical axis.

#### 3. Delete Confirmation

**Trigger:** Tap delete button (X icon)

**Dialog:**
```
┌──────────────────────────────┐
│  删除柱位                     │
├──────────────────────────────┤
│  确定要删除「月柱」吗?        │
│  此操作无法撤销。             │
│                              │
│      [取消]      [确定]       │
└──────────────────────────────┘
```

#### 4. Add Pillar Menu

**Trigger:** Tap "+" button

**Menu:**
```
┌──────────────────────────────┐
│  添加柱位                     │
├──────────────────────────────┤
│  ☑ 年柱   (已添加)            │
│  ☐ 胎元                       │
│  ☐ 命宫                       │
│  ☐ 大运                       │
│  ☐ 流年                       │
│  ☐ 流月                       │
│  ☐ 流日                       │
│  ☐ 流时                       │
│  ☐ 分隔符                     │
└──────────────────────────────┘
```

### Animations

| Interaction | Animation Type | Duration | Easing |
|-------------|----------------|----------|--------|
| Mode switch (view ↔ edit) | Fade + slide | 300ms | Cubic ease-in-out |
| Pillar reorder | Position shift | 250ms | Cubic ease-out |
| Row reorder | Position shift | 250ms | Cubic ease-out |
| Delete pillar | Fade + shrink | 200ms | Linear |
| Add pillar | Expand + fade-in | 250ms | Cubic ease-out |
| Drag feedback | Follow cursor | Realtime | No easing |
| Row visibility toggle | Height collapse/expand | 200ms | Cubic ease-in-out |

### Responsive Behavior

| Screen Width | Behavior |
|--------------|----------|
| < 360px | Minimum width enforced (240px), horizontal scroll if needed |
| 360-600px | Card fits screen width, text sizes maintained |
| 600-900px | Card centered, maximum width 420px |
| > 900px | Card centered, maximum width 420px |

### Accessibility

#### Semantic Labels
- Drag handles: "Reorder [pillar/row name]"
- Delete buttons: "Delete [pillar name]"
- Add button: "Add pillar"
- Eye toggle: "Toggle visibility of [row name]"

#### Touch Targets
- Minimum size: 48x48 dp
- Drag handles: 48x48 dp (visible icon may be smaller, but touch area padded)
- Delete buttons: 48x48 dp

#### Screen Reader Support
- Announce drag start: "Dragging [pillar name]"
- Announce drop: "Moved [pillar name] to position [X]"
- Announce delete: "Deleted [pillar name]"
- Announce row toggle: "Hidden [row name]" / "Shown [row name]"

---

## Data Models

### Complete Data Model Hierarchy

```
EditableFourZhuCardConfig
├── List<PillarConfig> pillars
│   ├── String id
│   ├── PillarType type
│   ├── int order
│   ├── bool isVisible
│   └── JiaZi? jiaZi (optional)
│
└── List<RowConfig> rows
    ├── String id
    ├── RowType type
    ├── int order
    ├── bool isVisible
    ├── bool showLabel
    ├── TextStyle? textStyle (optional)
    └── BorderType? borderType (optional)
```

### Enums (Existing in Codebase)

**PillarType** (from `layout_template_enums.dart`):
- year, month, day, hour, ke
- taiMeta, taiMonth, taiDay
- lifeHouse, luckCycle
- annual, monthly, daily, hourly
- separator

**RowType** (from `layout_template_enums.dart`):
- heavenlyStem, earthlyBranch, tenGod, naYin
- kongWang, xunShou
- hiddenStems, hiddenStemsTenGod
- hiddenStemsPrimary, hiddenStemsSecondary, hiddenStemsTertiary
- hiddenStemsPrimaryGods, hiddenStemsSecondaryGods, hiddenStemsTertiaryGods
- starYun, selfSiting

**BorderType** (from `layout_template_enums.dart`):
- solid, dashed, dotted, none

### Example Configuration JSON

```json
{
  "pillars": [
    {
      "id": "year",
      "type": "year",
      "order": 0,
      "isVisible": true
    },
    {
      "id": "month",
      "type": "month",
      "order": 1,
      "isVisible": true
    },
    {
      "id": "day",
      "type": "day",
      "order": 2,
      "isVisible": true
    },
    {
      "id": "hour",
      "type": "hour",
      "order": 3,
      "isVisible": true
    },
    {
      "id": "separator_1",
      "type": "separator",
      "order": 4,
      "isVisible": true
    },
    {
      "id": "taiyuan",
      "type": "taiMeta",
      "order": 5,
      "isVisible": true,
      "jiaZi": {
        "tianGan": "JIA",
        "diZhi": "ZI"
      }
    }
  ],
  "rows": [
    {
      "id": "tianGan",
      "type": "heavenlyStem",
      "order": 0,
      "isVisible": true,
      "showLabel": true
    },
    {
      "id": "diZhi",
      "type": "earthlyBranch",
      "order": 1,
      "isVisible": true,
      "showLabel": true
    },
    {
      "id": "shiShen",
      "type": "tenGod",
      "order": 2,
      "isVisible": true,
      "showLabel": true
    },
    {
      "id": "naYin",
      "type": "naYin",
      "order": 3,
      "isVisible": true,
      "showLabel": true
    },
    {
      "id": "xunShou",
      "type": "xunShou",
      "order": 4,
      "isVisible": false,
      "showLabel": true
    }
  ]
}
```

---

## Implementation Plan

### Phase 1: Foundation (Week 1)

**Milestone M1: Core Models & Basic Display**

**Tasks:**
1. Create data models (PillarConfig, RowConfig, EditableFourZhuCardConfig)
2. Implement JSON serialization with `@JsonSerializable()`
3. Create EditableFourZhuCard widget scaffold (StatefulWidget)
4. Implement view mode rendering (static display, parity with FourZhuEightCharsCard)
5. Add theme integration and Five Elements color mapping
6. Write unit tests for data models

**Deliverables:**
- `pillar_config.dart` + `.g.dart`
- `row_config.dart` + `.g.dart`
- `editable_four_zhu_card_config.dart` + `.g.dart`
- `editable_four_zhu_card.dart` (view mode only)
- Unit tests (≥ 80% coverage)

**Acceptance Criteria:**
- Component displays correctly in view mode
- Matches FourZhuEightCharsCard visual appearance
- Configuration models serialize/deserialize correctly
- All tests pass

---

### Phase 2: Edit Mode UI (Week 2)

**Milestone M2: Edit Mode Layout & Controls**

**Tasks:**
1. Implement edit mode layout (add drag handles, delete buttons, add button)
2. Create mode switching logic (isEditable parameter)
3. Add visual affordances (icons, hover states)
4. Implement add pillar menu UI
5. Implement row visibility toggle UI
6. Add animations for mode switching
7. Write widget tests for edit mode rendering

**Deliverables:**
- Edit mode UI complete
- Add pillar menu component
- Row visibility toggle buttons
- Widget tests for edit mode

**Acceptance Criteria:**
- Edit mode shows all controls correctly
- Mode switching animates smoothly
- Add pillar menu lists available pillar types
- Visibility toggles show correct icon states
- Widget tests validate UI structure

---

### Phase 3: Pillar Drag-and-Drop (Week 3)

**Milestone M3: Horizontal Pillar Reordering**

**Tasks:**
1. Implement custom Draggable for pillars
2. Implement DragTarget for pillar drop zones
3. Create drag feedback widget
4. Implement reorder logic (_handlePillarReorder)
5. Add animations for drag, drop, and snap
6. Handle edge cases (drag beyond bounds, invalid drops)
7. Write widget tests for pillar dragging

**Deliverables:**
- Working pillar drag-and-drop
- Smooth drag animations
- Edge case handling
- Widget tests for drag interactions

**Acceptance Criteria:**
- Pillars can be reordered via drag-and-drop
- Drag feedback follows cursor smoothly (60 FPS)
- Drop zones highlight correctly
- Invalid drops are rejected with visual feedback
- Pillar order updates in state and triggers onConfigChanged

---

### Phase 4: Row Drag-and-Drop (Week 4)

**Milestone M4: Vertical Row Reordering**

**Tasks:**
1. Implement custom Draggable for rows
2. Implement DragTarget for row drop zones
3. Create row drag feedback widget
4. Implement reorder logic (_handleRowReorder)
5. Ensure pillar and row dragging do not conflict
6. Add animations for row dragging
7. Write widget tests for row dragging

**Deliverables:**
- Working row drag-and-drop
- Bidirectional dragging (pillars + rows) without conflicts
- Widget tests for row interactions

**Acceptance Criteria:**
- Rows can be reordered via drag-and-drop
- Row dragging does not interfere with pillar dragging
- Drag feedback and animations are smooth
- Row order updates in state and triggers onConfigChanged

---

### Phase 5: Pillar Management (Week 5)

**Milestone M5: Add, Delete, External Drag**

**Tasks:**
1. Implement add pillar functionality (from menu)
2. Implement delete pillar functionality (with confirmation)
3. Integrate with PillarPalette (accept external DragTarget<PillarData>)
4. Handle pillar count constraints (1-8 pillars)
5. Add undo/redo support (optional, via parent state management)
6. Write integration tests for pillar management

**Deliverables:**
- Add pillar from menu working
- Delete pillar with confirmation working
- External pillar drag from PillarPalette working
- Integration tests

**Acceptance Criteria:**
- Tapping "+" opens menu, selecting pillar adds it
- Tapping delete shows confirmation, confirming removes pillar
- Dragging from PillarPalette to card adds pillar at correct position
- Pillar count constraints enforced (cannot delete last pillar, cannot add beyond 8)

---

### Phase 6: Row Management (Week 6)

**Milestone M6: Row Visibility & Addition**

**Tasks:**
1. Implement row visibility toggle functionality
2. Implement add row functionality (from menu)
3. Handle row visibility constraints (minimum 2 visible rows)
4. Add animations for row show/hide (height collapse/expand)
5. Write widget tests for row management

**Deliverables:**
- Row visibility toggle working
- Add row functionality working
- Widget tests for row management

**Acceptance Criteria:**
- Tapping eye icon toggles row visibility with animation
- Hidden rows do not occupy layout space
- Minimum 2 visible rows enforced
- Add row menu lists available row types (excluding already visible)

---

### Phase 7: Polish & Optimization (Week 7)

**Milestone M7: Performance, Accessibility, Edge Cases**

**Tasks:**
1. Performance optimization (rebuild minimization, key management)
2. Add accessibility features (semantic labels, touch targets, screen reader support)
3. Add haptic feedback for mobile
4. Handle edge cases (empty data, malformed config, rapid drag operations)
5. Add error boundaries and graceful degradation
6. Write performance tests

**Deliverables:**
- Performance optimizations
- Accessibility enhancements
- Edge case handling
- Performance tests

**Acceptance Criteria:**
- Component maintains 60 FPS during all interactions
- All interactive elements have ≥ 48dp touch targets
- Screen readers announce interactions correctly
- Edge cases handled gracefully without crashes

---

### Phase 8: Testing & Documentation (Week 8)

**Milestone M8: Comprehensive Testing & Documentation**

**Tasks:**
1. Achieve ≥ 85% unit test coverage
2. Write integration tests for end-to-end workflows
3. Create golden tests for visual regression
4. Write dartdoc comments for all public APIs
5. Create usage examples and integration guide
6. Update CLAUDE.md with component usage instructions

**Deliverables:**
- Test suite (unit, widget, integration, golden)
- API documentation
- Usage examples
- Updated CLAUDE.md

**Acceptance Criteria:**
- Test coverage ≥ 85%
- All public APIs documented
- At least 3 usage examples provided
- Documentation reviewed and approved

---

### Phase 9: Integration & Migration (Week 9-10)

**Milestone M9: Integrate with Existing Pages**

**Tasks:**
1. Update LayoutEditorPage to use EditableFourZhuCard (optional migration)
2. Create example usage in example app
3. Test with real EightChars data from divination modules
4. Gather feedback from team and iterate
5. Prepare release notes

**Deliverables:**
- Example app integration
- LayoutEditorPage migration (optional)
- Release notes

**Acceptance Criteria:**
- EditableFourZhuCard works correctly in example app
- No regressions in existing FourZhuEightCharsCard usage
- Positive feedback from team on usability

---

## Testing Strategy

### Unit Tests

**Coverage Target:** ≥ 85%

**Test Files:**
- `pillar_config_test.dart`: JSON serialization, copyWith, equality
- `row_config_test.dart`: JSON serialization, copyWith, equality
- `editable_four_zhu_card_config_test.dart`: Standard factory, serialization, validation
- `eight_chars_helpers_test.dart`: Row data extraction logic

**Key Test Cases:**
- Configuration serialization/deserialization round-trip
- Default configuration correctness
- Pillar/row reordering logic
- Order update after reorder
- Pillar/row count constraints

---

### Widget Tests

**Coverage Target:** All interactive elements

**Test Files:**
- `editable_four_zhu_card_test.dart`: Main component widget tests
- `editable_four_zhu_card_edit_mode_test.dart`: Edit mode specific tests

**Key Test Cases:**
1. **View Mode Rendering:**
   - Displays pillars correctly
   - Displays rows correctly
   - Hides edit controls
   - Applies Five Elements colors

2. **Edit Mode Rendering:**
   - Shows drag handles
   - Shows delete buttons
   - Shows add button
   - Shows visibility toggle buttons

3. **Mode Switching:**
   - Switching from view to edit mode
   - Switching from edit to view mode
   - Animation completion

4. **Pillar Dragging:**
   - Drag start detection
   - Drag feedback visibility
   - Drop zone highlighting
   - Successful drop and reorder
   - Invalid drop rejection

5. **Row Dragging:**
   - Similar to pillar dragging but vertical axis

6. **Pillar Management:**
   - Add pillar via menu
   - Delete pillar with confirmation
   - Accept external pillar from PillarPalette

7. **Row Management:**
   - Toggle row visibility
   - Add row via menu
   - Enforce minimum visible rows

---

### Integration Tests

**Test Files:**
- `editable_four_zhu_card_integration_test.dart`

**Key Test Scenarios:**
1. **End-to-End Layout Customization:**
   - Start with default config
   - Add Tai Yuan pillar
   - Reorder pillars (move Day to front)
   - Hide NaYin row
   - Add XunShou row
   - Verify final configuration

2. **External Drag Integration:**
   - Drag pillar from PillarPalette
   - Drop onto EditableFourZhuCard
   - Verify pillar added correctly

3. **State Persistence:**
   - Modify configuration
   - Pass configuration to new widget instance
   - Verify state restored correctly

4. **Error Handling:**
   - Load malformed configuration
   - Verify graceful degradation
   - Verify error messages

---

### Golden Tests (Visual Regression)

**Test Files:**
- `editable_four_zhu_card_golden_test.dart`

**Test Cases:**
1. View mode - light theme
2. View mode - dark theme
3. Edit mode - light theme
4. Edit mode - dark theme
5. Pillar drag feedback
6. Row drag feedback
7. Add pillar menu
8. Delete confirmation dialog

---

### Performance Tests

**Test Files:**
- `editable_four_zhu_card_performance_test.dart`

**Metrics to Measure:**
1. Initial render time (< 100ms)
2. Rebuild time on state change (< 16ms)
3. Drag-and-drop frame rate (≥ 60 FPS)
4. Memory usage with 8 pillars + 15 rows (< 20MB)

**Tools:**
- Flutter DevTools Timeline
- `flutter drive --profile` for performance profiling
- Memory profiler

---

### Manual Testing Checklist

**Devices:**
- [ ] Android phone (mid-range, e.g., Pixel 5)
- [ ] Android tablet
- [ ] iOS phone (iPhone 12 or newer)
- [ ] iOS tablet (iPad)
- [ ] Web (Chrome, Firefox, Safari)

**Test Scenarios:**
- [ ] Drag pillar with touch
- [ ] Drag pillar with mouse
- [ ] Rapid drag operations (stress test)
- [ ] Delete all pillars except one (constraint enforcement)
- [ ] Add maximum 8 pillars
- [ ] Hide all rows except two (constraint enforcement)
- [ ] Switch theme while in edit mode
- [ ] Rotate device while dragging (mobile)

---

## Dependencies & Integration

### Internal Dependencies

| Dependency | Usage | Location |
|------------|-------|----------|
| `EightChars` | Primary data model for eight characters | `lib/models/eight_chars.dart` |
| `TaiYuanModel` | Optional Tai Yuan data | `lib/features/tai_yuan/tai_yuan_model.dart` |
| `JiaZi` | Pillar stem-branch data | `lib/enums/enum_jia_zi.dart` |
| `TianGan`, `DiZhi` | Five Elements mapping | `lib/enums/enum_tian_gan.dart`, `lib/enums/enum_di_zhi.dart` |
| `AppColors` | Five Elements color scheme | `lib/themes/gan_zhi_gua_colors.dart` |
| `PillarType`, `RowType`, `BorderType` | Layout enums | `lib/enums/layout_template_enums.dart` |
| `PillarData` | External drag data from PillarPalette | `lib/models/pillar_data.dart` |

### External Dependencies (Existing in common module)

| Package | Version | Usage |
|---------|---------|-------|
| `google_fonts` | ^6.2.1 | ZhiMangXing, LongCang fonts for Chinese characters |
| `json_annotation` | ^4.9.0 | JSON serialization annotations |
| `equatable` | ^2.0.7 | Value equality for data models |
| `flutter` | SDK 3.0.2+ | Core framework |

### Integration Points

#### 1. PillarPalette Integration
**File:** `lib/widgets/pillar_palette.dart`

**Integration:**
- PillarPalette already uses `Draggable<PillarData>`
- EditableFourZhuCard adds `DragTarget<PillarData>` acceptance
- No changes needed to PillarPalette component

**Code:**
```dart
// In EditableFourZhuCard
DragTarget<PillarData>(
  onAccept: (pillarData) {
    _handleExternalPillarAdd(pillarData);
  },
  builder: ...,
)
```

#### 2. LayoutEditorPage Integration
**File:** `lib/pages/layout_editor_page.dart`

**Migration Path:**
```dart
// BEFORE (current implementation)
ReorderableListView(
  scrollDirection: Axis.horizontal,
  children: <Widget>[
    for (int index = 0; index < _canvasPillars.length; index += 1)
      PillarCard(
        key: Key(_canvasPillars[index].pillarId),
        pillar: _canvasPillars[index],
        onDelete: () { ... },
      ),
  ],
  onReorder: (int oldIndex, int newIndex) { ... },
)

// AFTER (using EditableFourZhuCard)
EditableFourZhuCard(
  eightChars: _currentEightChars,
  isEditable: true,
  initialConfig: _savedConfig,
  onConfigChanged: (config) {
    setState(() {
      _savedConfig = config;
    });
  },
)
```

**Benefits:**
- Reduce LayoutEditorPage code by ~100 lines
- Remove manual DragTarget wrapper
- Remove manual ReorderableListView logic
- All editing handled by component

#### 3. State Management Integration

**Provider Pattern (Optional):**
```dart
// If using Provider for global layout config
class LayoutConfigProvider extends ChangeNotifier {
  EditableFourZhuCardConfig _config = EditableFourZhuCardConfig.standard();

  EditableFourZhuCardConfig get config => _config;

  void updateConfig(EditableFourZhuCardConfig newConfig) {
    _config = newConfig;
    notifyListeners();
    _saveToDatabase();
  }
}

// In widget
Consumer<LayoutConfigProvider>(
  builder: (context, provider, child) {
    return EditableFourZhuCard(
      eightChars: eightChars,
      isEditable: true,
      initialConfig: provider.config,
      onConfigChanged: provider.updateConfig,
    );
  },
)
```

---

## Risks & Mitigation

### Technical Risks

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|------------|--------|---------------------|
| **R1: Drag-and-drop performance issues on low-end devices** | Medium | High | - Profile early on low-end devices (Android API 21)<br>- Use RepaintBoundary for feedback widgets<br>- Minimize rebuilds during drag<br>- Consider disabling animations on low-end devices |
| **R2: Bidirectional dragging conflicts (horizontal + vertical)** | Medium | High | - Use separate DragData types (PillarDragData, RowDragData)<br>- Track current drag axis in state<br>- Disable cross-axis drop targets during drag<br>- Extensive widget testing for edge cases |
| **R3: Complex state management leading to bugs** | Medium | Medium | - Keep state simple (List<PillarConfig>, List<RowConfig>)<br>- Use immutable config objects with copyWith<br>- Write comprehensive unit tests for state transitions<br>- Add assertions for invariants (min pillars, min rows) |
| **R4: Integration issues with existing PillarPalette** | Low | Medium | - Verify PillarPalette drag data structure early<br>- Create integration test with real PillarPalette<br>- Maintain backward compatibility with PillarData model |
| **R5: JSON serialization issues with complex TextStyle** | Medium | Low | - Make TextStyle optional<br>- Provide sensible defaults<br>- Document limitation in API docs<br>- Consider custom JSON converter if needed |

---

### UX Risks

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|------------|--------|---------------------|
| **R6: Users accidentally delete pillars** | High | Medium | - Always show confirmation dialog for delete<br>- Add undo functionality (via parent state)<br>- Enforce minimum 1 pillar constraint<br>- Consider "trash bin" for recovery |
| **R7: Drag-and-drop not discoverable** | Medium | High | - Show tutorial overlay on first use<br>- Add subtle hint text in edit mode ("Drag to reorder")<br>- Ensure drag handles are visually obvious<br>- Provide alternative reorder via arrow buttons (accessibility) |
| **R8: Edit mode cluttered with too many controls** | Medium | Medium | - Use subtle, monochrome icons for controls<br>- Show controls on hover (desktop) or always visible (mobile)<br>- Group related controls (e.g., visibility + drag handle)<br>- Test with users for visual clarity |
| **R9: Performance perception issues (feels slow)** | Medium | High | - Ensure animations are < 300ms<br>- Provide immediate visual feedback (no lag)<br>- Add haptic feedback on mobile for tactile response<br>- Show loading states for async operations |

---

### Project Risks

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|------------|--------|---------------------|
| **R10: Scope creep (feature requests during development)** | High | Medium | - Lock requirements after Phase 2<br>- Defer non-essential features to "Future Enhancements"<br>- Use "Won't-have" category in user stories<br>- Time-box implementation phases strictly |
| **R11: Testing taking longer than estimated** | Medium | High | - Write tests incrementally during development<br>- Prioritize critical path tests first<br>- Use golden tests sparingly (only for key layouts)<br>- Automate test runs in CI/CD |
| **R12: Breaking changes to existing code** | Low | High | - Create new component alongside existing FourZhuEightCharsCard<br>- No modifications to existing components<br>- Add regression tests for existing components<br>- Document migration path clearly |
| **R13: Performance regression in existing code** | Low | Medium | - Run performance benchmarks before/after integration<br>- Profile memory usage and frame rates<br>- Use `flutter analyze` to catch potential issues<br>- Code review focusing on performance |

---

## Release Criteria

### Must-Have (Blocking Release)

- [ ] All Must-have user stories implemented and tested
- [ ] Unit test coverage ≥ 85%
- [ ] Widget tests for all interactive elements
- [ ] Integration test for end-to-end workflow
- [ ] Performance: 60 FPS on mid-range devices during drag operations
- [ ] No regressions in existing FourZhuEightCharsCard functionality
- [ ] API documentation complete (dartdoc comments)
- [ ] Code passes `flutter analyze` with 0 errors
- [ ] Manual testing completed on Android, iOS, Web
- [ ] Light/dark theme support verified
- [ ] Accessibility: Touch targets ≥ 48dp, semantic labels present

### Should-Have (Strongly Recommended)

- [ ] Row visibility toggle functionality
- [ ] Row reordering via drag-and-drop
- [ ] Golden tests for view/edit modes in both themes
- [ ] Example app integration
- [ ] LayoutEditorPage migration example
- [ ] Performance tests with automated benchmarks
- [ ] Haptic feedback on mobile devices

### Could-Have (Nice to Have)

- [ ] Pillar divider (separator) support
- [ ] Add custom row functionality
- [ ] Keyboard navigation support
- [ ] Undo/redo support
- [ ] Tutorial overlay for first-time users

### Won't-Have (Out of Scope)

- [ ] Row border style customization (solid/dashed/dotted)
- [ ] Multi-card selection and bulk operations
- [ ] Cloud sync for configurations
- [ ] AI-powered layout suggestions
- [ ] Export layout as image

---

## Future Enhancements

### Post-V1 Roadmap

#### V1.1: Enhanced Customization (Q1 2026)
- **Row border style picker** (solid, dashed, dotted, none)
- **Custom text style editor** for individual rows
- **Pillar width adjustment** (narrow, standard, wide)
- **Custom color overrides** for specific pillars/rows

#### V1.2: Advanced Interactions (Q2 2026)
- **Keyboard shortcuts** for power users (Ctrl+D to delete, arrow keys to reorder)
- **Undo/redo stack** with Ctrl+Z / Ctrl+Y support
- **Copy/paste pillar configurations** between cards
- **Preset templates** (quick apply common layouts)

#### V1.3: Collaboration Features (Q3 2026)
- **Layout sharing** (export/import JSON configs)
- **Cloud sync** for layout configurations
- **Template marketplace** (user-contributed layouts)
- **Version history** for layout configurations

#### V2.0: AI-Powered Features (Q4 2026)
- **Auto-layout suggestions** based on divination type
- **Smart row recommendations** based on pillar types
- **Layout optimization** (suggest reordering for better analysis flow)
- **Accessibility auto-fixes** (flag and fix accessibility issues)

---

## Appendix

### A. Design Mockup Reference

**File:** `docs/feature/eight_chars/card_template.png`

**Description:**
- Vertical pillar layout with 5 columns (label + 4 pillars)
- Rows: 天干, 十神, 地支, 旬首, 纳音, 戊寅, 成家
- Traditional Chinese calligraphy fonts
- Centered layout with "本命" title

**Key Differences from PRD:**
- PRD uses horizontal pillar labels (年月日时) instead of vertical names
- PRD includes edit mode controls (drag handles, delete buttons)
- PRD supports variable pillar count (4-8 vs fixed 4)

---

### B. Color Reference

#### Five Elements Color Mapping

**TianGan (Heavenly Stems):**
| Stem | Element | RGB | Hex | Description |
|------|---------|-----|-----|-------------|
| 甲, 乙 | Wood | (84, 150, 136) | #549686 | Copper Green (铜绿) |
| 丙, 丁 | Fire | (233, 84, 100) | #E95464 | Watermelon Red (西瓜红) |
| 戊, 己 | Earth | (168, 132, 98) | #A88462 | Camel (驼色) |
| 庚, 辛 | Metal | (240, 167, 46) | #F0A72E | Golden Leaf (黄金叶) |
| 壬, 癸 | Water | (39, 117, 182) | #2775B6 | Cloisonné Blue (景泰蓝) |

**DiZhi (Earthly Branches):**
| Branch | Element | RGB | Hex | Description |
|--------|---------|-----|-----|-------------|
| 子, 亥 | Water | (61, 89, 171) | #3D59AB | Sky Blue (天青色) |
| 寅, 卯 | Wood | (120, 146, 98) | #789262 | Pea Green (豆绿) |
| 巳, 午 | Fire | (205, 92, 92) | #CD5C5C | Cinnabar Orange (丹橙) |
| 申, 酉 | Metal | (242, 190, 69) | #F2BE45 | Red Gold (赤金) |
| 辰, 戌, 丑, 未 | Earth | (210, 180, 140) | #D2B48C | Tea Brown (茶色) |

---

### C. Font Reference

**TianGan Font:**
- **Family:** ZhiMangXing (致美星体)
- **Weight:** 200 (Light)
- **Size:** 28
- **Line Height:** 1.0
- **Source:** Google Fonts

**DiZhi Font:**
- **Family:** LongCang (龙藏体)
- **Weight:** 500 (Medium)
- **Size:** 28
- **Line Height:** 1.0
- **Source:** Google Fonts

**Label Font:**
- **Family:** ZhiMangXing (致美星体)
- **Weight:** 600 (Semi-bold)
- **Size:** 14
- **Line Height:** 1.0
- **Source:** Google Fonts

---

### D. Existing Component API Reference

#### FourZhuEightCharsCard (Current Component)

```dart
class FourZhuEightCharsCard extends StatelessWidget {
  final EightChars eightChars;
  final TaiYuanModel taiYuan;
  final JiaZi? keZhu;
  final bool showTaiYuan;
  final bool showXunShou;
  final bool showNaYin;
  final bool showKongWang;
  final bool showKe;

  FourZhuEightCharsCard({
    Key? key,
    required this.eightChars,
    required this.taiYuan,
    this.keZhu,
    this.showTaiYuan = false,
    this.showXunShou = false,
    this.showNaYin = false,
    this.showKongWang = false,
    this.showKe = false,
  }) : super(key: key);
}
```

**Key Differences in EditableFourZhuCard:**
- Adds `isEditable` parameter
- Adds `initialConfig` parameter
- Adds `onConfigChanged` callback
- Removes individual boolean flags (replaced by RowConfig visibility)

---

### E. Glossary

| Term | Chinese | Description |
|------|---------|-------------|
| BaZi | 八字 | Eight Characters - Chinese astrological system based on birth date/time |
| TianGan | 天干 | Heavenly Stems (10 celestial stems: 甲乙丙丁戊己庚辛壬癸) |
| DiZhi | 地支 | Earthly Branches (12 terrestrial branches: 子丑寅卯辰巳午未申酉戌亥) |
| JiaZi | 甲子 | Combination of one TianGan + one DiZhi (60 combinations total) |
| Four Pillars | 四柱 | Year, Month, Day, Hour pillars in BaZi |
| Pillar | 柱 | A column representing a time period (Year/Month/Day/Hour) |
| ShiShen / Ten Gods | 十神 | Ten relationships between stems (正官, 偏印, 食神, etc.) |
| NaYin | 纳音 | Hidden Tone - 60 combinations mapped to 30 elements |
| KongWang | 空亡 | Void - missing branches in a JiaZi cycle |
| XunShou | 旬首 | Cycle Header - first JiaZi in a 10-day cycle |
| Tai Yuan | 胎元 | Conception Pillar - calculated from birth month |
| Da Yun | 大运 | Major Luck Cycle - 10-year periods in destiny analysis |
| Liu Nian | 流年 | Annual Transit - current year's influence |
| Ke | 刻 | Quarter Hour - 1/8 of a traditional Chinese hour |

---

### F. References

**Codebase Files:**
- `lib/widgets/four_zhu_eight_chars_card.dart` - Current display component
- `lib/widgets/pillar_palette.dart` - Pillar drag source
- `lib/pages/layout_editor_page.dart` - Current editor implementation
- `lib/enums/layout_template_enums.dart` - PillarType, RowType enums
- `lib/models/pillar_data.dart` - Pillar data model
- `lib/themes/gan_zhi_gua_colors.dart` - Five Elements color scheme

**Flutter Documentation:**
- [Draggable & DragTarget](https://api.flutter.dev/flutter/widgets/Draggable-class.html)
- [AnimatedContainer](https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html)
- [Theme](https://api.flutter.dev/flutter/material/Theme-class.html)
- [Semantics](https://api.flutter.dev/flutter/widgets/Semantics-class.html)

**Design Inspiration:**
- Material Design 3 - Drag and Drop patterns
- Notion - Flexible block layouts
- Figma - Canvas interactions

---

### G. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-23 | Product Team | Initial PRD creation |

---

**Document Status:** Draft
**Next Review Date:** 2025-11-01
**Approvers:** Engineering Lead, Product Manager, UX Designer

---

*End of Product Requirements Document*
