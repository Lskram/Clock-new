import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../controllers/app_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/notification_session.dart';
import '../models/treatment.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final notificationController = Get.find<NotificationController>();
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeCard(context, settingsController),
                const SizedBox(height: 16),
                _buildQuickStatsCard(context, notificationController),
                const SizedBox(height: 16),
                _buildActiveSessionCard(context, notificationController),
                const SizedBox(height: 16),
                _buildQuickActionsCard(context),
                const SizedBox(height: 16),
                _buildRecentSessionsCard(context, notificationController),
                const SizedBox(height: 100), // Bottom padding for FAB
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Office Syndrome Helper',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.settings),
          icon: const Icon(Icons.settings),
          tooltip: 'การตั้งค่า',
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(
      BuildContext context, SettingsController settingsController) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.waving_hand,
                  color: Colors.orange.withValues(alpha: 0.8),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'พร้อมดูแลสุขภาพกันแล้วหรือยัง?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final selectedPainPoints =
                  settingsController.settings.selectedPainPoints;
              if (selectedPainPoints.isEmpty) {
                return _buildSetupPrompt(context);
              }
              return _buildPainPointsSummary(context, selectedPainPoints);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .secondaryContainer
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'เริ่มต้นใช้งาน',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'กรุณาตั้งค่าจุดปวดเมื่อยที่คุณต้องการดูแลเพื่อเริ่มรับการแจ้งเตือน',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.questionnaire),
              icon: const Icon(Icons.play_arrow),
              label: const Text('เริ่มตั้งค่า'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPainPointsSummary(
      BuildContext context, List<String> selectedPainPoints) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.3),
            Theme.of(context)
                .colorScheme
                .secondaryContainer
                .withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'จุดที่กำลังดูแล',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: selectedPainPoints.map((pointId) {
              return Chip(
                label: Text(
                  _getPainPointName(pointId),
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Theme.of(context).colorScheme.surface,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCard(
      BuildContext context, NotificationController controller) {
    return Obx(() {
      final sessions = controller.recentSessions;
      final todayCompleted = sessions.where((session) {
        return session.isCompleted &&
            _isSameDay(
                session.completedTime ?? session.scheduledTime, DateTime.now());
      }).length;

      final weekCompleted = sessions.where((session) {
        return session.isCompleted &&
            _isThisWeek(session.completedTime ?? session.scheduledTime);
      }).length;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'สถิติการออกกำลัง',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      icon: Icons.today,
                      label: 'วันนี้',
                      value: todayCompleted.toString(),
                      color: Colors.blue,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.withValues(alpha: 0.3),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      icon: Icons.date_range,
                      label: 'สัปดาห์นี้',
                      value: weekCompleted.toString(),
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildActiveSessionCard(
      BuildContext context, NotificationController controller) {
    return Obx(() {
      final activeSession = controller.currentSession.value;

      if (activeSession == null) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.self_improvement,
                  size: 48,
                  color: Colors.grey.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'ไม่มีเซสชันที่ใช้งานอยู่',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'รอการแจ้งเตือนครั้งต่อไป',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _startImmediateSession(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('เริ่มเซสชันทันที'),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return _buildActiveSessionDetails(context, activeSession, controller);
    });
  }

  Widget _buildActiveSessionDetails(
    BuildContext context,
    NotificationSession session,
    NotificationController controller,
  ) {
    final progress = session.completionProgress;

    return Card(
      color:
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เซสชันที่กำลังดำเนินการ',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        '${session.completedTreatmentIds.length}/${session.treatmentIds.length} รายการเสร็จสิ้น',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              percent: progress,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              progressColor: Theme.of(context).colorScheme.primary,
              lineHeight: 8,
              barRadius: const Radius.circular(4),
              animation: true,
              animationDuration: 500,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.pauseSession(),
                    icon: const Icon(Icons.pause),
                    label: const Text('หยุดชั่วคราว'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.todo),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('ดำเนินการต่อ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'เมนูด่วน',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.list_alt,
                  label: 'รายการท่า',
                  onTap: () => Get.toNamed(AppRoutes.settingsTreatments),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.bar_chart,
                  label: 'สถิติ',
                  onTap: () => Get.toNamed(AppRoutes.statistics),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.healing,
                  label: 'จุดปวดเมื่อย',
                  onTap: () => Get.toNamed(AppRoutes.settingsPainPoints),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.notifications,
                  label: 'การแจ้งเตือน',
                  onTap: () => Get.toNamed(AppRoutes.settingsNotification),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSessionsCard(
      BuildContext context, NotificationController controller) {
    return Obx(() {
      final recentSessions = controller.recentSessions.take(5).toList();

      if (recentSessions.isEmpty) {
        return const SizedBox.shrink();
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'เซสชันล่าสุด',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.statistics),
                    child: const Text('ดูทั้งหมด'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...recentSessions
                  .map((session) => _buildSessionTile(context, session)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSessionTile(BuildContext context, NotificationSession session) {
    final statusColor = _getSessionStatusColor(session.status);
    final statusIcon = _getSessionStatusIcon(session.status);
    final displayTime = session.completedTime ?? session.scheduledTime;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.treatmentIds.length} ท่าการออกกำลัง',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  _formatDateTime(displayTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
          if (session.isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'เสร็จสิ้น',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _startImmediateSession(context),
      icon: const Icon(Icons.play_arrow),
      label: const Text('เริ่มออกกำลัง'),
      tooltip: 'เริ่มเซสชันออกกำลังทันที',
    );
  }

  // Helper Methods
  String _getGreeting(int hour) {
    if (hour < 12) return 'สวัสดีตอนเช้า';
    if (hour < 17) return 'สวัสดีตอนบ่าย';
    return 'สวัสดีตอนเย็น';
  }

  String _getPainPointName(String pointId) {
    // This should be replaced with actual data lookup
    final painPointNames = {
      'neck_pain': 'ปวดคอ',
      'shoulder_pain': 'ปวดไหล่',
      'back_pain': 'ปวดหลัง',
      'eye_strain': 'ปวดตา',
      'wrist_pain': 'ปวดข้อมือ',
    };
    return painPointNames[pointId] ?? pointId;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  Color _getSessionStatusColor(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.completed:
        return Colors.green;
      case NotificationStatus.snoozed:
        return Colors.orange;
      case NotificationStatus.skipped:
        return Colors.grey;
      case NotificationStatus.dismissed:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getSessionStatusIcon(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.completed:
        return Icons.check_circle;
      case NotificationStatus.snoozed:
        return Icons.snooze;
      case NotificationStatus.skipped:
        return Icons.skip_next;
      case NotificationStatus.dismissed:
        return Icons.close;
      default:
        return Icons.schedule;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    if (_isSameDay(dateTime, now)) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _startImmediateSession(BuildContext context) {
    // TODO: Implement immediate session start
    Get.toNamed(AppRoutes.todo);
  }
}
