# xuan

用来“承装”有关玄学的小App

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# APP 说明
### 胎元计算
在命理学中，若命主已知自己的受孕时间（即受精怀胎的具体日期），胎元的推算方法会更为直接和精准。以下是基于传统命理理论和现代实践总结的胎元计算方法及注意事项：
一、直接以受孕时间确定胎元
此方法最符合胎元“受胎成人之月”的本质定义：
核心操作：
胎元干支 = 受孕当天的日柱干支。
若受孕时间在当日 子时（23:00-1:00）之前，取 上一天 的日柱；
若在 子时之后，取 当天 的日柱。
示例：
若受孕日为农历1984年9月27日，且时间在子时后，则胎元为 甲子（该日的干支）

二、月柱推算法（主流方法）
推算规则：
胎元天干：出生月柱的天干向前顺推一位（如月干为乙，则胎元天干为丙）。
胎元地支：出生月柱的地支向前顺推三位（如月支为亥，则胎元地支为寅）。
示例：若命主生于乙亥月，胎元为丙寅（乙→丙，亥→子→丑→寅）。
理论依据：
基于“十月怀胎”的假设，从出生月倒推十个月即为受胎月，干支按六十甲子顺序递推

 三、生日倒推法（古法参考）
推算规则：
从出生日向前推算300天（约十个月），该日的干支即为胎元。
示例：甲子日出生者，300天前同为甲子日，胎元即甲子。
争议点：
实际妊娠周期存在个体差异（早产/晚产），此方法准确性受质疑
四、日主阴阳属性法（少数流派应用）
推算规则：
阳干日主（甲、丙等）：胎元天干取出生月地支的藏干（如月支申藏庚壬戊，取主气庚）。
阴干日主（乙、丁等）：胎元天干取出生时地支的藏干（如时支卯藏乙，取乙）。
示例：日主乙木（阴干），出生时支为卯，藏干乙木，胎元为乙木


早产/晚产的修正：

早产（＜10个月）：在干支推算法结果基础上，地支再减一位（如原胎元壬子→修正为癸丑）。
晚产（＞10个月）：地支再加一位（如原胎元壬子→修正为辛亥）。
示例：月柱辛酉，正常胎元壬子；若早产则取癸丑，晚产取辛亥。

 注意事项
若已知实际受孕时间，应以实际日期为准；无确切信息时，默认按“十月怀胎”推算
试管婴：以植入胚胎时间作为
受孕时间可通过末次月经、B超孕囊大小或排卵期反推，但医学推算存在±1周误差