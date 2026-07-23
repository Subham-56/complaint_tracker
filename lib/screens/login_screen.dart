import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../services/backend_warmup_service.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminCodeController = TextEditingController();
  bool _isWarming = !BackendWarmupService.isWarm;
  bool _isLoginMode = true;
  bool _isAdminAuth = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // main.dart already fires a single wake-up ping on app launch. Rather
    // than pinging the backend again here, just listen for that one ping
    // to finish so we don't double up requests during cold start.
    BackendWarmupService.onWarm(() {
      if (mounted) setState(() => _isWarming = false);
    });
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();
    final adminCode = _adminCodeController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack("Enter email and password");
      return;
    }
    if (!_isLoginMode && username.isEmpty) {
      _showSnack("Enter username");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_isLoginMode) {
        final result = await ApiService.login(email, password);

        if (_isAdminAuth && result.role != "admin") {
          throw Exception("This account is not an admin account");
        }
        if (!_isAdminAuth && result.role == "admin") {
          throw Exception("Use admin login for admin accounts");
        }

        await SessionService.saveAuthSession(
          token: result.token,
          email: email,
          username: result.username,
          role: result.role,
          userId: result.userId,
        );

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      } else {
        final role = await ApiService.register(
          email: email,
          password: password,
          username: username,
          adminCode: _isAdminAuth ? adminCode : null,
        );

        if (_isAdminAuth && role != "admin") {
          throw Exception("Invalid admin code");
        }

        if (!mounted) return;
        _showSnack("Registration successful. Please login.");
        setState(() {
          _isLoginMode = true;
          _passwordController.clear();
          _adminCodeController.clear();
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: isWide ? 440 : double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.accent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'ComplaintIQ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  _isLoginMode ? 'Welcome back' : 'Create account',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isLoginMode
                      ? 'Sign in to your account'
                      : 'Join ComplaintIQ today',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // User / Admin toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _toggleBtn("Citizen", !_isAdminAuth, () {
                        setState(() => _isAdminAuth = false);
                      }),
                      _toggleBtn("Admin", _isAdminAuth, () {
                        setState(() => _isAdminAuth = true);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Fields
                if (!_isLoginMode) ...[
                  _field(
                    controller: _usernameController,
                    label: 'Username',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                ],
                _field(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                if (!_isLoginMode && _isAdminAuth) ...[
                  const SizedBox(height: 14),
                  _field(
                    controller: _adminCodeController,
                    label: 'Admin Code',
                    icon: Icons.shield_outlined,
                    obscure: true,
                  ),
                ],
                const SizedBox(height: 24),

                if (_isWarming) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primary,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Waking up server, please wait...',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isSubmitting || _isWarming)
                        ? null
                        : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isLoginMode ? 'Sign In' : 'Create Account',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Switch mode
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLoginMode
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLoginMode = !_isLoginMode;
                            _passwordController.clear();
                            _adminCodeController.clear();
                          });
                        },
                        child: Text(
                          _isLoginMode ? 'Sign up' : 'Sign in',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      enabled: !_isSubmitting,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        suffixIcon: suffix,
      ),
    );
  }
}