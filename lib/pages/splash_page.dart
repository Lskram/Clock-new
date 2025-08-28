import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../controllers/app_controller.dart';
import '../routes/app_routes.dart';
import '../utils/colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _startInitialization();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  void _startInitialization() async {
    final appController = Get.find<AppController>();

    // เริ่มการเตรียมข้อมูล
    await appController.initializeApp();

    // รอให้ animation เสร็จก่อน (อย่างน้อย 2.5 วินาที)
    await Future.delayed(const Duration(milliseconds: 2500));

    // ตรวจสอบว่าเป็นการใช้งานครั้งแรกหรือไม่
    if (appController.isFirstTimeSetup) {
      Get.offNamed(AppRoutes.QUESTIONNAIRE);
    } else {
      Get.offNamed(AppRoutes.HOME);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and Title
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        children: [
                          // App Icon/Logo
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.health_and_safety,
                              size: 60,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // App Title
                          const Text(
                            'Office Syndrome\nHelper',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Subtitle
                          Text(
                            'ดูแลสุขภาพในที่ทำงาน\nด้วยการออกกำลังกายง่าย ๆ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 80),

              // Loading Indicator
              GetBuilder<AppController>(
                builder: (controller) {
                  return Column(
                    children: [
                      // Progress Indicator
                      CircularPercentIndicator(
                        radius: 30.0,
                        lineWidth: 4.0,
                        animation: true,
                        animationDuration: 1200,
                        percent: controller.initializationProgress,
                        center: Text(
                          '${(controller.initializationProgress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.3),
                      ),

                      const SizedBox(height: 20),

                      // Loading Text
                      Text(
                        controller.initializationMessage,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
