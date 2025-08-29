import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../controllers/notification_controller.dart';
import '../utils/colors.dart';
import '../routes/app_routes.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with TickerProviderStateMixin {
  final NotificationController _controller = Get.find<NotificationController>();

  late AnimationController _progressAnimationController;
  late AnimationController _celebrationAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSessionData();
  }

  void _initializeAnimations() {
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _celebrationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _progressAnimationController.forward();
  }

  void _loadSessionData() {
    // Data should already be loaded from parameters or active session
    if (!_controller.isSessionActive.value) {
      // No active session, go back to home
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offNamed(AppRoutes.HOME);
      });
    }
  }

  void _onTreatmentToggle(int index) {
    final isCompleted = _controller.treatmentCompletionStatus[index];

    if (isCompleted) {
      _controller.markTreatmentUncompleted(index);
    } else {
      _controller.markTreatmentCompleted(index);

      // Play celebration animation for completion
      _celebrationAnimationController.forward().then((_) {
        _celebrationAnimationController.reset();
      });

      // Check if all completed
      if (_controller.isAllTreatmentsCompleted) {
        _showCompletionDialog();
      }
    }
  }

  void _showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.orange),
            const SizedBox(width: 12),
            const Text('เยี่ยมมาก!'),
          ],
        ),
        content: const Text(
          'คุณทำออกกำลังกายครบทุกท่าแล้ว!\nพร้อมจะบันทึกผลลัพธ์หรือยัง?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ยังไม่เสร็จ'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _controller.completeSession();
            },
            child: const Text('เสร็จแล้ว'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _celebrationAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!_controller.isSessionActive.value) {
          return _buildNoSessionView();
        }

        return _buildSessionContent();
      }),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Obx(() => Text(
            _controller.currentPainPointName.value.isNotEmpty
                ? 'ดูแล: ${_controller.currentPainPointName.value}'
                : 'ออกกำลังกาย',
          )),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => _showExitConfirmDialog(),
        icon: const Icon(Icons.close),
      ),
      actions: [
        Obx(() {
          if (_controller.canSnooze) {
            return IconButton(
              onPressed: () => _controller.showSnoozeOptionsDialog(),
              icon: const Icon(Icons.snooze),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildSessionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Greeting and Progress
          _buildGreetingCard(),

          const SizedBox(height: 20),

          // Progress Indicator
          _buildProgressCard(),

          const SizedBox(height: 20),

          // Treatment List
          _buildTreatmentsList(),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Obx(() => Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
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
                Icon(
                  Icons.health_and_safety,
                  size: 48,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 12),
                Text(
                  _controller.sessionGreeting.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'รวมเวลา ${_formatDuration(_controller.totalSessionDuration)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildProgressCard() {
    return Obx(() => Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ความก้าวหน้า',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_controller.completedTreatmentCount.value}/${_controller.currentTreatments.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearPercentIndicator(
                      lineHeight: 8,
                      percent: _controller.progressPercentage *
                          _progressAnimation.value,
                      backgroundColor: AppColors.divider,
                      progressColor: AppColors.success,
                      barRadius: const Radius.circular(4),
                      animation: false,
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildTreatmentsList() {
    return Obx(() => Column(
          children: _controller.currentTreatments.asMap().entries.map((entry) {
            final index = entry.key;
            final treatment = entry.value;
            final isCompleted = _controller.treatmentCompletionStatus[index];

            return AnimatedBuilder(
              animation: _celebrationAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isCompleted
                      ? 1.0 + (_celebrationAnimation.value * 0.05)
                      : 1.0,
                  child: _buildTreatmentCard(treatment, isCompleted, index),
                );
              },
            );
          }).toList(),
        ));
  }

  Widget _buildTreatmentCard(treatment, bool isCompleted, int index) {
    return Card(
      elevation: isCompleted ? 4 : 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isCompleted
              ? Border.all(color: AppColors.success, width: 2)
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: GestureDetector(
            onTap: () => _onTreatmentToggle(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.success : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? AppColors.success : AppColors.divider,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          ),
          title: Text(
            '${index + 1}. ${treatment.name}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isCompleted ? AppColors.success : AppColors.textPrimary,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                treatment.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '⏱️ ${treatment.durationSeconds} วินาที',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          trailing: isCompleted
              ? Icon(
                  Icons.celebration,
                  color: AppColors.success,
                  size: 24,
                )
              : null,
          onTap: () => _onTreatmentToggle(index),
        ),
      ),
    );
  }

  Widget _buildNoSessionView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 20),
            const Text(
              'ไม่มี Session ที่ใช้งานได้',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'กรุณารอการแจ้งเตือนหรือกลับไปหน้าหลัก',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.offNamed(AppRoutes.HOME),
              child: const Text('กลับหน้าหลัก'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Obx(() {
      if (!_controller.isSessionActive.value) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Skip Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _controller.showSkipConfirmationDialog(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.divider),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.skip_next, size: 20),
                      const SizedBox(width: 8),
                      const Text('ข้าม'),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Snooze Button
              if (_controller.canSnooze)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _controller.showSnoozeOptionsDialog(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: BorderSide(color: AppColors.warning),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.snooze, size: 20),
                        const SizedBox(width: 8),
                        const Text('เลื่อน'),
                      ],
                    ),
                  ),
                ),

              if (_controller.canSnooze) const SizedBox(width: 12),

              // Complete Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _controller.isAllTreatmentsCompleted
                      ? () => _controller.completeSession()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _controller.isAllTreatmentsCompleted
                        ? AppColors.success
                        : AppColors.divider,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _controller.isAllTreatmentsCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _controller.isAllTreatmentsCompleted
                            ? 'เสร็จแล้ว'
                            : 'ยังไม่เสร็จ',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showExitConfirmDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('ออกจาก Session?'),
        content: const Text(
          'คุณแน่ใจหรือไม่ที่จะออกจากการออกกำลังกาย? '
          'ความก้าวหน้าจะไม่ถูกบันทึก',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.back(); // Go back to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('ออก'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes} นาที ${seconds} วินาที';
    } else {
      return '${seconds} วินาที';
    }
  }
}
