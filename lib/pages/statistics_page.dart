import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/statistics_controller.dart';
import '../models/notification_session.dart';
import '../utils/constants.dart';

class StatisticsPage extends GetView<StatisticsController> {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 20),
                  _buildPeriodSelector(),
                  const SizedBox(height: 20),
                  _buildSessionsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.blue[600],
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'สถิติการใช้งาน',
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
                Colors.blue[400]!,
                Colors.blue[600]!,
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.white30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'วันนี้',
              controller.todayCompletedSessions.toString(),
              'เซสชัน',
              Icons.today,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'สัปดาห์นี้',
              controller.weekCompletedSessions.toString(),
              'เซสชัน',
              Icons.date_range,
              Colors.blue,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() {
        return Row(
          children: [
            Expanded(
              child: _buildPeriodButton(
                'วันนี้',
                StatisticsPeriod.today,
                controller.selectedPeriod.value == StatisticsPeriod.today,
              ),
            ),
            Expanded(
              child: _buildPeriodButton(
                'สัปดาห์นี้',
                StatisticsPeriod.week,
                controller.selectedPeriod.value == StatisticsPeriod.week,
              ),
            ),
            Expanded(
              child: _buildPeriodButton(
                'เดือนนี้',
                StatisticsPeriod.month,
                controller.selectedPeriod.value == StatisticsPeriod.month,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPeriodButton(
      String title, StatisticsPeriod period, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.changePeriod(period),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue[600] : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.history,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'ประวัติการออกกำลัง',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            final sessions = controller.filteredSessions;

            if (sessions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ยังไม่มีประวัติการออกกำลัง',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เมื่อคุณเริ่มออกกำลังกาย ประวัติจะแสดงที่นี่',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sessions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final session = sessions[index];
                return _buildSessionItem(session);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSessionItem(NotificationSession session) {
    final dateFormat = DateFormat('dd MMM yyyy', 'th');
    final timeFormat = DateFormat('HH:mm', 'th');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(session.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(session.status),
              color: _getStatusColor(session.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(session.status),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dateFormat.format(session.scheduledAt)} • ${timeFormat.format(session.scheduledAt)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (session.completedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'เสร็จสิ้นเมื่อ ${timeFormat.format(session.completedAt!)}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (session.treatments.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${session.treatments.length} ท่า',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.completed:
        return Colors.green;
      case NotificationStatus.snoozed:
        return Colors.orange;
      case NotificationStatus.dismissed:
        return Colors.red;
      case NotificationStatus.scheduled:
        return Colors.blue;
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
}
