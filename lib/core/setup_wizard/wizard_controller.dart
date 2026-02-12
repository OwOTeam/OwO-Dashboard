import 'package:flutter/material.dart';
import '../services/persistence_service.dart';
import '../utils/logger.dart';
import 'wizard_step.dart';

class WizardController extends ChangeNotifier {
  int _currentStep = 0;
  final List<WizardStep> _steps;

  String? _selectedPath;
  bool _logEnabled = true;
  bool _isCompleted = false;
  VoidCallback? onCompleted;

  WizardController({required List<WizardStep> steps}) : _steps = steps {
    if (_steps.isNotEmpty) {
      _steps[0].onInit();
    }
  }

  int get currentStep => _currentStep;
  int get totalSteps => _steps.length;
  String? get selectedPath => _selectedPath;
  bool get logEnabled => _logEnabled;
  bool get isCompleted => _isCompleted;

  // 进度计算
  double get progress => (_currentStep + 1) / totalSteps;

  int get remainingItems => totalSteps - (_currentStep + 1);

  String get currentStepTitle => _steps[_currentStep].title;

  WizardStep get currentStepInstance => _steps[_currentStep];

  /// 根据索引获取步骤实例
  WizardStep getStepAt(int index) {
    if (index < 0 || index >= _steps.length) {
      throw RangeError('Step index out of range: $index');
    }
    return _steps[index];
  }

  void setSelectedPath(String path) {
    _selectedPath = path;
    notifyListeners();
  }

  void setLogEnabled(bool value) {
    _logEnabled = value;
    notifyListeners();
  }

  bool get canGoNext {
    // 存储路径步骤（步骤索引0）必须选择路径
    if (_currentStep == 0 && _selectedPath == null) {
      return false;
    }
    return _steps[_currentStep].canGoNext();
  }

  void nextStep() {
    if (canGoNext) {
      if (_currentStep < totalSteps - 1) {
        _steps[_currentStep].onComplete();
        _currentStep++;
        _steps[_currentStep].onInit();
        notifyListeners();
      } else {
        _complete();
      }
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _steps[_currentStep].onInit();
      notifyListeners();
    }
  }

  Future<void> _complete() async {
    if (_selectedPath != null) {
      await _steps[_currentStep].onComplete();

      // 使用 PersistenceService 统一处理路径（追加 AppName 并清洗）
      await PersistenceService().init(customPath: _selectedPath);

      await PersistenceService().setBool('log_enabled', _logEnabled);
      await AppLogger.init();
      await PersistenceService().setBool('is_first_launch', false);
      await PersistenceService().setString('data_root_path', _selectedPath!);

      _isCompleted = true;
      notifyListeners();
      onCompleted?.call();
    }
  }
}
