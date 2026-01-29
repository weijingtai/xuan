import '../../domain/models/tiao_wen_list_result.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../domain/models/tiao_wen_list_state.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';

/// 条文项数据类
///
/// 用于UI组件显示的条文项数据结构
class TiaoWenItemData {
  /// 条文编号
  final int number;

  /// 条文内容
  final String content;

  /// 年龄信息
  final String ageInfo;

  /// 分类信息
  final String? category;

  const TiaoWenItemData({
    required this.number,
    required this.content,
    required this.ageInfo,
    this.category,
  });

  /// 从TiaoWenDataModel创建TiaoWenItemData
  factory TiaoWenItemData.fromEntity(TiaoWenDataModel entity) {
    // 格式化年龄信息
    String ageInfo = '';
    if (entity.ageSet1 != null && entity.ageSet1!.isNotEmpty) {
      ageInfo = entity.ageSet1!.join(', ');
      if (entity.ageSet2 != null && entity.ageSet2!.isNotEmpty) {
        ageInfo += ' / ${entity.ageSet2!.join(', ')}';
      }
    }

    return TiaoWenItemData(
      number: entity.id,
      content: entity.content1,
      ageInfo: ageInfo.isNotEmpty ? ageInfo : '无年龄信息',
      category: entity.setName.name.toString(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TiaoWenItemData &&
        other.number == number &&
        other.content == content &&
        other.ageInfo == ageInfo &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(number, content, ageInfo, category);

  @override
  String toString() {
    return 'TiaoWenItemData(number: $number, content: $content, ageInfo: $ageInfo, category: $category)';
  }
}

/// UI层的条文列表结果模型
///
/// 基于Domain层的TiaoWenListResult，提供UI友好的属性和方法
/// 包含完整的条文entity列表，这是UI模型存在的核心价值
class UITiaoWenListResultModel {
  final TiaoWenListResult _domainResult;

  UITiaoWenListResultModel(this._domainResult);

  /// 从Domain结果创建UI模型
  factory UITiaoWenListResultModel.fromDomain(TiaoWenListResult domainResult) {
    return UITiaoWenListResultModel(domainResult);
  }

  /// 从MultiBaseNumberResult创建UI模型
  factory UITiaoWenListResultModel.fromMultiBaseNumberResult(MultiBaseNumberResult multiResult) {
    // 创建一个兼容的TiaoWenListResult
    final tiaoWenListResult = TiaoWenListResult.success(
      tiaoWenNumbers: multiResult.allTiaoWenNumbers,
      tiaoWenEntities: multiResult.tiaoWenEntities ?? [],
      calculationMethod: multiResult.algorithmName,
      sourceData: multiResult.sourceData,
    );
    return UITiaoWenListResultModel(tiaoWenListResult);
  }

  /// 条文编号列表
  List<int> get tiaoWenNumbers => _domainResult.tiaoWenNumbers;

  /// 条文实体列表 - UI模型的核心价值
  List<TiaoWenDataModel> get tiaoWenEntities => _domainResult.tiaoWenEntities;

  /// 计算状态
  TiaoWenListState get state => _domainResult.state;

  /// 计算方法名称
  String get calculationMethod => _domainResult.calculationMethod;

  /// 源数据
  Map<String, dynamic> get sourceData => _domainResult.sourceData;

  /// 错误消息
  String? get errorMessage => _domainResult.errorMessage;

  /// 是否计算成功
  bool get isSuccess => _domainResult.isSuccess;

  /// 是否有错误
  bool get hasError => _domainResult.hasError;

  /// 是否正在加载
  bool get isLoading => _domainResult.isLoading;

  /// 是否为初始状态
  bool get isInitial => _domainResult.isInitial;

  /// 条文数量
  int get tiaoWenCount => _domainResult.tiaoWenCount;

  /// 根据索引获取条文entity
  TiaoWenDataModel? getTiaoWenEntityAt(int index) {
    if (index < 0 || index >= tiaoWenEntities.length) {
      return null;
    }
    return tiaoWenEntities[index];
  }

  /// 根据条文编号获取条文entity
  TiaoWenDataModel? getTiaoWenEntityByNumber(int number) {
    try {
      return tiaoWenEntities.firstWhere((entity) => entity.id == number);
    } catch (e) {
      return null;
    }
  }

  /// 检查是否有条文数据
  bool get hasTiaoWenData => tiaoWenEntities.isNotEmpty;

  /// UI专用：条文项数据列表
  ///
  /// 将条文entities转换为UI组件友好的数据结构
  List<TiaoWenItemData> get tiaoWenItems {
    return tiaoWenEntities
        .map((entity) => TiaoWenItemData.fromEntity(entity))
        .toList();
  }

  /// UI专用：获取状态显示文本
  String get stateDisplayText {
    switch (state) {
      case TiaoWenListState.initial:
        return '准备就绪';
      case TiaoWenListState.loading:
        return '计算中...';
      case TiaoWenListState.success:
        return '计算完成';
      case TiaoWenListState.error:
        return '计算失败';
    }
  }

  /// UI专用：获取状态图标
  String get stateIcon {
    switch (state) {
      case TiaoWenListState.initial:
        return '⚪';
      case TiaoWenListState.loading:
        return '🔄';
      case TiaoWenListState.success:
        return '✅';
      case TiaoWenListState.error:
        return '❌';
    }
  }

  /// UI专用：获取结果摘要文本
  String get resultSummary {
    if (isLoading) {
      return '正在使用 $calculationMethod 进行计算...';
    } else if (hasError) {
      return '计算失败：${errorMessage ?? "未知错误"}';
    } else if (isSuccess) {
      return '使用 $calculationMethod 计算得到 $tiaoWenCount 个条文';
    } else {
      return '等待开始计算';
    }
  }

  /// UI专用：获取条文编号的显示文本
  String get tiaoWenNumbersDisplayText {
    if (tiaoWenNumbers.isEmpty) {
      return '暂无条文';
    }
    return tiaoWenNumbers.join(', ');
  }

  /// UI专用：获取简短的条文编号显示（最多显示前5个）
  String get shortTiaoWenNumbersDisplayText {
    if (tiaoWenNumbers.isEmpty) {
      return '暂无条文';
    }

    const maxDisplay = 5;
    if (tiaoWenNumbers.length <= maxDisplay) {
      return tiaoWenNumbers.join(', ');
    } else {
      final displayNumbers = tiaoWenNumbers.take(maxDisplay).join(', ');
      final remainingCount = tiaoWenNumbers.length - maxDisplay;
      return '$displayNumbers... (还有${remainingCount}个)';
    }
  }

  /// UI专用：是否可以显示结果
  bool get canDisplayResult => isSuccess && tiaoWenNumbers.isNotEmpty;

  /// UI专用：是否应该显示加载指示器
  bool get shouldShowLoadingIndicator => isLoading;

  /// UI专用：是否应该显示错误信息
  bool get shouldShowError => hasError;

  /// UI专用：是否应该显示重试按钮
  bool get shouldShowRetryButton => hasError;

  /// UI专用：获取用于调试的详细信息
  String get debugInfo {
    return '''
计算方法: $calculationMethod
状态: ${stateDisplayText}
条文数量: $tiaoWenCount
条文编号: ${tiaoWenNumbersDisplayText}
源数据: $sourceData
错误信息: ${errorMessage ?? "无"}
''';
  }

  /// 获取原始Domain结果
  TiaoWenListResult get domainResult => _domainResult;

  @override
  String toString() {
    return 'UITiaoWenListResultModel('
        'state: $state, '
        'calculationMethod: $calculationMethod, '
        'tiaoWenCount: $tiaoWenCount, '
        'hasError: $hasError'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UITiaoWenListResultModel &&
        other._domainResult == _domainResult;
  }

  @override
  int get hashCode => _domainResult.hashCode;
}
