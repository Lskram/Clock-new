import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      debugPrint('Notification permission status: $status');

      if (status.isDenied) {
        debugPrint('Notification permission denied');
        return false;
      }

      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  // Check notification permission status
  Future<bool> hasNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      debugPrint('Current notification permission status: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return false;
    }
  }

  // Request schedule exact alarm permission (Android 12+)
  Future<bool> requestScheduleExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.scheduleExactAlarm.request();
      debugPrint('Schedule exact alarm permission status: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting schedule exact alarm permission: $e');
      return false;
    }
  }

  // Check schedule exact alarm permission
  Future<bool> hasScheduleExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.scheduleExactAlarm.status;
      debugPrint('Current schedule exact alarm permission status: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking schedule exact alarm permission: $e');
      return false;
    }
  }

  // Request system alert window permission (for overlay notifications)
  Future<bool> requestSystemAlertWindowPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.systemAlertWindow.request();
      debugPrint('System alert window permission status: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting system alert window permission: $e');
      return false;
    }
  }

  // Check system alert window permission
  Future<bool> hasSystemAlertWindowPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.systemAlertWindow.status;
      debugPrint('Current system alert window permission status: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking system alert window permission: $e');
      return false;
    }
  }

  // Request all necessary permissions
  Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};

    debugPrint('Requesting all permissions...');

    // Notification permission
    results['notification'] = await requestNotificationPermission();

    // Schedule exact alarm permission (Android 12+)
    if (Platform.isAndroid) {
      results['scheduleExactAlarm'] =
          await requestScheduleExactAlarmPermission();
      results['systemAlertWindow'] = await requestSystemAlertWindowPermission();
    }

    debugPrint('Permission results: $results');
    return results;
  }

  // Check all permission statuses
  Future<Map<String, bool>> checkAllPermissions() async {
    final results = <String, bool>{};

    results['notification'] = await hasNotificationPermission();

    if (Platform.isAndroid) {
      results['scheduleExactAlarm'] = await hasScheduleExactAlarmPermission();
      results['systemAlertWindow'] = await hasSystemAlertWindowPermission();
    }

    return results;
  }

  // Check if all required permissions are granted
  Future<bool> hasAllRequiredPermissions() async {
    final permissions = await checkAllPermissions();

    // Notification is always required
    if (permissions['notification'] != true) return false;

    // Android specific permissions
    if (Platform.isAndroid) {
      if (permissions['scheduleExactAlarm'] != true) return false;
    }

    return true;
  }

  // Open app settings
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }

  // Show permission dialog
  Future<bool> showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('จำเป็นต้องได้รับอนุญาต'),
            content: const Text(
              'แอปนี้ต้องการอนุญาตในการส่งการแจ้งเตือนเพื่อช่วยเตือนคุณออกกำลังกาย\n\n'
              'กรุณาอนุญาตการแจ้งเตือนในการตั้งค่า',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('ยกเลิก'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                  await openAppSettings();
                },
                child: const Text('ไปที่การตั้งค่า'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Handle permission status with proper handling for different statuses
  String getPermissionStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'อนุญาตแล้ว';
      case PermissionStatus.denied:
        return 'ปฏิเสธ';
      case PermissionStatus.restricted:
        return 'ถูกจำกัด';
      case PermissionStatus.permanentlyDenied:
        return 'ปฏิเสธถาวร';
      case PermissionStatus.provisional:
        return 'อนุญาตชั่วคราว';
      // แทนที่ limitedGranted ด้วย limited
      case PermissionStatus.limited:
        return 'อนุญาตบางส่วน';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  // Check if permission status allows notifications
  bool isPermissionSufficient(PermissionStatus status) {
    return status == PermissionStatus.granted ||
        status == PermissionStatus.provisional ||
        status == PermissionStatus.limited;
  }

  // Request permission with retry logic
  Future<PermissionStatus> requestPermissionWithRetry(
    Permission permission, {
    int maxRetries = 3,
  }) async {
    PermissionStatus status = await permission.status;

    for (int i = 0; i < maxRetries && !isPermissionSufficient(status); i++) {
      debugPrint('Requesting permission attempt ${i + 1}/$maxRetries');
      status = await permission.request();

      if (status == PermissionStatus.permanentlyDenied) {
        debugPrint('Permission permanently denied, stopping retries');
        break;
      }
    }

    debugPrint('Final permission status: $status');
    return status;
  }
}
