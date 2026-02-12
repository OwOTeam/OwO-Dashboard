import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../services/persistence_service.dart';
import '../theme/app_theme_data.dart';
import '../utils/logger.dart';
import '../widgets/common/snack_bar.dart';
import '../widgets/common/storage_path_tile.dart';
import '../widgets/common/dialog.dart';

class GeneralSettingsPage extends StatefulWidget {
  final VoidCallback onBack;
  const GeneralSettingsPage({super.key, required this.onBack});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
  String? _currentPath;
  bool _logEnabled = true;
  double _logMaxSizeMb = 5;

  @override
  void initState() {
    super.initState();
    _currentPath = PersistenceService().rootPath;
    final settings = AppLogger.loadSettings();
    _logEnabled = settings.enabled;
    _logMaxSizeMb = settings.maxFileSizeMb.toDouble();
  }

  Future<void> _updatePath(String newPath) async {
    if (_currentPath == newPath) return;

    final result = await showAdvancedConfirmDialog(
      context: context,
      title: '修改存储路径',
      content: '修改存储路径后，应用将重新初始化该目录下的数据文件。建议手动将原目录文件移动到新目录以保留数据。是否继续？',
      icon: Icons.warning_amber_rounded,
      confirmText: '确认修改',
      cancelText: '取消',
    );

    if (result == true) {
      // PersistenceService().init 内部会自动处理追加 AppName 和清洗特殊字符
      await PersistenceService().init(customPath: newPath);
      final finalPath = PersistenceService().rootPath!;

      // 存储最终生成的完整路径
      await PersistenceService().set('data_root_path', finalPath);
      await AppLogger.init();

      setState(() {
        _currentPath = finalPath;
      });

      if (mounted) {
        SnackBarHelper.showSuccess(context, '路径修改成功，应用已自动连接新位置。');
      }
    }
  }

  Future<void> _updateLogEnabled(bool value) async {
    setState(() {
      _logEnabled = value;
    });
    await AppLogger.updateSettings(enabled: value);
  }

  Future<void> _updateLogMaxSize(double value) async {
    final rounded = value.round().clamp(1, 1024);
    setState(() {
      _logMaxSizeMb = rounded.toDouble();
    });
    await AppLogger.updateSettings(maxFileSizeMb: rounded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(AppThemeData.spacingMedium),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              const SizedBox(width: AppThemeData.spacingSmall),
              Text('常规设置', style: theme.textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: AppThemeData.spacingMedium),
          _buildStorageSection(theme),
          const SizedBox(height: AppThemeData.spacingLarge),
          _buildLogSection(theme),
          const SizedBox(height: AppThemeData.spacingLarge),
          _buildDangerSection(context, theme),
        ],
      ),
    );
  }

  Widget _buildStorageSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppThemeData.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppThemeData.borderRadiusSmall,
                    ),
                  ),
                  child: Icon(
                    Icons.folder_open,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppThemeData.spacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('应用存储', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('设置应用数据的保存位置', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppThemeData.spacingMedium),
            StoragePathTile(
              currentPath: _currentPath,
              onPathSelected: _updatePath,
              showHeader: false,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppThemeData.spacingSmall),
            Text(
              '数据目录包含配置、插件路径与日志等核心信息',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppThemeData.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppThemeData.borderRadiusSmall,
                    ),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppThemeData.spacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('应用日志', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('记录运行过程，便于排查问题', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Switch(value: _logEnabled, onChanged: _updateLogEnabled),
              ],
            ),
            const SizedBox(height: AppThemeData.spacingMedium),
            Row(
              children: [
                Expanded(
                  child: Text('日志分割大小', style: theme.textTheme.bodyMedium),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_logMaxSizeMb.toInt()} MB',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: _logMaxSizeMb,
              min: 1,
              max: 50,
              divisions: 49,
              label: '${_logMaxSizeMb.toInt()} MB',
              onChanged: _logEnabled
                  ? (value) => setState(() => _logMaxSizeMb = value)
                  : null,
              onChangeEnd: _logEnabled ? _updateLogMaxSize : null,
            ),
            Text(
              '建议按使用强度调整，避免日志文件过大',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerSection(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppThemeData.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      AppThemeData.borderRadiusSmall,
                    ),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppThemeData.spacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('危险操作', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('重置后需要重新完成初始化', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppThemeData.spacingMedium),
            _buildResetButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return InkWell(
      onTap: () => _handleResetApp(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
          color: Colors.red.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Icon(Icons.restore, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '重置应用',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '清除所有配置和缓存，重新引导初始化',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: Colors.red.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleResetApp(BuildContext context) async {
    // 第一次确认
    final firstConfirm = await showAdvancedConfirmDialog(
      context: context,
      title: '确认重置应用？',
      content: '此操作将清除所有配置、缓存数据，并重新引导您完成初始化。\n\n该操作不可撤销！',
      icon: Icons.warning_amber_rounded,
      confirmColor: Colors.orange,
      confirmText: '继续',
      cancelText: '取消',
    );

    if (firstConfirm != true) return;

    // 第二次确认
    final secondConfirm = await showAdvancedConfirmDialog(
      context: context,
      title: '最后确认',
      content: '您真的要重置应用吗？所有数据将被清除且无法恢复。',
      icon: Icons.error_outline,
      confirmColor: Colors.red,
      confirmText: '确认重置',
      cancelText: '取消',
    );

    if (secondConfirm != true) return;

    try {
      if (!mounted) return;

      showLoadingDialog(context: context, title: '正在重置应用...', content: '请稍候');

      await PersistenceService().resetApp();

      if (!mounted) return;

      Navigator.of(context).pop(); // 关闭加载对话框

      // 显示成功提示并重启应用
      await showAdvancedConfirmDialog(
        context: context,
        title: '重置成功',
        content: '应用将重新启动以完成初始化',
        icon: Icons.check_circle_outline,
        confirmColor: Colors.green,
        confirmText: '确定',
        cancelText: '',
      );

      // 重启应用
      if (mounted) {
        final executable = Platform.resolvedExecutable;
        await Process.start(executable, []);
        await windowManager.destroy();
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop(); // 关闭加载对话框
      SnackBarHelper.showError(context, '重置失败: $e');
    }
  }
}
