import 'dart:io';

/// 简单的测试运行脚本，用于验证皇极公式相关测试
void main() async {
  print('=== 皇极公式测试运行器 ===\n');
  
  // 检查必要的文件是否存在
  final jsonFile = File('test/assets/formula/huang_ji_formula.json');
  if (!await jsonFile.exists()) {
    print('❌ 错误: huang_ji_formula.json 文件不存在');
    return;
  }
  
  final jsonTestFile = File('test/domain/models/huang_ji_formula_json_test.dart');
  if (!await jsonTestFile.exists()) {
    print('❌ 错误: huang_ji_formula_json_test.dart 文件不存在');
    return;
  }
  
  final integrationTestFile = File('test/domain/models/huang_ji_formula_raw_number_integration_test.dart');
  if (!await integrationTestFile.exists()) {
    print('❌ 错误: huang_ji_formula_raw_number_integration_test.dart 文件不存在');
    return;
  }
  
  print('✅ 所有必要的测试文件都存在');
  print('📁 JSON 数据文件: ${jsonFile.path}');
  print('🧪 JSON 测试文件: ${jsonTestFile.path}');
  print('🔗 集成测试文件: ${integrationTestFile.path}');
  
  // 读取 JSON 文件大小
  final jsonSize = await jsonFile.length();
  print('📊 JSON 文件大小: ${jsonSize} 字节');
  
  print('\n=== 测试文件准备完成 ===');
  print('请运行以下命令来执行测试:');
  print('dart test test/domain/models/huang_ji_formula_json_test.dart');
  print('dart test test/domain/models/huang_ji_formula_raw_number_integration_test.dart');
}