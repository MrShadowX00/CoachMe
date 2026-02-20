import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  Future<void> _handleGoogle() async {
    setState(() { _loading = true; _error = null; });
    final user = await AuthService.signInWithGoogle();
    if (user != null) {
      await FirestoreService.createUserProfile(
        user.displayName ?? 'Champion',
        user.email ?? '',
      );
    } else {
      setState(() { _error = 'Google sign in failed. Try again.'; _loading = false; });
    }
  }

  Future<void> _handleEmail() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      if (_isLogin) {
        await AuthService.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      } else {
        final user = await AuthService.registerWithEmail(
          _emailCtrl.text.trim(),
          _passCtrl.text,
          _nameCtrl.text.trim().isEmpty ? 'Champion' : _nameCtrl.text.trim(),
        );
        if (user != null) {
          await FirestoreService.createUserProfile(
            _nameCtrl.text.trim().isEmpty ? 'Champion' : _nameCtrl.text.trim(),
            _emailCtrl.text.trim(),
          );
        }
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(40),
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 32)),
                ),
              ),
              const Gap(24),
              Text(
                _isLogin ? 'Welcome back!' : 'Join CoachMe',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textColor,
                ),
              ),
              const Gap(6),
              Text(
                _isLogin
                    ? 'Sign in to continue your habit journey'
                    : 'Start building better habits with AI',
                style: GoogleFonts.inter(fontSize: 15, color: AppTheme.muted),
              ),
              const Gap(36),

              // Google Sign In
              GestureDetector(
                onTap: _loading ? null : _handleGoogle,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF4285F4))),
                      const Gap(10),
                      Text(
                        'Continue with Google',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(20),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppTheme.cardBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: GoogleFonts.inter(color: AppTheme.muted, fontSize: 13)),
                  ),
                  const Expanded(child: Divider(color: AppTheme.cardBorder)),
                ],
              ),
              const Gap(20),

              // Name (register only)
              if (!_isLogin) ...[
                _buildField(_nameCtrl, 'Your name', Icons.person_outline),
                const Gap(12),
              ],
              _buildField(_emailCtrl, 'Email', Icons.email_outlined),
              const Gap(12),
              _buildField(_passCtrl, 'Password', Icons.lock_outline, obscure: true),

              if (_error != null) ...[
                const Gap(12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                  ),
                  child: Text(_error!, style: GoogleFonts.inter(color: AppTheme.danger, fontSize: 13)),
                ),
              ],

              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          _isLogin ? 'Sign In' : 'Create Account',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const Gap(20),

              Center(
                child: GestureDetector(
                  onTap: () => setState(() { _isLogin = !_isLogin; _error = null; }),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 14, color: AppTheme.muted),
                      children: [
                        TextSpan(text: _isLogin ? "Don't have an account? " : 'Already have an account? '),
                        TextSpan(
                          text: _isLogin ? 'Sign Up' : 'Sign In',
                          style: const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: GoogleFonts.inter(color: AppTheme.textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppTheme.muted),
        prefixIcon: Icon(icon, color: AppTheme.muted, size: 20),
        filled: true,
        fillColor: AppTheme.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary)),
      ),
    );
  }
}
