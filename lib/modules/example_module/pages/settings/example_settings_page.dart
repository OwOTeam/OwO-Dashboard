import 'package:flutter/material.dart';
import '../../../../core/module_registry/settings_page/settings_page_item.dart';
import '../../localization/example_localization_keys.dart';
import '../../../../core/services/localization_service.dart';

/// 示例设置页面（已整合到 ExamplePagesModule）
class ExampleSettingsPage extends SettingsPageItem {
  @override
  String get id => 'example_settings';

  @override
  String getTitle(BuildContext context) {
    return ExampleLocalizationKeys.exampleSettingsTitle.tr(context);
  }

  @override
  IconData get icon => Icons.extension_outlined;

  @override
  int get priority => 80;

  @override
  String? getDescription(BuildContext context) {
    return ExampleLocalizationKeys.exampleSettingsDesc.tr(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ExampleLocalizationKeys.exampleSettingsTitle.tr(context),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            ExampleLocalizationKeys.exampleSettingsDesc.tr(context),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          _buildInfoCard(context),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: const ListTile(
        leading: Icon(Icons.auto_awesome),
        title: Text('模块化提示'),
        subtitle: Text('此页面现在完全由 ExamplePagesModule 独立管理。'),
      ),
    );
  }
}
