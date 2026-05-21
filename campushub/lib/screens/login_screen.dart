import 'package:flutter/material.dart';
import '../services/local_auth_service.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameOrEmailController = TextEditingController();
  String _usernameOrEmail = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _isNavigating = false;

  static const Color primaryNavy = Color(0xFF142B47);
  static const Color primaryBlue = Color(0xFF1A56DB);

  @override
  void dispose() {
    _usernameOrEmailController.dispose();
    super.dispose();
  }

  void _login(BuildContext formContext) {
    if (_isNavigating) return;
    if (!Form.of(formContext).validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();

    final account = LocalAuthService.login(
      usernameOrEmail: _usernameOrEmail,
      password: _password,
    );

    if (account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account not found or password is incorrect. Please sign up first.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isNavigating = true);
    debugPrint('Login: ${account.username}');
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final email = await showDialog<String>(
      context: context,
      builder: (_) => _ForgotPasswordDialog(initialEmail: _usernameOrEmail),
    );

    if (!mounted || email == null) return;

    debugPrint('Password reset requested: $email');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code verified for $email'),
        backgroundColor: primaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFDDE4F0),
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/img/background.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 40.0,
                ),
                child: Form(
                  child: Builder(
                    builder: (formContext) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Campus',
                                    style: TextStyle(color: primaryNavy),
                                  ),
                                  TextSpan(
                                    text: 'Hub',
                                    style: TextStyle(color: primaryBlue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            'Username or Email',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _usernameOrEmailController,
                            keyboardType: TextInputType.text,
                            onChanged: (value) =>
                                _usernameOrEmail = value.trim(),
                            decoration: InputDecoration(
                              hintText: 'Enter your email or username',
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: primaryBlue,
                              ),
                              border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black26),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black26),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: primaryBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              if (value.isEmpty) {
                                return 'Please enter your username or email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            obscureText: _obscurePassword,
                            onChanged: (value) => _password = value,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: primaryBlue,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.black45,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black26),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black26),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: primaryBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordDialog,
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(color: primaryBlue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => _login(formContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.black54),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (_isNavigating) return;
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  setState(() => _isNavigating = true);
                                  final createdIdentifier =
                                      await Navigator.of(context).push<String>(
                                        MaterialPageRoute(
                                          builder: (_) => const SignUpScreen(),
                                        ),
                                      );
                                  if (!context.mounted) return;
                                  setState(() => _isNavigating = false);

                                  if (createdIdentifier != null &&
                                      createdIdentifier.isNotEmpty) {
                                    setState(() {
                                      _usernameOrEmail = createdIdentifier;
                                      _usernameOrEmailController.text =
                                          createdIdentifier;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Account created. Please log in.',
                                        ),
                                        backgroundColor: primaryBlue,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final TextEditingController _resetEmailController =
      TextEditingController(text: widget.initialEmail);
  late final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _codeFocusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );
  bool _codeSent = false;

  @override
  void dispose() {
    _resetEmailController.dispose();
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final focusNode in _codeFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _sendLink(BuildContext formContext) {
    if (!Form.of(formContext).validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _codeSent = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _codeFocusNodes.first.requestFocus();
    });
  }

  void _verifyCode() {
    final code = _codeControllers.map((controller) => controller.text).join();
    if (code.length < 6) return;

    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(_resetEmailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Builder(
        builder: (formContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              _codeSent ? 'Enter Code' : 'Reset Password',
              style: TextStyle(
                color: _LoginScreenState.primaryNavy,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_codeSent) ...[
                  const Text(
                    'Enter your email address and we will send a password reset link.',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                ] else ...[
                  Text(
                    'We sent a 6-digit code to ${_resetEmailController.text.trim()}.',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 38,
                        height: 48,
                        child: TextField(
                          controller: _codeControllers[index],
                          focusNode: _codeFocusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _codeFocusNodes[index + 1].requestFocus();
                            }
                            if (value.isEmpty && index > 0) {
                              _codeFocusNodes[index - 1].requestFocus();
                            }
                            setState(() {});
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _codeSent
                    ? _verifyCode
                    : () => _sendLink(formContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _LoginScreenState.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: Text(_codeSent ? 'Verify Code' : 'Send Link'),
              ),
            ],
          );
        },
      ),
    );
  }
}
