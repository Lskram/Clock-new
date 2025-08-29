import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../services/permission_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final PermissionService permissionService = Get.find<PermissionService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('การตั้งค่า'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final settings = appController.userSettings;
        if (settings == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Notification Settings
              _buildNotificationSettingsCard(appController, settings),

              const SizedBox(height: 16),

              // Pain Points Settings
              _buildPainPointsCard(appController),

              const SizedBox(height: 16),

              // Working Hours Settings
              _buildWorkingHoursCard(appController, settings),

              const SizedBox(height: 16),

              // App Information
              _buildAppInfoCard(),

              const SizedBox(height: 16),

              // Permissions Status
              _buildPermissionsCard(permissionService),

              const SizedBox(height: 100), // Bottom space
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNotificationSettingsCard(AppController controller, settings) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'การแจ้งเตือน',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Enable/Disable Notifications
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('เปิดใช้การแจ้งเตือน'),
              subtitle: const Text('รับการแจ้งเตือนเมื่อถึงเวลาออกกำลังกาย'),
              trailing: Switch(
                value: settings.isNotificationEnabled,
                onChanged: (value) async {
                  final updatedSettings = settings.copyWith(
                    isNotificationEnabled: value,
                  );
                  await controller.updateUserSettings(updatedSettings);
                },
              ),
            ),

            const Divider(),

            // Interval Setting
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('ช่วงเวลาการแจ้งเตือน'),
              subtitle: Text('ทุก ${settings.intervalMinutes} นาที'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showIntervalDialog(controller, settings),
            ),

            const Divider(),

            // Sound Settings
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('เสียงแจ้งเตือน'),
              trailing: Switch(
                value: settings.isSoundEnabled,
                onChanged: (value) async {
                  final updatedSettings = settings.copyWith(
                    isSoundEnabled: value,
                  );
                  await controller.updateUserSettings(updatedSettings);
                },
              ),
            ),

            // Vibration Settings
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('สั่นแจ้งเตือน'),
              trailing: Switch(
                value: settings.isVibrationEnabled,
                onChanged: (value) async {
                  final updatedSettings = settings.copyWith(
                    isVibrationEnabled: value,
                  );
                  await controller.updateUserSettings(updatedSettings);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPainPointsCard(AppController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.my_location, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'จุดที่ปวด',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Selected Pain Points
            Obx(() {
              final selectedPainPoints = controller.getSelectedPainPoints();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'จุดที่เลือกไว้ (${selectedPainPoints.length} จุด):',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selectedPainPoints.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedPainPoints.map((painPoint) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.getPainPointColor(painPoint.id - 1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            painPoint.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text(
                      'ยังไม่ได้เลือกจุดที่ปวด',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Get.snackbar('เร็วๆ นี้',
                          'ฟีเจอร์แก้ไขจุดที่ปวดจะเปิดใช้เร็วๆ นี้');
                    },
                    child: const Text('แก้ไขจุดที่ปวด'),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingHoursCard(AppController controller, settings) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'เวลาทำงาน',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('เวลาเริ่มงาน'),
              subtitle: Text(settings.workStartTime.toString()),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showTimePickerDialog(
                controller,
                settings,
                true, // isStartTime
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('เวลาเลิกงาน'),
              subtitle: Text(settings.workEndTime.toString()),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showTimePickerDialog(
                controller,
                settings,
                false, // isStartTime
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('วันทำงาน'),
              subtitle: Text(_getWorkDaysText(settings.workDays)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showWorkDaysDialog(controller, settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'เกี่ยวกับแอป',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('เวอร์ชัน'),
              subtitle: Text(AppConstants.APP_VERSION),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Office Syndrome Helper'),
              subtitle: const Text('แอปช่วยดูแลสุขภาพในที่ทำงาน'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsCard(PermissionService permissionService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'สิทธิ์การใช้งาน',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, bool>>(
              future: Future.wait([
                permissionService.hasNotificationPermission(),
                permissionService.hasExactAlarmPermission(),
              ]).then((results) => {
                    'notification': results[0],
                    'exactAlarm': results[1],
                  }),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final permissions = snapshot.data!;

                return Column(
                  children: [
                    _buildPermissionItem(
                      'การแจ้งเตือน',
                      permissions['notification'] ?? false,
                      () => permissionService.requestNotificationPermission(),
                    ),
                    _buildPermissionItem(
                      'การตั้งเวลาแม่นยำ',
                      permissions['exactAlarm'] ?? false,
                      () => permissionService.requestExactAlarmPermission(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  permissionService.checkAndRequestAllPermissions(),
              child: const Text('ตรวจสอบสิทธิ์ทั้งหมด'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(
      String title, bool isGranted, VoidCallback onRequest) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGranted ? Icons.check_circle : Icons.error,
            color: isGranted ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          if (!isGranted)
            TextButton(
              onPressed: onRequest,
              child: const Text('ขออนุญาต'),
            ),
        ],
      ),
    );
  }

  void _showIntervalDialog(AppController controller, settings) {
    Get.dialog(
      AlertDialog(
        title: const Text('ช่วงเวลาการแจ้งเตือน'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [15, 30, 60, 90, 120].map((minutes) {
            return RadioListTile<int>(
              title: Text('$minutes นาที'),
              value: minutes,
              groupValue: settings.intervalMinutes,
              onChanged: (value) async {
                if (value != null) {
                  final updatedSettings = settings.copyWith(
                    intervalMinutes: value,
                  );
                  await controller.updateUserSettings(updatedSettings);
                  Get.back();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );
  }

  void _showTimePickerDialog(
      AppController controller, settings, bool isStartTime) {
    final currentTime =
        isStartTime ? settings.workStartTime : settings.workEndTime;

    showTimePicker(
      context: Get.context!,
      initialTime:
          TimeOfDay(hour: currentTime.hour, minute: currentTime.minute),
    ).then((selectedTime) async {
      if (selectedTime != null) {
        final newTime = settings.workStartTime.copyWith(
          hour: selectedTime.hour,
          minute: selectedTime.minute,
        );

        final updatedSettings = isStartTime
            ? settings.copyWith(workStartTime: newTime)
            : settings.copyWith(workEndTime: newTime);

        await controller.updateUserSettings(updatedSettings);
      }
    });
  }

  void _showWorkDaysDialog(AppController controller, settings) {
    final selectedDays = List<int>.from(settings.workDays);

    Get.dialog(
      AlertDialog(
        title: const Text('วันทำงาน'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                {'day': 1, 'name': 'จันทร์'},
                {'day': 2, 'name': 'อังคาร'},
                {'day': 3, 'name': 'พุธ'},
                {'day': 4, 'name': 'พฤหัสบดี'},
                {'day': 5, 'name': 'ศุกร์'},
                {'day': 6, 'name': 'เสาร์'},
                {'day': 7, 'name': 'อาทิตย์'},
              ].map((dayInfo) {
                return CheckboxListTile(
                  title: Text(dayInfo['name'] as String),
                  value: selectedDays.contains(dayInfo['day']),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedDays.add(dayInfo['day'] as int);
                      } else {
                        selectedDays.remove(dayInfo['day']);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedSettings = settings.copyWith(workDays: selectedDays);
              await controller.updateUserSettings(updatedSettings);
              Get.back();
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  String _getWorkDaysText(List<int> workDays) {
    const dayNames = ['', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
    return workDays.map((day) => dayNames[day]).join(', ');
  }
}
