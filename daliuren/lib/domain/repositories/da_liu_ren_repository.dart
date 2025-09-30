import 'package:daliuren/model/da_liu_ren_ke_pan.dart';

abstract class DaLiuRenRepository {
  Future<DaLiuRenKePan> calculateDivination(DateTime dateTime, {String? question});
  Future<void> loadDivinationData();
  Future<List<dynamic>> getYuDingData();
  Future<Map<String, dynamic>> getJuMapperData();
}