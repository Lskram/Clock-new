import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/app_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/statistics_controller.dart';
import '../models/notification_session.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppController appController = Get.find<AppController>();
  final NotificationController notificationController =
      Get.find<NotificationController>();
  final StatisticsController statisticsController =
      Get.find<StatisticsController>();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    // แก้ไข use_of_void_result และ await_only_futures
    notificationController.checkPendingNotifications(); // ลบ await
    statisticsController.loadTodayStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildTodayProgress(),
                    const SizedBox(height: 20),
                    _buildUpcomingSession(),
                    const SizedBox(height: 20),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Office Syndrome Helper',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryLight,
                AppColors.primary,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const Positioned(
                right: 20,
                top: 60,
                child: Icon(
                  Icons.health_and_safety_outlined,
                  size: 48,
                  color: Colors.white30,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => Get.toNamed(AppRoutes.SETTINGS),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.waving_hand,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'สวัสดี!',
                    style: AppTextStyles.heading2,
                  ),
                  Text(
                    'พร้อมดูแลสุขภาพกันหรือยัง?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final todaySession =
                statisticsController.todayCompletedSessions.value;
            return Text(
              'วันนี้คุณออกกำลังกายแล้ว $todaySession ครั้ง',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เมนูหลัก',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'เริ่มออกกำลัง',
                'ออกกำลังกายทันที',
                Icons.play_circle_fill,
                AppColors.success,
                () => _startImmediateSession(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'สถิติ',
                'ดูความก้าวหน้า',
                Icons.analytics_outlined,
                AppColors.info,
                () => Get.toNamed(AppRoutes.STATISTICS),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'การตั้งค่า',
                'ปรับแต่งแอป',
                Icons.tune,
                AppColors.warning,
                () => Get.toNamed(AppRoutes.SETTINGS),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'ท่าออกกำลัง',
                'ดูท่าทั้งหมด',
                Icons.accessibility_new,
                AppColors.accent,
                () => Get.toNamed(AppRoutes.SETTINGS_TREATMENTS),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'ความก้าวหน้าวันนี้',
                style: AppTextStyles.heading3,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            // แก้ไข null safety issue
            final completed = statisticsController.todayCompletedSessions.value;
            final estimated = statisticsController.estimatedSessionsToday.value;
            final progress = estimated > 0 ? completed / estimated : 0.0;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'เซสชันที่เสร็จสิ้น',
                      style: AppTextStyles.bodyMedium,
                    ),
                    Text(
                      '$completed / $estimated',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0), // แก้ไข argument type issue
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? AppColors.success : AppColors.primary,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUpcomingSession() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'เซสชันถัดไป',
                style: AppTextStyles.heading3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final upcomingSession =
                notificationController.upcomingSession.value;

            if (upcomingSession == null) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ไม่มีเซสชันที่กำลังจะมาถึง',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            final timeFormat = DateFormat('HH:mm', 'th');
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เวลา ${timeFormat.format(upcomingSession.scheduledAt)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${upcomingSession.treatments.length} ท่าออกกำลัง',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Start immediate session
                      _startSessionFromNotification(upcomingSession);
                    },
                    child: const Text('เริ่มเลย'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'กิจกรรมล่าสุด',
                    style: AppTextStyles.heading3,
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.STATISTICS),
                child: const Text('ดูทั้งหมด'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final recentSessions = statisticsController.recentSessions;

            if (recentSessions.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ยังไม่มีกิจกรรม',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentSessions.length > 3 ? 3 : recentSessions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final session = recentSessions[index];
                return _buildActivityItem(session);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivityItem(NotificationSession session) {
    final timeFormat = DateFormat('HH:mm', 'th');
    final dateFormat = DateFormat('dd MMM', 'th');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getStatusColor(session.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(session.status),
              color: _getStatusColor(session.status),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(session.status),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${dateFormat.format(session.scheduledAt)} • ${timeFormat.format(session.scheduledAt)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          if (session.treatments.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${session.treatments.length} ท่า',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _startImmediateSession,
      backgroundColor: AppColors.success,
      icon: const Icon(Icons.play_arrow, color: Colors.white),
      label: const Text(
        'เริ่มออกกำลัง',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.completed:
        return AppColors.success;
      case NotificationStatus.snoozed:
        return AppColors.warning;
      case NotificationStatus.dismissed:
        return AppColors.error;
      case NotificationStatus.scheduled:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.completed:
        return Icons.check_circle;
      case NotificationStatus.snoozed:
        return Icons.snooze;
      case NotificationStatus.dismissed:
        return Icons.cancel;
      case NotificationStatus.scheduled:
        return Icons.schedule;
    }
  }

  String _getStatusText(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.completed:
        return 'ออกกำลังเสร็จสิ้น';
      case NotificationStatus.snoozed:
        return 'เลื่อนการแจ้งเตือน';
      case NotificationStatus.dismissed:
        return 'ยกเลิกการแจ้งเตือน';
      case NotificationStatus.scheduled:
        return 'รอการแจ้งเตือน';
    }
  }

  // Action methods
  Future<void> _refreshData() async {
    await statisticsController.loadTodayStatistics();
    notificationController.checkPendingNotifications();
  }

  void _startImmediateSession() {
    Get.toNamed(AppRoutes.TODO);
  }

  void _startSessionFromNotification(NotificationSession session) {
    Get.toNamed(AppRoutes.TODO, arguments: session);
  }
}
