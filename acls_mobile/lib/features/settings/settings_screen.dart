import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_provider.dart';
import './language_provider.dart';
import './theme_color_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(themeColorProvider);
    final curLang = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(curLang == 'te' ? 'సెట్టింగులు' : 'Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSection(
            context,
            title: curLang == 'te' ? '🎨 థీమ్ రంగు' : '🎨 Theme Color',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: availableThemes.entries.map((entry) {
                final isSelected = primaryColor.toARGB32() == entry.value.toARGB32();
                return GestureDetector(
                  onTap: () => ref.read(themeColorProvider.notifier).setColor(entry.value),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: entry.value,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? (isDark ? Colors.white : const Color(0xFF0F172A)) : Colors.transparent,
                        width: isSelected ? 4 : 0,
                      ),
                      boxShadow: [
                        if (!isSelected) BoxShadow(
                          color: entry.value.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
          _buildSection(
            context,
            title: curLang == 'te' ? '🌗 ప్రదర్శన మోడ్' : '🌗 Appearance',
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                title: Text(isDark ? (curLang == 'te' ? 'డార్క్ మోడ్' : 'Dark Mode') : (curLang == 'te' ? 'లైట్ మోడ్' : 'Light Mode')),
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                  activeThumbColor: primaryColor,
                  activeTrackColor: primaryColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSection(
            context,
            title: curLang == 'te' ? '🌐 భాష' : '🌐 Language',
            child: Row(
              children: [
                _buildLangButton(
                  context,
                  ref,
                  label: 'English',
                  code: 'en',
                  isSelected: curLang == 'en',
                  primaryColor: primaryColor,
                ),
                const SizedBox(width: 12),
                _buildLangButton(
                  context,
                  ref,
                  label: 'తెలుగు',
                  code: 'te',
                  isSelected: curLang == 'te',
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              foregroundColor: Colors.red,
              elevation: 0,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.exit_to_app_rounded, size: 20),
                const SizedBox(width: 12),
                Text(
                  curLang == 'te' ? 'డాష్‌బోర్డ్‌కు వెళ్లండి' : 'Go to Dashboard',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildLangButton(BuildContext context, WidgetRef ref, {required String label, required String code, required bool isSelected, required Color primaryColor}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(languageProvider.notifier).setLanguage(code),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
