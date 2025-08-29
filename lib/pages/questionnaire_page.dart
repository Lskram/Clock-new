import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../models/pain_point.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final PageController _pageController = PageController();
  final settingsController = Get.find<SettingsController>();
  
  int _currentPage = 0;
  final List<String> _selectedPainPoints = [];
  int _selectedInterval = 60;
  TimeOfDay _workStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _workEndTime = const TimeOfDay(hour: 17, minute: 0);
  List<int> _selectedWorkDays = [1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          _buildAppBar(context),
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildWelcomePage(),
                _buildPainPointsPage(),
                _buildSchedulePage(),
                _buildWorkHoursPage(),
                _buildSummaryPage(),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_currentPage > 0)
              IconButton(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back),
              ),
            Expanded(
              child: Text(
                'การตั้งค่าเริ่มต้น',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (_currentPage > 0)
              TextButton(
                onPressed: _skipToEnd,
                child: const Text('ข้าม'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: LinearProgressIndicator(
        value: (_currentPage + 1) / 5,
        backgroundColor: Colors.grey.withValues(alpha: 0.3),
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.self_improvement,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 32),
          Text(
            'ยินดีต้อนรับสู่ Office Syndrome Helper',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'เราจะช่วยคุณตั้งค่าการแจ้งเตือนและเลือกท่าออกกำลังที่เหมาะสมสำหรับการทำงาน',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.timer,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'ใช้เวลาประมาณ 2-3 นาที',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPainPointsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'เลือกจุดที่คุณมีปัญหาหรือต้องการดูแล',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เลือกได้สูงสุด $maxSelectedPainPoints รายการ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _getPainPointOptions().length,
              itemBuilder: (context, index) {
                final painPoint = _getPainPointOptions()[index];
                final isSelected = _selectedPainPoints.contains(painPoint.id);
                
                return _buildPainPointCard(painPoint, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPainPointCard(PainPoint painPoint, bool isSelected) {
    return GestureDetector(
      onTap: () => _togglePainPoint(painPoint.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getPainPointIcon(painPoint.id),
              size: 40,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              painPoint.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ตั้งค่าความถี่ในการแจ้งเตือน',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เราจะแจ้งเตือนให้คุณออกกำลังตามความถี่ที่ตั้งไว้',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ทุกๆ $_selectedInterval นาที',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: _selectedInterval.toDouble(),
                    min: 15,
                    max: 240,
                    divisions: 15,
                    label: '$_selectedInterval นาที',
                    onChanged: (value) {
                      setState(() {
                        _selectedInterval = value.round();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('15 นาที', style: Theme.of(context).textTheme.bodySmall),
                      Text('4 ชั่วโมง', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildPresetButtons(),
        ],
      ),
    );
  }

  Widget _buildPresetButtons() {
    final presets = [30, 60, 90, 120];
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: presets.map((minutes) {
        final isSelected = _selectedInterval == minutes;
        return FilterChip(
          selected: isSelected,
          label: Text('$minutes นาที'),
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedInterval = minutes;
              });
            }
          },
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildWorkHoursPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ตั้งค่าเวลาทำงาน',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เราจะแจ้งเตือนเฉพาะในช่วงเวลาทำงานของคุณ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTimeSelector(
                    'เวลาเริ่มงาน',
                    _workStartTime,
                    Icons.work_outline,
                    (time) => setState(() => _workStartTime = time),
                  ),
                  const SizedBox(height: 24),
                  _buildTimeSelector(
                    'เวลาเลิกงาน',
                    _workEndTime,
                    Icons.work_off_outlined,
                    (time) => setState(() => _workEndTime = time),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'วันทำงาน',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildWorkDaysSelector(),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    String label,
    TimeOfDay time,
    IconData icon,
    Function(TimeOfDay) onChanged,
  ) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            final newTime = await showTimePicker(
              context: context,
              initialTime: time,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    timePickerTheme: TimePickerThemeData(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      hourMinuteTextColor: Theme.of(context).colorScheme.onSurface,
                      dialHandColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (newTime != null) {
              onChanged(newTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time.format(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkDaysSelector() {
    const dayNames = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
    
    return Row(
      children: List.generate(7, (index) {
        final dayNumber = index + 1;
        final isSelected = _selectedWorkDays.contains(dayNumber);
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => _toggleWorkDay(dayNumber),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dayNames[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สรุปการตั้งค่า',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ตรวจสอบการตั้งค่าก่อนเริ่มใช้งาน',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildSummaryCard(
                  'จุดที่เลือกดูแล',
                  '${_selectedPainPoints.length} รายการ',
                  Icons.healing,
                  _selectedPainPoints.map((id) => _getPainPointName(id)).join(', '),
                ),
                _buildSummaryCard(
                  'ความถี่การแจ้งเตือน',
                  'ทุกๆ $_selectedInterval นาที',
                  Icons.schedule,
                  null,
                ),
                _buildSummaryCard(
                  'เวลาทำงาน',
                  '${_workStartTime.format(context)} - ${_workEndTime.format(context)}',
                  Icons.work_outline,
                  _getWorkDaysText(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _finishSetup,
              icon: const Icon(Icons.check),
              label: const Text('เริ่มใช้งาน'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    String? subtitle,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                child: const Text('ย้อนกลับ'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentPage == 4 ? _finishSetup : _nextPage,
              child: Text(_currentPage == 4 ? 'เริ่มใช้งาน' : 'ถัดไป'),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  List<PainPoint> _getPainPointOptions() {
    return PainPoint.getDefaultPainPoints();
  }

  IconData _getPainPointIcon(String painPointId) {
    final icons = {
      'neck_pain': Icons.person_outline,
      'shoulder_pain': Icons.accessibility_new,
      'back_pain': Icons.airline_seat_recline_normal,
      'eye_strain': Icons.visibility,
      'wrist_pain': Icons.back_hand,
    };
    return icons[painPointId] ?? Icons.healing;
  }

  String _getPainPointName(String painPointId) {
    final names = {
      'neck_pain': 'ปวดคอ',
      'shoulder_pain': 'ปวดไหล่',
      'back_pain': 'ปวดหลัง',
      'eye_strain': 'ปวดตา',
      'wrist_pain': 'ปวดข้อมือ',
    };
    return names[painPointId] ?? painPointId;
  }

  String _getWorkDaysText() {
    const dayNames = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
    return _selectedWorkDays.map((day) => dayNames[day - 1]).join(', ');
  }

  void _togglePainPoint(String painPointId) {
    setState(() {
      if (_selectedPainPoints.contains(painPointId)) {
        _selectedPainPoints.remove(painPointId);
      } else if (_selectedPainPoints.length < maxSelectedPainPoints) {
        _selectedPainPoints.add(painPointId);
      } else {
        Get.snackbar(
          'ข้อจำกัด',
          'สามารถเลือกได้สูงสุด $maxSelectedPainPoints รายการ',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    });
  }

  void _toggleWorkDay(int day) {
    setState(() {
      if (_selectedWorkDays.contains(day)) {
        if (_selectedWorkDays.length > 1) {
          _selectedWorkDays.remove(day);
        }
      } else {
        _selectedWorkDays.add(day);
      }
      _selectedWorkDays.sort();
    });
  }

  void _nextPage() {
    if (_currentPage == 1 && _selectedPainPoints.isEmpty) {
      Get.snackbar(
        'กรุณาเลือก',
        'กรุณาเลือกอย่างน้อย 1 จุดที่ต้องการดูแล',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    Get.offAllNamed(AppRoutes.home);
  }

  Future<void> _finishSetup() async {
    try {
      // Save settings to controller
      await settingsController.updateSelectedPainPoints(_selectedPainPoints);
      await settingsController.updateNotificationInterval(_selectedInterval);
      await settingsController.updateWorkHours(_workStartTime, _workEndTime);
      await settingsController.updateWorkDays(_selectedWorkDays);
      await settingsController.updateNotificationEnabled(true);
      
      // Navigate to home
      Get.offAllNamed(AppRoutes.home);
      
      // Show welcome message
      Get.snackbar(
        'ยินดีต้อนรับ!',
        'ตั้งค่าเรียบร้อยแล้ว พร้อมเริ่มดูแลสุขภาพกัน',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Error finishing setup: $e');
      Get.snackbar(
        'เกิดข้อผิดพลาด',
        'ไม่สามารถบันทึกการตั้งค่าได้',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}