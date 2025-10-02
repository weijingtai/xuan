class PalaceUtils {
  static const List<String> PALACES = [
    '子',
    '丑',
    '寅',
    '卯',
    '辰',
    '巳',
    '午',
    '未',
    '申',
    '酉',
    '戌',
    '亥'
  ];

  // 获取下一个宫位
  static String getNextPalace(String palace, {int step = 1}) {
    int index = PALACES.indexOf(palace);
    if (index == -1) throw Exception('无效的宫位: $palace');
    return PALACES[(index + step) % 12];
  }

  // 获取上一个宫位
  static String getPrevPalace(String palace, {int step = 1}) {
    int index = PALACES.indexOf(palace);
    if (index == -1) throw Exception('无效的宫位: $palace');
    return PALACES[(index - step + 12) % 12];
  }

  // 获取对宫
  static String getOppositePalace(String palace) {
    int index = PALACES.indexOf(palace);
    if (index == -1) throw Exception('无效的宫位: $palace');
    return PALACES[(index + 6) % 12];
  }
}
