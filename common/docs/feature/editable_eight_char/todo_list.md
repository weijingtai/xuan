# EditableFourZhuCard - Task List

> **Project**: EditableFourZhuCard Component
> **Status**: Planning
> **Last Updated**: 2025-10-23
> **Total Tasks**: 68

---

## Task Status Legend

- ⬜ **Pending**: Not started
- 🟦 **In Progress**: Currently being worked on
- ✅ **Completed**: Finished and verified
- ⏸️ **Blocked**: Waiting on dependency or decision
- ❌ **Cancelled**: No longer needed

---

## Milestone Overview

| Milestone | Description | Tasks | Estimated Time | Status |
|-----------|-------------|-------|----------------|--------|
| M1 | Foundation & Basic Rendering | 8 | 2-3 days | ⬜ Pending |
| M2 | Pillar Dragging | 8 | 2-3 days | ⬜ Pending |
| M3 | Row Dragging | 8 | 2-3 days | ⬜ Pending |
| M4 | Edit Operations | 9 | 2-3 days | ⬜ Pending |
| M5 | Palette Integration | 8 | 1-2 days | ⬜ Pending |
| M6 | Dividers Support | 7 | 1-2 days | ⬜ Pending |
| M7 | Polish & Testing | 12 | 3-4 days | ⬜ Pending |
| M8 | Migration Support | 8 | 2-3 days | ⬜ Pending |

**Total Estimated Time**: 15-23 days

---

## M1: Foundation & Basic Rendering

**Goal**: Create core data models and basic view-mode rendering

**Dependencies**: None

**Deliverable**: Component renders eight characters data correctly in view mode (no editing features)

### M1.1: Define PillarConfig Model
- **ID**: M1.1
- **Status**: ⬜ Pending
- **Complexity**: Low (1-2 hours)
- **File**: `lib/models/pillar_config.dart` (new file)
- **Dependencies**: None

**Tasks**:
1. Create `lib/models/pillar_config.dart` file
2. Define `@immutable class PillarConfig` with fields:
   - `String id` (UUID)
   - `PillarType type`
   - `JiaZi? jiaZi` (nullable for separator type)
   - `bool isVisible` (default: true)
   - `int order` (position in sequence)
3. Add `@JsonSerializable()` annotation
4. Implement `copyWith()` method
5. Implement `operator ==` and `hashCode`
6. Add `part 'pillar_config.g.dart';` directive
7. Add `factory PillarConfig.fromJson()` and `Map<String, dynamic> toJson()`
8. Run `dart run build_runner build --delete-conflicting-outputs`

**Acceptance Criteria**:
- [ ] File compiles without errors
- [ ] JSON serialization works (can convert to/from JSON)
- [ ] `copyWith()` creates new instance with updated fields
- [ ] Equality comparison works correctly
- [ ] `.g.dart` file generated successfully

---

### M1.2: Define RowConfig Model
- **ID**: M1.2
- **Status**: ⬜ Pending
- **Complexity**: Low (1-2 hours)
- **File**: `lib/models/row_config.dart` (new file)
- **Dependencies**: M1.3 (needs RowType enum)

**Tasks**:
1. Create `lib/models/row_config.dart` file
2. Define `@immutable class RowConfig` with fields:
   - `String id` (UUID)
   - `RowType type`
   - `bool isVisible` (default: true)
   - `bool showLabel` (default: true)
   - `int order`
   - `TextStyle? textStyle` (optional custom styling)
3. Add `@JsonSerializable()` annotation
4. Implement `copyWith()` method
5. Implement `operator ==` and `hashCode`
6. Add JSON serialization methods
7. Run code generation

**Acceptance Criteria**:
- [ ] File compiles without errors
- [ ] JSON serialization works
- [ ] `copyWith()` method functional
- [ ] Equality comparison works

---

### M1.3: Extend RowType Enum
- **ID**: M1.3
- **Status**: ⬜ Pending
- **Complexity**: Low (30 minutes)
- **File**: `lib/enums/layout_template_enums.dart`
- **Dependencies**: None

**Tasks**:
1. Open `lib/enums/layout_template_enums.dart`
2. Add new `enum RowType` with values:
   ```dart
   enum RowType {
     tianGan,      // 天干
     diZhi,        // 地支
     shiShen,      // 十神
     naYin,        // 纳音
     kongWang,     // 空亡
     xunShou,      // 旬首
     cangGan,      // 藏干
     yinLu,        // 引禄
     qinTu,        // 禽土
     separator,    // 分割线
   }
   ```
3. Add helper methods if needed (e.g., `displayName`, `description`)
4. Update barrel export in `lib/enums.dart` if needed

**Acceptance Criteria**:
- [ ] Enum compiles without errors
- [ ] All required row types included
- [ ] Includes `separator` type for dividers

---

### M1.4: Create EditableFourZhuCard Widget Scaffold
- **ID**: M1.4
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart` (new file)
- **Dependencies**: M1.1, M1.2, M1.3

**Tasks**:
1. Create `lib/widgets/editable_four_zhu_card.dart`
2. Define `class EditableFourZhuCard extends StatefulWidget` with constructor:
   ```dart
   EditableFourZhuCard({
     Key? key,
     required this.eightChars,
     this.isEditable = false,
     this.pillarOrder,
     this.rowConfigs,
     this.onPillarOrderChanged,
     this.onPillarDelete,
     this.onPillarAdd,
     this.onRowConfigsChanged,
     this.pillarBuilder,
     this.rowCellBuilder,
     this.dividerBuilder,
     this.padding,
     this.backgroundColor,
     this.elevation,
     this.borderRadius,
   });
   ```
3. Create `_EditableFourZhuCardState` class
4. Add state variables:
   - `late List<PillarConfig> _pillars`
   - `late List<RowConfig> _rows`
   - `int? _draggedPillarIndex`
   - `int? _draggedRowIndex`
5. Implement `initState()` to initialize default pillars and rows
6. Add stub `build()` method returning placeholder `Card` widget

**Acceptance Criteria**:
- [ ] Widget scaffold compiles
- [ ] Constructor accepts all required parameters
- [ ] State initializes correctly
- [ ] Placeholder UI renders

---

### M1.5: Implement Basic View Mode Rendering
- **ID**: M1.5
- **Status**: ⬜ Pending
- **Complexity**: High (4-6 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M1.4

**Tasks**:
1. Implement `_buildViewMode()` method
2. Create table-like layout:
   - Title row with "四柱" or custom title
   - Row for each visible RowConfig
   - Column for each visible PillarConfig
3. Extract pillar data from `eightChars` based on `PillarType`
4. Render cells for each (row, pillar) combination
5. Apply proper spacing and alignment:
   - Card padding: 16px
   - Pillar spacing: 12px horizontal
   - Row spacing: 8px vertical
6. Add responsive sizing (min width: 60px per pillar, min height: 40px per row)
7. Style card with elevation, border radius, background color

**Acceptance Criteria**:
- [ ] Card displays all visible pillars horizontally
- [ ] Card displays all visible rows vertically
- [ ] Spacing matches design specs
- [ ] Renders correctly on different screen sizes
- [ ] No edit controls visible when `isEditable = false`

---

### M1.6: Apply Five Elements Color Scheme
- **ID**: M1.6
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M1.5

**Tasks**:
1. Define color constants for five elements:
   ```dart
   static const Map<WuXing, Color> _wuXingColors = {
     WuXing.wood: Color(0xFF549688),   // 木
     WuXing.fire: Color(0xFFE95464),   // 火
     WuXing.earth: Color(0xFFA88462),  // 土
     WuXing.metal: Color(0xFFF0A72E),  // 金
     WuXing.water: Color(0xFF2775B6),  // 水
   };
   ```
2. Create helper method `Color _getColorForGan(TianGan gan)` that maps gan to WuXing color
3. Create helper method `Color _getColorForZhi(DiZhi zhi)` that maps zhi to WuXing color
4. Apply colors to tianGan row cells
5. Apply colors to diZhi row cells
6. Ensure text is readable (consider contrast ratio, white text on dark colors)

**Acceptance Criteria**:
- [ ] TianGan characters display in correct five element colors
- [ ] DiZhi characters display in correct five element colors
- [ ] Colors match design specs exactly
- [ ] Text remains readable (WCAG AA contrast)

---

### M1.7: Add Typography Styling
- **ID**: M1.7
- **Status**: ⬜ Pending
- **Complexity**: Medium (1-2 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M1.5

**Tasks**:
1. Define typography styles:
   - Pillar headers (年月日时): 16sp, FontWeight.w500
   - Main characters (天干地支): 32sp, FontWeight.bold, calligraphy font
   - Row labels: 14sp, FontWeight.normal
   - Metadata (十神纳音等): 12sp, FontWeight.normal
2. Apply `GoogleFonts.zhiMangXing()` or `GoogleFonts.longCang()` to main characters (if available)
3. Fallback to `NotoSansSC` if Google Fonts not available
4. Add responsive font scaling for different screen sizes:
   - Small screens (<360dp): reduce by 10%
   - Large screens (>600dp): increase by 10%

**Acceptance Criteria**:
- [ ] Typography matches design specs
- [ ] Calligraphy fonts applied to main characters
- [ ] Fonts scale appropriately on different devices
- [ ] Text is legible at all sizes

---

### M1.8: Create Example Page
- **ID**: M1.8
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour)
- **File**: `example/lib/editable_four_zhu_card_demo.dart` (new file)
- **Dependencies**: M1.5, M1.6, M1.7

**Tasks**:
1. Create `example/lib/editable_four_zhu_card_demo.dart`
2. Create `EightChars` sample data (甲子年、乙丑月、丙寅日、丁卯时)
3. Add page with `EditableFourZhuCard(eightChars: sampleData, isEditable: false)`
4. Test that example compiles and runs
5. Add toggle button to switch between view/edit mode (edit mode won't work yet)
6. Update `example/lib/main.dart` to include route to demo page

**Acceptance Criteria**:
- [ ] Example page displays card correctly
- [ ] Can navigate to demo page from example app
- [ ] Sample data renders properly
- [ ] No runtime errors

---

## M2: Pillar Dragging

**Goal**: Enable horizontal pillar reordering via drag-and-drop

**Dependencies**: M1 (all tasks completed)

**Deliverable**: Users can drag pillars horizontally to reorder them

### M2.1: Add Pillar Drag Handle UI
- **ID**: M2.1
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M1.8

**Tasks**:
1. Modify `_buildEditMode()` method to show drag affordances
2. Add drag handle icon to each pillar header (optional, or entire pillar draggable)
3. Style drag handle: `Icons.drag_indicator`, grey color
4. Only show drag handle when `isEditable = true`
5. Add visual hover state (cursor changes to grab on desktop)

**Acceptance Criteria**:
- [ ] Drag handles visible in edit mode
- [ ] Drag handles hidden in view mode
- [ ] Cursor changes appropriately on hover (desktop)

---

### M2.2: Implement LongPressDraggable for Pillars
- **ID**: M2.2
- **Status**: ⬜ Pending
- **Complexity**: High (3-4 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M2.1

**Tasks**:
1. Wrap each pillar column widget in `LongPressDraggable<int>` (int = pillar index)
2. Configure `LongPressDraggable`:
   - `data`: pillar index
   - `delay`: Duration(milliseconds: 200)
   - `feedback`: Semi-transparent pillar widget (opacity: 0.7, elevation: 8)
   - `childWhenDragging`: Placeholder with dashed border
3. Implement `onDragStarted` callback to update `_draggedPillarIndex`
4. Implement `onDragEnd` callback to clear `_draggedPillarIndex`
5. Test on mobile (long press) and desktop (mouse drag)

**Acceptance Criteria**:
- [ ] Long press initiates drag on mobile
- [ ] Drag starts immediately with mouse on desktop
- [ ] Drag feedback shows semi-transparent pillar
- [ ] Original position shows placeholder

---

### M2.3: Create DragTarget Zones Between Pillars
- **ID**: M2.3
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M2.2

**Tasks**:
1. Create `_DropZone` widget extending `StatelessWidget`
2. Return `DragTarget<int>` configured to accept pillar indices
3. Implement `onWillAccept`: return true if dragging a different pillar
4. Implement `onAccept`: no-op (actual reordering in M2.4)
5. Style drop zone:
   - Default: transparent
   - `candidateData.isNotEmpty`: highlight with primary color (0.2 opacity), dashed border
6. Insert drop zones between each pillar in horizontal layout
7. Add leading and trailing drop zones (for moving to start/end)

**Acceptance Criteria**:
- [ ] Drop zones appear between pillars
- [ ] Drop zones highlight when draggable hovers over
- [ ] Drop zones reject self-drops

---

### M2.4: Implement Snap-to-Slot Logic
- **ID**: M2.4
- **Status**: ⬜ Pending
- **Complexity**: High (3-4 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M2.3

**Tasks**:
1. Calculate drop position based on horizontal drag offset
2. Determine nearest slot (between which two pillars)
3. Implement `_reorderPillars(int oldIndex, int newIndex)` method:
   - Remove pillar from `oldIndex`
   - Insert at `newIndex`
   - Update `order` field on all PillarConfigs
   - Call `setState()` to rebuild
4. Wire `onAccept` in DragTarget to call `_reorderPillars`
5. Add animation for smooth reordering (use `AnimatedList` or manual animation)
6. Handle edge cases:
   - Dragging to same position (no-op)
   - Dragging to first position
   - Dragging to last position

**Acceptance Criteria**:
- [ ] Pillar moves to correct position on drop
- [ ] Other pillars shift smoothly
- [ ] Order persists after reorder
- [ ] No duplicate or missing pillars

---

### M2.5: Fire onPillarOrderChanged Callback
- **ID**: M2.5
- **Status**: ⬜ Pending
- **Complexity**: Low (30 minutes)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M2.4

**Tasks**:
1. After reordering in `_reorderPillars()`, call `widget.onPillarOrderChanged?.call(_pillars)`
2. Pass updated `List<PillarConfig>` to callback
3. Ensure callback is called AFTER state update
4. Update example page to listen to callback and print new order

**Acceptance Criteria**:
- [ ] Callback fires after pillar reorder
- [ ] Callback receives correct updated list
- [ ] Example page logs new order correctly

---

### M2.6: Add Drag Feedback Styling
- **ID**: M2.6
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M2.2

**Tasks**:
1. Customize `feedback` widget in `LongPressDraggable`:
   - Opacity: 0.7
   - Elevation: 8.0
   - Scale: 1.05 (using Transform.scale)
   - Box shadow for depth
2. Customize `childWhenDragging`:
   - Dashed border container
   - Reduced opacity (0.3)
   - Same size as original pillar
3. Add cursor change on hover (desktop): `SystemMouseCursors.grab` → `SystemMouseCursors.grabbing`

**Acceptance Criteria**:
- [ ] Drag feedback looks polished
- [ ] Placeholder is visually clear
- [ ] Cursor changes appropriately (desktop)

---

### M2.7: Handle Edge Cases
- **ID**: M2.7
- **Status**: ⬜ Pending
- **Complexity**: Medium (2 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M2.4

**Tasks**:
1. Prevent dragging if only 1 pillar remains
2. Prevent accepting drop on same position (no-op)
3. Handle drag canceled (onDragEnd with no accept):
   - Clear `_draggedPillarIndex`
   - Animate pillar back to original position
4. Test with 2 pillars, 4 pillars, 8 pillars
5. Test rapid consecutive drags

**Acceptance Criteria**:
- [ ] Cannot drag sole remaining pillar
- [ ] Dropping on same position does nothing
- [ ] Canceled drags revert smoothly
- [ ] No crashes with various pillar counts

---

### M2.8: Unit Tests for Pillar Reordering
- **ID**: M2.8
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `test/widgets/editable_four_zhu_card_test.dart` (new file)
- **Dependencies**: M2.7

**Tasks**:
1. Create test file `test/widgets/editable_four_zhu_card_test.dart`
2. Write test: "reorders pillars correctly when dragged"
3. Write test: "fires onPillarOrderChanged callback with correct data"
4. Write test: "prevents reordering with only 1 pillar"
5. Write test: "handles edge case: drag to first position"
6. Write test: "handles edge case: drag to last position"
7. Write test: "handles edge case: drag to same position (no-op)"
8. Run tests with `flutter test`

**Acceptance Criteria**:
- [ ] All tests pass
- [ ] Coverage includes happy path and edge cases
- [ ] Tests are deterministic (no flakiness)

---

## M3: Row Dragging

**Goal**: Enable vertical row reordering via drag-and-drop

**Dependencies**: M2 (all tasks completed)

**Deliverable**: Users can drag rows vertically to reorder them

### M3.1: Add Row Drag Handle UI
- **ID**: M3.1
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M2.8

**Tasks**:
1. Add drag handle icon (☰) to left side of each row
2. Use `Icons.drag_handle`, grey color (#757575)
3. Position handle before row label
4. Only show when `isEditable = true`
5. Add semantic label: "拖动以重新排序此行"

**Acceptance Criteria**:
- [ ] Drag handles visible on all rows in edit mode
- [ ] Handles hidden in view mode
- [ ] Handles positioned correctly (left of row label)

---

### M3.2: Implement Draggable for Rows
- **ID**: M3.2
- **Status**: ⬜ Pending
- **Complexity**: High (3-4 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M3.1

**Tasks**:
1. Wrap each row widget in `Draggable<int>` (int = row index)
2. Make entire row draggable (all cells move together)
3. Configure `Draggable`:
   - `data`: row index
   - `feedback`: Semi-transparent row (opacity: 0.7)
   - `childWhenDragging`: Placeholder with dashed border
4. Implement `onDragStarted` to update `_draggedRowIndex`
5. Implement `onDragEnd` to clear `_draggedRowIndex`
6. Test vertical dragging

**Acceptance Criteria**:
- [ ] Entire row drags as a unit
- [ ] Drag feedback shows all cells in row
- [ ] Placeholder appears in original position

---

### M3.3: Create DragTarget Zones Between Rows
- **ID**: M3.3
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M3.2

**Tasks**:
1. Create vertical drop zones between each row
2. Use `DragTarget<int>` to accept row indices
3. Highlight drop zone when row hovers over:
   - Background: primary color with 0.2 opacity
   - Height: 4px (expands to 8px on hover)
4. Add leading and trailing drop zones
5. Implement `onWillAccept` to reject invalid drops

**Acceptance Criteria**:
- [ ] Drop zones appear between all rows
- [ ] Drop zones highlight on hover
- [ ] Drop zones reject self-drops

---

### M3.4: Implement Vertical Reordering Logic
- **ID**: M3.4
- **Status**: ⬜ Pending
- **Complexity**: High (3-4 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M3.3

**Tasks**:
1. Implement `_reorderRows(int oldIndex, int newIndex)` method:
   - Remove row from `oldIndex`
   - Insert at `newIndex`
   - Update `order` field on all RowConfigs
   - Call `setState()` to rebuild
2. Wire `onAccept` in DragTarget to call `_reorderRows`
3. Add smooth animation for row reordering
4. Handle edge cases (same position, first, last)

**Acceptance Criteria**:
- [ ] Rows reorder correctly on drop
- [ ] Other rows shift smoothly
- [ ] Order persists
- [ ] No duplicate or missing rows

---

### M3.5: Fire onRowConfigsChanged Callback
- **ID**: M3.5
- **Status**: ⬜ Pending
- **Complexity**: Low (30 minutes)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M3.4

**Tasks**:
1. After reordering in `_reorderRows()`, call `widget.onRowConfigsChanged?.call(_rows)`
2. Pass updated `List<RowConfig>` to callback
3. Ensure callback fires AFTER state update
4. Update example page to listen and log

**Acceptance Criteria**:
- [ ] Callback fires after row reorder
- [ ] Callback receives correct data
- [ ] Example logs new order

---

### M3.6: Add Drag Feedback for Rows
- **ID**: M3.6
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M3.2

**Tasks**:
1. Customize `feedback` widget:
   - Opacity: 0.7
   - Elevation: 8.0
   - Full width of card
   - Includes all cells in row
2. Customize `childWhenDragging`:
   - Dashed border
   - Reduced opacity (0.3)

**Acceptance Criteria**:
- [ ] Drag feedback shows entire row
- [ ] Feedback is visually distinct from static rows
- [ ] Placeholder is clear

---

### M3.7: Handle Row Dragging Edge Cases
- **ID**: M3.7
- **Status**: ⬜ Pending
- **Complexity**: Medium (2 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M3.4

**Tasks**:
1. Prevent dragging if only 1 visible row remains
2. Prevent dropping on same position
3. Handle drag canceled (animate back)
4. Test with 2 rows, 4 rows, 8 rows
5. Test rapid consecutive drags

**Acceptance Criteria**:
- [ ] Cannot drag sole visible row
- [ ] Same-position drops are no-ops
- [ ] Canceled drags revert
- [ ] No crashes with various row counts

---

### M3.8: Unit Tests for Row Reordering
- **ID**: M3.8
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `test/widgets/editable_four_zhu_card_test.dart`
- **Dependencies**: M3.7

**Tasks**:
1. Write test: "reorders rows correctly when dragged"
2. Write test: "fires onRowConfigsChanged callback"
3. Write test: "prevents reordering with only 1 row"
4. Write test: "handles edge case: drag to first position"
5. Write test: "handles edge case: drag to last position"
6. Write test: "handles edge case: drag to same position"
7. Run tests

**Acceptance Criteria**:
- [ ] All tests pass
- [ ] Edge cases covered
- [ ] No flaky tests

---

## M4: Edit Operations

**Goal**: Add, delete, show/hide functionality for pillars and rows

**Dependencies**: M3 (all tasks completed)

**Deliverable**: Users can add, delete, and show/hide pillars and rows

### M4.1: Add Delete Button to Pillar Headers
- **ID**: M4.1
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M3.8

**Tasks**:
1. Add delete button (×) to top-right of each pillar header
2. Use `Icons.close`, red color (#F44336)
3. Only show when `isEditable = true`
4. Add semantic label: "删除此柱"
5. Show button on hover (desktop) or always (mobile)

**Acceptance Criteria**:
- [ ] Delete button visible on all pillars in edit mode
- [ ] Button hidden in view mode
- [ ] Button positioned correctly (top-right)

---

### M4.2: Implement onPillarDelete Callback
- **ID**: M4.2
- **Status**: ⬜ Pending
- **Complexity**: Medium (2 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M4.1

**Tasks**:
1. Implement `_deletePillar(int index)` method:
   - Check if more than 1 pillar remains (minimum 1)
   - Remove pillar from `_pillars` list
   - Update `order` on remaining pillars
   - Call `setState()`
2. Wire delete button `onPressed` to `_deletePillar`
3. Call `widget.onPillarDelete?.call(index)` after deletion
4. Add optional confirmation dialog (can be controlled by parent)
5. Update example page to handle deletion

**Acceptance Criteria**:
- [ ] Clicking delete removes pillar
- [ ] Cannot delete last remaining pillar
- [ ] Callback fires with correct index
- [ ] UI updates smoothly

---

### M4.3: Add (+) Button to Title Bar
- **ID**: M4.3
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M4.2

**Tasks**:
1. Add (+) button to right side of title row
2. Use `Icons.add`, primary color
3. Only show when `isEditable = true`
4. Add semantic label: "添加柱位"
5. Position at top-right of card

**Acceptance Criteria**:
- [ ] (+) button visible in edit mode
- [ ] Button hidden in view mode
- [ ] Button positioned correctly

---

### M4.4: Implement Add Pillar Menu
- **ID**: M4.4
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M4.3

**Tasks**:
1. Create `_showAddPillarMenu()` method
2. Show bottom sheet or popup menu with pillar options:
   - 胎元 (TaiYuan)
   - 刻 (Ke)
   - 命宫 (MingGong)
   - 分割线 (Separator)
   - Other available PillarTypes
3. On selection, create new `PillarConfig`:
   - Generate UUID for id
   - Set selected type
   - Set order = _pillars.length
   - Add to _pillars list
4. Call `widget.onPillarAdd?.call(newPillar)`
5. Call `setState()`

**Acceptance Criteria**:
- [ ] Clicking (+) shows menu
- [ ] Selecting option adds new pillar
- [ ] New pillar appears at end
- [ ] Callback fires with new pillar data

---

### M4.5: Add Eye Icon Toggle for Rows
- **ID**: M4.5
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M4.4

**Tasks**:
1. Add eye icon next to each row label
2. Use `Icons.visibility` (visible) or `Icons.visibility_off` (hidden)
3. Only show when `isEditable = true`
4. Add semantic label: "显示/隐藏此行"
5. Wire to toggle method

**Acceptance Criteria**:
- [ ] Eye icons visible in edit mode
- [ ] Icons hidden in view mode
- [ ] Icons positioned next to row labels

---

### M4.6: Implement Row Visibility Toggle
- **ID**: M4.6
- **Status**: ⬜ Pending
- **Complexity**: Medium (2 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M4.5

**Tasks**:
1. Implement `_toggleRowVisibility(int index)` method:
   - Check if more than 1 visible row (minimum 1)
   - Toggle `_rows[index].isVisible`
   - Update RowConfig with copyWith
   - Call `setState()`
2. Wire eye icon `onTap` to `_toggleRowVisibility`
3. Call `widget.onRowVisibilityChange?.call(rowType, visible)`
4. Add smooth fade-out/fade-in animation for hiding/showing
5. Update icon based on visibility state

**Acceptance Criteria**:
- [ ] Clicking eye toggles row visibility
- [ ] Cannot hide last visible row
- [ ] Callback fires with correct data
- [ ] Animation is smooth

---

### M4.7: Add Confirmation Dialog for Destructive Actions
- **ID**: M4.7
- **Status**: ⬜ Pending
- **Complexity**: Low (1-2 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M4.2, M4.6

**Tasks**:
1. Create optional `showDeleteConfirmation` parameter (default: false)
2. If enabled, show confirmation dialog before deleting pillar
3. Dialog message: "确定要删除此柱位吗？" (Are you sure you want to delete this pillar?)
4. Buttons: "取消" (Cancel), "删除" (Delete, red color)
5. Only delete if user confirms
6. Similarly for hiding rows (optional)

**Acceptance Criteria**:
- [ ] Dialog appears when enabled
- [ ] Delete only happens on confirmation
- [ ] Cancel dismisses dialog without action
- [ ] Can be disabled for direct deletion

---

### M4.8: Handle Maximum Pillar Count
- **ID**: M4.8
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M4.4

**Tasks**:
1. Add `maxPillarCount` parameter (default: 10)
2. Check count before adding new pillar
3. If at maximum, show snackbar: "已达到最大柱位数量" (Maximum pillar count reached)
4. Disable (+) button when at maximum
5. Add visual indicator (greyed out button)

**Acceptance Criteria**:
- [ ] Cannot add pillars beyond maximum
- [ ] User feedback when limit reached
- [ ] (+) button disabled at maximum

---

### M4.9: Unit Tests for Edit Operations
- **ID**: M4.9
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `test/widgets/editable_four_zhu_card_test.dart`
- **Dependencies**: M4.7, M4.8

**Tasks**:
1. Write test: "deletes pillar correctly"
2. Write test: "prevents deleting last pillar"
3. Write test: "adds new pillar via menu"
4. Write test: "prevents adding beyond max count"
5. Write test: "toggles row visibility"
6. Write test: "prevents hiding last visible row"
7. Write test: "shows confirmation dialog when enabled"
8. Run tests

**Acceptance Criteria**:
- [ ] All tests pass
- [ ] Edge cases covered
- [ ] Tests verify callbacks fire

---

## M5: Palette Integration

**Goal**: Support dragging pillars from PillarPalette sidebar into card

**Dependencies**: M4 (all tasks completed)

**Deliverable**: Users can drag pillars from palette into card

### M5.1: Review Existing PillarPalette Implementation
- **ID**: M5.1
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour)
- **File**: `lib/widgets/pillar_palette.dart`
- **Dependencies**: M4.9

**Tasks**:
1. Read `lib/widgets/pillar_palette.dart` thoroughly
2. Understand current data model: `PillarData`, `PillarPreset`
3. Identify how pillars are currently displayed
4. Check if `Draggable` is already implemented
5. Document current API and usage patterns
6. Identify needed changes to support EditableFourZhuCard

**Acceptance Criteria**:
- [ ] Understand existing implementation
- [ ] List of needed modifications documented
- [ ] No breaking changes to existing usage

---

### M5.2: Update PillarPalette to Provide Draggable<PillarConfig>
- **ID**: M5.2
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `lib/widgets/pillar_palette.dart`
- **Dependencies**: M5.1

**Tasks**:
1. Wrap pillar items in palette with `Draggable<PillarConfig>`
2. On drag start, create `PillarConfig` from `PillarData`:
   - Generate UUID
   - Map PillarType
   - Set default visibility, order
3. Configure `Draggable`:
   - `data`: PillarConfig
   - `feedback`: Semi-transparent pillar icon/preview
   - `childWhenDragging`: Dimmed original
4. Test dragging from palette (doesn't connect yet, just initiates)
5. Ensure backward compatibility (existing usages still work)

**Acceptance Criteria**:
- [ ] Palette items are draggable
- [ ] Dragging provides PillarConfig data
- [ ] Drag feedback looks good
- [ ] Existing features not broken

---

### M5.3: Add DragTarget in EditableFourZhuCard
- **ID**: M5.3
- **Status**: ⬜ Pending
- **Complexity**: Medium (2 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M5.2

**Tasks**:
1. Add `DragTarget<PillarConfig>` around entire card (or specific zones)
2. Configure to accept `PillarConfig` from palette
3. Highlight drop zones when palette pillar hovers
4. Determine drop position based on horizontal drag position
5. Implement `onWillAccept`: return true if valid pillar type
6. Implement `onAccept`: add pillar (handled in M5.4)

**Acceptance Criteria**:
- [ ] Card accepts drags from palette
- [ ] Drop zones highlight appropriately
- [ ] Rejects invalid pillar types if needed

---

### M5.4: Implement onPillarAdd Callback
- **ID**: M5.4
- **Status**: ⬜ Pending
- **Complexity**: Medium (2 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M5.3

**Tasks**:
1. Implement `_addPillarAtPosition(PillarConfig pillar, int position)` method:
   - Insert pillar at specified position
   - Update `order` on all pillars
   - Call `setState()`
2. Wire `DragTarget.onAccept` to call `_addPillarAtPosition`
3. Call `widget.onPillarAdd?.call(pillar)`
4. Add smooth animation for insertion
5. Handle edge cases (duplicate types, max count)

**Acceptance Criteria**:
- [ ] Dropping from palette adds pillar
- [ ] Pillar inserted at correct position
- [ ] Callback fires with pillar data
- [ ] Animation is smooth

---

### M5.5: Handle Cross-Widget Drag Positioning
- **ID**: M5.5
- **Status**: ⬜ Pending
- **Complexity**: High (3-4 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M5.4

**Tasks**:
1. Track drag position during drag (use `onMove` in DragTarget)
2. Calculate insertion index based on horizontal position
3. Show insertion indicator (vertical line) at drop position
4. Update indicator position as drag moves horizontally
5. Insert at indicated position on drop
6. Handle edge cases (drag outside card bounds, etc.)

**Acceptance Criteria**:
- [ ] Insertion indicator shows during drag
- [ ] Indicator position updates with drag movement
- [ ] Pillar inserts at indicated position
- [ ] Indicator disappears on drop/cancel

---

### M5.6: Add Parent-Provided Pillar Source
- **ID**: M5.6
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M5.4

**Tasks**:
1. Add optional `customPillarSource` parameter
2. Allow parent to provide custom list of available pillars
3. If provided, use custom source instead of default palette
4. Document usage in API docs
5. Update example to show custom source

**Acceptance Criteria**:
- [ ] Parent can provide custom pillar options
- [ ] Custom source works correctly
- [ ] Falls back to default if not provided
- [ ] Example demonstrates usage

---

### M5.7: Test Cross-Component Dragging
- **ID**: M5.7
- **Status**: ⬜ Pending
- **Complexity**: Medium (2 hours)
- **File**: Integration test
- **Dependencies**: M5.5, M5.6

**Tasks**:
1. Create integration test with palette and card side-by-side
2. Test dragging each pillar type from palette to card
3. Test dropping at different positions (start, middle, end)
4. Test drag cancel (drag out and release)
5. Test rapid consecutive drags
6. Test on mobile and desktop

**Acceptance Criteria**:
- [ ] All pillar types drag successfully
- [ ] Drop positions are accurate
- [ ] Canceled drags don't add pillars
- [ ] No crashes or errors

---

### M5.8: Document Palette Integration
- **ID**: M5.8
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour)
- **File**: API docs, README
- **Dependencies**: M5.7

**Tasks**:
1. Document `onPillarAdd` callback in API docs
2. Provide code example of palette + card integration
3. Document `customPillarSource` parameter
4. Add usage notes for parent component setup
5. Update example page with comments

**Acceptance Criteria**:
- [ ] API docs include palette integration
- [ ] Code examples are clear
- [ ] Parent setup documented

---

## M6: Dividers Support

**Goal**: Support separator elements between pillars and rows

**Dependencies**: M5 (all tasks completed)

**Deliverable**: Users can insert and manage dividers

### M6.1: Implement Separator Rendering for Pillars
- **ID**: M6.1
- **Status**: ⬜ Pending
- **Complexity**: Medium (2 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M5.8

**Tasks**:
1. Check for `PillarType.separator` in pillar list
2. Render vertical divider instead of pillar column:
   - Width: 2px
   - Height: full card height
   - Color: grey (#E0E0E0) or theme divider color
3. Skip data cells for separator (only render divider line)
4. Apply custom `dividerBuilder` if provided
5. Test rendering with multiple separators

**Acceptance Criteria**:
- [ ] Separator renders as vertical line
- [ ] Separator spans full card height
- [ ] Custom builder applied if provided
- [ ] Multiple separators work

---

### M6.2: Implement Separator Rendering for Rows
- **ID**: M6.2
- **Status**: ⬜ Pending
- **Complexity**: Medium (2 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M6.1

**Tasks**:
1. Check for `RowType.separator` in row list
2. Render horizontal divider instead of row:
   - Height: 1px
   - Width: full card width
   - Color: grey (#E0E0E0)
3. Skip row cells for separator
4. Apply custom `dividerBuilder` if provided
5. Test rendering with multiple separators

**Acceptance Criteria**:
- [ ] Separator renders as horizontal line
- [ ] Separator spans full card width
- [ ] Custom builder applied if provided
- [ ] Multiple separators work

---

### M6.3: Allow Dragging Separators
- **ID**: M6.3
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M6.2

**Tasks**:
1. Make pillar separators draggable (same as regular pillars)
2. Make row separators draggable (same as regular rows)
3. Separators can be reordered like normal elements
4. Visual feedback during separator drag
5. Test dragging separators to various positions

**Acceptance Criteria**:
- [ ] Pillar separators draggable horizontally
- [ ] Row separators draggable vertically
- [ ] Separators reorder correctly
- [ ] Visual feedback is clear

---

### M6.4: Add Separator to Add Pillar Menu
- **ID**: M6.4
- **Status**: ⬜ Pending
- **Complexity**: Low (30 minutes)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M6.3

**Tasks**:
1. Add "分割线" (Separator) option to add pillar menu (M4.4)
2. On selection, create `PillarConfig(type: PillarType.separator)`
3. Insert at end or selected position
4. Test adding separator via menu

**Acceptance Criteria**:
- [ ] Separator option appears in menu
- [ ] Selecting adds separator pillar
- [ ] Separator renders correctly after addition

---

### M6.5: Add Custom dividerBuilder Parameter
- **ID**: M6.5
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M6.4

**Tasks**:
1. Add `Widget Function(BuildContext context, Axis direction)? dividerBuilder` parameter
2. Call divider builder for separator elements:
   - `direction = Axis.vertical` for pillar separators
   - `direction = Axis.horizontal` for row separators
3. Fall back to default divider if builder not provided
4. Update example to show custom divider
5. Document parameter in API docs

**Acceptance Criteria**:
- [ ] Custom divider builder works
- [ ] Direction parameter correct
- [ ] Falls back to default
- [ ] Example demonstrates usage

---

### M6.6: Handle Separator Edge Cases
- **ID**: M6.6
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M6.5

**Tasks**:
1. Prevent consecutive separators (optional, or allow)
2. Prevent starting/ending with separator (optional)
3. Handle deleting separators (should be allowed)
4. Test with all separators (edge case: no actual pillars)
5. Test with no separators

**Acceptance Criteria**:
- [ ] Edge cases handled gracefully
- [ ] No crashes with unusual configurations
- [ ] Deleting separators works

---

### M6.7: Unit Tests for Separators
- **ID**: M6.7
- **Status**: ⬜ Pending
- **Complexity**: Medium (2 hours)
- **File**: `test/widgets/editable_four_zhu_card_test.dart`
- **Dependencies**: M6.6

**Tasks**:
1. Write test: "renders pillar separator as vertical divider"
2. Write test: "renders row separator as horizontal divider"
3. Write test: "can drag and reorder pillar separators"
4. Write test: "can drag and reorder row separators"
5. Write test: "applies custom divider builder"
6. Write test: "handles multiple consecutive separators"
7. Run tests

**Acceptance Criteria**:
- [ ] All tests pass
- [ ] Separator rendering tested
- [ ] Separator dragging tested

---

## M7: Polish & Testing

**Goal**: Production-ready quality with comprehensive testing and polish

**Dependencies**: M6 (all tasks completed)

**Deliverable**: Production-ready component with ≥80% test coverage

### M7.1: Add Comprehensive Widget Tests
- **ID**: M7.1
- **Status**: ⬜ Pending
- **Complexity**: High (4-6 hours)
- **File**: `test/widgets/editable_four_zhu_card_test.dart`
- **Dependencies**: M6.7

**Tasks**:
1. Write test: "renders correctly in view mode"
2. Write test: "shows edit controls when isEditable = true"
3. Write test: "hides edit controls when isEditable = false"
4. Write test: "applies five elements colors correctly"
5. Write test: "applies typography styles correctly"
6. Write test: "responds to window size changes"
7. Write test: "handles empty pillar list gracefully"
8. Write test: "handles empty row list gracefully"
9. Achieve ≥80% code coverage for widget
10. Run `flutter test --coverage`

**Acceptance Criteria**:
- [ ] All widget tests pass
- [ ] Code coverage ≥80%
- [ ] Tests cover view and edit modes
- [ ] Edge cases tested

---

### M7.2: Add Integration Tests
- **ID**: M7.2
- **Status**: ⬜ Pending
- **Complexity**: High (3-4 hours)
- **File**: `integration_test/editable_four_zhu_card_test.dart` (new file)
- **Dependencies**: M7.1

**Tasks**:
1. Create integration test file
2. Test full drag-and-drop flow for pillars
3. Test full drag-and-drop flow for rows
4. Test add pillar workflow (menu + palette)
5. Test delete pillar workflow
6. Test toggle row visibility workflow
7. Test mode switching (view → edit → view)
8. Run with `flutter test integration_test/`

**Acceptance Criteria**:
- [ ] All integration tests pass
- [ ] Complete user flows tested
- [ ] Tests run on emulator/device

---

### M7.3: Implement Accessibility Features
- **ID**: M7.3
- **Status**: ⬜ Pending
- **Complexity**: Medium (3-4 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M7.1

**Tasks**:
1. Add semantic labels to all interactive elements:
   - Drag handles: "拖动以重新排序"
   - Delete buttons: "删除此柱"
   - Add button: "添加柱位"
   - Eye toggles: "显示/隐藏此行"
2. Add `Semantics` widgets where needed
3. Ensure focus order is logical (top to bottom, left to right)
4. Test with TalkBack (Android) and VoiceOver (iOS)
5. Add keyboard shortcuts (optional):
   - Alt+↑/↓: Move selected row up/down
   - Alt+←/→: Move selected pillar left/right
   - Delete key: Delete selected pillar
6. Ensure minimum touch target size (48x48 dp)

**Acceptance Criteria**:
- [ ] All interactive elements have semantic labels
- [ ] Screen reader announces elements correctly
- [ ] Focus order is logical
- [ ] Touch targets meet minimum size

---

### M7.4: Add Responsive Behavior
- **ID**: M7.4
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M7.3

**Tasks**:
1. Detect screen size using `MediaQuery.of(context).size`
2. Small screens (<360dp width):
   - Reduce pillar width to 50px
   - Reduce font sizes by 10%
   - Reduce padding to 12px
3. Large screens (>600dp width):
   - Expand pillar width to 80px
   - Increase font sizes by 10%
   - Increase padding to 20px
4. Handle very narrow screens (stacking pillars vertically if needed)
5. Test on various device sizes

**Acceptance Criteria**:
- [ ] Scales appropriately on small phones
- [ ] Expands nicely on tablets
- [ ] No horizontal overflow on any device
- [ ] Text remains legible at all sizes

---

### M7.5: Performance Optimization
- **ID**: M7.5
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M7.4

**Tasks**:
1. Wrap pillar widgets in `RepaintBoundary` to isolate repaints
2. Use `const` constructors where possible for static widgets
3. Lazy render rows (only render visible rows)
4. Use `ValueKey` for stable widget identity during reorders
5. Profile with Flutter DevTools:
   - Check for excessive rebuilds
   - Check for layout thrashing
   - Optimize hot paths
6. Ensure 60fps during drag operations
7. Test on low-end device (or slow down CPU in DevTools)

**Acceptance Criteria**:
- [ ] No unnecessary rebuilds during drag
- [ ] Maintains 60fps on mid-range devices
- [ ] DevTools shows no performance warnings
- [ ] Memory usage is reasonable

---

### M7.6: API Documentation
- **ID**: M7.6
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M7.5

**Tasks**:
1. Add comprehensive dartdoc comments to class
2. Document all constructor parameters with examples
3. Document all callbacks (when they fire, what data they receive)
4. Add usage examples in class doc comment
5. Document data models (PillarConfig, RowConfig)
6. Run `dart doc` to generate documentation
7. Review generated docs for clarity

**Acceptance Criteria**:
- [ ] All public APIs documented
- [ ] Examples are clear and runnable
- [ ] Generated docs look good
- [ ] No dartdoc warnings

---

### M7.7: Create Comprehensive Example Page
- **ID**: M7.7
- **Status**: ⬜ Pending
- **Complexity**: Medium (3-4 hours)
- **File**: `example/lib/editable_four_zhu_card_demo.dart`
- **Dependencies**: M7.6

**Tasks**:
1. Expand example page with multiple demos:
   - View mode demo
   - Edit mode demo
   - Custom styling demo
   - Custom dividers demo
   - Palette integration demo
2. Add controls to toggle features:
   - View/Edit mode switch
   - Show/hide confirmation dialogs
   - Enable/disable features
3. Add debug output (show callbacks firing)
4. Add visual polish (nice layout, instructions)
5. Test all demos work correctly

**Acceptance Criteria**:
- [ ] Example demonstrates all major features
- [ ] Example is well-organized and commented
- [ ] Example is visually polished
- [ ] No errors in example

---

### M7.8: Golden Tests for Visual Regression
- **ID**: M7.8
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `test/widgets/editable_four_zhu_card_golden_test.dart` (new file)
- **Dependencies**: M7.7

**Tasks**:
1. Create golden test file
2. Write golden test: "view mode appearance"
3. Write golden test: "edit mode appearance"
4. Write golden test: "drag feedback state"
5. Write golden test: "small screen layout"
6. Write golden test: "large screen layout"
7. Write golden test: "with separators"
8. Generate golden images: `flutter test --update-goldens`
9. Add golden images to git

**Acceptance Criteria**:
- [ ] Golden tests pass on CI
- [ ] Images capture all important states
- [ ] Tests detect visual regressions

---

### M7.9: Dark Mode Support (Optional)
- **ID**: M7.9
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M7.8

**Tasks**:
1. Detect theme brightness: `Theme.of(context).brightness`
2. Adjust colors for dark mode:
   - Background: dark card color
   - Text: light colors
   - Dividers: lighter grey
   - Five elements colors: adjust for dark background (increase luminosity)
3. Test in dark mode
4. Add golden tests for dark mode
5. Document dark mode support

**Acceptance Criteria**:
- [ ] Looks good in dark mode
- [ ] All text is readable
- [ ] Colors are adjusted appropriately
- [ ] Golden tests pass for dark mode

---

### M7.10: Localization Support (Optional)
- **ID**: M7.10
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M7.9

**Tasks**:
1. Extract hardcoded strings to localization:
   - "四柱" (Four Pillars)
   - "年月日时" (Year Month Day Hour)
   - Row labels (天干地支等)
   - Button labels
   - Confirmation messages
2. Support `Localizations` widget
3. Provide Chinese (zh_CN) and English (en_US) translations
4. Test with different locales
5. Document localization support

**Acceptance Criteria**:
- [ ] No hardcoded strings in widget
- [ ] Chinese and English supported
- [ ] Locale switching works correctly

---

### M7.11: Error Handling & Validation
- **ID**: M7.11
- **Status**: ⬜ Pending
- **Complexity**: Low (1-2 hours)
- **File**: `lib/widgets/editable_four_zhu_card.dart`
- **Dependencies**: M7.10

**Tasks**:
1. Add assertions for invalid inputs:
   - `assert(eightChars != null)`
   - `assert(maxPillarCount > 0)`
   - etc.
2. Handle null/empty data gracefully:
   - Empty pillar list: show placeholder message
   - Empty row list: show placeholder message
3. Add try-catch around risky operations (JSON parsing, etc.)
4. Log errors to console (use `debugPrint`)
5. Show user-friendly error messages

**Acceptance Criteria**:
- [ ] Invalid inputs throw clear errors
- [ ] Null/empty data handled gracefully
- [ ] No uncaught exceptions
- [ ] Error messages are helpful

---

### M7.12: Final Manual Testing
- **ID**: M7.12
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: N/A (manual testing)
- **Dependencies**: M7.11

**Tasks**:
1. Test on physical Android device (various screen sizes)
2. Test on physical iOS device (various screen sizes)
3. Test on web browser (Chrome, Safari, Firefox)
4. Test with screen reader (TalkBack on Android, VoiceOver on iOS)
5. Test with keyboard (desktop)
6. Test all user stories from PRD (US-1.1 through US-4.2)
7. Test edge cases and error conditions
8. Document any bugs found
9. Fix critical bugs before milestone completion

**Acceptance Criteria**:
- [ ] All user stories pass manual testing
- [ ] No critical bugs found
- [ ] Works on all target platforms
- [ ] Accessible via screen reader

---

## M8: Migration Support

**Goal**: Enable gradual adoption without breaking existing features

**Dependencies**: M7 (all tasks completed)

**Deliverable**: Smooth migration path for existing features

### M8.1: Create Migration Guide Document
- **ID**: M8.1
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `docs/feature/editable_eight_char/MIGRATION.md` (new file)
- **Dependencies**: M7.12

**Tasks**:
1. Create migration guide document
2. Document differences between old and new components:
   - FourZhuEightCharsCard (old) vs EditableFourZhuCard (new)
   - LayoutEditorPage (old) vs built-in editing (new)
3. Provide step-by-step migration instructions
4. Include code examples (before/after)
5. Document breaking changes (if any)
6. Provide rollback instructions
7. Add troubleshooting section (common issues)

**Acceptance Criteria**:
- [ ] Migration guide is comprehensive
- [ ] Examples are clear and accurate
- [ ] Covers all migration scenarios
- [ ] Troubleshooting addresses common issues

---

### M8.2: Add Helper Functions for Data Conversion
- **ID**: M8.2
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `lib/utils/eight_chars_migration_helper.dart` (new file)
- **Dependencies**: M8.1

**Tasks**:
1. Create helper file
2. Implement `List<PillarConfig> convertLegacyPillars(Map<String, JiaZi> oldData)`:
   - Convert old format to new PillarConfig list
   - Generate UUIDs
   - Set default order, visibility
3. Implement `List<RowConfig> getDefaultRowConfigs()`:
   - Return default row configuration
   - Can be customized by caller
4. Add unit tests for helper functions
5. Document usage in migration guide

**Acceptance Criteria**:
- [ ] Helper functions work correctly
- [ ] Unit tests pass
- [ ] Documented in migration guide

---

### M8.3: Update LayoutEditorPage to Use New Component
- **ID**: M8.3
- **Status**: ⬜ Pending
- **Complexity**: High (4-6 hours)
- **File**: `lib/pages/layout_editor_page.dart`
- **Dependencies**: M8.2

**Tasks**:
1. Add feature flag: `bool useNewEditableCard = false`
2. When true, replace old editing UI with `EditableFourZhuCard(isEditable: true)`
3. Wire callbacks to view model:
   - `onPillarOrderChanged` → update view model state
   - `onPillarDelete` → update view model
   - `onPillarAdd` → update view model
   - `onRowConfigsChanged` → update view model
4. Test both old and new paths
5. Ensure no regressions in old path

**Acceptance Criteria**:
- [ ] New component integrates correctly
- [ ] Feature flag works
- [ ] Old path still works when flag is false
- [ ] No regressions in editor functionality

---

### M8.4: Add A/B Test Support (Optional)
- **ID**: M8.4
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: `lib/utils/feature_flags.dart`
- **Dependencies**: M8.3

**Tasks**:
1. Create feature flag system (if not exists)
2. Add flag: `editable_four_zhu_card_enabled`
3. Support remote config (Firebase Remote Config or similar)
4. Allow toggling at runtime
5. Log analytics events (component_shown, edit_action, etc.)
6. Monitor usage and errors

**Acceptance Criteria**:
- [ ] Feature flag controls component usage
- [ ] Can toggle remotely without app update
- [ ] Analytics track component usage
- [ ] Errors are logged and monitored

---

### M8.5: Monitor Production Issues
- **ID**: M8.5
- **Status**: ⬜ Pending
- **Complexity**: Low (ongoing)
- **File**: N/A (monitoring)
- **Dependencies**: M8.4

**Tasks**:
1. Set up error tracking (Sentry, Crashlytics, etc.)
2. Monitor for crashes related to new component
3. Monitor for performance regressions
4. Track user engagement metrics:
   - How many users enable edit mode
   - How many perform drag operations
   - Average time spent editing
5. Collect user feedback (in-app surveys, support tickets)
6. Create dashboard to track metrics

**Acceptance Criteria**:
- [ ] Error tracking is active
- [ ] Metrics are being collected
- [ ] Dashboard shows component health
- [ ] Issues are triaged and addressed

---

### M8.6: Gradual Rollout Plan
- **ID**: M8.6
- **Status**: ⬜ Pending
- **Complexity**: Low (1 hour planning)
- **File**: N/A (planning document)
- **Dependencies**: M8.5

**Tasks**:
1. Create rollout plan:
   - Week 1: Internal testing (10% of team)
   - Week 2: Beta users (25% of user base)
   - Week 3: Wider rollout (50% of user base)
   - Week 4: Full rollout (100% of users)
2. Define rollback criteria (error rate > 5%, crash rate > 1%, etc.)
3. Assign rollout manager
4. Schedule checkpoints for go/no-go decisions
5. Communicate plan to stakeholders

**Acceptance Criteria**:
- [ ] Rollout plan is documented
- [ ] Rollback criteria are clear
- [ ] Stakeholders are informed
- [ ] Checkpoints are scheduled

---

### M8.7: Gather User Feedback & Iterate
- **ID**: M8.7
- **Status**: ⬜ Pending
- **Complexity**: Medium (ongoing)
- **File**: N/A (feedback collection)
- **Dependencies**: M8.6

**Tasks**:
1. Add in-app feedback mechanism (optional):
   - "How do you like the new editing experience?" (thumbs up/down)
   - Optional comment field
2. Monitor support tickets for component-related issues
3. Conduct user interviews (5-10 users)
4. Analyze feedback and identify improvement opportunities
5. Prioritize and implement top-requested features
6. Communicate updates to users

**Acceptance Criteria**:
- [ ] Feedback is being collected
- [ ] Feedback is analyzed and categorized
- [ ] Improvement opportunities identified
- [ ] Action plan created for top issues

---

### M8.8: Complete Migration & Deprecate Old Component
- **ID**: M8.8
- **Status**: ⬜ Pending
- **Complexity**: Medium (2-3 hours)
- **File**: Multiple files
- **Dependencies**: M8.7

**Tasks**:
1. After successful rollout (4-8 weeks), plan full migration
2. Replace all usages of old component with new component
3. Add `@deprecated` annotation to old components:
   - FourZhuEightCharsCard
   - Old LayoutEditorPage editing logic
4. Update all documentation to reference new component
5. Schedule removal of deprecated code (e.g., 3 months later)
6. Communicate deprecation timeline to team

**Acceptance Criteria**:
- [ ] All features use new component
- [ ] Old components marked deprecated
- [ ] Documentation updated
- [ ] Removal timeline communicated

---

## Summary

**Total Tasks**: 68 tasks across 8 milestones

**Estimated Timeline**: 15-23 days (3-5 weeks)

**Critical Path**:
M1 → M2 → M3 → M4 → M5 → M6 → M7 → M8

**Parallel Work Opportunities**:
- M7.6 (Documentation) can start alongside M7.1-M7.5
- M7.8 (Golden tests) can run in parallel with M7.7 (Example)
- M8.1 (Migration guide) can be drafted during M7

**Risk Areas**:
- M2 & M3 (Drag & drop implementation) - most technically complex
- M5 (Palette integration) - requires coordination with existing component
- M7 (Testing & polish) - can expand in scope if issues found

**Success Metrics**:
- ✅ Component renders correctly in view and edit modes
- ✅ Drag-and-drop works smoothly on all platforms
- ✅ Test coverage ≥80%
- ✅ No regressions in existing features
- ✅ User satisfaction with new editing experience

---

## Next Steps

1. **Review and Approve**: Review this task list with team, adjust estimates
2. **Assign Ownership**: Assign milestones to team members
3. **Set Up Project Board**: Create GitHub project or Jira board with these tasks
4. **Begin M1**: Start with foundation work (data models, basic rendering)
5. **Daily Standups**: Track progress, identify blockers
6. **Weekly Reviews**: Demo completed milestones, gather feedback

**Questions? Concerns?** Review with team before starting implementation.

---

*Document Version: 1.0*
*Last Updated: 2025-10-23*
