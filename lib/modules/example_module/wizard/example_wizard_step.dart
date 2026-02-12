import 'package:flutter/material.dart';
import '../../../core/setup_wizard/wizard_step.dart';
import '../localization/example_localization_keys.dart';
import '../../../core/services/localization_service.dart';

/// 示例向导步骤（已整合到 ExamplePagesModule）
class ExampleWizardStep extends WizardStep {
  @override
  String get id => 'example_step';

  @override
  String get title => ExampleLocalizationKeys.exampleWizardStepTitle;

  @override
  int get priority => 50;

  @override
  bool canGoNext() => true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        ExampleLocalizationKeys.exampleWizardStepTitle.tr(context),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  @override
  Map<String, String>? getSummary() {
    return {'示例配置': '已启用'};
  }
}
