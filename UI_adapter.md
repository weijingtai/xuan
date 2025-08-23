# UI Adapter Development Plan

## 1. Project Goal

To refactor the application's UI rendering logic to support multiple, distinct circular measurement systems (360°, 365 days, and 365.25 days). This adaptation must handle variations in both celestial body positioning and the division of the 12 houses (Gongs), ensuring the architecture is clean, robust, and easily extensible for future systems.

## 2. Core Architectural Approach

We will implement the **Strategy Pattern** to abstract the geometric rules of each circular system. A `DrawingStrategy` interface will define the contract for how to calculate positions and divisions. Concrete classes (`DrawingStrategy360`, `DrawingStrategy365`, etc.) will provide the specific implementations for each system. This decouples the UI painting logic from the geometric calculation rules.

## 3. Development Plan

### Phase 1: Configuration and Data Model

- [x] **Extend `CircularSystem` Enum:** Add `Days365` and `Days365_25` alongside `Degrees360`.
- [x] **Update `PanelConfig` Model:** Add the `circularSystem` property to the main configuration model.
- [x] **Update Configuration UI:** Modify `custom_config_section.dart` to display all three `CircularSystem` options for user selection.

### Phase 2: Architectural Foundation (Drawing Strategy)

- [ ] **Create `DrawingStrategy` Abstract Class:**
    -   Define the file `qizhengsiyu/lib/services/drawing_strategy.dart`.
    -   Define the abstract class `DrawingStrategy` with the following methods:
        -   `double getTotalDivisions()`
        -   `Offset mapAngleToCanvas(double angle, double radius, Offset center)`
        -   `List<double> getHouseDivisionAngles()`
        -   `String formatAngle(double angle)`
- [ ] **Implement Concrete Strategy Classes:**
    -   Create `DrawingStrategy360`.
    -   Create `DrawingStrategy365`.
    -   Create `DrawingStrategy365_25`.
    -   For now, the `365` and `365.25` strategies will use equal house divisions.
- [ ] **Integrate Strategy Creation:**
    -   In `beauty_page.dart`, add logic to its `initState` to instantiate the correct `DrawingStrategy` object based on a (currently simulated) `PanelConfig`.

### Phase 3: Refactor UI Painters

- [ ] **Refactor `TwelveZhiGongCircleRingPrinter`:**
    -   Modify its constructor to accept a `DrawingStrategy` object.
    -   Remove hardcoded 30-degree logic.
    -   Update its `paint` method to use `strategy.getHouseDivisionAngles()` to draw the house division lines.
    -   Update its instantiation in `beauty_page.dart` to pass the strategy object.
- [ ] **Refactor `StarXiuRingPainter`:**
    -   Modify its constructor to accept a `DrawingStrategy` object.
    -   Update its `paint` method to scale the widths of the 28 mansions based on the ratio from `strategy.getTotalDivisions()`.
    -   Update its instantiation in `beauty_page.dart`.
- [ ] **Refactor Star Painters (e.g., `star2` method in `beauty_page.dart`):**
    -   Update the `Transform.rotate` logic to calculate the angle in radians using the `_drawingStrategy.getTotalDivisions()` to ensure correct placement in all systems.

### Phase 4: Refactor Text Display

- [ ] **Update Angle Formatting Logic:**
    -   Locate where angles are converted to display strings (e.g., "15° 30'").
    -   Modify this logic to use the `strategy.formatAngle()` method to display the correct unit ("°" or "日").

### Phase 5: Finalization and Testing

- [ ] **Connect `beauty_page.dart` to `PanelConfigViewModel`:**
    -   Remove the simulated `PanelConfig` from `beauty_page.dart`.
    -   Refactor the widget to receive the `PanelConfig` from a provider that holds the `QiZhengSiYuViewModel`.
- [ ] **Thoroughly Test All Systems:**
    -   Test switching between all three `CircularSystem` options from the configuration page.
    -   Visually verify that the star positions and house divisions render correctly for each system.
