import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('การตั้งค่า'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (settingsController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildNotificationSection(context, settingsController),
            const SizedBox(height: 16),
            _buildExerciseSection(context, settingsController),
            const SizedBox(height: 16),
            _buildScheduleSection(context, settingsController),
            const SizedBox(height: 16),
            _buildAppearanceSection(context, settingsController),
            const SizedBox(height: 16),
            _buildAboutSection(context, settingsController),
          ],
        );
      }),
    );
  }

  Widget _buildNotificationSection(
      BuildContext context, SettingsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'การแจ้งเตือน',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('เปิดการแจ้งเตือน'),
              subtitle: const Text('แจ้งเตือนให้ออกกำลังตามเวลาที่กำหนด'),
              value: controller.settings.notificationsEnabled,
              onChanged: controller.updateNotificationEnabled,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              title: const Text('ความถี่การแจ้งเตือน'),
              subtitle: Text(
                  'ทุกๆ ${controller.settings.notificationIntervalMinutes} นาที'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showIntervalDialog(context, controller),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('เสียงแจ้งเตือน'),
              subtitle: const Text('เล่นเสียงเมื่อมีการแจ้งเตือน'),
              value: controller.settings.soundEnabled,
              onChanged: (value) => controller.updateSettings(
                controller.settings.copyWith(soundEnabled: value),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('การสั่น'),
              subtitle: const Text('สั่นเครื่องเมื่อมีการแจ้งเตือน'),
              value: controller.settings.vibrationEnabled,
              onChanged: (value) => controller.updateSettings(
                controller.settings.copyWith(vibrationEnabled: value),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSection(
      BuildContext context, SettingsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'การออกกำลัง',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('จุดปวดเมื่อย'),
              subtitle: Text(
                  '${controller.settings.selectedPainPoints.length} รายการ'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed(AppRoutes.settingsPainPoints),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              title: const Text('ท่าการออกกำลัง'),
              subtitle: const Text('จัดการท่าการออกกำลัง'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed(AppRoutes.settingsTreatments),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              title: const Text('จำนวนท่าต่อเซสชัน'),
              subtitle: Text('${controller.settings.treatmentsPerSession} ท่า'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showTreatmentsPerSessionDialog(context, controller),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection(
      BuildContext context, SettingsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'ตารางเวลา',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('เวลาทำงาน'),
              subtitle: Text(
                '${controller.settings.workStartTime.format(context)} - '
                '${controller.settings.workEndTime.format(context)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showWorkHoursDialog(context, controller),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              title: const Text('วันทำงาน'),
              subtitle: Text(_getWorkDaysText(controller.settings.workDays)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showWorkDaysDialog(context, controller),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              title: const Text('เวลาพัก'),
              subtitle: const Text('ตั้งค่าเวลาพักที่ไม่ต้องการแจ้งเตือน'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed(AppRoutes.settingsBreakTimes),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(
      BuildContext context, SettingsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'ธีมและภาษา',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('ธีม'),
              subtitle: Text(_getThemeModeText(controller.settings.themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeDialog(context, controller),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              title: const Text('ภาษา'),
              subtitle: Text(_getLanguageText(controller.settings.language)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(context, controller),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(
      BuildContext context, SettingsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'เกี่ยวกับ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('รีเซ็ตการตั้งค่า'),
              subtitle: const Text('กลับไปสู่การตั้งค่าเริ่มต้น'),
              trailing: const Icon(Icons.refresh),
              onTap: () => controller.resetToDefault(),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              title: const Text('เวอร์ชัน'),
              subtitle: const Text(appVersion),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Methods
  void _showIntervalDialog(
      BuildContext context, SettingsController controller) {
    int selectedInterval = controller.settings.notificationIntervalMinutes;

    Get.dialog(
      AlertDialog(
        title: const Text('ความถี่การแจ้งเตือน'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ทุกๆ $selectedInterval นาที'),
                Slider(
                  value: selectedInterval.toDouble(),
                  min: minIntervalMinutes.toDouble(),
                  max: maxIntervalMinutes.toDouble(),
                  divisions: (maxIntervalMinutes - minIntervalMinutes) ~/ 15,
                  label: '$selectedInterval นาที',
                  onChanged: (value) {
                    setState(() {
                      selectedInterval = value.round();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$minIntervalMinutes นาที'),
                    Text('$maxIntervalMinutes นาที'),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateNotificationInterval(selectedInterval);
              Get.back();
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showTreatmentsPerSessionDialog(
      BuildContext context, SettingsController controller) {
    int selectedCount = controller.settings.treatmentsPerSession;

    Get.dialog(
      AlertDialog(
        title: const Text('จำนวนท่าต่อเซสชัน'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$selectedCount ท่า'),
                Slider(
                  value: selectedCount.toDouble(),
                  min: 1,
                  max: 8,
                  divisions: 7,
                  label: '$selectedCount ท่า',
                  onChanged: (value) {
                    setState(() {
                      selectedCount = value.round();
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateTreatmentsPerSession(selectedCount);
              Get.back();
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showWorkHoursDialog(
      BuildContext context, SettingsController controller) {
    TimeOfDay startTime = controller.settings.workStartTime;
    TimeOfDay endTime = controller.settings.workEndTime;

    Get.dialog(
      AlertDialog(
        title: const Text('เวลาทำงาน'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('เวลาเริ่มงาน'),
                  subtitle: Text(startTime.format(context)),
                  onTap: () async {
                    final newTime = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (newTime != null) {
                      setState(() => startTime = newTime);
                    }
                  },
                ),
                ListTile(
                  title: const Text('เวลาเลิกงาน'),
                  subtitle: Text(endTime.format(context)),
                  onTap: () async {
                    final newTime = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (newTime != null) {
                      setState(() => endTime = newTime);
                    }
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.isValidWorkTime(startTime, endTime)) {
                controller.updateWorkHours(startTime, endTime);
                Get.back();
              } else {
                Get.snackbar(
                  'ข้อผิดพลาด',
                  'เวลาเริ่มงานต้องมาก่อนเวลาเลิกงาน',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showWorkDaysDialog(
      BuildContext context, SettingsController controller) {
    List<int> selectedDays = List.from(controller.settings.workDays);

    Get.dialog(
      AlertDialog(
        title: const Text('วันทำงาน'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(7, (index) {
                final dayNumber = index + 1;
                final isSelected = selectedDays.contains(dayNumber);

                return CheckboxListTile(
                  title: Text(dayNamesLong[index]),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedDays.add(dayNumber);
                      } else {
                        selectedDays.remove(dayNumber);
                      }
                      selectedDays.sort();
                    });
                  },
                );
              }),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedDays.isNotEmpty) {
                controller.updateWorkDays(selectedDays);
                Get.back();
              } else {
                Get.snackbar(
                  'ข้อผิดพลาด',
                  'กรุณาเลือกอย่างน้อย 1 วัน',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('เลือกธีม'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('ตามระบบ'),
              value: ThemeMode.system,
              groupValue: controller.settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  controller.updateThemeMode(value);
                  Get.back();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('โหมดสว่าง'),
              value: ThemeMode.light,
              groupValue: controller.settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  controller.updateThemeMode(value);
                  Get.back();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('โหมดมืด'),
              value: ThemeMode.dark,
              groupValue: controller.settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  controller.updateThemeMode(value);
                  Get.back();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('เลือกภาษา'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('ไทย'),
              value: 'th',
              groupValue: controller.settings.language,
              onChanged: (value) {
                if (value != null) {
                  controller.updateLanguage(value);
                  Get.back();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: controller.settings.language,
              onChanged: (value) {
                if (value != null) {
                  controller.updateLanguage(value);
                  Get.back();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  String _getWorkDaysText(List<int> workDays) {
    if (workDays.length == 7) return 'ทุกวัน';
    if (workDays.length == 5 && workDays.every((day) => day >= 1 && day <= 5)) {
      return 'วันจันทร์-ศุกร์';
    }
    return workDays.map((day) => dayNamesShort[day - 1]).join(', ');
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'ตามระบบ';
      case ThemeMode.light:
        return 'โหมดสว่าง';
      case ThemeMode.dark:
        return 'โหมดมืด';
    }
  }

  String _getLanguageText(String language) {
    switch (language) {
      case 'th':
        return 'ไทย';
      case 'en':
        return 'English';
      default:
        return language;
    }
  }
}
