import 'package:common/models/shen_sha_gan_zhi.dart';
import 'package:qizhengsiyu/domain/entities/entities_temp/di_zhi_shen_sha.dart';

abstract class ShenShaRepository {
  Future<List<TianGanShenSha>> getTianGanShenSha();
  Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha();
  Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha();
  Future<List<GanZhiShenSha>> getGanZhiShenSha();
  Future<List<BundledShenSha>> getBundledShenSha();
  Future<List<OtherShenSha>> getOtherShenSha();
}
