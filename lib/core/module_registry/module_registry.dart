import 'module_registrar.dart';
import '../setup_wizard/wizard_step_registry.dart';
import '../settings_pages/settings_page_registry.dart';

/// 模块注册管理器
class ModuleRegistry {
  static final ModuleRegistry _instance = ModuleRegistry._internal();
  factory ModuleRegistry() => _instance;
  ModuleRegistry._internal();

  final List<ModuleRegistrar> _modules = [];
  bool _initialized = false;

  /// 注册模块
  void registerModule(ModuleRegistrar module) {
    if (_initialized) {
      throw StateError('Cannot register modules after initialization');
    }
    _modules.add(module);
  }

  /// 初始化所有模块
  void initializeAll() {
    if (_initialized) return;

    for (final module in _modules) {
      module.register();
    }

    _initialized = true;
  }

  /// 获取向导步骤注册表
  WizardStepRegistry get wizardSteps => WizardStepRegistry();

  /// 获取设置页面注册表
  SettingsPageRegistry get settingsPages => SettingsPageRegistry();

  /// 清空所有注册（仅用于测试）
  void clear() {
    _modules.clear();
    _initialized = false;
    WizardStepRegistry().clear();
    SettingsPageRegistry().clear();
  }
}
