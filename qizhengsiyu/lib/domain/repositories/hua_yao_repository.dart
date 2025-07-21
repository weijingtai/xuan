import 'package:qizhengsiyu/domain/entities/entities_temp/hua_yao.dart';

abstract class HuaYaoRepository {
  Future<List<TianGanHuaYao>> getTianGanHuaYao();
  Future<List<DiZhiHuaYao>> getDiZhiHuaYao();
  Future<List<OthersHuaYao>> getOthersHuaYao();
}
