import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PermissionService extends GetxService {
  
  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      debugPrint('PermissionService: Requesting notification permission');
      final status = await Permission.notification.request();
      
      debugPrint('PermissionService: Notification permission status: $status');
      return _isPermissionGranted(status);
    } catch (e) {
      debugPrint('PermissionService: Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check if notification permission is granted
  Future<bool> hasNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      debugPrint('PermissionService: Current notification permission: $status');
      return _isPermissionGranted(status);
    } catch (e) {
      debugPrint('PermissionService: Error checking notification permission: $e');
      return false;
    }
  }

  /// Request storage permission for data backup/restore
  Future<bool> requestStoragePermission() async {
    try {
      debugPrint('PermissionService: Requesting storage permission');
      final status = await Permission.storage.request();
      
      debugPrint('PermissionService: Storage permission status: $status');
      return _isPermissionGranted(status);
    } catch (e) {
      debugPrint('PermissionService: Error requesting storage permission: $e');
      return false;
    }
  }

  /// Request exact alarm permission (Android 12+)
  Future<bool> requestExactAlarmPermission() async {
    try {
      debugPrint('PermissionService: Requesting exact alarm permission');
      
      // For Android 12+ (API 31+)
      final status = await Permission.systemAlertWindow.request();
      debugPrint('PermissionService: Exact alarm permission status: $status');
      
      return _isPermissionGranted(status);
    } catch (e) {
      debugPrint('PermissionService: Error requesting exact alarm permission: $e');
      return false;
    }
  }

  /// Request phone permission for full-screen notifications
  Future<bool> requestPhonePermission() async {
    try {
      debugPrint('PermissionService: Requesting phone permission');
      final status = await Permission.phone.request();
      
      debugPrint('PermissionService: Phone permission status: $status');
      return _isPermissionGranted(status);
    } catch (e) {
      debugPrint('PermissionService: Error requesting phone permission: $e');
      return false;
    }
  }

  /// Request all required permissions
  Future<Map<Permission, bool>> requestAllPermissions() async {
    debugPrint('PermissionService: Requesting all permissions');
    
    final results = <Permission, bool>{};
    
    try {
      // Request multiple permissions at once
      final statuses = await [
        Permission.notification,
        Permission.storage,
        Permission.systemAlertWindow, // For exact alarms
      ].request();

      // Process results
      statuses.forEach((permission, status) {
        results[permission] = _isPermissionGranted(status);
        debugPrint('PermissionService: $permission = $status (${results[permission]})');
      });

    } catch (e) {
      debugPrint('PermissionService: Error requesting multiple permissions: $e');
    }

    return results;
  }

  /// Check all permission statuses
  Future<Map<Permission, PermissionStatus>> checkAllPermissions() async {
    debugPrint('PermissionService: Checking all permissions');
    
    try {
      final permissions = [
        Permission.notification,
        Permission.storage,
        Permission.systemAlertWindow,
        Permission.phone,
      ];

      final statuses = <Permission, PermissionStatus>{};
      
      for (final permission in permissions) {
        final status = await permission.status;
        statuses[permission] = status;
        debugPrint('PermissionService: $permission status: $status');
      }

      return statuses;
    } catch (e) {
      debugPrint('PermissionService: Error checking permissions: $e');
      return {};
    }
  }

  /// Show permission rationale dialog
  Future<bool> showPermissionRationale(Permission permission) async {
    String title = '';
    String message = '';

    switch (permission) {
      case Permission.notification:
        title = 'การอนุญาติแจ้งเตือน';
        message = 'แอปต้องการส่งการแจ้งเตือนเพื่อเตือนให้คุณออกกำลังกายตามช่วงเวลาที่กำหนด';
        break;
      case Permission.storage:
        title = 'การอนุญาติการจัดเก็บข้อมูล';
        message = 'แอปต้องการสิทธิ์ในการจัดเก็บข้อมูลเพื่อบันทึกการตั้งค่าและประวัติการใช้งาน';
        break;
      case Permission.systemAlertWindow:
        title = 'การอนุญาติการแจ้งเตือนแบบแม่นยำ';
        message = 'แอปต้องการสิทธิ์ในการตั้งการแจ้งเตือนที่เวลาแม่นยำเพื่อให้การเตือนออกกำลังกายทำงานได้ดีที่สุด';
        break;
      default:
        title = 'การอนุญาติ';
        message = 'แอปต้องการสิทธิ์นี้เพื่อให้ทำงานได้อย่างสมบูรณ์';
    }

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('ไม่อนุญาต'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('อนุญาต'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Open app settings if permission is permanently denied
  Future<void> openAppSettings() async {
    debugPrint('PermissionService: Opening app settings');
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('PermissionService: Error opening app settings: $e');
    }
  }

  /// Check if permission is granted (แก้ไข limitedGranted ที่ไม่มี)
  bool _isPermissionGranted(PermissionStatus status) {
    return status == PermissionStatus.granted || 
           status == PermissionStatus.limited; // ใช้ limited แทน limitedGranted
  }

  /// Get permission status text in Thai
  String getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'อนุญาตแล้ว';
      case PermissionStatus.denied:
        return 'ไม่อนุญาต';
      case PermissionStatus.restricted:
        return 'ถูกจำกัด';
      case PermissionStatus.limited:
        return 'อนุญาตบางส่วน';
      case PermissionStatus.permanentlyDenied:
        return 'ปฏิเสธถาวร';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  /// Show permission denied dialog with option to open settings
  Future<void> showPermissionDeniedDialog(Permission permission) async {
    debugPrint('PermissionService: Showing permission denied dialog');
    await Get.dialog(
      AlertDialog(
        title: const Text('ไม่ได้รับอนุญาต'),
        content: Text(
          'จำเป็นต้องได้รับการอนุญาติเพื่อให้แอปทำงานได้อย่างสมบูรณ์\n'
          'กรุณาเปิดการตั้งค่าและอนุญาติสิทธิ์ที่จำเป็น'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ปิด'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('เปิดการตั้งค่า'),
          ),
        ],
      ),
    );
  }

  debugPrint('PermissionService: Initialized');
}