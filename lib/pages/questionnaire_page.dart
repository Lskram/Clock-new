import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../models/pain_point.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({Key? key}) : super(key: key);

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage>
    with SingleTickerProviderStateMixin {
  final AppController _appController = Get.find<AppController>();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<PainPoint> _painPoints = PainPointData.getAllPainPoints();
  final Set<int> _selectedPainPointIds = <int>{};
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _togglePainPoint(int painPointId) {
    setState(() {
      if (_selectedPainPointIds.contains(painPointId)) {
        _selectedPainPointIds.remove(painPointId);
      } else {
        if (_selectedPainPointIds.length < AppConstants.MAX_SELECTED_PAIN_POINTS) {
          _selectedPainPointIds.add(painPointId);
        } else {
          // แสดงข้อความเตือนเมื่อเลือกเกิน
          Get.snackbar(
            'เลือกได้สูงสุด ${AppConstants.MAX_SELECTED_PAIN_POINTS} จุด',
            'กรุณาเลือกจุดที่ปวดบ่อยที่สุดเท่านั้น',
            backgroundColor: AppColors.warning.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      }
    });
  }

  void _completeSetup() async {
    if (_selectedPainPointIds.length < AppConstants.MIN_SELECTED_PAIN_POINTS) {
      Get.snackbar(
        'กรุณาเลือกจุดที่ปวด',
        'เลือกอย่างน้อย ${AppConstants.MIN_SELECTED_PAIN_POINTS} จุด เพื่อให้แอปช่วยดูแลได้',
        backgroundColor: AppColors.error.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // แสดง loading
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      // บันทึกการตั้งค่า
      await _appController.completeFirstTimeSetup(_selectedPainPointIds.toList());
      
      // ปิด loading dialog
      Get.back();
      
      // แสดงข้อความยินดี
      Get.snackbar(
        'ตั้งค่าเสร็จสมบูรณ์! 🎉',
        'แอปจะเริ่มแจ้งเตือนให้คุณออกกำลังกายแล้ว',
        backgroundColor: AppColors.success.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      // ไปหน้าหลัก
      Get.offNamed(AppRoutes.HOME);
    } catch (e) {
      // ปิด loading dialog
      Get.back();
      
      Get.snackbar(
        'เกิดข้อผิดพลาด',
        'ไม่สามารถบันทึกการตั้งค่าได้ กรุณาลองใหม่',
        backgroundColor: AppColors.error.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(),
                      
                      const SizedBox(height: 32),
                      
                      // Pain Points Grid
                      Expanded(
                        child: _buildPainPointsGrid(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Selection Info
                      _buildSelectionInfo(),
                      
                      const SizedBox(height: 24),
                      
                      // Complete Button
                      _buildCompleteButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.health_and_safety,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'เริ่มต้นใช้งาน',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          'คุณปวดหรือเมื่อยบริเวณไหนบ่อย?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'เลือกจุดที่ปวดบ่อยที่สุด สูงสุด ${AppConstants.MAX_SELECTED_PAIN_POINTS} จุด\nแอปจะสุ่มแนะนำท่าออกกำลังกายที่เหมาะสม',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPainPointsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _painPoints.length,
      itemBuilder: (context, index) {
        final painPoint = _painPoints[index];
        final isSelected = _selectedPainPointIds.contains(painPoint.id);
        
        return _buildPainPointCard(painPoint, isSelected, index);
      },
    );
  }

  Widget _buildPainPointCard(PainPoint painPoint, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => _togglePainPoint(painPoint.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon/Image placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2) 
                    : AppColors.getPainPointColor(index).withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                _getPainPointIcon(painPoint.id),
                size: 28,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Pain point name
            Text(
              painPoint.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                painPoint.description,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected 
                      ? Colors.white.withOpacity(0.8) 
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'เลือกแล้ว ${_selectedPainPointIds.length} จาก ${AppConstants.MAX_SELECTED_PAIN_POINTS} จุด',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                if (_selectedPainPointIds.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getSelectedPainPointNames(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    final canComplete = _selectedPainPointIds.length >= AppConstants.MIN_SELECTED_PAIN_POINTS;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canComplete ? _completeSetup : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canComplete ? AppColors.primary : AppColors.divider,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.divider,
          elevation: canComplete ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              canComplete ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              canComplete ? 'เริ่มใช้งาน' : 'เลือกจุดที่ปวดอย่างน้อย 1 จุด',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPainPointIcon(int painPointId) {
    switch (painPointId) {
      case 1: return Icons.psychology; // ศีรษะ
      case 2: return Icons.visibility; // ตา
      case 3: return Icons.accessibility_new; // คอ
      case 4: return Icons.fitness_center; // บ่าและไหล่
      case 5: return Icons.straighten; // หลังส่วนบน
      case 6: return Icons.airline_seat_recline_normal; // หลังส่วนล่าง
      case 7: return Icons.pan_tool; // แขน/ศอก
      case 8: return Icons.touch_app; // ข้อมือ/มือ/นิ้ว
      case 9: return Icons.directions_walk; // ขา
      case 10: return Icons.directions_run; // เท้า
      default: return Icons.health_and_safety;
    }
  }

  String _getSelectedPainPointNames() {
    final selectedNames = _painPoints
        .where((pp) => _selectedPainPointIds.contains(pp.id))
        .map((pp) => pp.name)
        .toList();
    
    return selectedNames.join(', ');
  }
}