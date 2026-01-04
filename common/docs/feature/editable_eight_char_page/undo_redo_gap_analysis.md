# Undo/Redo Gap Analysis (Task 0 Output)

## 1. ViewModel Direct Modifications (`FourZhuEditorViewModel`)
The following methods currently modify `_currentTemplate` directly via `_applyCurrentTemplate` or internal assignment, bypassing `CommandHistory`. They need to be refactored to use `Command` pattern.

### Chart Group Operations
- `reorderGroups`: Uses `_applyCurrentTemplate`.
- `addPillarToGroup`: Uses `_applyCurrentTemplate`.
- `removePillarFromGroup`: Uses `_applyCurrentTemplate`.
- `updateChartGroupTitle`: Uses `_applyCurrentTemplate`.
- `toggleChartGroupVisibility`: Uses `_applyCurrentTemplate`.

### Row Configuration Operations
- `updateRowConfig`: Uses `_applyCurrentTemplate`.
- `toggleRowVisibility`: Uses `_applyCurrentTemplate`.
- `updateRowTitleVisibility`: Uses `_applyCurrentTemplate`.
- `updateRowOrder`: Uses `_applyCurrentTemplate`.
- `reorderRowsByTypes`: Uses `_applyCurrentTemplate`.

### Style Operations
- `updateCardStyle`: Uses `_applyCurrentTemplate`.

## 2. Card Widget Direct Modifications (`EditableFourZhuCardV3`)
The following interactions directly modify `cardPayloadNotifier`. They need to be converted to callbacks (Intents) that the ViewModel handles via Commands.

### Row Operations
- `_onReorder` -> `_setRows`: Direct write.
- `_onDeleteRow` -> `_setRows`: Direct write.
- `_onInsertRow` -> `_setRows`: Direct write.

### Pillar Operations
- `_onReorderPillar` -> `_setPillars`: Direct write.
- `_onDeletePillar` -> `_setPillars`: Direct write.
- `_onInsertPillar` -> `_setPillars`: Direct write.

## 3. Plan
1. **Phase 1 (Template)**: Create specific `Command` implementations for the ViewModel methods listed above.
2. **Phase 2 (Card Interaction)**: 
   - Define callbacks/intents in `EditableFourZhuCardV3`.
   - Implement handlers in ViewModel to wrap these intents in Commands.
   - Ensure `syncRuntimeThemeFromCardStyle` logic is preserved and unified.
