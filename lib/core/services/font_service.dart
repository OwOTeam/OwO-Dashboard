import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../utils/logger.dart';
import 'persistence_service.dart';

/// 字体资源管理服务
/// 负责处理字体文件的迁移（从 Roaming 默认目录到用户配置目录）以及动态加载
class FontService {
  static final FontService _instance = FontService._internal();
  factory FontService() => _instance;
  FontService._internal();

  bool _isMigrated = false;
  bool _isLoaded = false;

  bool get isMigrated => _isMigrated;
  bool get isLoaded => _isLoaded;

  /// 执行迁移和加载
  /// 通常在 SetupWizard 完成后或 App 启动时（如果已配置路径）调用
  Future<void> initialize() async {
    final persistence = PersistenceService();
    final rootPath = persistence.rootPath;

    // 如果还没有根路径（未初始化完成），则跳过
    if (rootPath == null || persistence.getString('data_root_path') == null) {
      AppLogger.info(
        'FontService: No data root path configured, skipping migration.',
      );
      return;
    }

    await migrateFonts();
    await loadFonts();
  }

  /// 将字体文件从 Roaming 默认路径迁移到配置路径
  Future<void> migrateFonts() async {
    try {
      final persistence = PersistenceService();
      final rootPath = persistence.rootPath;
      if (rootPath == null) return;

      final targetFontsDir = Directory(p.join(rootPath, 'assets', 'fonts'));

      // 获取默认的 Roaming 路径 (C:\Users\<user>\AppData\Roaming\com.owoblog\owo_dashboard)
      final supportDir = await getApplicationSupportDirectory();
      final sourceDir = supportDir;

      if (!await sourceDir.exists()) {
        AppLogger.info(
          'FontService: Source directory does not exist: ${sourceDir.path}',
        );
        return;
      }

      // 确保目标目录存在
      if (!await targetFontsDir.exists()) {
        await targetFontsDir.create(recursive: true);
      }

      AppLogger.info('FontService: Checking for fonts in ${sourceDir.path}');

      final entities = await sourceDir.list().toList();
      int movedCount = 0;

      for (final entity in entities) {
        if (entity is File) {
          final fileName = p.basename(entity.path);
          final targetFile = File(p.join(targetFontsDir.path, fileName));

          // 移动文件 (复制并删除原文件)
          AppLogger.info(
            'FontService: Migrating file $fileName to ${targetFile.path}',
          );
          await entity.copy(targetFile.path);
          await entity.delete();
          movedCount++;
        }
      }

      if (movedCount > 0) {
        AppLogger.info('FontService: Successfully migrated $movedCount fonts.');
      }
      _isMigrated = true;
    } catch (e, s) {
      AppLogger.error('FontService: Font migration failed', e, s);
    }
  }

  /// 从配置路径动态加载字体到 Flutter 引擎
  Future<void> loadFonts() async {
    try {
      final persistence = PersistenceService();
      final rootPath = persistence.rootPath;
      if (rootPath == null) return;

      final targetFontsDir = Directory(p.join(rootPath, 'assets', 'fonts'));
      if (!await targetFontsDir.exists()) {
        AppLogger.warning(
          'FontService: Target fonts directory does not exist: ${targetFontsDir.path}',
        );
        return;
      }

      final entities = await targetFontsDir.list().toList();

      // 按 Family 分组加载，因为一个 Family 可能有多个文件 (Regular, Bold 等)
      // 在这个项目中，我们主要关注 MicrosoftYaHei
      final Map<String, List<File>> fontFamilies = {};

      for (final entity in entities) {
        if (entity is File && entity.path.toLowerCase().endsWith('.ttf')) {
          final fileName = p.basenameWithoutExtension(entity.path);
          String family = 'MicrosoftYaHei'; // 默认

          if (fileName.contains('Microsoft-YaHei')) {
            family = 'MicrosoftYaHei';
          } else {
            // 其他字体则使用文件名作为 Family
            family = fileName.split('-').first;
          }

          fontFamilies.putIfAbsent(family, () => []).add(entity);
        }
      }

      for (final entry in fontFamilies.entries) {
        final family = entry.key;
        final files = entry.value;

        final fontLoader = FontLoader(family);
        for (final file in files) {
          final fontData = await file.readAsBytes();
          fontLoader.addFont(Future.value(ByteData.view(fontData.buffer)));
          AppLogger.info(
            'FontService: Adding $family font variant: ${p.basename(file.path)}',
          );
        }

        await fontLoader.load();
        AppLogger.info('FontService: Successfully loaded font family: $family');
      }

      _isLoaded = true;
    } catch (e, s) {
      AppLogger.error('FontService: Dynamic font loading failed', e, s);
    }
  }
}
