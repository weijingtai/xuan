/// 条文列表UI状态枚举
enum TiaoWenListState {
  /// 初始状态
  initial,
  
  /// 加载中
  loading,
  
  /// 加载成功
  success,
  
  /// 加载失败
  error;

  /// 是否为加载中状态
  bool get isLoading => this == TiaoWenListState.loading;
  
  /// 是否为成功状态
  bool get isSuccess => this == TiaoWenListState.success;
  
  /// 是否为错误状态
  bool get isError => this == TiaoWenListState.error;
  
  /// 是否为初始状态
  bool get isInitial => this == TiaoWenListState.initial;
}