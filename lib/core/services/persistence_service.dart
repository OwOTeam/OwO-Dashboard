import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'bootstrap_service.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

/// App 内置持久化存储系统
/// 用于替代 shared_preferences，支持自定义存储路径
class PersistenceService {
  static final PersistenceService _instance = PersistenceService._internal();
  factory PersistenceService() => _instance;
  PersistenceService._internal();

  String? _rootPath;
  File? _settingsFile;
  Map<String, dynamic> _data = {};
  bool _initialized = false;

  bool get isInitialized => _initialized;
  String? get rootPath => _rootPath;

  /// 清洗路径名称，去除特殊字符
  static String sanitizeDirectoryName(String name) {
    // 允许字母、数字、空格、下划线、连字符、点
    // 过滤掉 Windows/Linux 不允许的字符: < > : " / \ | ? *
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '').trim();
  }

  /// 获取处理后的存储根路径（追加 AppName）
  static String getProcessedRootPath(String baseDir) {
    final sanitizedAppName = sanitizeDirectoryName(AppConstants.appName);
    // 如果 baseDir 已经是以 sanitizedAppName 结尾，则不再追加
    if (p.basename(baseDir) == sanitizedAppName) {
      return baseDir;
    }
    return p.join(baseDir, sanitizedAppName);
  }

  /// 初始化存储系统
  /// [customPath] 如果提供，则使用该路径存储数据；否则使用默认的应用文档目录
  Future<void> init({String? customPath}) async {
    if (customPath != null) {
      _rootPath = getProcessedRootPath(customPath);
    } else {
      // 默认路径：Documents/OwODashboard
      final appDocDir = await getApplicationDocumentsDirectory();
      _rootPath = getProcessedRootPath(appDocDir.path);
    }

    // 处理旧数据迁移 (从 Roaming 迁移到新路径)
    // 只有在首次启动且选择了自定义路径时才执行迁移
    final bootstrap = BootstrapService();
    if (bootstrap.isFirstLaunch() && customPath != null) {
      await _performFullMigration(_rootPath!);
    }

    try {
      final directory = Directory(_rootPath!);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 同步路径到引导文件，确保下次启动能找到
      if (bootstrap.isInitialized) {
        await bootstrap.setDataPath(_rootPath!);
      }

      _settingsFile = File(p.join(_rootPath!, 'settings.json'));
      await _load();
      _initialized = true;
      AppLogger.info('PersistenceService initialized at: $_rootPath');
    } catch (e) {
      AppLogger.error('PersistenceService initialization failed: $e');
    }
  }

  /// 执行全量数据迁移（从默认 Roaming 路径迁移到自定义路径）
  Future<void> _performFullMigration(String targetPath) async {
    try {
      // 获取默认的 Roaming 路径 (C:\Users\<user>\AppData\Roaming\com.owoblog\OwO! Dashboard)
      final sourceDir = await getApplicationSupportDirectory();

      if (!await sourceDir.exists()) {
        AppLogger.info('PersistenceService: No legacy data to migrate.');
        return;
      }

      final targetDir = Directory(targetPath);
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // 如果源路径和目标路径相同，跳过
      if (p.equals(sourceDir.path, targetDir.path)) {
        AppLogger.info(
          'PersistenceService: Source and target are the same, skipping migration.',
        );
        return;
      }

      AppLogger.info(
        'PersistenceService: Migrating app data from ${sourceDir.path} to ${targetDir.path}',
      );

      // 递归复制所有内容
      await _copyDirectoryRecursive(sourceDir, targetDir);

      // 迁移完成后尝试删除源目录
      try {
        await sourceDir.delete(recursive: true);
        AppLogger.info('PersistenceService: Legacy data directory deleted.');
      } catch (e) {
        AppLogger.warning(
          'PersistenceService: Failed to delete legacy directory: $e',
        );
      }
    } catch (e, s) {
      AppLogger.error('PersistenceService: Full migration failed', e, s);
    }
  }

  /// 递归复制目录内容
  Future<void> _copyDirectoryRecursive(
    Directory source,
    Directory destination,
  ) async {
    await for (final entity in source.list(recursive: false)) {
      final name = p.basename(entity.path);
      final destPath = p.join(destination.path, name);

      if (entity is Directory) {
        final newDir = Directory(destPath);
        if (!await newDir.exists()) {
          await newDir.create(recursive: true);
        }
        await _copyDirectoryRecursive(entity, newDir);
      } else if (entity is File) {
        await entity.copy(destPath);
      }
    }
  }

  /// 加载数据
  Future<void> _load() async {
    if (_settingsFile == null || !await _settingsFile!.exists()) {
      _data = {};
      return;
    }

    try {
      final content = await _settingsFile!.readAsString();
      if (content.isNotEmpty) {
        _data = json.decode(content);
      }
    } catch (e) {
      AppLogger.warning('Error loading persistence data: $e');
      _data = {};
    }
  }

  /// 保存数据
  Future<void> _save() async {
    if (_settingsFile == null) return;
    try {
      final content = const JsonEncoder.withIndent('  ').convert(_data);
      await _settingsFile!.writeAsString(content);
    } catch (e) {
      AppLogger.warning('Error saving persistence data: $e');
    }
  }

  // ============ 通用操作 ============

  T? get<T>(String key, {T? defaultValue}) {
    final value = _data[key];
    if (value == null) return defaultValue;

    // 处理类型转换，例如 json 解码后 int 可能会变成 double (在某些情况下)
    if (T == int && value is num) return value.toInt() as T;
    if (T == double && value is num) return value.toDouble() as T;

    return value as T?;
  }

  String? getString(String key) => get<String>(key);
  int? getInt(String key) => get<int>(key);
  double? getDouble(String key) => get<double>(key);
  bool? getBool(String key) => get<bool>(key);
  List<String>? getStringList(String key) {
    final list = get<List<dynamic>>(key);
    return list?.map((e) => e.toString()).toList();
  }

  Future<void> set(String key, dynamic value) async {
    _data[key] = value;
    await _save();
  }

  Future<void> setString(String key, String value) => set(key, value);
  Future<void> setInt(String key, int value) => set(key, value);
  Future<void> setDouble(String key, double value) => set(key, value);
  Future<void> setBool(String key, bool value) => set(key, value);
  Future<void> setStringList(String key, List<String> value) => set(key, value);

  Future<void> remove(String key) async {
    _data.remove(key);
    await _save();
  }

  Future<void> clear() async {
    _data.clear();
    await _save();
  }

  bool containsKey(String key) => _data.containsKey(key);

  /// 重新定位存储路径（用于迁移数据）
  Future<void> migrateTo(String newPath) async {
    final oldPath = _rootPath;
    if (oldPath == null || oldPath == newPath) return;

    await init(customPath: newPath);
  }

  /// 重置应用（清除所有配置和缓存）
  Future<void> resetApp() async {
    try {
      // 1. 清除所有持久化数据
      _data.clear();
      if (_settingsFile != null && await _settingsFile!.exists()) {
        try {
          await _settingsFile!.delete();
        } catch (e) {
          AppLogger.warning('无法删除配置文件: $e');
        }
      }

      // 2. 清除应用数据目录（如果存在）
      if (_rootPath != null) {
        final rootDir = Directory(_rootPath!);
        if (await rootDir.exists()) {
          try {
            // 尝试删除目录内容
            await for (final entity in rootDir.list(recursive: false)) {
              try {
                if (entity is File) {
                  await entity.delete();
                } else if (entity is Directory) {
                  await entity.delete(recursive: true);
                }
              } catch (e) {
                // 静默处理单个文件/目录删除失败
                AppLogger.warning('无法删除: ${entity.path}');
              }
            }
            // 尝试删除目录本身
            try {
              await rootDir.delete();
            } catch (e) {
              AppLogger.warning('无法删除数据目录（可能包含同步文件）: $_rootPath');
            }
          } catch (e) {
            AppLogger.warning('清除数据目录失败: $e');
          }
        }
      }

      // 3. 清除应用专属的临时缓存（仅限 Flutter 应用缓存）
      try {
        final tempDir = await getTemporaryDirectory();
        final appCacheDir = Directory(
          p.join(tempDir.path, 'owo_dashboard_cache'),
        );

        if (await appCacheDir.exists()) {
          try {
            await appCacheDir.delete(recursive: true);
            AppLogger.info('已清除应用缓存');
          } catch (e) {
            AppLogger.warning('清除应用缓存失败: $e');
          }
        }
      } catch (e) {
        AppLogger.warning('访问临时目录失败: $e');
      }

      // 4. 重置初始化状态
      _initialized = false;
      _rootPath = null;
      _settingsFile = null;

      // 5. 重置引导配置
      await BootstrapService().reset();

      AppLogger.info('应用已重置');
    } catch (e) {
      AppLogger.error('重置应用失败: $e');
      rethrow;
    }
  }
}
