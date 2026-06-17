import 'package:flutter/material.dart';
import 'dart:ui';

import '../../core/profile_service.dart';
import '../../core/auth_service.dart';
import '../shell/main_shell.dart';

// ─────────────────────────────────────────────
//  USER PROFILE SCREEN
//  Two modes:
//   - isOnboarding: true  -> shown right after signup, "Skip" allowed,
//                            "Save" routes to MainShell
//   - isOnboarding: false -> opened from Settings, "Save" pops back
// ─────────────────────────────────────────────
class UserProfileScreen extends StatefulWidget {
  final bool isOnboarding;

  const UserProfileScreen({super.key, this.isOnboarding = false});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static const Color accent = Color(0xFFE91E63);
  static const Color bg = Color(0xFFFDF6F9);

  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _cycleLengthController = TextEditingController(text: "28");
  final _periodLengthController = TextEditingController(text: "5");
  final _lastPeriodController = TextEditingController();

  bool _isLoadingInitial = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    _lastPeriodController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final profile = await ProfileService.getProfile();
      if (!mounted) return;
      setState(() {
        if (profile.age != null) _ageController.text = profile.age.toString();
        if (profile.heightCm != null) {
          _heightController.text = _trimDecimal(profile.heightCm!);
        }
        if (profile.weightKg != null) {
          _weightController.text = _trimDecimal(profile.weightKg!);
        }
        _cycleLengthController.text = profile.averageCycleLength.toString();
        _periodLengthController.text = profile.averagePeriodLength.toString();
        if (profile.lastPeriodStartDate != null) {
          _lastPeriodController.text = profile.lastPeriodStartDate!;
        }
        _isLoadingInitial = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingInitial = false);
      // Onboarding: nothing to load yet is expected, not an error to surface.
      if (!widget.isOnboarding) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }

  String _trimDecimal(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  bool _isValidDateFormat(String value) {
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(value)) return false;
    try {
      final parts = value.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final date = DateTime(year, month, day);
      return date.year == year && date.month == month && date.day == day;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await ProfileService.updateProfile(
        age: _ageController.text.trim().isEmpty
            ? null
            : int.tryParse(_ageController.text.trim()),
        heightCm: _heightController.text.trim().isEmpty
            ? null
            : double.tryParse(_heightController.text.trim()),
        weightKg: _weightController.text.trim().isEmpty
            ? null
            : double.tryParse(_weightController.text.trim()),
        averageCycleLength: int.tryParse(_cycleLengthController.text.trim()),
        averagePeriodLength: int.tryParse(_periodLengthController.text.trim()),
        lastPeriodStartDate: _lastPeriodController.text.trim().isEmpty
            ? null
            : _lastPeriodController.text.trim(),
      );

      if (!mounted) return;

      if (widget.isOnboarding) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainShell(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profile saved 💖"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: accent,
          ),
        );
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() =>
          _errorMessage = "Something went wrong while saving. Please try again.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleSkip() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: widget.isOnboarding
          ? null
          : AppBar(
              backgroundColor: bg,
              elevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
              title: const Text(
                "Your Profile",
                style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFCE4EC),
                  Color(0xFFFDF6F9),
                  Color(0xFFF3E5F5),
                ],
              ),
            ),
          ),
          SafeArea(
            child: _isLoadingInitial
                ? const Center(
                    child: CircularProgressIndicator(color: accent),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.isOnboarding) ...[
                          const SizedBox(height: 12),
                          const Text(
                            "Tell us about you",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "this helps us personalise your experience — you can skip and fill this in later",
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.black.withOpacity(0.55),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_errorMessage != null) ...[
                                _ErrorBanner(message: _errorMessage!),
                                const SizedBox(height: 16),
                              ],

                              _SectionCard(
                                title: "about you",
                                emoji: "🌷",
                                accent: accent,
                                children: [
                                  _NumberField(
                                    label: "age",
                                    hint: "e.g. 24",
                                    controller: _ageController,
                                    accent: accent,
                                    suffix: "years",
                                  ),
                                  const SizedBox(height: 14),
                                  _NumberField(
                                    label: "height",
                                    hint: "e.g. 165",
                                    controller: _heightController,
                                    accent: accent,
                                    suffix: "cm",
                                    allowDecimal: true,
                                  ),
                                  const SizedBox(height: 14),
                                  _NumberField(
                                    label: "weight",
                                    hint: "e.g. 58",
                                    controller: _weightController,
                                    accent: accent,
                                    suffix: "kg",
                                    allowDecimal: true,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              _SectionCard(
                                title: "cycle tracking",
                                emoji: "🌙",
                                accent: accent,
                                children: [
                                  _NumberField(
                                    label: "average cycle length",
                                    hint: "e.g. 28",
                                    controller: _cycleLengthController,
                                    accent: accent,
                                    suffix: "days",
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "Required";
                                      }
                                      final n = int.tryParse(value.trim());
                                      if (n == null || n < 15 || n > 60) {
                                        return "Enter a value between 15 and 60";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  _NumberField(
                                    label: "average period length",
                                    hint: "e.g. 5",
                                    controller: _periodLengthController,
                                    accent: accent,
                                    suffix: "days",
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "Required";
                                      }
                                      final n = int.tryParse(value.trim());
                                      if (n == null || n < 1 || n > 15) {
                                        return "Enter a value between 1 and 15";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  _DateField(
                                    label: "last period start date",
                                    hint: "YYYY-MM-DD, e.g. 2026-06-10",
                                    controller: _lastPeriodController,
                                    accent: accent,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return null; // optional
                                      }
                                      if (!_isValidDateFormat(value.trim())) {
                                        return "Use the format YYYY-MM-DD";
                                      }
                                      final entered = DateTime.parse(value.trim());
                                      if (entered.isAfter(DateTime.now())) {
                                        return "Date can't be in the future";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 26),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accent,
                                    disabledBackgroundColor: accent.withOpacity(0.6),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: _isSaving ? null : _handleSave,
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.4,
                                          ),
                                        )
                                      : Text(
                                          widget.isOnboarding ? "Save & Continue" : "Save Changes",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),

                              if (widget.isOnboarding) ...[
                                const SizedBox(height: 14),
                                Center(
                                  child: TextButton(
                                    onPressed: _isSaving ? null : _handleSkip,
                                    child: Text(
                                      "Skip for now",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black.withOpacity(0.45),
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SECTION CARD
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final String emoji;
  final Color accent;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.emoji,
    required this.accent,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 7),
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: accent,
                      letterSpacing: 1.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NUMBER FIELD
// ─────────────────────────────────────────────
class _NumberField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Color accent;
  final String suffix;
  final bool allowDecimal;
  final String? Function(String?)? validator;

  const _NumberField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.accent,
    required this.suffix,
    this.allowDecimal = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
          validator: validator,
          style: const TextStyle(fontSize: 14.5, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: Colors.black.withOpacity(0.4),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.7),
            contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accent.withOpacity(0.5), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.5),
            ),
            errorStyle: const TextStyle(fontSize: 11.5, height: 0.9),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  DATE FIELD (manual text entry, validated format)
// ─────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Color accent;
  final String? Function(String?)? validator;

  const _DateField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.accent,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.datetime,
          validator: validator,
          style: const TextStyle(fontSize: 14.5, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
            prefixIcon: Icon(Icons.calendar_today_rounded,
                color: accent.withOpacity(0.7), size: 18),
            filled: true,
            fillColor: Colors.white.withOpacity(0.7),
            contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accent.withOpacity(0.5), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.5),
            ),
            errorStyle: const TextStyle(fontSize: 11.5, height: 0.9),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  ERROR BANNER
// ─────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE57373).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE57373).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFD32F2F), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}