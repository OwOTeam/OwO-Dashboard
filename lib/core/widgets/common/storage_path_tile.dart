import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class StoragePathTile extends StatelessWidget {
  final String? currentPath;
  final Function(String) onPathSelected;
  final String title;
  final String subtitle;
  final bool showHeader;
  final EdgeInsetsGeometry contentPadding;

  const StoragePathTile({
    super.key,
    required this.currentPath,
    required this.onPathSelected,
    this.title = '数据存储路径',
    this.subtitle = '应用的所有配置、日志和缓存文件都将保存在这个地方。',
    this.showHeader = true,
    this.contentPadding = const EdgeInsets.all(16),
  });

  Future<void> _pickPath() async {
    String? result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '请选择应用数据存储路径',
    );
    if (result != null) {
      onPathSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader)
            Row(
              children: [
                Icon(
                  Icons.folder_open,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_location_alt_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
          if (showHeader) const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              currentPath ?? '未选择路径',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: currentPath != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (!showHeader) {
      return InkWell(onTap: _pickPath, child: content);
    }

    return InkWell(
      onTap: _pickPath,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
        ),
        child: content,
      ),
    );
  }
}
