/// UseCase 基类
///
/// 所有用例都应继承此基类以保持统一的调用接口
abstract class UseCase<Type, Params> {
  Future<Type> execute(Params params);
}

/// 无参数 UseCase
///
/// 适用于不需要参数的用例
abstract class NoParamsUseCase<Type> {
  Future<Type> execute();
}
