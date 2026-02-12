import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../wizard_step.dart';
import '../wizard_controller.dart';
import 'dart:io';

/// 配置确认步骤
class SummaryStep extends WizardStep {
  SummaryStep();

  @override
  String get id => 'summary';

  @override
  String get title => '配置确认';

  @override
  int get priority => 1000; // 总结步骤始终最后

  @override
  bool canGoNext() => true;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WizardController>();
    final summaryItems = _collectSummaryItems(controller);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              '配置摘要',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '已完成 ${controller.currentStep} 个配置步骤',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            itemCount: summaryItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = summaryItems[index];
              return _buildSummaryCard(context, item);
            },
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '点击"完成初始化"后，应用将根据以上配置自动初始化并启动。',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 智能收集所有步骤的配置摘要
  List<_SummaryItem> _collectSummaryItems(WizardController controller) {
    final items = <_SummaryItem>[];

    // 遍历所有已完成的步骤（不包括当前的 Summary 步骤）
    for (int i = 0; i < controller.currentStep; i++) {
      final step = controller.getStepAt(i);
      final stepTitle = step.title;

      // 获取步骤的配置摘要
      final summary = step.getSummary();

      if (summary != null && summary.isNotEmpty) {
        // 如果步骤提供了自定义摘要
        items.add(
          _SummaryItem(
            stepTitle: stepTitle,
            icon: _getIconForStep(i),
            configurations: summary,
          ),
        );
      } else {
        // 智能推断配置内容
        final inferredConfig = _inferStepConfiguration(i, controller);
        if (inferredConfig.isNotEmpty) {
          items.add(
            _SummaryItem(
              stepTitle: stepTitle,
              icon: _getIconForStep(i),
              configurations: inferredConfig,
            ),
          );
        }
      }
    }

    return items;
  }

  /// 智能推断步骤配置
  Map<String, String> _inferStepConfiguration(
    int stepIndex,
    WizardController controller,
  ) {
    switch (stepIndex) {
      case 0: // Storage path step (现在是第一个步骤)
        final path = controller.selectedPath;
        if (path != null) {
          final dir = Directory(path);
          final pathName = dir.path.split(Platform.pathSeparator).last;
          return {'存储路径': path, '目录名称': pathName, '路径类型': _getPathType(path)};
        }
        return {};
      case 1:
        return {'日志记录': controller.logEnabled ? '已启用' : '已关闭'};
      default:
        return {};
    }
  }

  /// 获取路径类型描述
  String _getPathType(String path) {
    if (path.contains('Documents')) return '文档目录';
    if (path.contains('AppData')) return '应用数据目录';
    if (path.contains('Desktop')) return '桌面';
    if (path.contains('Downloads')) return '下载目录';
    return '自定义路径';
  }

  /// 根据步骤索引获取图标
  IconData _getIconForStep(int stepIndex) {
    switch (stepIndex) {
      case 0: // Storage path step
        return Icons.folder_open;
      case 1:
        return Icons.description_outlined;
      default:
        return Icons.settings;
    }
  }

  /// 构建配置摘要卡片
  Widget _buildSummaryCard(BuildContext context, _SummaryItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                item.stepTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...item.configurations.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 配置摘要项
class _SummaryItem {
  final String stepTitle;
  final IconData icon;
  final Map<String, String> configurations;

  _SummaryItem({
    required this.stepTitle,
    required this.icon,
    required this.configurations,
  });
}
