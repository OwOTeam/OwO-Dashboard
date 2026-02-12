import '../../core/module_registry/module_registrar.dart';
import '../../core/setup_wizard/wizard_step_registry.dart';
import 'steps/example_wizard_step.dart';

/// 示例向导步骤模块
class MyWizardStepsModule implements ModuleRegistrar {
  @override
  String get moduleName => 'my_wizard_steps';

  @override
  void register() {
    // 注册自定义向导步骤
    final registry = WizardStepRegistry();
    registry.register('example_step', () => ExampleWizardStep());

    // 在此处注册更多步骤...
  }
}
