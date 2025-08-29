import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/app_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/statistics_controller.dart';
import '../utils/colors.dart';
import '../routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final AppController _appController = Get.find<AppController>();
  final NotificationController _notificationController =
      Get.find<NotificationController>();
  final StatisticsController _statisticsController =
      Get.find<StatisticsController>();

  late AnimationController _refreshAnimationController;
  late Animation<double> _refreshAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _refreshAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _loadData() async {
    await _statisticsController.loadTodayStats();
  }

  void _refreshData() async {
    _refreshAnimationController.forward();
    await _loadData();
    _refreshAnimationController.reset();
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: CustomScrollView(
          slivers: [
            // App Bar
            _buildSliverAppBar(),

            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Current Status Card
                    _buildCurrentStatusCard(),

                    const SizedBox(height: 16),

                    // Today's Stats
                    _buildTodayStatsCard(),

                    const SizedBox(height: 16),

                    // Selected Pain Points
                    _buildSelectedPainPointsCard(),

                    const SizedBox(height: 16),

                    // Quick Actions
                    _buildQuickActionsCard(),

                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),

      // Floating Action Button
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Office Syndrome Helper',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
          ),
        ),
      ),
      actions: [
        AnimatedBuilder(
          animation: _refreshAnimation,
          builder: (context, child) {
            return IconButton(
              onPressed: _refreshData,
              icon: Transform.rotate(
                angle: _refreshAnimation.value * 2 * 3.14159,
                child: const Icon(Icons.refresh),
              ),
            );
          },
        ),
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.SETTINGS),
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }

  Widget _buildCurrentStatusCard() {
    return Obx(() {
      final settings = _appController.userSettings;
      if (settings == null) return const SizedBox.shrink();

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.getGradient(0),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'สถานะการแจ้งเตือน',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          settings.isNotificationEnabled
                              ? 'เปิดใช้งาน'
                              : 'ปิดใช้งาน',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: settings.isNotificationEnabled,
                    onChanged: (value) async {
                      final updatedSettings = settings.copyWith(
                        isNotificationEnabled: value,
                      );
                      await _appController.updateUserSettings(updatedSettings);
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
              if (settings.isNotificationEnabled &&
                  settings.nextNotificationTime != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'แจ้งเตือนครั้งถัดไป: ${_formatNextNotificationTime(settings.nextNotificationTime!)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTodayStatsCard() {
    return GetBuilder<StatisticsController>(
      builder: (controller) {
        final stats = controller.todayStats;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'สถิติวันนี้',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.STATISTICS),
                      child: const Text('ดูเพิ่มเติม'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.notification_important,
                        label: 'แจ้งเตือน',
                        value: '${stats['total'] ?? 0}',
                        color: AppColors.info,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.check_circle,
                        label: 'เสร็จแล้ว',
                        value: '${stats['completed'] ?? 0}',
                        color: AppColors.success,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.skip_next,
                        label: 'ข้าม',
                        value: '${stats['skipped'] ?? 0}',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (stats['total'] != null && stats['total'] > 0) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'อัตราความสำเร็จ: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${((stats['completed'] ?? 0) / stats['total'] * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedPainPointsCard() {
    return Obx(() {
      final selectedPainPoints = _appController.getSelectedPainPoints();

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.my_location,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'จุดที่กำลังดูแล',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.SETTINGS),
                    child: const Text('แก้ไข'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (selectedPainPoints.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedPainPoints.map((painPoint) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getPainPointColor(painPoint.id - 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.health_and_safety,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            painPoint.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'ยังไม่ได้เลือกจุดที่ต้องการดูแล',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuickActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'การดำเนินการด่วน',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.play_circle_fill,
                    label: 'เริ่มออกกำลัง',
                    color: AppColors.success,
                    onTap: () {
                      // TODO: Start immediate session
                      Get.snackbar(
                          'เร็วๆ นี้', 'ฟีเจอร์นี้จะเปิดใช้งานเร็วๆ นี้');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.history,
                    label: 'ประวัติ',
                    color: AppColors.info,
                    onTap: () => Get.toNamed(AppRoutes.STATISTICS),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              icon: Icons.home,
              label: 'หน้าหลัก',
              isSelected: true,
              onTap: () {},
            ),
            _buildBottomNavItem(
              icon: Icons.analytics,
              label: 'สถิติ',
              isSelected: false,
              onTap: () => Get.toNamed(AppRoutes.STATISTICS),
            ),
            const SizedBox(width: 40), // Space for FAB
            _buildBottomNavItem(
              icon: Icons.fitness_center,
              label: 'ท่าออกกำลัง',
              isSelected: false,
              onTap: () {
                Get.snackbar('เร็วๆ นี้', 'ฟีเจอร์นี้จะเปิดใช้งานเร็วๆ นี้');
              },
            ),
            _buildBottomNavItem(
              icon: Icons.settings,
              label: 'การตั้งค่า',
              isSelected: false,
              onTap: () => Get.toNamed(AppRoutes.SETTINGS),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      final hasActiveSession = _notificationController.isSessionActive.value;

      return FloatingActionButton(
        onPressed: () {
          if (hasActiveSession) {
            Get.toNamed(AppRoutes.TODO);
          } else {
            // Test notification
            Get.snackbar('ทดสอบ', 'ส่งการแจ้งเตือนทดสอบแล้ว');
          }
        },
        backgroundColor:
            hasActiveSession ? AppColors.warning : AppColors.primary,
        child: Icon(
          hasActiveSession ? Icons.play_arrow : Icons.add,
          color: Colors.white,
        ),
      );
    });
  }

  String _formatNextNotificationTime(DateTime time) {
    final now = DateTime.now();
    final difference = time.difference(now);

    if (difference.inDays > 0) {
      return DateFormat('dd/MM/yyyy HH:mm').format(time);
    } else if (difference.inHours > 0) {
      return 'อีก ${difference.inHours} ชั่วโมง ${difference.inMinutes % 60} นาที';
    } else if (difference.inMinutes > 0) {
      return 'อีก ${difference.inMinutes} นาที';
    } else {
      return 'เร็วๆ นี้';
    }
  }
}
