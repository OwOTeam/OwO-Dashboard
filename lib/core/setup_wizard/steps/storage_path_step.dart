import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../wizard_step.dart';
import '../wizard_controller.dart';
import '../../widgets/common/storage_path_tile.dart';

/// 存储路径选择步骤
class StoragePathStep extends WizardStep {
  StoragePathStep();

  @override
  String get id => 'storage_path';

  @override
  String get title => '选择存储路径';

  @override
  int get priority => 10;

  @override
  bool canGoNext() {
    // 这个方法会在控制器中调用，此时无法访问context
    // 所以我们需要在控制器中传递路径状态
    return true; // 临时返回true，实际验证在控制器中
  }

  @override
  Map<String, String>? getSummary() {
    // 此方法在 SummaryStep 中通过控制器调用
    // 返回 null 表示需要从控制器获取路径
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WizardController>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StoragePathTile(
          currentPath: controller.selectedPath,
          onPathSelected: (path) => controller.setSelectedPath(path),
        ),
        const SizedBox(height: 24),
        const Text(
          '提示：应用的所有配置、日志、缓存数据都将存放于此。',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
