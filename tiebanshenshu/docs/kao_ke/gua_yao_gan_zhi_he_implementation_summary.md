# GuaYaoGanZhiHe (卦爻干支和数法) Implementation Summary

## Algorithm Overview

The GuaYaoGanZhiHe (Hexagram Yao Heavenly Stems and Earthly Branches Sum Method) calculates base numbers from Four Pillars (八字) using hexagram mappings and NaJia assignments.

## Implementation Status

✅ **COMPLETED** - All tests passing

## Key Algorithm Steps

1. **Gan-Zhi to 64 Gua Mapping**
   - Map each pillar's Heavenly Stem (Gan) to an 8 Gua
   - Map each pillar's Earthly Branch (Zhi) to an 8 Gua
   - Combine to get a 64 Gua (upper + lower)

2. **NaJia Installation** (Two Methods)
   - **yearGanYinYang**: Uses innerGuaYaoTianGan for lower gua, outerGuaYaoTianGan for upper gua
   - **innerOuterGua**: Traditional method using SixYaoCalculator's najiaGanZhuangGua

3. **TaiXuan Sum Calculation**
   - For each yao: sum = TaiXuan(Gan) + TaiXuan(Zhi)
   - Filter out yaos where sum = 10
   - Lower gua sum: yaos 0-2 (excluding filtered)
   - Upper gua sum: yaos 3-5 (excluding filtered)

4. **Base Number Generation**
   - Formula: `baseNumber = upperSum * 100 + lowerSum`

## Critical Implementation Details

### NaJia Assignment for yearGanYinYang Method

The **yearGanYinYang** method uses:
- **Lower Gua (内卦)**: `innerGuaYaoTianGan` mapping
- **Upper Gua (外卦)**: `outerGuaYaoTianGan` mapping

This is **NOT** based on the year's yin-yang! The name is somewhat misleading - it's actually about using the inner/outer gua distinction.

**Example for 地山谦 (Kun上艮下):**
- Upper gua 坤: Uses outerGuaYaoTianGan[Kun] = 癸癸癸
- Lower gua 艮: Uses innerGuaYaoTianGan[Gen] = 丙丙丙

### Yao Position Indexing

Yaos are indexed **bottom to top** (0-5):
- Position 0 = 初爻 (bottom)
- Position 1 = 二爻
- Position 2 = 三爻
- Position 3 = 四爻
- Position 4 = 五爻
- Position 5 = 上爻 (top)

But NaJia mappings from constants are **top to bottom**, so we reverse them before assignment.

## Test Case: 癸未 癸亥 壬午 戊申

### Year Pillar: 癸未 → 地山谦 → 3342

**Yao Details (bottom→top):**
```
Position 0: 丙辰 = 7+5 = 12
Position 1: 丙午 = 7+9 = 16
Position 2: 丙申 = 7+7 = 14
Position 3: 癸丑 = 5+8 = 13
Position 4: 癸亥 = 5+4 = 9
Position 5: 癸酉 = 5+6 = 11
```

**Calculation:**
- Lower sum: 12 + 16 + 14 = 42
- Upper sum: 13 + 9 + 11 = 33
- Base number: 33 * 100 + 42 = **3342** ✓

### Month Pillar: 癸亥 → 地水师 → 3326

**Yao Details (bottom→top):**
```
Position 0: 戊寅 = 5+7 = 12
Position 1: 戊辰 = 5+5 = 10 [FILTERED]
Position 2: 戊午 = 5+9 = 14
Position 3: 癸丑 = 5+8 = 13
Position 4: 癸亥 = 5+4 = 9
Position 5: 癸酉 = 5+6 = 11
```

**Calculation:**
- Lower sum: 12 + 14 = 26 (戊辰 filtered)
- Upper sum: 13 + 9 + 11 = 33
- Base number: 33 * 100 + 26 = **3326** ✓

### Day Pillar: 壬午 → 天火同人 → 3945

**Yao Details (bottom→top):**
```
Position 0: 己卯 = 9+6 = 15
Position 1: 己丑 = 9+8 = 17
Position 2: 己亥 = 9+4 = 13
Position 3: 壬午 = 6+9 = 15
Position 4: 壬申 = 6+7 = 13
Position 5: 壬戌 = 6+5 = 11
```

**Calculation:**
- Lower sum: 15 + 17 + 13 = 45
- Upper sum: 15 + 13 + 11 = 39
- Base number: 39 * 100 + 45 = **3945** ✓

### Time Pillar: 戊申 → 水天需 → 2648

**Yao Details (bottom→top):**
```
Position 0: 甲子 = 9+9 = 18
Position 1: 甲寅 = 9+7 = 16
Position 2: 甲辰 = 9+5 = 14
Position 3: 戊申 = 5+7 = 12
Position 4: 戊戌 = 5+5 = 10 [FILTERED]
Position 5: 戊子 = 5+9 = 14
```

**Calculation:**
- Lower sum: 18 + 16 + 14 = 48
- Upper sum: 12 + 14 = 26 (戊戌 filtered)
- Base number: 26 * 100 + 48 = **2648** ✓

## Files Modified

### Core Strategy Files
- `lib/service/strategy/gua_yao_gan_zhi_he_strategy.dart` - Main algorithm
- `lib/service/strategy/gua_yao_gan_zhi_he_result.dart` - Result model
- `lib/domain/models/gua_yao_gan_zhi_he_base_number_model.dart` - Domain models

### Integration Files
- `lib/features/kao_ke/kao_ke_calculation_strategy_impl.dart` - KaoKe integration
- `lib/infrastructure/di/strategy_providers.dart` - DI setup

### Test Files
- `test/service/strategy/gua_yao_gan_zhi_he_gui_wei_simple_test.dart` - Basic tests
- `test/service/strategy/gua_yao_gan_zhi_he_detailed_yao_test.dart` - Detailed yao-by-yao tests

## Verification

All tests passing:
- ✅ Year pillar produces 3342
- ✅ Month pillar produces 3326
- ✅ Day pillar produces 3945
- ✅ Time pillar produces 2648
- ✅ Each yao has correct NaJia Gan-Zhi assignment
- ✅ Sum=10 filtering works correctly
- ✅ KaoKe integration works correctly

## Integration with KaoKe

The `GuaYaoGanZhiHeStrategy.calculateFromGua64()` static method is used by KaoKe:

```dart
// KaoKe calls this with a 64 Gua derived from base number
final result = GuaYaoGanZhiHeStrategy.calculateFromGua64(
  gua64,
  GuaYaoGanZhiHeNaJiaMethod.yearGanYinYang,
  isYangYear,
);
```

This integration allows KaoKe to use both:
1. **BaGuaJiaZe** method (two approaches: YaoSequence and NaJia)
2. **GuaYaoGanZhiHe** method (two approaches: yearGanYinYang and innerOuterGua)

## Next Steps

Future enhancements could include:
- [ ] Add more test cases for edge cases
- [ ] Performance optimization for bulk calculations
- [ ] UI integration for displaying yao details
- [ ] Documentation for users

## Conclusion

The GuaYaoGanZhiHe algorithm is now fully implemented, tested, and integrated with the KaoKe feature. All calculations match the human-verified specifications.
