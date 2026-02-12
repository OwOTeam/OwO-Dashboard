import 'package:flutter/material.dart';
import '../../../core/setup_wizard/wizard_step.dart';

/// 示例向导步骤
///
/// 这是一个模板，展示如何创建自定义向导步骤
class ExampleWizardStep extends WizardStep {
  @override
  String get id => 'example_step';

  @override
  String get title => '示例步骤';

  @override
  int get priority => 50; // 优先级，数字越小越靠前

  @override
  bool canGoNext() {
    // 返回是否可以进入下一步
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('这是一个示例向导步骤'));
  }

  @override
  Map<String, String>? getSummary() {
    // 返回配置摘要（可选）
    return {'示例配置': '示例值'};
  }
}
