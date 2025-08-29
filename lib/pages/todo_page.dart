import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../controllers/notification_controller.dart';
import '../models/treatment.dart';
import '../models/notification_session.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with TickerProviderStateMixin {
  final notificationController = Get.find<NotificationController>();
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  Timer? _timer;
  int _currentTreatmentIndex = 0;
  int _remainingSeconds = 0;
  bool _isPlaying = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCurrentSession();
  }

  void _initializeAnimations() {
    _progressAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadCurrentSession() async {
    final session = notificationController.currentSession.value;
    if (session != null && session.treatmentIds.isNotEmpty) {
      _currentTreatmentIndex = session.completedTreatmentIds.length;
      if (_currentTreatmentIndex < session.treatmentIds.length) {
        await _loadCurrentTreatment();
      }
    }
  }

  Future<void> _loadCurrentTreatment() async {
    final session = notificationController.currentSession.value;
    if (session != null &&
        _currentTreatmentIndex < session.treatmentIds.length) {
      final treatmentId = session.treatmentIds[_currentTreatmentIndex];
      final treatment = await _getTreatmentById(treatmentId);
      if (treatment != null) {
        setState(() {
          _remainingSeconds = treatment.durationSeconds;
          _isPlaying = false;
          _isPaused = false;
        });
      }
    }
  }

  Future<Treatment?> _getTreatmentById(String id) async {
    // This should be implemented to get treatment from database
    // For now, return a placeholder
    final defaultTreatments = Treatment.getDefaultTreatments();
    return defaultTreatments.firstWhereOrNull((t) => t.id == id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Obx(() {
        final session = notificationController.currentSession.value;
        if (session == null) {
          return _buildNoSessionView();
        }
        return _buildSessionView(session);
      }),
    );
  }

  Widget _buildNoSessionView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ออกกำลังกาย'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.self_improvement,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'ไม่มีเซสชันที่ใช้งานอยู่',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'กลับไปหน้าหลักเพื่อเริ่มเซสชันใหม่',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.home),
              label: const Text('กลับหน้าหลัก'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionView(NotificationSession session) {
    return Column(
      children: [
        _buildAppBar(session),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProgressCard(session),
                const SizedBox(height: 16),
                _buildCurrentTreatmentCard(session),
                const SizedBox(height: 16),
                _buildTreatmentsList(session),
              ],
            ),
          ),
        ),
        _buildBottomControls(session),
      ],
    );
  }

  Widget _buildAppBar(NotificationSession session) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              onPressed: () => _showExitDialog(),
              icon: const Icon(Icons.close),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'เซสชันออกกำลัง',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${session.completedTreatmentIds.length}/${session.treatmentIds.length} เสร็จสิ้น',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showSessionMenu(),
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(NotificationSession session) {
    final progress = session.completionProgress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ความคืบหน้า',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTreatmentCard(NotificationSession session) {
    if (_currentTreatmentIndex >= session.treatmentIds.length) {
      return _buildCompletionCard();
    }

    return FutureBuilder<Treatment?>(
      future: _getTreatmentById(session.treatmentIds[_currentTreatmentIndex]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final treatment = snapshot.data!;
        return _buildTreatmentCard(treatment, isActive: true);
      },
    );
  }

  Widget _buildTreatmentCard(Treatment treatment, {bool isActive = false}) {
    return Card(
      color: isActive
          ? Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.3)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: isActive ? Colors.white : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        treatment.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                      ),
                      Text(
                        treatment.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 24),
              _buildTimer(treatment),
              const SizedBox(height: 16),
              _buildInstructions(treatment),
            ] else ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: Colors.grey.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    treatment.formattedDuration,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.withValues(alpha: 0.6),
                        ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'เสร็จสิ้น',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimer(Treatment treatment) {
    final progress = 1.0 - (_remainingSeconds / treatment.durationSeconds);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    'เหลือ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_isPlaying || _isPaused)
                IconButton(
                  onPressed: _pauseTimer,
                  icon: Icon(
                    _isPaused ? Icons.play_arrow : Icons.pause,
                    size: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.orange.withValues(alpha: 0.1),
                    foregroundColor: Colors.orange,
                  ),
                ),
              IconButton(
                onPressed: _isPlaying ? null : _startTimer,
                icon: const Icon(Icons.play_arrow, size: 32),
                style: IconButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: _skipTreatment,
                icon: const Icon(Icons.skip_next, size: 32),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.withValues(alpha: 0.1),
                  foregroundColor: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(Treatment treatment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt,
                color: Colors.blue.withValues(alpha: 0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'วิธีการทำ',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.withValues(alpha: 0.8),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...treatment.instructions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTreatmentsList(NotificationSession session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'รายการท่าทั้งหมด',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...session.treatmentIds.asMap().entries.map((entry) {
              final index = entry.key;
              final treatmentId = entry.value;
              final isCompleted =
                  session.completedTreatmentIds.contains(treatmentId);
              final isActive = index == _currentTreatmentIndex;

              return FutureBuilder<Treatment?>(
                future: _getTreatmentById(treatmentId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text('กำลังโหลด...'),
                    );
                  }

                  final treatment = snapshot.data!;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.2)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green
                              : isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : Icons.fitness_center,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      title: Text(
                        treatment.name,
                        style: TextStyle(
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                      subtitle: Text(treatment.formattedDuration),
                      trailing: isCompleted
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : isActive
                              ? Icon(
                                  Icons.play_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Card(
      color: Colors.green.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'เยี่ยมมาก!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'คุณได้ทำท่าออกกำลังครบทุกท่าแล้ว',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.green.withValues(alpha: 0.8),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _completeSession,
                icon: const Icon(Icons.check),
                label: const Text('เสร็จสิ้น'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(NotificationSession session) {
    if (_currentTreatmentIndex >= session.treatmentIds.length) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _skipTreatment,
                icon: const Icon(Icons.skip_next),
                label: const Text('ข้าม'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _completeTreatment,
                icon: const Icon(Icons.check),
                label: const Text('ทำเสร็จแล้ว'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Timer Methods
  void _startTimer() {
    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeCurrentTreatment();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _isPaused = true;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });
  }

  // Treatment Methods
  void _completeTreatment() {
    _stopTimer();
    _completeCurrentTreatment();
  }

  void _skipTreatment() {
    _stopTimer();
    _moveToNextTreatment();
  }

  void _completeCurrentTreatment() {
    final session = notificationController.currentSession.value;
    if (session != null &&
        _currentTreatmentIndex < session.treatmentIds.length) {
      final treatmentId = session.treatmentIds[_currentTreatmentIndex];
      session.addCompletedTreatment(treatmentId);
      notificationController.updateCurrentSession(session);

      _moveToNextTreatment();
    }
  }

  void _moveToNextTreatment() {
    setState(() {
      _currentTreatmentIndex++;
    });

    final session = notificationController.currentSession.value;
    if (session != null &&
        _currentTreatmentIndex < session.treatmentIds.length) {
      _loadCurrentTreatment();
    }
  }

  // Session Methods
  Future<void> _completeSession() async {
    final session = notificationController.currentSession.value;
    if (session != null) {
      session.markAsCompleted();
      await notificationController.clearCurrentSession();

      Get.back();
      Get.snackbar(
        'ยินดีด้วย!',
        'คุณได้ออกกำลังครบทุกท่าแล้ว',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // UI Helper Methods
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showExitDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('ออกจากเซสชัน'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากเซสชันนี้?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('ออก'),
          ),
        ],
      ),
    );
  }

  void _showSessionMenu() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pause),
              title: const Text('หยุดชั่วคราว'),
              onTap: () {
                Get.back();
                _pauseTimer();
              },
            ),
            ListTile(
              leading: const Icon(Icons.skip_next),
              title: const Text('ข้ามท่านี้'),
              onTap: () {
                Get.back();
                _skipTreatment();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('ออกจากเซสชัน'),
              onTap: () {
                Get.back();
                _showExitDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressAnimationController.dispose();
    super.dispose();
  }
}
