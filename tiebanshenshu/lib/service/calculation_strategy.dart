abstract class CalculationStrategy<P, R> {
  // 策略名称
  String get name;

  // 策略描述
  String get description;

  // 策略详细步骤
  List<String> get detailSteps;
  // 所属流派
  String get school => "default";

  // 计算
  R calculate(P params);
}
