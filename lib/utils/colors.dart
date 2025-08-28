import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Accent Colors
  static const Color accent = Color(0xFF4CAF50);
  static const Color accentDark = Color(0xFF388E3C);
  static const Color accentLight = Color(0xFF81C784);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;

  // Border & Divider
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Pain Point Colors (สำหรับแสดง pain point แต่ละประเภท)
  static const List<Color> painPointColors = [
    Color(0xFFE3F2FD), // Light Blue
    Color(0xFFE8F5E8), // Light Green
    Color(0xFFFFF3E0), // Light Orange
    Color(0xFFF3E5F5), // Light Purple
    Color(0xFFFFEBEE), // Light Red
    Color(0xFFF1F8E9), // Light Lime
    Color(0xFFF9FBE7), // Light Yellow
    Color(0xFFEDE7F6), // Light Deep Purple
    Color(0xFFE0F2F1), // Light Teal
    Color(0xFFEFEBE9), // Light Brown
  ];

  // Progress Colors
  static const Color progressBackground = Color(0xFFE0E0E0);
  static const Color progressForeground = Color(0xFF4CAF50);

  // Card Shadow
  static const Color cardShadow = Color(0x1A000000);

  // Notification Colors
  static const Color notificationPending = Color(0xFFFF9800);
  static const Color notificationCompleted = Color(0xFF4CAF50);
  static const Color notificationSkipped = Color(0xFF9E9E9E);
  static const Color notificationSnoozed = Color(0xFF2196F3);

  // Gradient Colors (สำหรับ cards และ backgrounds)
  static const List<List<Color>> gradients = [
    [Color(0xFF64B5F6), Color(0xFF2196F3)], // Blue gradient
    [Color(0xFF81C784), Color(0xFF4CAF50)], // Green gradient
    [Color(0xFFFFB74D), Color(0xFFFF9800)], // Orange gradient
    [Color(0xFFBA68C8), Color(0xFF9C27B0)], // Purple gradient
    [Color(0xFFE57373), Color(0xFFF44336)], // Red gradient
  ];

  // Helper methods
  static Color getPainPointColor(int index) {
    return painPointColors[index % painPointColors.length];
  }

  static List<Color> getGradient(int index) {
    return gradients[index % gradients.length];
  }

  static Color getNotificationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return notificationPending;
      case 'completed':
        return notificationCompleted;
      case 'skipped':
        return notificationSkipped;
      case 'snoozed':
        return notificationSnoozed;
      default:
        return textSecondary;
    }
  }

  // Material 3 inspired colors
  static const Color primaryContainer = Color(0xFFD1E4FF);
  static const Color onPrimaryContainer = Color(0xFF001D36);
  static const Color secondaryContainer = Color(0xFFE8DEF8);
  static const Color onSecondaryContainer = Color(0xFF1D192B);
  static const Color tertiaryContainer = Color(0xFFFFD8E4);
  static const Color onTertiaryContainer = Color(0xFF31111D);

  // Dark theme colors (สำหรับอนาคต)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);
}
