import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

import '../../core/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color accent = Color(0xFFE91E63);
  static const Color bg = Color(0xFFFDF6F9);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Email isn't collected on this form — AuthService derives a
      // placeholder (username@shesync.local) since Django's User model
      // requires one. Swap this for a real email field later if you add
      // email verification or password reset.
      await AuthService.register(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      // ✅ After signup → go to LOGIN, not home
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("🌸  Account created! Please sign in."),
          backgroundColor: accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = "Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Gradient Background ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFCE4EC),
                  Color(0xFFFDF6F9),
                  Color(0xFFF8BBD9),
                  Color(0xFFF3E5F5),
                ],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // ── Floral Decorations ──
          Positioned(
            top: -30, right: -30,
            child: _FloralDecor(size: 180, opacity: 0.18),
          ),
          Positioned(
            top: 60, left: -40,
            child: _FloralDecor(size: 130, opacity: 0.12, rotate: 0.4),
          ),
          Positioned(
            bottom: 120, right: -20,
            child: _FloralDecor(size: 140, opacity: 0.13, rotate: -0.3),
          ),
          Positioned(
            bottom: -20, left: -30,
            child: _FloralDecor(size: 160, opacity: 0.15, rotate: 0.6),
          ),

          // ── Scattered petals ──
          Positioned(top: size.height * 0.18, right: 30,
              child: _Petal(size: 22, opacity: 0.35)),
          Positioned(top: size.height * 0.28, left: 20,
              child: _Petal(size: 16, opacity: 0.28)),
          Positioned(top: size.height * 0.12, left: size.width * 0.4,
              child: _Petal(size: 14, opacity: 0.22)),
          Positioned(bottom: size.height * 0.22, left: 40,
              child: _Petal(size: 18, opacity: 0.3)),

          // ── Main Content ──
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // ── Logo ──
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 90, height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(colors: [
                                  accent.withOpacity(0.15),
                                  accent.withOpacity(0.0),
                                ]),
                              ),
                            ),
                            Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                shape: BoxShape.circle,
                                border: Border.all(color: accent.withOpacity(0.3), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withOpacity(0.2),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text("🌸", style: TextStyle(fontSize: 34)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Center(
                        child: Text(
                          "Join SheSync",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          "your personal health companion 🌺",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Form Card ──
                      _GlassFormCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_errorMessage != null) ...[
                                _ErrorBanner(message: _errorMessage!),
                                const SizedBox(height: 16),
                              ],

                              // Username
                              _FieldLabel("username"),
                              const SizedBox(height: 8),
                              _StyledTextField(
                                controller: _usernameController,
                                hint: "choose a username",
                                icon: Icons.person_outline_rounded,
                                accent: accent,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Please enter a username";
                                  }
                                  if (value.trim().length < 3) {
                                    return "Username must be at least 3 characters";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Password
                              _FieldLabel("password"),
                              const SizedBox(height: 8),
                              _StyledTextField(
                                controller: _passwordController,
                                hint: "create a password",
                                icon: Icons.lock_outline_rounded,
                                accent: accent,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: Colors.black38,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a password";
                                  }
                                  if (value.length < 6) {
                                    return "Password must be at least 6 characters";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Confirm Password
                              _FieldLabel("confirm password"),
                              const SizedBox(height: 8),
                              _StyledTextField(
                                controller: _confirmPasswordController,
                                hint: "repeat your password",
                                icon: Icons.lock_outline_rounded,
                                accent: accent,
                                obscureText: _obscureConfirm,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: Colors.black38,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please confirm your password";
                                  }
                                  if (value != _passwordController.text) {
                                    return "Passwords do not match";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              // Sign Up Button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accent,
                                    disabledBackgroundColor: accent.withOpacity(0.6),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: _isLoading ? null : _handleSignup,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22, height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2.4),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Create Account",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text("🌸", style: TextStyle(fontSize: 16)),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.pink.withOpacity(0.2))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text("or",
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.35),
                                    fontSize: 13)),
                          ),
                          Expanded(child: Divider(color: Colors.pink.withOpacity(0.2))),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Login Link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const LoginScreen(),
                                transitionsBuilder: (_, anim, __, child) =>
                                    FadeTransition(opacity: anim, child: child),
                                transitionDuration: const Duration(milliseconds: 280),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: accent.withOpacity(0.2)),
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account?  ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black.withOpacity(0.55),
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Sign In",
                                    style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FLORAL DECORATIONS
// ─────────────────────────────────────────────
class _FloralDecor extends StatelessWidget {
  final double size;
  final double opacity;
  final double rotate;

  const _FloralDecor({
    required this.size,
    required this.opacity,
    this.rotate = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotate,
      child: Opacity(
        opacity: opacity,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _FlowerPainter()),
        ),
      ),
    );
  }
}

class _FlowerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final petalLength = size.width * 0.42;
    final petalRadius = size.width * 0.28;
    const petalCount = 8;

    // Outer petals
    final outerPaint = Paint()
      ..color = const Color(0xFFE91E63)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * math.pi) / petalCount;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, -petalLength * 0.5),
          width: petalRadius,
          height: petalLength,
        ),
        outerPaint,
      );
      canvas.restore();
    }

    // Inner petals
    final innerPaint = Paint()
      ..color = const Color(0xFFF48FB1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * math.pi) / petalCount + math.pi / petalCount;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, -petalLength * 0.35),
          width: petalRadius * 0.6,
          height: petalLength * 0.6,
        ),
        innerPaint,
      );
      canvas.restore();
    }

    // Yellow center
    canvas.drawCircle(center, size.width * 0.13,
        Paint()..color = const Color(0xFFFFD54F));
    canvas.drawCircle(center, size.width * 0.07,
        Paint()..color = const Color(0xFFF57F17));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Petal extends StatelessWidget {
  final double size;
  final double opacity;
  const _Petal({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Text("🌸", style: TextStyle(fontSize: size)),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED FORM WIDGETS
// ─────────────────────────────────────────────
class _GlassFormCard extends StatelessWidget {
  final Widget child;
  const _GlassFormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE91E63).withOpacity(0.08),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Colors.black.withOpacity(0.45),
        letterSpacing: 1.2,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color accent;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.accent,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14.5, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        prefixIcon: Icon(icon, color: accent.withOpacity(0.7), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
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
    );
  }
}

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
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFD32F2F), size: 18),
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