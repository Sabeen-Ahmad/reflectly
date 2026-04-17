import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const bgDeep = Color(0xFF0D1A0D);
  static const bgCard = Color(0xFF152015);
  static const bgSurface = Color(0xFF1C2E1C);
  static const bgElevated = Color(0xFF243424);

  // Accents
  static const accentLime = Color(0xFFB5D96A);
  static const accentLimeLight = Color(0xFFCFEC8A);
  static const accentGreen = Color(0xFF4CAF50);
  static const accentMoss = Color(0xFF6B8F4E);

  // Text
  static const textPrimary = Color(0xFFF0EDE6);
  static const textSecondary = Color(0xFFB8C4A8);
  static const textMuted = Color(0xFF6B7A5E);

  // Borders
  static const border = Color(0xFF2A3D2A);
  static const borderLight = Color(0xFF3A5A3A);

  // Tags
  static const tagFocus = Color(0xFFB5D96A);
  static const tagCalm = Color(0xFF5EEAD4);
  static const tagSleep = Color(0xFF93C5FD);
  static const tagReset = Color(0xFFFDBA74);

  // Legacy aliases (keep for compatibility)
  static const surface = bgSurface;
  static const surfaceBorder = border;
  static const accentViolet = accentLime;
  static const accentLight = accentLimeLight;
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDeep,
      fontFamily: 'DMSans',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentLime,
        surface: AppColors.bgSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDeep,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accentLime,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.accentLimeLight,
        trackHeight: 2,
      ),
    );
  }
}

Color tagColor(String tag) {
  switch (tag.toLowerCase()) {
    case 'focus':
      return AppColors.tagFocus;
    case 'calm':
      return AppColors.tagCalm;
    case 'sleep':
      return AppColors.tagSleep;
    case 'reset':
      return AppColors.tagReset;
    default:
      return AppColors.accentLimeLight;
  }
}

Color tagBg(String tag) => tagColor(tag).withOpacity(0.14);

// ── Journal / Reflection light theme colors ───────────────────────────────────
class JournalColors {
  static const bg         = Color(0xFFFAF8F4);   // warm cream
  static const bgCard     = Color(0xFFFFFFFF);   // pure white cards
  static const bgChip     = Color(0xFFF2EFE9);   // slightly darker cream
  static const border     = Color(0xFFE8E3DA);   // warm grey border
  static const textDark   = Color(0xFF1C1917);   // near-black
  static const textMid    = Color(0xFF78716C);   // warm grey
  static const textLight  = Color(0xFFA8A29E);   // placeholder
  static const accent     = Color(0xFF3D6B35);   // deep forest green accent
  static const accentBg   = Color(0xFFEAF2E8);   // light green tint
}
