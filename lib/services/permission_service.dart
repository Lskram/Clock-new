import 'dart:io';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService extends GetxService {
  // Initialize method for GetxService
  Future<PermissionService> init() async {
    return this;
  }

  /// ตรวจสอบและขออนุญาตทั้งหมดที่จำเป็น
  Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};

    // Notification permission
    results['notification'] = await requestNotificationPermission();

    // Exact alarm permission (Android 12+)
    if (Platform.isAndroid) {
      results['exactAlarm'] = await requestExactAlarmPermission();
      results['scheduleExactAlarm'] =
          await requestScheduleExactAlarmPermission();
    }

    return results;
  }

  /// ขออนุญาติการแจ้งเตือน
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      print('Notification permission status: $status');
      return status.isGranted;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  /// ตรวจสอบสิทธิ์การแจ้งเตือน
  Future<bool> hasNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking notification permission: $e');
      return false;
    }
  }

  /// ขออนุญาติ Exact Alarm (Android 12+)
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      // ใช้ scheduleExactAlarm แทน exactAlarm
      final status = await Permission.scheduleExactAlarm.request();
      print('Exact alarm permission status: $status');
      return status.isGranted;
    } catch (e) {
      print('Error requesting exact alarm permission: $e');
      return false;
    }
  }

  /// ตรวจสอบสิทธิ์ Exact Alarm
  Future<bool> hasExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.scheduleExactAlarm.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking exact alarm permission: $e');
      return false;
    }
  }

  /// ขออนุญาติ Schedule Exact Alarm (Android 14+)
  Future<bool> requestScheduleExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.scheduleExactAlarm.request();
      print('Schedule exact alarm permission status: $status');
      return status.isGranted;
    } catch (e) {
      print('Error requesting schedule exact alarm permission: $e');
      return false;
    }
  }

  /// ตรวจสอบสิทธิ์ Schedule Exact Alarm
  Future<bool> hasScheduleExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.scheduleExactAlarm.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking schedule exact alarm permission: $e');
      return false;
    }
  }

  /// เปิดหน้าตั้งค่าแอป
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
      return false;
    }
  }

  /// แสดง Dialog แจ้งเตือนเรื่องสิทธิ์
  Future<void> showPermissionDialog({
    required String title,
    required String message,
    required String permissionType,
    VoidCallback? onSettingsPressed,
  }) async {
    return Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (onSettingsPressed != null) {
                onSettingsPressed();
              } else {
                openAppSettings();
              }
            },
            child: const Text('ไปที่การตั้งค่า'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// แสดง Dialog สำหรับ Notification Permission
  Future<void> showNotificationPermissionDialog() async {
    await showPermissionDialog(
      title: 'จำเป็นต้องใช้การแจ้งเตือน',
      message:
          'แอปต้องการสิทธิ์ในการส่งการแจ้งเตือนเพื่อเตือนให้คุณออกกำลังกาย กรุณาอนุญาติในการตั้งค่า',
      permissionType: 'notification',
    );
  }

  /// แสดง Dialog สำหรับ Exact Alarm Permission
  Future<void> showExactAlarmPermissionDialog() async {
    await showPermissionDialog(
      title: 'จำเป็นต้องใช้การตั้งเวลาที่แม่นยำ',
      message:
          'แอปต้องการสิทธิ์ในการตั้งการแจ้งเตือนที่เวลาที่แม่นยำ เพื่อให้การแจ้งเตือนทำงานได้ถูกต้อง',
      permissionType: 'exactAlarm',
    );
  }

  /// ตรวจสอบสิทธิ์ทั้งหมดและแสดง Dialog หากจำเป็น
  Future<bool> checkAndRequestAllPermissions() async {
    bool allGranted = true;

    // ตรวจสอบ notification permission
    if (!await hasNotificationPermission()) {
      await showNotificationPermissionDialog();
      final granted = await requestNotificationPermission();
      if (!granted) {
        allGranted = false;
        print('Notification permission denied');
      }
    }

    // ตรวจสอบ exact alarm permission (Android เท่านั้น)
    if (Platform.isAndroid) {
      if (!await hasExactAlarmPermission()) {
        await showExactAlarmPermissionDialog();
        final granted = await requestExactAlarmPermission();
        if (!granted) {
          allGranted = false;
          print('Exact alarm permission denied');
        }
      }
    }

    return allGranted;
  }

  /// ได้สถานะสิทธิ์ทั้งหมด
  Future<Map<String, PermissionStatus>> getAllPermissionStatuses() async {
    final statuses = <String, PermissionStatus>{};

    statuses['notification'] = await Permission.notification.status;

    if (Platform.isAndroid) {
      try {
        statuses['scheduleExactAlarm'] =
            await Permission.scheduleExactAlarm.status;
      } catch (e) {
        print('Error getting schedule exact alarm status: $e');
        statuses['scheduleExactAlarm'] = PermissionStatus.denied;
      }
    }

    return statuses;
  }

  /// แปลงสถานะ permission เป็นข้อความ
  String getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'อนุญาต';
      case PermissionStatus.denied:
        return 'ไม่อนุญาต';
      case PermissionStatus.restricted:
        return 'จำกัด';
      case PermissionStatus.limitedGranted:
        return 'อนุญาตบางส่วน';
      case PermissionStatus.permanentlyDenied:
        return 'ปฏิเสธถาวร';
      default:
        return 'ไม่ทราบ';
    }
  }

  /// ตรวจสอบว่าสิทธิ์ที่จำเป็นทั้งหมดได้รับอนุญาต
  Future<bool> areAllRequiredPermissionsGranted() async {
    final hasNotification = await hasNotificationPermission();

    if (Platform.isAndroid) {
      final hasExactAlarm = await hasExactAlarmPermission();
      return hasNotification && hasExactAlarm;
    }

    return hasNotification;
  }

  /// แสดงสถานะสิทธิ์ในรูปแบบ Debug
  Future<void> printAllPermissionStatuses() async {
    print('=== Permission Status Debug ===');

    final statuses = await getAllPermissionStatuses();
    for (final entry in statuses.entries) {
      print('${entry.key}: ${getPermissionStatusText(entry.value)}');
    }

    print(
        'All required permissions granted: ${await areAllRequiredPermissionsGranted()}');
    print('==============================');
  }

  /// Handle permission result และแสดงข้อความเหมาะสม
  String getPermissionResultMessage(String permissionType, bool granted) {
    if (granted) {
      switch (permissionType) {
        case 'notification':
          return 'สิทธิ์การแจ้งเตือนได้รับอนุญาตแล้ว';
        case 'exactAlarm':
          return 'สิทธิ์การตั้งเวลาแม่นยำได้รับอนุญาตแล้ว';
        default:
          return 'สิทธิ์ได้รับอนุญาตแล้ว';
      }
    } else {
      switch (permissionType) {
        case 'notification':
          return 'ไม่สามารถใช้การแจ้งเตือนได้ กรุณาอนุญาติในการตั้งค่า';
        case 'exactAlarm':
          return 'การแจ้งเตือนอาจไม่ทำงานได้ตรงเวลา กรุณาอนุญาติในการตั้งค่า';
        default:
          return 'ไม่ได้รับอนุญาตสิทธิ์';
      }
    }
  }
}
