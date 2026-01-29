enum CalanderType {
  lunar("阴历"),
  solar("阳历");

  final String name;

  const CalanderType(this.name);
}

/// 元堂卦月份阴阳判定规则
///
/// - oddEven: 旧规则，奇数月为阳月(1,3,5,7,9,11)，偶数月为阴月(2,4,6,8,10,12)
/// - yueLing: 新规则，月令阴阳（冬至后→夏至前为阳令：11,12,1,2,3,4；夏至后→冬至前为阴令：5,6,7,8,9,10）
enum YuanTangMonthYinYangRule { oddEven, yueLing }
