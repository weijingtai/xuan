# Product Requirements Document: EditableFourZhuCard

## Document Information
- **Feature Name**: EditableFourZhuCard (可编辑四柱卡片组件)
- **Version**: 1.0
- **Date**: 2025-10-23
- **Author**: Product Team
- **Status**: Draft

---

## Executive Summary

EditableFourZhuCard is a unified, self-contained Flutter widget that combines display and editing capabilities for eight characters (八字) data in the xuan divination application. This component addresses the current pain point where users must use separate display and editing components with complex wrapper hierarchies to achieve basic editing functionality.

The new component will support:
- Seamless switching between view and edit modes
- Bidirectional drag-and-drop (horizontal for pillars, vertical for rows)
- Inline pillar and row management (add, remove, reorder, show/hide)
- Integration with existing pillar palette sidebar
- Customizable dividers between pillars and rows

---

## Problem Statement

### Current Issues

1. **Component Fragmentation**
   - `FourZhuEightCharsCard` is display-only with no interactive capabilities
   - `LayoutEditorPage` requires wrapping components in `ReorderableListView` + external `DragTarget`
   - Users must manage state across multiple components for basic editing

2. **Poor User Experience**
   - Switching from view to edit mode requires completely different UI components
   - External canvas containers (`PillarCard` wrappers) needed for drag-and-drop
   - Non-intuitive editing workflow

3. **Technical Debt**
   - Tight coupling between display and container components
   - Duplicate logic for rendering pillars in display vs. edit contexts
   - Difficult to maintain consistency across view and edit states

### User Pain Points

- "I want to quickly reorder pillars without entering a special edit mode"
- "I need to add dividers between certain pillars for visual organization"
- "The current editing experience feels clunky and disconnected from the display"

---

## Goals & Success Metrics

### Primary Goals

1. **Unified Component**: Single component handles both display and editing
2. **Self-Contained**: No external wrapper components required for editing
3. **Intuitive UX**: Drag-and-drop feels natural and responsive
4. **Backward Compatible**: New component coexists with existing code

### Success Metrics

- **Development**: Component can be integrated without breaking existing features
- **User Experience**: Editing operations require ≤3 user actions (vs. current 5-7)
- **Performance**: Drag-and-drop responds within 16ms (60fps)
- **Code Quality**: Test coverage ≥80% for component logic

### Non-Goals (Out of Scope)

- Replacing existing `FourZhuEightCharsCard` immediately (migration will be gradual)
- Supporting cross-widget dragging beyond pillar palette integration
- Advanced animations beyond standard Flutter drag feedback

---

## User Stories

### Epic 1: Unified View/Edit Experience

**US-1.1**: As a user, I want to view eight characters data in a clean card layout
- **Acceptance Criteria**:
  - Card displays pillars (年月日时) horizontally
  - Each pillar shows configurable rows (天干、地支、十神、纳音 by default)
  - Five elements color coding applies to tianGan and diZhi
  - Layout matches design mockup (docs/feature/eight_chars/card_template.png)

**US-1.2**: As a user, I want to toggle edit mode to reorganize pillars and rows
- **Acceptance Criteria**:
  - Edit mode controlled by `isEditable` parameter
  - In edit mode, drag handles appear on pillars and rows
  - Delete buttons (×) appear on pillar headers
  - Add button (+) appears in title row

### Epic 2: Pillar Management

**US-2.1**: As a user, I want to reorder pillars by dragging them horizontally
- **Acceptance Criteria**:
  - Can drag any pillar to any position (free dragging)
  - Visual feedback shows drag in progress (opacity/shadow)
  - Pillar snaps to nearest valid slot on release
  - Callback `onPillarReorder(oldIndex, newIndex)` fires with new order

**US-2.2**: As a user, I want to add new pillars from the pillar palette
- **Acceptance Criteria**:
  - Can drag from `PillarPalette` sidebar into card
  - DragTarget accepts new pillar and inserts at drop position
  - Supports adding 胎元、刻、命宫 and other pillar types
  - Parent component can provide custom pillar sources

**US-2.3**: As a user, I want to delete pillars I don't need
- **Acceptance Criteria**:
  - Delete button (×) appears on each pillar header in edit mode
  - Clicking delete triggers `onPillarDelete(index)` callback
  - Pillar removed with smooth animation

**US-2.4**: As a user, I want to insert dividers between pillars for visual grouping
- **Acceptance Criteria**:
  - Can add separator using `PillarType.separator`
  - Separator renders as vertical line or custom widget
  - Separator can be reordered like regular pillars

### Epic 3: Row Management

**US-3.1**: As a user, I want to reorder rows by dragging them vertically
- **Acceptance Criteria**:
  - Can drag any row to any position
  - All pillar data in that row moves together
  - Callback `onRowReorder(oldIndex, newIndex)` fires

**US-3.2**: As a user, I want to show/hide specific rows
- **Acceptance Criteria**:
  - Eye icon (👁) toggle next to each row in edit mode
  - Clicking toggle calls `onRowVisibilityChange(rowType, visible)`
  - Hidden rows are not rendered (not just opacity:0)

**US-3.3**: As a user, I want to insert dividers between rows
- **Acceptance Criteria**:
  - RowType enum extended with `separator` type
  - Separator renders as horizontal line or custom widget
  - Separator can be reordered like regular rows

### Epic 4: Customization

**US-4.1**: As a developer, I want to customize which rows are displayed by default
- **Acceptance Criteria**:
  - `defaultRows` parameter accepts `List<RowType>`
  - Defaults to `[tianGan, diZhi, shiShen, naYin]`
  - Order in list determines initial row order

**US-4.2**: As a developer, I want to provide custom styling for pillars and rows
- **Acceptance Criteria**:
  - `pillarBuilder` callback allows custom pillar rendering
  - `rowBuilder` callback allows custom row cell rendering
  - Falls back to default styling if builders not provided

---

## Functional Requirements

### FR-1: Component API

#### Constructor Parameters

```dart
EditableFourZhuCard({
  Key? key,
  required EightChars eightChars,           // Data source
  bool isEditable = false,                   // Edit mode toggle
  List<PillarConfig>? pillarOrder,          // Custom pillar sequence
  List<RowConfig>? rowConfigs,              // Custom row configurations

  // Callbacks
  ValueChanged<List<PillarConfig>>? onPillarOrderChanged,
  ValueChanged<int>? onPillarDelete,
  ValueChanged<PillarConfig>? onPillarAdd,
  ValueChanged<List<RowConfig>>? onRowConfigsChanged,

  // Customization
  PillarBuilder? pillarBuilder,
  RowCellBuilder? rowCellBuilder,
  Widget Function(BuildContext)? dividerBuilder,

  // Styling
  EdgeInsets? padding,
  Color? backgroundColor,
  double? elevation,
  BorderRadius? borderRadius,
})
```

#### Data Models

```dart
@immutable
class PillarConfig {
  final String id;                // Unique identifier (UUID)
  final PillarType type;          // 年/月/日/时/胎元/刻/separator
  final JiaZi? jiaZi;            // Null for separator type
  final bool isVisible;
  final int order;

  PillarConfig copyWith({...});
  @override bool operator ==(Object other);
  @override int get hashCode;
}

@immutable
class RowConfig {
  final String id;
  final RowType type;             // 天干/地支/十神/纳音/separator/etc.
  final bool isVisible;
  final bool showLabel;           // Show left label column
  final int order;
  final TextStyle? textStyle;

  RowConfig copyWith({...});
  @override bool operator ==(Object other);
  @override int get hashCode;
}

enum RowType {
  tianGan,        // 天干
  diZhi,          // 地支
  shiShen,        // 十神
  naYin,          // 纳音
  kongWang,       // 空亡
  xunShou,        // 旬首
  cangGan,        // 藏干
  separator,      // Divider
  // Add more as needed
}
```

### FR-2: Drag and Drop System

#### Pillar Dragging (Horizontal)

- **Implementation**: Custom `Draggable` + `DragTarget`
- **Behavior**:
  - Long press to initiate drag (configurable delay: 200ms)
  - Drag feedback shows semi-transparent pillar card
  - Drop zones highlight when draggable hovers over them
  - Snap to nearest slot based on horizontal position
- **Edge Cases**:
  - Cannot drag if only 1 pillar remains
  - Cannot drop on self (no-op)
  - Invalid drop targets reject and animate back

#### Row Dragging (Vertical)

- **Implementation**: Custom `Draggable` + `DragTarget`
- **Behavior**:
  - Drag handle (☰) on left side of each row
  - Drag affects entire row across all pillars
  - Drop zones appear between existing rows
  - Smooth animation when rows reorder
- **Edge Cases**:
  - Cannot drag separator rows (or make configurable)
  - Minimum 1 visible row must remain

#### Cross-Component Dragging

- **From Pillar Palette**:
  - `PillarPalette` provides `Draggable<PillarConfig>`
  - `EditableFourZhuCard` provides `DragTarget<PillarConfig>`
  - Parent component can listen to `onPillarAdd` callback
  - New pillar inserted at drop position

### FR-3: Edit Operations

#### Add Pillar
- Trigger: Drag from palette OR click (+) button in title
- Action: Insert new `PillarConfig` at specified index
- Validation: Check maximum pillar count (default: 10)

#### Delete Pillar
- Trigger: Click (×) button on pillar header
- Action: Remove `PillarConfig` from list
- Validation: Require at least 1 pillar remain

#### Toggle Row Visibility
- Trigger: Click eye icon (👁) next to row
- Action: Update `RowConfig.isVisible`
- Validation: Require at least 1 visible row

#### Insert Divider
- Trigger: Drag separator type from palette
- Action: Insert `PillarConfig(type: separator)` or `RowConfig(type: separator)`
- Rendering: Show vertical/horizontal line

### FR-4: View Mode Rendering

When `isEditable = false`:
- No drag handles visible
- No delete buttons
- No add buttons
- No row visibility toggles
- Cleaner, read-only appearance
- Maintain same layout and styling

---

## Technical Specifications

### Architecture

```
EditableFourZhuCard (StatefulWidget)
├── _EditableFourZhuCardState
│   ├── List<PillarConfig> _pillars
│   ├── List<RowConfig> _rows
│   ├── int? _draggedPillarIndex
│   ├── int? _draggedRowIndex
│   └── Methods:
│       ├── _buildPillarColumn()
│       ├── _buildRowCells()
│       ├── _handlePillarDragStart()
│       ├── _handlePillarDragEnd()
│       ├── _handleRowDragStart()
│       └── _handleRowDragEnd()
│
├── _PillarColumn (Draggable pillar)
│   ├── Header (title + delete button)
│   ├── Cell widgets (one per row)
│   └── LongPressDraggable wrapper
│
├── _RowDragHandle (left side drag handle)
│   └── Icon(Icons.drag_handle)
│
└── _DropZone (highlights on drag hover)
    └── DragTarget<PillarConfig | RowConfig>
```

### Dependencies

**Required**:
- `flutter/material.dart` - Core Flutter widgets
- `../../models/layout_template.dart` - PillarConfig, RowConfig
- `../../enums/layout_template_enums.dart` - PillarType, RowType
- `../../datamodel/eight_chars.dart` - EightChars data model
- `../../enums/enum_gan_zhi.dart` - TianGan, DiZhi

**Optional** (for enhanced features):
- `flutter_reorderable_list` - If we want smoother reordering
- `provider` - For shared state management if needed

### Platform Support

- Android: ✓ Full support
- iOS: ✓ Full support
- Web: ✓ Full support (with mouse/touch events)
- Desktop: ⚠️ Basic support (may need keyboard shortcuts)

### Performance Considerations

1. **Lazy Rendering**: Only render visible rows (use `isVisible` flag)
2. **Const Constructors**: Use `const` for static widgets where possible
3. **Key Management**: Assign stable keys to pillars and rows for efficient rebuilds
4. **Debouncing**: Debounce rapid drag events (if performance issues arise)

### Accessibility

- Drag handles: Semantic label "拖动以重新排序" (Drag to reorder)
- Delete buttons: Semantic label "删除此柱" (Delete this pillar)
- Row toggles: Semantic label "显示/隐藏此行" (Show/hide this row)
- Support screen readers (TalkBack/VoiceOver)
- Keyboard navigation: Arrow keys to move focus, Enter to activate

---

## UI/UX Design

### Visual Design

#### Layout Structure

```
┌─────────────────────────────────────────────────────────┐
│  [☰] 四柱      [年]      [月]      [日]      [时]   [+]  │ ← Title bar
├─────────────────────────────────────────────────────────┤
│  [☰][👁] 天干    甲       乙       丙       丁           │ ← Row 1
│  [☰][👁] 地支    子       丑       寅       卯           │ ← Row 2
│  [☰][👁] 十神    正官     偏印     食神     劫财         │ ← Row 3
│  [☰][👁] 纳音    海中金   炉中火   大溪水   沙中土       │ ← Row 4
└─────────────────────────────────────────────────────────┘
    ↑    ↑        ↑
   Drag  Eye    Pillar header (with [×] delete in edit mode)
  handle icon
```

#### Edit Mode Indicators

- **Drag Handles**: `Icons.drag_handle` (☰) in grey color (#757575)
- **Delete Buttons**: `Icons.close` (×) in red color (#F44336)
- **Add Button**: `Icons.add` (+) in primary color
- **Eye Toggle**: `Icons.visibility` / `Icons.visibility_off`

#### Drag Feedback

- **Dragging Pillar**:
  - Opacity: 0.7
  - Elevation: 8.0
  - Scale: 1.05
  - Cursor: `SystemMouseCursors.grabbing`

- **Drop Zones**:
  - Background: Primary color with 0.2 opacity
  - Border: 2px dashed primary color
  - Animation: Gentle pulsing (scale 1.0 ↔ 1.02)

#### Color Scheme (Five Elements)

Applied to tianGan and diZhi characters:

| Element | Chinese | Color Code | RGB |
|---------|---------|------------|-----|
| Wood | 木 (甲乙) | `#549688` | (84, 150, 136) |
| Fire | 火 (丙丁) | `#E95464` | (233, 84, 100) |
| Earth | 土 (戊己) | `#A88462` | (168, 132, 98) |
| Metal | 金 (庚辛) | `#F0A72E` | (240, 167, 46) |
| Water | 水 (壬癸) | `#2775B6` | (39, 117, 182) |

#### Typography

- **Pillar Headers** (年月日时): 16sp, FontWeight.w500
- **Main Characters** (甲子等): 32sp, FontWeight.bold, Custom calligraphy font (zhiMangXing/longCang or NotoSansSC)
- **Row Labels** (天干地支等): 14sp, FontWeight.normal
- **Metadata** (十神纳音等): 12sp, FontWeight.normal

#### Spacing & Sizing

- Card padding: 16px
- Pillar spacing: 12px horizontal
- Row spacing: 8px vertical
- Minimum pillar width: 60px
- Minimum row height: 40px

### Interaction Design

#### Gesture Mapping

| Gesture | Context | Action |
|---------|---------|--------|
| Tap | Pillar header (edit mode) | Select pillar |
| Long press | Pillar (edit mode) | Start pillar drag |
| Long press | Row handle (edit mode) | Start row drag |
| Tap | Delete button (×) | Delete pillar |
| Tap | Eye icon (👁) | Toggle row visibility |
| Tap | Add button (+) | Show add pillar menu |
| Drag | From palette | Add new pillar |

#### State Transitions

```
[View Mode] ←→ [Edit Mode]
                    ↓
          [Dragging Pillar] → [Drop] → [Reordered]
                    ↓
          [Dragging Row] → [Drop] → [Reordered]
```

### Responsive Behavior

- **Small screens** (<360dp width):
  - Reduce pillar width to 50px
  - Reduce font sizes by 10%
  - Stack pillars vertically if horizontal space insufficient

- **Large screens** (>600dp width):
  - Expand pillar width to 80px
  - Increase font sizes by 10%
  - Add more horizontal padding

---

## Implementation Plan

### Phase 1: Foundation (M1)
**Goal**: Core data models and basic rendering

- [ ] M1.1: Define `PillarConfig` model with JSON serialization
- [ ] M1.2: Define `RowConfig` model with JSON serialization
- [ ] M1.3: Extend `RowType` enum to include `separator`
- [ ] M1.4: Create `EditableFourZhuCard` stateful widget scaffold
- [ ] M1.5: Implement basic rendering in view mode (no editing)
- [ ] M1.6: Apply five elements color scheme to tianGan/diZhi

**Deliverable**: Component renders eight characters data correctly in view mode

### Phase 2: Pillar Dragging (M2)
**Goal**: Enable horizontal pillar reordering

- [ ] M2.1: Implement `LongPressDraggable` for pillar columns
- [ ] M2.2: Create `DragTarget` zones between pillars
- [ ] M2.3: Add drag feedback (opacity, elevation, scale)
- [ ] M2.4: Implement snap-to-slot logic on drag end
- [ ] M2.5: Fire `onPillarOrderChanged` callback with new order
- [ ] M2.6: Add unit tests for pillar reordering logic

**Deliverable**: Users can drag pillars horizontally to reorder

### Phase 3: Row Dragging (M3)
**Goal**: Enable vertical row reordering

- [ ] M3.1: Add drag handles (☰) to left side of each row
- [ ] M3.2: Implement `Draggable` for entire row (all cells move together)
- [ ] M3.3: Create `DragTarget` zones between rows
- [ ] M3.4: Implement vertical reordering logic
- [ ] M3.5: Fire `onRowConfigsChanged` callback
- [ ] M3.6: Add unit tests for row reordering

**Deliverable**: Users can drag rows vertically to reorder

### Phase 4: Edit Operations (M4)
**Goal**: Add, delete, show/hide functionality

- [ ] M4.1: Add delete button (×) to pillar headers in edit mode
- [ ] M4.2: Implement `onPillarDelete` callback
- [ ] M4.3: Add (+) button to title bar for adding pillars
- [ ] M4.4: Add eye icon (👁) toggles for row visibility
- [ ] M4.5: Implement `onRowVisibilityChange` callback
- [ ] M4.6: Add confirmation dialog for destructive actions (optional)

**Deliverable**: Users can add, delete, and show/hide pillars and rows

### Phase 5: Palette Integration (M5)
**Goal**: Support dragging from PillarPalette sidebar

- [ ] M5.1: Review existing `pillar_palette.dart` implementation
- [ ] M5.2: Update `PillarPalette` to provide `Draggable<PillarConfig>`
- [ ] M5.3: Add `DragTarget<PillarConfig>` in `EditableFourZhuCard`
- [ ] M5.4: Implement `onPillarAdd` callback
- [ ] M5.5: Handle insertion at drop position
- [ ] M5.6: Test cross-widget dragging

**Deliverable**: Users can drag pillars from palette into card

### Phase 6: Dividers (M6)
**Goal**: Support separator elements

- [ ] M6.1: Implement separator rendering for `PillarType.separator`
- [ ] M6.2: Implement separator rendering for `RowType.separator`
- [ ] M6.3: Allow separators to be dragged like regular elements
- [ ] M6.4: Add custom `dividerBuilder` parameter
- [ ] M6.5: Test separator insertion and reordering

**Deliverable**: Users can insert and manage dividers

### Phase 7: Polish & Testing (M7)
**Goal**: Production-ready quality

- [ ] M7.1: Add widget tests for all user stories
- [ ] M7.2: Add integration tests for drag-and-drop flows
- [ ] M7.3: Implement accessibility labels and semantics
- [ ] M7.4: Add responsive behavior for different screen sizes
- [ ] M7.5: Performance optimization (lazy rendering, const widgets)
- [ ] M7.6: Documentation (API docs, usage examples)
- [ ] M7.7: Create example page in `example/` package

**Deliverable**: Production-ready component with ≥80% test coverage

### Phase 8: Migration Support (M8)
**Goal**: Enable gradual adoption

- [ ] M8.1: Create migration guide document
- [ ] M8.2: Add helper functions to convert existing data to new format
- [ ] M8.3: Update `LayoutEditorPage` to optionally use new component
- [ ] M8.4: Monitor for issues in production
- [ ] M8.5: Gather user feedback and iterate

**Deliverable**: Smooth migration path for existing features

---

## Testing Strategy

### Unit Tests

**Target Coverage**: ≥80%

- [ ] PillarConfig model: serialization, equality, copyWith
- [ ] RowConfig model: serialization, equality, copyWith
- [ ] Pillar reordering logic (various edge cases)
- [ ] Row reordering logic
- [ ] Visibility toggle logic
- [ ] Add/delete operations
- [ ] Separator handling

### Widget Tests

- [ ] Renders correctly in view mode
- [ ] Shows edit controls when `isEditable = true`
- [ ] Drag handle appears/disappears based on edit mode
- [ ] Delete button triggers callback
- [ ] Eye icon toggles row visibility
- [ ] Pillars reorder on drag
- [ ] Rows reorder on drag

### Integration Tests

- [ ] Full drag-and-drop flow (pillar)
- [ ] Full drag-and-drop flow (row)
- [ ] Drag from palette into card
- [ ] Add pillar via (+) button
- [ ] Delete pillar workflow
- [ ] Toggle multiple rows
- [ ] Insert and reorder separators

### Golden Tests

- [ ] View mode appearance
- [ ] Edit mode appearance
- [ ] Drag feedback states
- [ ] Responsive layouts (small, medium, large screens)
- [ ] Dark mode rendering (if applicable)

### Manual Testing

- [ ] Test on physical Android device
- [ ] Test on physical iOS device
- [ ] Test on web browser (Chrome, Safari, Firefox)
- [ ] Test with screen reader (TalkBack/VoiceOver)
- [ ] Test with different locales (zh_CN, en_US)

---

## Risks & Mitigation

### Risk 1: Performance Degradation

**Risk**: Dragging feels laggy on lower-end devices

**Mitigation**:
- Use `RepaintBoundary` for pillar widgets
- Implement lazy rendering for rows
- Profile with Flutter DevTools and optimize hot paths
- Consider using `AnimatedList` for smoother reordering

### Risk 2: Gesture Conflicts

**Risk**: Drag gestures conflict with scroll gestures in parent widgets

**Mitigation**:
- Use `GestureDetector` with `onLongPressStart` for explicit drag initiation
- Add configurable drag delay (default 200ms)
- Test thoroughly in nested scroll contexts
- Document best practices for parent widget setup

### Risk 3: Complex State Management

**Risk**: Managing pillar/row state becomes unwieldy

**Mitigation**:
- Keep state minimal in widget (delegate to parent where possible)
- Use callbacks for all state changes (don't mutate internal state directly)
- Consider using ChangeNotifier or Riverpod if complexity grows
- Write comprehensive unit tests for state transitions

### Risk 4: Accessibility Compliance

**Risk**: Drag-and-drop not accessible to screen reader users

**Mitigation**:
- Provide keyboard shortcuts for reordering (Alt+↑/↓)
- Add semantic labels to all interactive elements
- Test with TalkBack and VoiceOver
- Provide alternative UI for reordering (e.g., move up/down buttons)

### Risk 5: Cross-Platform Inconsistencies

**Risk**: Drag-and-drop behaves differently on web vs. mobile

**Mitigation**:
- Test on all target platforms early
- Use Flutter's `Draggable` which abstracts platform differences
- Add platform-specific adjustments if needed (kIsWeb conditional logic)
- Document platform-specific behaviors

### Risk 6: Breaking Changes During Migration

**Risk**: New component breaks existing features

**Mitigation**:
- Don't remove old components immediately
- Use feature flags to toggle between old and new
- Gradual rollout (one feature at a time)
- Comprehensive regression testing
- Easy rollback plan

---

## Dependencies & Prerequisites

### Code Dependencies

- Existing models: `EightChars`, `JiaZi`, `TianGan`, `DiZhi`
- Existing widgets: `PillarPalette`, `FourZhuEightCharsCard` (for reference)
- Existing enums: `PillarType`, to be extended with `RowType`

### Design Assets

- Five elements color palette (already defined)
- Calligraphy fonts: `zhiMangXing`, `longCang`, or fallback to `NotoSansSC`
- Icon assets: drag handle, eye, delete (using Material Icons)

### Development Environment

- Flutter SDK: >=3.0.2
- Dart SDK: >=2.17.0
- Build tools: `build_runner` for code generation

---

## Appendix

### A. Design Mockup Reference

See: `docs/feature/eight_chars/card_template.png`

The mockup shows:
- Vertical pillar layout (traditional top-to-bottom reading)
- 5 columns: label column + 4 pillars (年月日时)
- 6-7 data points per pillar
- Five elements color coding
- Clean card design with rounded corners and shadows

### B. Related Documents

- Original discussion: (conversation context provided)
- Existing component: `lib/widgets/four_zhu_eight_chars_card.dart`
- Layout editor: `lib/pages/layout_editor_page.dart`
- Pillar palette: `lib/widgets/pillar_palette.dart`

### C. Glossary

- **八字 (BaZi)**: Eight Characters - a Chinese divination system based on birth date/time
- **柱 (Zhu)**: Pillar - represents year, month, day, or hour
- **天干 (TianGan)**: Heavenly Stem - one of 10 celestial elements
- **地支 (DiZhi)**: Earthly Branch - one of 12 terrestrial elements
- **十神 (ShiShen)**: Ten Gods - relationship types in BaZi
- **纳音 (NaYin)**: Hidden Note - derived five element type
- **五行 (WuXing)**: Five Elements - Wood, Fire, Earth, Metal, Water

### D. Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-23 | Product Team | Initial PRD draft |

---

**Approval Signatures**

- Product Manager: ____________________ Date: __________
- Engineering Lead: ____________________ Date: __________
- Design Lead: ____________________ Date: __________
