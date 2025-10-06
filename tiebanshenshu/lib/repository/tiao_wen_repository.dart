import 'datamodels/tiao_wen_datamodel.dart';

/// 条文数据仓库抽象接口
///
/// 提供条文数据的基本CRUD操作接口
abstract class TiaoWenRepository {
  /// 根据ID获取单个条文
  ///
  /// [id] 条文ID
  /// 返回对应的条文数据模型，如果不存在则返回null
  Future<TiaoWenDataModel?> getById(int id);

  /// 根据ID列表和分页范围获取条文列表
  ///
  /// [ids] 条文ID列表
  /// [pageRange] 分页范围，格式为 [startIndex, endIndex]
  /// [steps] 步长，用于控制获取的间隔
  /// 返回指定范围内的条文列表
  Future<List<TiaoWenDataModel>> getByIdsWithPageRange({
    required List<int> ids,
    required List<int> pageRange,
    int steps = 1,
  });

  /// 获取所有条文
  ///
  /// 返回数据库中的所有条文数据
  Future<List<TiaoWenDataModel>> listAll();

  /// 根据条件搜索条文
  ///
  /// [setName] 按地支名称筛选（可选）
  /// [contentKeyword] 内容关键词搜索（可选）
  /// 返回符合条件的条文列表
  Future<List<TiaoWenDataModel>> search({
    String? setName,
    String? contentKeyword,
  });

  /// 获取条文总数
  ///
  /// 返回数据库中条文的总数量
  Future<int> getCount();

  /// 获取指定ID前后指定数量的条文
  ///
  /// [centerId] 中心ID
  /// [beforeCount] 前面获取的条文数量
  /// [afterCount] 后面获取的条文数量
  /// [includeCenterItem] 是否包含中心ID的条文，默认为true
  /// 返回包含中心ID前后条文的列表，按ID升序排列
  Future<List<TiaoWenDataModel>> getAroundById({
    required int centerId,
    required int beforeCount,
    required int afterCount,
    bool includeCenterItem = true,
  });

  /// 获取指定ID前后按间隔获取的条文
  ///
  /// [centerId] 中心ID
  /// [interval] 间隔步长
  /// [minCount] 最少获取的条文数量
  /// [maxRange] 最大搜索范围（可选），防止无限扩展
  /// [includeCenterItem] 是否包含中心ID的条文，默认为true
  /// 返回按间隔获取的条文列表，按ID升序排列
  Future<List<TiaoWenDataModel>> getByIntervalAroundId({
    required int centerId,
    required int interval,
    required int minCount,
    int? maxRange,
    bool includeCenterItem = true,
  });

  /// 获取指定ID范围内的所有条文
  ///
  /// [startId] 起始ID（包含）
  /// [endId] 结束ID（包含）
  /// 返回指定范围内的条文列表，按ID升序排列
  Future<List<TiaoWenDataModel>> getByIdRange({
    required int startId,
    required int endId,
  });

  /// 根据ID列表批量查询条文
  ///
  /// [queryList] 要查询的条文ID列表
  /// [preserveOrder] 是否保持与输入列表相同的顺序，默认为false（按ID升序排列）
  /// [skipNotFound] 是否跳过不存在的ID，默认为true
  /// 返回查询到的条文列表
  Future<List<TiaoWenDataModel>> getByIdList({
    required List<int> queryList,
    bool preserveOrder = false,
    bool skipNotFound = true,
  });

  /// 批量获取条文内容
  ///
  /// [numbers] 条文数列表
  /// 返回: Map<条文数, 条文内容>
  /// 不存在的条文数不会出现在返回 Map 中
  Future<Map<int, String>> getTiaoWenContentByNumbers(List<int> numbers);

  /// 获取单个条文内容
  ///
  /// [number] 条文数
  /// 返回: 条文内容字符串，不存在则返回 null
  Future<String?> getTiaoWenContentByNumber(int number);
}
