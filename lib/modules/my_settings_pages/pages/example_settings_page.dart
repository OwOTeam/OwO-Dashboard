import 'package:flutter/material.dart';
import '../../../core/settings_pages/settings_page_item.dart';

/// 示例设置页面
///
/// 这是一个模板，展示如何创建自定义设置页面
class ExampleSettingsPage extends SettingsPageItem {
  @override
  String get id => 'example_settings';

  @override
  String get title => '示例设置';

  @override
  IconData get icon => Icons.extension;

  @override
  int get priority => 50; // 优先级，数字越小越靠前

  @override
  String? get description => '这是一个示例设置页面';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('这是一个示例设置页面', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text(
            '您可以在 modules/my_settings_pages/pages/ 目录下创建自己的设置页面。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('提示'),
              subtitle: const Text('设置页面会自动添加到设置菜单中'),
            ),
          ),
        ],
      ),
    );
  }
}
