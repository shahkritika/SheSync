import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/auth_service.dart';
import '../../core/profile_service.dart';
import '../login_screen.dart';
import '../profile/user_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final accent = const Color(0xFF7ED6B2);
  final bg = const Color(0xFFF2FFFA);

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ── Profile ──
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  String selectedAvatar = "🌸";
  final avatars = ["🌸", "🌺", "🌻", "🌼", "🌷", "💐", "🦋", "🌙"];
  String? currentUsername;

  // ── Health Profile from ProfileService ──
  UserProfile? userProfile;

  // ── Notifications ──
  bool dailyReminder = true;
  bool periodReminder = true;
  bool medicationReminder = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0);

  // ── Appearance ──
  bool isDarkMode = false;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _loadAll();
  }

  @override
  void dispose() {
    _animController.dispose();
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadSettings(), _loadProfile()]);
    if (mounted) {
      setState(() => isLoading = false);
      _animController.forward();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final username = await AuthService.getUsername();
    if (!mounted) return;
    setState(() {
      nameController.text = prefs.getString('name') ?? '';
      ageController.text = prefs.getString('age') ?? '';
      selectedAvatar = prefs.getString('avatar') ?? '🌸';
      dailyReminder = prefs.getBool('dailyReminder') ?? true;
      periodReminder = prefs.getBool('periodReminder') ?? true;
      medicationReminder = prefs.getBool('medicationReminder') ?? false;
      isDarkMode = prefs.getBool('darkMode') ?? false;
      final hour = prefs.getInt('reminderHour') ?? 9;
      final minute = prefs.getInt('reminderMinute') ?? 0;
      reminderTime = TimeOfDay(hour: hour, minute: minute);
      currentUsername = username;
    });
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService.getProfile();
      if (!mounted) return;
      setState(() => userProfile = profile);
    } catch (_) {}
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text.trim());
    await prefs.setString('age', ageController.text.trim());
    await prefs.setString('avatar', selectedAvatar);
    await prefs.setBool('dailyReminder', dailyReminder);
    await prefs.setBool('periodReminder', periodReminder);
    await prefs.setBool('medicationReminder', medicationReminder);
    await prefs.setBool('darkMode', isDarkMode);
    await prefs.setInt('reminderHour', reminderTime.hour);
    await prefs.setInt('reminderMinute', reminderTime.minute);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("✅  Settings saved!"),
        backgroundColor: accent,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Logout ──
  Future<void> _handleLogout() async {
    final confirmed = await _showConfirmDialog(
      emoji: "👋",
      title: "Log Out?",
      message:
          "You will be returned to the login screen. Your data will be saved.",
      confirmText: "Log Out",
      confirmColor: accent,
    );
    if (confirmed == true) {
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

  // ── Delete Account ──
  Future<void> _deleteAccount() async {
    final confirmed = await _showConfirmDialog(
      emoji: "⚠️",
      title: "Delete Account?",
      message:
          "This will permanently delete your account and ALL data. This cannot be undone.",
      confirmText: "Delete",
      confirmColor: Colors.red.shade400,
    );
    if (confirmed != true) return;

    final confirmController = TextEditingController();
    final doubleConfirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("🔴 Final Confirmation",
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Type your username "$currentUsername" to confirm:',
                style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
              Row(
                children: [
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Username doesn't match!"),
                              backgroundColor: Colors.red.shade400,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      },
                      child: const Text("Confirm Delete",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (doubleConfirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
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

  // ── Export Data ──
  Future<void> _exportData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final buffer = StringBuffer();
      buffer.writeln('SheSync Data Export');
      buffer.writeln('Exported on: ${DateTime.now().toString().split('.')[0]}');
      buffer.writeln('Username: ${currentUsername ?? "Unknown"}');
      buffer.writeln('---');
      buffer.writeln('Key,Value');
      for (final key in allKeys) {
        buffer.writeln('$key,${prefs.get(key)}');
      }

      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/shesync_export.csv');
        await file.writeAsString(buffer.toString());
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("📁", style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  const Text("Export Successful!",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Saved to:\n${file.path}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      buffer.toString().split('\n').take(8).join('\n'),
                      style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: buffer.toString()));
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text("📋 Copied to clipboard!"),
                              backgroundColor: accent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                            ));
                          },
                          child: const Text("Copy"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
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
                ],
              ),
            ),
          ),
        );
      } catch (_) {
        await Clipboard.setData(ClipboardData(text: buffer.toString()));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("📋 Data copied to clipboard!"),
          backgroundColor: accent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Export failed: ${e.toString()}"),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  // ── Clear All Data ──
  Future<void> _clearAllData() async {
    final confirmed = await _showConfirmDialog(
      emoji: "🗑️",
      title: "Clear All Data?",
      message:
          "This will permanently delete all your tracking history and settings. This cannot be undone.",
      confirmText: "Delete",
      confirmColor: Colors.red.shade400,
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('auth_username');
      final password = prefs.getString('auth_password');
      final loggedIn = prefs.getBool('auth_logged_in');
      await prefs.clear();
      if (username != null) await prefs.setString('auth_username', username);
      if (password != null) await prefs.setString('auth_password', password);
      if (loggedIn != null) await prefs.setBool('auth_logged_in', loggedIn);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("All data cleared"),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      _loadAll();
    }
  }

  // ── Rate App ──
  void _rateApp() {
    int selectedStars = 0;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("⭐ Rate SheSync",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("How would you rate your experience?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final filled = i < selectedStars;
                    return GestureDetector(
                      onTap: () =>
                          setStateDialog(() => selectedStars = i + 1),
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
                const SizedBox(height: 8),
                Text(
                  selectedStars == 0
                      ? "Tap to rate"
                      : selectedStars == 1
                          ? "Poor 😞"
                          : selectedStars == 2
                              ? "Fair 😐"
                              : selectedStars == 3
                                  ? "Good 🙂"
                                  : selectedStars == 4
                                      ? "Great 😊"
                                      : "Excellent! 🤩",
                  style: TextStyle(
                    color: selectedStars == 0
                        ? Colors.grey.shade400
                        : Colors.amber.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
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
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      "Thanks for your $selectedStars⭐ rating!"),
                                  backgroundColor: Colors.amber.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  margin: const EdgeInsets.all(16),
                                ));
                              }
                            : null,
                        child: const Text("Submit",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Share App ──
  Future<void> _shareApp() async {
    await Clipboard.setData(const ClipboardData(
        text:
            'Check out SheSync - your personal women\'s health companion! 🌸'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("📋 Share link copied to clipboard!"),
      backgroundColor: accent,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Send Feedback ──
  void _sendFeedback() {
    final feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("💬 Send Feedback",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("We'd love to hear from you!",
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                maxLines: 4,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Write your feedback here...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
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
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("💚 Feedback sent! Thank you."),
                          backgroundColor: accent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ));
                      },
                      child: const Text("Send",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Pick Reminder Time ──
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
      builder: (context, child) => Theme(
        data: Theme.of(context)
            .copyWith(colorScheme: ColorScheme.light(primary: accent)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => reminderTime = picked);
  }

  // ── Open Health Profile (editable) ──
  Future<void> _openHealthProfile() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const UserProfileScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
    // Reload profile after returning
    await _loadProfile();
    setState(() {});
  }

  // ── Reusable confirm dialog ──
  Future<bool?> _showConfirmDialog({
    required String emoji,
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
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
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                children: [
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
                      child: Text(confirmText,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── UI Helpers ──
  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF444444),
                  letterSpacing: 0.3)),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.green.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
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
    IconData? icon,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? accent).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor ?? accent),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: accent),
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
                color: (iconColor ?? accent).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor ?? accent),
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
                          color: titleColor ?? const Color(0xFF333333))),
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
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.shade100);

  // ── Health info chip ──
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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text("Settings ⚙️",
            style: TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _saveSettings,
              child: Text("Save",
                  style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: accent))
          : FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Profile Header ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accent, const Color(0xFFB2EED6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: accent.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _showAvatarPicker,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(selectedAvatar,
                                    style:
                                        const TextStyle(fontSize: 32)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // ✅ Shows username from signup
                                Text(
                                  currentUsername ?? "Welcome! 👋",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userProfile?.age != null
                                      ? "Age ${userProfile!.age} · ${userProfile?.weightKg != null ? '${userProfile!.weightKg}kg' : ''}"
                                      : "Tap to set up profile",
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _handleLogout,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withOpacity(0.25),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.logout,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text("Logout",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── HEALTH PROFILE CARD ──
                    _sectionHeader(
                        "Health Profile", Icons.favorite_outline),
                    _sectionCard(
                      child: Column(
                        children: [
                          // Info chips row
                          if (userProfile != null &&
                              (userProfile!.age != null ||
                                  userProfile!.heightCm != null ||
                                  userProfile!.weightKg != null ||
                                  userProfile!.averageCycleLength != 28)) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 16, 16, 4),
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
                                      accent),
                                  _infoChip(
                                      "Period",
                                      "${userProfile!.averagePeriodLength}d",
                                      Colors.red.shade300),
                                  if (userProfile!.lastPeriodStartDate !=
                                      null)
                                    _infoChip(
                                        "Last Period",
                                        userProfile!
                                            .lastPeriodStartDate!,
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
                                ? "Update your age, height, weight & cycle details"
                                : "Add your health details for better tracking",
                            icon: Icons.edit_outlined,
                            iconColor: const Color(0xFFE91E63),
                            onTap: _openHealthProfile,
                          ),
                        ],
                      ),
                    ),

                    // ── PROFILE SECTION ──
                    _sectionHeader("Profile", Icons.person_outline),
                    _sectionCard(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16, 14, 16, 14),
                            child: TextField(
                              controller: nameController,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: "Display Name",
                                labelStyle: TextStyle(
                                    color: Colors.grey.shade500),
                                prefixIcon: Icon(Icons.person,
                                    color: accent, size: 20),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  borderSide:
                                      BorderSide(color: accent),
                                ),
                              ),
                            ),
                          ),
                          _divider(),
                          _tapRow(
                            title: "Choose Avatar",
                            subtitle:
                                "Your profile icon: $selectedAvatar",
                            icon: Icons.face_retouching_natural,
                            onTap: _showAvatarPicker,
                            trailing: Text(selectedAvatar,
                                style:
                                    const TextStyle(fontSize: 22)),
                          ),
                        ],
                      ),
                    ),

                    // ── NOTIFICATIONS ──
                    _sectionHeader(
                        "Notifications", Icons.notifications_outlined),
                    _sectionCard(
                      child: Column(
                        children: [
                          _toggleRow(
                            title: "Daily Reminder",
                            subtitle: "Remind me to track every day",
                            value: dailyReminder,
                            onChanged: (v) =>
                                setState(() => dailyReminder = v),
                            icon: Icons.today,
                            iconColor: accent,
                          ),
                          _divider(),
                          _toggleRow(
                            title: "Period Reminder",
                            subtitle:
                                "Alert 2 days before predicted period",
                            value: periodReminder,
                            onChanged: (v) =>
                                setState(() => periodReminder = v),
                            icon: Icons.water_drop,
                            iconColor: Colors.red.shade300,
                          ),
                          _divider(),
                          _toggleRow(
                            title: "Medication Reminder",
                            subtitle:
                                "Remind me to take my medication",
                            value: medicationReminder,
                            onChanged: (v) =>
                                setState(() => medicationReminder = v),
                            icon: Icons.medication,
                            iconColor: Colors.purple.shade300,
                          ),
                          if (dailyReminder || medicationReminder) ...[
                            _divider(),
                            _tapRow(
                              title: "Reminder Time",
                              subtitle:
                                  "Currently set to ${reminderTime.format(context)}",
                              icon: Icons.access_time,
                              iconColor: Colors.orange.shade400,
                              onTap: _pickTime,
                              trailing: Text(
                                reminderTime.format(context),
                                style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ── APPEARANCE ──
                    _sectionHeader(
                        "Appearance", Icons.palette_outlined),
                    _sectionCard(
                      child: _toggleRow(
                        title: "Dark Mode",
                        subtitle: "Switch to dark theme",
                        value: isDarkMode,
                        onChanged: (v) => setState(() => isDarkMode = v),
                        icon: Icons.dark_mode,
                        iconColor: Colors.indigo.shade400,
                      ),
                    ),

                    // ── DATA ──
                    _sectionHeader("Data", Icons.storage_outlined),
                    _sectionCard(
                      child: Column(
                        children: [
                          _tapRow(
                            title: "Export Data",
                            subtitle:
                                "Save your tracking history as CSV",
                            icon: Icons.download_outlined,
                            iconColor: Colors.blue.shade400,
                            onTap: _exportData,
                          ),
                          _divider(),
                          _tapRow(
                            title: "Clear All Data",
                            subtitle:
                                "Permanently delete all your data",
                            icon: Icons.delete_outline,
                            iconColor: Colors.red.shade400,
                            titleColor: Colors.red.shade400,
                            onTap: _clearAllData,
                            trailing: Icon(Icons.chevron_right,
                                color: Colors.red.shade300, size: 20),
                          ),
                        ],
                      ),
                    ),

                    // ── ABOUT ──
                    _sectionHeader("About", Icons.info_outline),
                    _sectionCard(
                      child: Column(
                        children: [
                          _tapRow(
                            title: "Rate SheSync",
                            subtitle: "Love the app? Leave a review ⭐",
                            icon: Icons.star_outline,
                            iconColor: Colors.amber.shade400,
                            onTap: _rateApp,
                          ),
                          _divider(),
                          _tapRow(
                            title: "Share SheSync",
                            subtitle: "Tell your friends about us 💚",
                            icon: Icons.share_outlined,
                            iconColor: accent,
                            onTap: _shareApp,
                          ),
                          _divider(),
                          _tapRow(
                            title: "Send Feedback",
                            subtitle: "Help us improve the app",
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
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.info_outline,
                                      size: 18,
                                      color: Colors.grey.shade500),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text("App Version",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF333333))),
                                    Text("SheSync v1.0.0",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                Colors.grey.shade500)),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Text("Latest",
                                      style: TextStyle(
                                          color: Color(0xFF2E7D60),
                                          fontSize: 11,
                                          fontWeight:
                                              FontWeight.bold)),
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
                    _sectionCard(
                      child: Column(
                        children: [
                          _tapRow(
                            title: "Log Out",
                            subtitle: "Sign out of your account",
                            icon: Icons.logout,
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

                    // ── Save Button ──
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: _saveSettings,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_alt, color: Colors.white),
                            SizedBox(width: 8),
                            Text("Save Settings",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text("Choose your avatar",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: avatars.map((a) {
                final selected = selectedAvatar == a;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedAvatar = a);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: selected
                          ? accent.withOpacity(0.2)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: selected
                              ? accent
                              : Colors.transparent,
                          width: 2),
                    ),
                    child: Center(
                        child: Text(a,
                            style:
                                const TextStyle(fontSize: 28))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}