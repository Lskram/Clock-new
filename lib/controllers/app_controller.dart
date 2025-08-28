import 'package:get/get.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';
import '../models/user_settings.dart';
import '../models/pain_point.dart';
import '../models/treatment.dart';

class AppController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final PermissionService _permissionService = Get.find<PermissionService>();

  // Initialization state
  double _initializationProgress = 0.0;
  String _initializationMessage = 'กำลังเริ่มต้น...';

  // App state
  UserSettings? _userSettings;
  List<PainPoint> _availablePainPoints = [];
  List<Treatment> _availableTreatments = [];
  bool _isFirstTimeSetup = true;

  // Getters
  double get initializationProgress => _initializationProgress;
  String get initializationMessage => _initializationMessage;
  UserSettings? get userSettings => _userSettings;
  List<PainPoint> get availablePainPoints => _availablePainPoints;
  List<Treatment> get availableTreatments => _availableTreatments;
  bool get isFirstTimeSetup => _isFirstTimeSetup;

  @override
  void onInit() {
    super.onInit();
    // การเตรียมข้อมูลเริ่มต้นจะเรียกผ่าน initializeApp()
  }

  Future<void> initializeApp() async {
    try {
      // Step 1: Initialize database (20%)
      _updateProgress(0.2, 'เตรียมฐานข้อมูล...');
      await _initializeDatabase();

      // Step 2: Load user settings (40%)
      _updateProgress(0.4, 'โหลดการตั้งค่า...');
      await _loadUserSettings();

      // Step 3: Load pain points and treatments (60%)
      _updateProgress(0.6, 'โหลดข้อมูลการรักษา...');
      await _loadPainPointsAndTreatments();

      // Step 4: Check permissions (80%)
      _updateProgress(0.8, 'ตรวจสอบสิทธิ์...');
      await _checkPermissions();

      // Step 5: Initialize notifications (100%)
      _updateProgress(1.0, 'เตรียมการแจ้งเตือน...');
      await _initializeNotifications();

      print('App initialization completed successfully');
    } catch (e) {
      print('Error during app initialization: $e');
      _updateProgress(1.0, 'เกิดข้อผิดพลาด');
    }
  }

  Future<void> _initializeDatabase() async {
    // Database service should already be initialized in main.dart
    // This step just ensures it's ready
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _loadUserSettings() async {
    _userSettings = await _databaseService.getUserSettings();
    _isFirstTimeSetup = _userSettings?.isFirstTimeSetup ?? true;

    print('User settings loaded. First time setup: $_isFirstTimeSetup');
  }

  Future<void> _loadPainPointsAndTreatments() async {
    // Load default pain points
    _availablePainPoints = PainPointData.getAllPainPoints();

    // Load user's selected pain points from database
    if (_userSettings != null &&
        _userSettings!.selectedPainPointIds.isNotEmpty) {
      for (int i = 0; i < _availablePainPoints.length; i++) {
        if (_userSettings!.selectedPainPointIds
            .contains(_availablePainPoints[i].id)) {
          _availablePainPoints[i] =
              _availablePainPoints[i].copyWith(isSelected: true);
        }
      }
    }

    // Load treatments
    _availableTreatments = TreatmentData.getAllTreatments();

    // Load custom treatments from database
    final customTreatments = await _databaseService.getCustomTreatments();
    _availableTreatments.addAll(customTreatments);
  }

  Future<void> _checkPermissions() async {
    // Check notification permissions
    final hasNotificationPermission =
        await _permissionService.hasNotificationPermission();
    if (!hasNotificationPermission) {
      print('Notification permission not granted');
    }

    // Check exact alarm permission (Android 12+)
    final hasExactAlarmPermission =
        await _permissionService.hasExactAlarmPermission();
    if (!hasExactAlarmPermission) {
      print('Exact alarm permission not granted');
    }
  }

  Future<void> _initializeNotifications() async {
    if (_userSettings != null &&
        _userSettings!.isNotificationEnabled &&
        !_userSettings!.isFirstTimeSetup) {
      // Schedule next notification if settings allow
      await _notificationService.scheduleNextNotification();
    }
  }

  void _updateProgress(double progress, String message) {
    _initializationProgress = progress;
    _initializationMessage = message;
    update(); // Notify GetBuilder widgets
  }

  // Methods called from other parts of the app
  Future<void> completeFirstTimeSetup(List<int> selectedPainPointIds) async {
    final newSettings = UserSettings(
      selectedPainPointIds: selectedPainPointIds,
      isFirstTimeSetup: false,
      isNotificationEnabled: true,
    );

    await _databaseService.saveUserSettings(newSettings);
    _userSettings = newSettings;
    _isFirstTimeSetup = false;

    // Update selected pain points
    for (int i = 0; i < _availablePainPoints.length; i++) {
      _availablePainPoints[i] = _availablePainPoints[i].copyWith(
        isSelected: selectedPainPointIds.contains(_availablePainPoints[i].id),
      );
    }

    // Start notifications
    await _notificationService.scheduleNextNotification();

    update();
  }

  Future<void> updateUserSettings(UserSettings newSettings) async {
    await _databaseService.saveUserSettings(newSettings);
    _userSettings = newSettings;
    update();
  }

  List<PainPoint> getSelectedPainPoints() {
    return _availablePainPoints.where((pp) => pp.isSelected).toList();
  }

  List<Treatment> getTreatmentsForPainPoint(int painPointId) {
    return _availableTreatments
        .where((treatment) => treatment.painPointId == painPointId)
        .toList();
  }

  // App lifecycle methods
  void onAppPaused() {
    print('App paused');
  }

  void onAppResumed() {
    print('App resumed');
    // Refresh notification status when app comes back to foreground
    update();
  }

  void onAppDetached() {
    print('App detached');
  }
}
