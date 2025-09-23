import 'tiao_wen_repository.dart';
import 'tiao_wen_repository_impl.dart';

/// Repository工厂类
///
/// 负责创建和管理各种Repository实例
class RepositoryFactory {
  static const String _defaultTiaoWenDataPath = 'assets/all_tiao_wen_v1.csv';

  /// 创建条文Repository实例
  ///
  /// [dataPath] 数据文件路径，默认使用预设路径
  /// 返回条文Repository实例
  static TiaoWenRepository createTiaoWenRepository({String? dataPath}) {
    return TiaoWenRepositoryImpl(dataPath: dataPath ?? _defaultTiaoWenDataPath);
  }

  /// 获取默认的条文Repository实例
  ///
  /// 使用默认配置创建Repository实例
  static TiaoWenRepository get defaultTiaoWenRepository {
    return createTiaoWenRepository();
  }
}
