class FeiXianInfo {
  final int startAge;
  final int endAge;
  final String palace;

  FeiXianInfo({
    required this.startAge,
    required this.endAge,
    required this.palace,
  });

  @override
  String toString() {
    return '($startAge,$endAge,$palace)';
  }
}
