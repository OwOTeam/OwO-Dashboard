import '../../core/module_registry/module_registrar.dart';
import '../../core/settings_pages/settings_page_registry.dart';
import 'pages/example_settings_page.dart';

/// 示例设置页面模块
class MySettingsPagesModule implements ModuleRegistrar {
  @override
  String get moduleName => 'my_settings_pages';

  @override
  void register() {
    // 注册自定义设置页面
    final registry = SettingsPageRegistry();
    registry.register('example_settings', () => ExampleSettingsPage());

    // 在此处注册更多设置页面...
  }
}
