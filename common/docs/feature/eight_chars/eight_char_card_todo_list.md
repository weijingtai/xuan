# Eight Characters Card - Refactoring TODO List

This document outlines the technical tasks required to refactor the `EightCharsCardV3` widget into a scalable, testable architecture using MVVM, Use Cases, and the Repository pattern.

### 1. Create Repository Layer
- [x] Rename `SettingsRepository` to `EightCharsInfoRepository`.
- [x] Define the `EightCharsInfoRepository` interface in a new file.
- [x] Implement `EightCharsInfoRepositoryImpl` using `shared_preferences` for persistence.

### 2. Create Use Case Layer
- [x] Create `GetDaYunUseCase` to encapsulate the `DaYunCalculator` logic.
- [x] Create `SaveLayoutUseCase` to handle saving row/pillar visibility and order via the repository.
- [x] Create `LoadLayoutUseCase` to handle loading the layout configuration from the repository.
- [x] Create `ApplyPillarPresetUseCase` to encapsulate the logic for applying pillar combination presets.

### 3. Create ViewModel Layer
- [x] Create the `BaziCardViewModel` class.
- [x] Move all UI state and logic from `_EightCharsCardV3State` into the ViewModel. This includes:
  - Pillar and row order lists for both cards.
  - All boolean visibility flags for rows and pillars.
  - Edit mode status (`isEditMode`, `isColumnReorderMode`).
- [x] Implement methods on the ViewModel to be called by the View (e.g., `toggleNayin()`, `reorderRow()`, `selectPillarPreset()`). These methods will call the appropriate Use Cases.

### 4. Refactor the View Layer
- [x] Create a new parent widget (`BaziDisplayPage`) to host the ViewModel and the two cards.
- [x] Refactor `EightCharsCardV3` into a generic `GenericPillarCard` widget.
- [x] Make `GenericPillarCard` a "dumb" widget that receives all its data and callbacks from its parent (`BaziDisplayPage`). It will be responsible for rendering only.
- [ ] **Implement Edit/Reorder UI in `GenericPillarCard`**. The ViewModel logic is ready, but the UI is missing.
- [ ] **Implement Pillar Selection UI**. The `OptionChip`s for toggling pillars need to be added, likely in `BaziDisplayPage`.
- [x] Connect the View to the ViewModel using a state management solution (e.g., `ChangeNotifierProvider` and `Consumer` from the `provider` package).

### 5. Cleanup
- [x] Rename `eight_chars_card_v3.dart` to `bazi_display_page.dart`.
- [x] Remove the obsolete `interactive_four_zhu_card.dart` file.
- [ ] Ensure all related code is pointing to the new, refactored components.