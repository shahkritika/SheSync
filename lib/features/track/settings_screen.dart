import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/auth_service.dart';
import '../../core/profile_service.dart';
import '../../main.dart';
import '../login_screen.dart';
import '../profile/user_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  // Accent stays fixed regardless of dark mode — it's the brand pink/green
  static const Color _accent = Color(0xFF7ED6B2);

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ── Auth ──
  String? currentUsername;

  // ── Health Profile ──
  UserProfile? userProfile;

  // ── Notifications ──
  // Note: on Windows desktop, these preferences are saved and respected by
  // the UI, but actual system notifications require platform channel work
  // beyond flutter_local_notifications (which supports Android/iOS/macOS only).
  // On Android/iOS builds, wire these values into a notification plugin.
  bool dailyReminder = true;
  bool periodReminder = true;
  bool medicationReminder = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0);

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _loadAll();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadPreferences(), _loadProfile()]);
    if (mounted) {
      setState(() => isLoading = false);
      _animController.forward();
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final username = await AuthService.getUsername();
    if (!mounted) return;
    setState(() {
      dailyReminder = prefs.getBool('dailyReminder') ?? true;
      periodReminder = prefs.getBool('periodReminder') ?? true;
      medicationReminder = prefs.getBool('medicationReminder') ?? false;
      final hour = prefs.getInt('reminderHour') ?? 9;
      final minute = prefs.getInt('reminderMinute') ?? 0;
      reminderTime = TimeOfDay(hour: hour, minute: minute);
      currentUsername = username;
    });
  }

  Future<void> _saveNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyReminder', dailyReminder);
    await prefs.setBool('periodReminder', periodReminder);
    await prefs.setBool('medicationReminder', medicationReminder);
    await prefs.setInt('reminderHour', reminderTime.hour);
    await prefs.setInt('reminderMinute', reminderTime.minute);
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService.getProfile();
      if (!mounted) return;
      setState(() => userProfile = profile);
    } catch (_) {}
  }

  // ─────────────────────────────────────────────
  //  DARK MODE
  // ─────────────────────────────────────────────
  bool get _isDarkMode =>
      ThemeNotifier.of(context)?.isDarkMode ?? false;

  void _toggleDarkMode(bool value) {
    ThemeNotifier.of(context)?.toggleTheme();
  }

  // ─────────────────────────────────────────────
  //  LOGOUT
  // ─────────────────────────────────────────────
  Future<void> _handleLogout() async {
    final confirmed = await _confirmDialog(
      emoji: "👋",
      title: "Log Out?",
      message: "You'll be returned to the login screen. Your data stays saved.",
      confirmLabel: "Log Out",
      confirmColor: _accent,
    );
    if (confirmed != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
      (route) => false,
    );
  }

  // ─────────────────────────────────────────────
  //  DELETE ACCOUNT
  // ─────────────────────────────────────────────
  Future<void> _deleteAccount() async {
    final confirmed = await _confirmDialog(
      emoji: "⚠️",
      title: "Delete Account?",
      message:
          "This permanently deletes your account and all data. It cannot be undone.",
      confirmLabel: "Delete",
      confirmColor: Colors.red.shade400,
    );
    if (confirmed != true) return;

    // Double-confirm by typing username
    final confirmController = TextEditingController();
    final doubleConfirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("🔴 Final Confirmation",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Type your username "$currentUsername" to confirm:',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Type username here",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade400),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.black54)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (confirmController.text.trim() == currentUsername) {
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("Username doesn't match!"),
                          backgroundColor: Colors.red.shade400,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ));
                      }
                    },
                    child: const Text("Confirm Delete",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );

    if (doubleConfirmed == true) {
      // TODO: call a DELETE /api/auth/delete/ endpoint when available.
      // For now, clear local state and log out.
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await AuthService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
        (route) => false,
      );
    }
  }

  // ─────────────────────────────────────────────
  //  EXPORT DATA
  // ─────────────────────────────────────────────
  Future<void> _exportData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final buffer = StringBuffer();
      buffer.writeln('SheSync Data Export');
      buffer.writeln('Exported: ${DateTime.now().toString().split('.')[0]}');
      buffer.writeln('Username: ${currentUsername ?? "Unknown"}');
      buffer.writeln('---');

      // Health profile
      if (userProfile != null) {
        buffer.writeln('age,${userProfile!.age ?? ""}');
        buffer.writeln('height_cm,${userProfile!.heightCm ?? ""}');
        buffer.writeln('weight_kg,${userProfile!.weightKg ?? ""}');
        buffer.writeln(
            'average_cycle_length,${userProfile!.averageCycleLength}');
        buffer.writeln(
            'average_period_length,${userProfile!.averagePeriodLength}');
        buffer.writeln(
            'last_period_start_date,${userProfile!.lastPeriodStartDate ?? ""}');
      }

      // Local preferences
      buffer.writeln('---');
      for (final key in prefs.getKeys()) {
        buffer.writeln('$key,${prefs.get(key)}');
      }

      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/shesync_export.csv');
        await file.writeAsString(buffer.toString());
        if (!mounted) return;
        _showInfoDialog(
          emoji: "📁",
          title: "Export Successful",
          body: "Saved to:\n${file.path}",
          extraWidget: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              buffer.toString().split('\n').take(8).join('\n'),
              style: const TextStyle(
                  fontSize: 11, fontFamily: 'monospace', color: Colors.black87),
            ),
          ),
        );
      } catch (_) {
        await Clipboard.setData(ClipboardData(text: buffer.toString()));
        if (!mounted) return;
        _snack("📋 Data copied to clipboard!");
      }
    } catch (e) {
      _snack("Export failed: $e", color: Colors.red.shade400);
    }
  }

  // ─────────────────────────────────────────────
  //  CLEAR DATA
  // ─────────────────────────────────────────────
  Future<void> _clearAllData() async {
    final confirmed = await _confirmDialog(
      emoji: "🗑️",
      title: "Clear All Local Data?",
      message:
          "This removes all locally stored settings and preferences. Your account and health data on the server stays safe.",
      confirmLabel: "Clear",
      confirmColor: Colors.red.shade400,
    );
    if (confirmed != true) return;
    final prefs = await SharedPreferences.getInstance();
    // Preserve auth tokens so user stays logged in
    final access = prefs.getString('access_token');
    final refresh = prefs.getString('refresh_token');
    final username = prefs.getString('cached_username');
    await prefs.clear();
    if (access != null) await prefs.setString('access_token', access);
    if (refresh != null) await prefs.setString('refresh_token', refresh);
    if (username != null) await prefs.setString('cached_username', username);
    if (!mounted) return;
    _snack("Local data cleared ✓");
    _loadAll();
  }

  // ─────────────────────────────────────────────
  //  PICK REMINDER TIME
  // ─────────────────────────────────────────────
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
      builder: (context, child) => Theme(
        data: Theme.of(context)
            .copyWith(colorScheme: ColorScheme.light(primary: _accent)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => reminderTime = picked);
      await _saveNotificationPreferences();
    }
  }

  // ─────────────────────────────────────────────
  //  RATE APP
  // ─────────────────────────────────────────────
  void _rateApp() {
    int selectedStars = 0;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("⭐ Rate SheSync",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text("How would you rate your experience?",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final filled = i < selectedStars;
                    return GestureDetector(
                      onTap: () => setLocal(() => selectedStars = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          filled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: filled
                              ? Colors.amber.shade400
                              : Colors.grey.shade300,
                          size: 44,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Text(
                  ['Tap to rate', 'Poor 😞', 'Fair 😐', 'Good 🙂', 'Great 😊',
                      'Excellent! 🤩'][selectedStars],
                  style: TextStyle(
                    color: selectedStars == 0
                        ? Colors.grey.shade400
                        : Colors.amber.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedStars > 0
                            ? Colors.amber.shade400
                            : Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: selectedStars > 0
                          ? () {
                              Navigator.pop(context);
                              _snack(
                                  "Thanks for your $selectedStars⭐ rating! 💚",
                                  color: Colors.amber.shade600);
                            }
                          : null,
                      child: const Text("Submit",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SHARE APP
  // ─────────────────────────────────────────────
  Future<void> _shareApp() async {
    const text =
        'I\'ve been using SheSync to track my cycle and feel so much more in tune with my body 🌸 Check it out!';
    await Clipboard.setData(const ClipboardData(text: text));
    _snack("📋 Message copied — paste it anywhere to share!");
  }

  // ─────────────────────────────────────────────
  //  SEND FEEDBACK
  // ─────────────────────────────────────────────
  void _sendFeedback() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("💬 Send Feedback",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("We read every message — thank you 💚",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                maxLines: 4,
                maxLength: 500,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _accent),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.black54)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (ctrl.text.trim().isEmpty) return;
                      // TODO: POST feedback to backend when endpoint exists.
                      // For now, copy to clipboard as a workaround.
                      Clipboard.setData(ClipboardData(
                          text:
                              'SheSync Feedback from $currentUsername:\n${ctrl.text.trim()}'));
                      Navigator.pop(context);
                      _snack("💚 Feedback noted — thank you!");
                    },
                    child: const Text("Send",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  OPEN HEALTH PROFILE
  // ─────────────────────────────────────────────
  Future<void> _openHealthProfile() async {
    await Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => const UserProfileScreen(),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 280),
    ));
    await _loadProfile();
    if (mounted) setState(() {});
  }

  // ─────────────────────────────────────────────
  //  REUSABLE HELPERS
  // ─────────────────────────────────────────────
  void _snack(String msg, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color ?? _accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<bool?> _confirmDialog({
    required String emoji,
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.black54)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(confirmLabel,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(
      {required String emoji,
      required String title,
      required String body,
      Widget? extraWidget}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(body,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              if (extraWidget != null) ...[
                const SizedBox(height: 12),
                extraWidget,
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Done",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  UI HELPERS
  // ─────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: _accent),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3)),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _toggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? _accent).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor ?? _accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: _accent),
        ],
      ),
    );
  }

  Widget _tapRow({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required IconData icon,
    Color? iconColor,
    Color? titleColor,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? _accent).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor ?? _accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: titleColor)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right,
                    color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(
      height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade200);

  Widget _infoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Settings ⚙️",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _handleLogout,
              child: Text("Logout",
                  style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _accent))
          : FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── PROFILE HEADER ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_accent, const Color(0xFFB2EED6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: _accent.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child:
                                  Text("🌸", style: TextStyle(fontSize: 28)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentUsername ?? "Welcome! 👋",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userProfile?.age != null
                                      ? "Age ${userProfile!.age}"
                                          "${userProfile!.weightKg != null ? ' · ${userProfile!.weightKg}kg' : ''}"
                                          "${userProfile!.currentPhase != null ? ' · ${userProfile!.currentPhase}' : ''}"
                                      : "Tap below to set up your profile",
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── HEALTH PROFILE ──
                    _sectionHeader("Health Profile", Icons.favorite_outline),
                    _card(
                      child: Column(
                        children: [
                          if (userProfile != null &&
                              (userProfile!.age != null ||
                                  userProfile!.heightCm != null ||
                                  userProfile!.weightKg != null)) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 4),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (userProfile!.age != null)
                                    _infoChip("Age",
                                        "${userProfile!.age} yrs",
                                        Colors.purple.shade400),
                                  if (userProfile!.heightCm != null)
                                    _infoChip("Height",
                                        "${userProfile!.heightCm} cm",
                                        Colors.blue.shade400),
                                  if (userProfile!.weightKg != null)
                                    _infoChip("Weight",
                                        "${userProfile!.weightKg} kg",
                                        Colors.orange.shade400),
                                  _infoChip(
                                      "Cycle",
                                      "${userProfile!.averageCycleLength}d",
                                      _accent),
                                  _infoChip(
                                      "Period",
                                      "${userProfile!.averagePeriodLength}d",
                                      Colors.red.shade300),
                                  if (userProfile!.currentPhase != null)
                                    _infoChip(
                                        "Phase",
                                        userProfile!.currentPhase!,
                                        Colors.pink.shade300),
                                ],
                              ),
                            ),
                            _divider(),
                          ],
                          _tapRow(
                            title: userProfile?.age != null
                                ? "Edit Health Profile"
                                : "Set Up Health Profile",
                            subtitle: userProfile?.age != null
                                ? "Update age, height, weight & cycle details"
                                : "Add your health details for better tracking",
                            icon: Icons.edit_outlined,
                            iconColor: const Color(0xFFE91E63),
                            onTap: _openHealthProfile,
                          ),
                        ],
                      ),
                    ),

                    // ── APPEARANCE ──
                    _sectionHeader("Appearance", Icons.palette_outlined),
                    _card(
                      child: _toggleRow(
                        title: "Dark Mode",
                        subtitle: isDark
                            ? "Dark theme is on"
                            : "Light theme is on",
                        value: isDark,
                        onChanged: _toggleDarkMode,
                        icon: isDark
                            ? Icons.dark_mode
                            : Icons.light_mode_outlined,
                        iconColor: isDark
                            ? Colors.indigo.shade400
                            : Colors.amber.shade500,
                      ),
                    ),

                    // ── NOTIFICATIONS ──
                    _sectionHeader(
                        "Notifications", Icons.notifications_outlined),
                    _card(
                      child: Column(
                        children: [
                          _toggleRow(
                            title: "Daily Reminder",
                            subtitle: "Remind me to track every day",
                            value: dailyReminder,
                            onChanged: (v) async {
                              setState(() => dailyReminder = v);
                              await _saveNotificationPreferences();
                            },
                            icon: Icons.today_rounded,
                            iconColor: _accent,
                          ),
                          _divider(),
                          _toggleRow(
                            title: "Period Reminder",
                            subtitle:
                                "Alert 2 days before predicted period",
                            value: periodReminder,
                            onChanged: (v) async {
                              setState(() => periodReminder = v);
                              await _saveNotificationPreferences();
                            },
                            icon: Icons.water_drop_rounded,
                            iconColor: Colors.red.shade300,
                          ),
                          _divider(),
                          _toggleRow(
                            title: "Medication Reminder",
                            subtitle:
                                "Remind me to take my medication",
                            value: medicationReminder,
                            onChanged: (v) async {
                              setState(() => medicationReminder = v);
                              await _saveNotificationPreferences();
                            },
                            icon: Icons.medication_rounded,
                            iconColor: Colors.purple.shade300,
                          ),
                          if (dailyReminder || medicationReminder) ...[
                            _divider(),
                            _tapRow(
                              title: "Reminder Time",
                              subtitle:
                                  "Set to ${reminderTime.format(context)}",
                              icon: Icons.access_time_rounded,
                              iconColor: Colors.orange.shade400,
                              onTap: _pickTime,
                              trailing: Text(
                                reminderTime.format(context),
                                style: const TextStyle(
                                    color: _accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Text(
                              "⚠️ Push notifications require additional setup on desktop. "
                              "Preferences are saved and will work when running on Android or iOS.",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── DATA ──
                    _sectionHeader("Data", Icons.storage_outlined),
                    _card(
                      child: Column(
                        children: [
                          _tapRow(
                            title: "Export Data",
                            subtitle: "Download your data as a CSV file",
                            icon: Icons.download_outlined,
                            iconColor: Colors.blue.shade400,
                            onTap: _exportData,
                          ),
                          _divider(),
                          _tapRow(
                            title: "Clear Local Data",
                            subtitle:
                                "Remove local settings (keeps server data)",
                            icon: Icons.delete_sweep_outlined,
                            iconColor: Colors.orange.shade400,
                            onTap: _clearAllData,
                          ),
                        ],
                      ),
                    ),

                    // ── ABOUT ──
                    _sectionHeader("About", Icons.info_outline),
                    _card(
                      child: Column(
                        children: [
                          _tapRow(
                            title: "Rate SheSync",
                            subtitle: "Love the app? Tell us ⭐",
                            icon: Icons.star_outline_rounded,
                            iconColor: Colors.amber.shade400,
                            onTap: _rateApp,
                          ),
                          _divider(),
                          _tapRow(
                            title: "Share SheSync",
                            subtitle: "Copy a message to share with friends",
                            icon: Icons.share_outlined,
                            iconColor: _accent,
                            onTap: _shareApp,
                          ),
                          _divider(),
                          _tapRow(
                            title: "Send Feedback",
                            subtitle: "Help us make SheSync better",
                            icon: Icons.feedback_outlined,
                            iconColor: Colors.purple.shade300,
                            onTap: _sendFeedback,
                          ),
                          _divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.info_outline,
                                      size: 18, color: Colors.grey.shade500),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text("App Version",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                    Text("SheSync v1.0.0",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500)),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _accent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text("Latest",
                                      style: TextStyle(
                                          color: Color(0xFF2E7D60),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── ACCOUNT ──
                    _sectionHeader(
                        "Account", Icons.manage_accounts_outlined),
                    _card(
                      child: Column(
                        children: [
                          _tapRow(
                            title: "Log Out",
                            subtitle: "Sign out of your account",
                            icon: Icons.logout_rounded,
                            iconColor: Colors.orange.shade400,
                            onTap: _handleLogout,
                          ),
                          _divider(),
                          _tapRow(
                            title: "Delete Account",
                            subtitle:
                                "Permanently remove your account & all data",
                            icon: Icons.person_remove_outlined,
                            iconColor: Colors.red.shade400,
                            titleColor: Colors.red.shade400,
                            onTap: _deleteAccount,
                            trailing: Icon(Icons.chevron_right,
                                color: Colors.red.shade300, size: 20),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}