/// 内存缓存数据源
///
/// 使用 LRU (Least Recently Used) 策略的内存缓存
class CacheDataSource {
  final Map<String, dynamic> _cache = {};
  final int _maxSize;
  final List<String> _accessOrder = [];

  CacheDataSource({int maxSize = 1000}) : _maxSize = maxSize;

  /// 获取缓存
  ///
  /// 返回缓存的值，如果不存在返回 null
  /// 同时更新访问顺序（LRU）
  Future<T?> get<T>(String key) async {
    if (!_cache.containsKey(key)) {
      return null;
    }

    // 更新访问顺序 (LRU)
    _accessOrder.remove(key);
    _accessOrder.add(key);

    return _cache[key] as T?;
  }

  /// 设置缓存
  ///
  /// 如果超出容量，删除最少使用的项
  Future<void> set<T>(String key, T value) async {
    // 超出容量，删除最少使用的
    if (_cache.length >= _maxSize && !_cache.containsKey(key)) {
      final lruKey = _accessOrder.first;
      _cache.remove(lruKey);
      _accessOrder.remove(lruKey);
    }

    _cache[key] = value;
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  /// 清除缓存
  Future<void> clear() async {
    _cache.clear();
    _accessOrder.clear();
  }

  /// 获取缓存大小
  int get size => _cache.length;

  /// 获取缓存容量
  int get maxSize => _maxSize;

  /// 检查是否包含 key
  bool containsKey(String key) => _cache.containsKey(key);
}
