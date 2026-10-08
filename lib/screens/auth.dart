import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/face_scan.dart';
import 'shell.dart';

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
String? _email(String? v) => _emailRe.hasMatch(v?.trim() ?? '') ? null : 'Enter a valid email';
String? _password(String? v) {
  final p = v ?? '';
  if (p.length < 8 || !p.contains(RegExp('[A-Z]')) || !p.contains(RegExp('[0-9]'))) {
    return 'At least 8 characters, with an uppercase letter and a number';
  }
  return null;
}

class _Subtitle extends StatelessWidget {
  const _Subtitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(kPad, 20, kPad, 0),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.45)),
  );
}

class _Footer extends StatelessWidget {
  const _Footer(this.prefix, this.action, this.onTap);

  final String prefix;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: WColors.grey),
      child: Text.rich(
        TextSpan(
          text: '$prefix ',
          children: [
            TextSpan(
              text: action,
              style: const TextStyle(color: WColors.green, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GreenPage(
      title: 'Log in',
      showBack: Navigator.of(context).canPop(),
      headerExtra: const _Subtitle('Welcome back! Log in to continue using Wpay.'),
      body: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const LineField(label: 'Email Address', keyboardType: TextInputType.emailAddress, validator: _email),
            const SizedBox(height: 16),
            LineField(
              label: 'Password',
              obscure: true,
              validator: (v) => (v ?? '').isEmpty ? 'Enter your password' : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(context, slideRoute(const ForgotPasswordScreen())),
                style: TextButton.styleFrom(foregroundColor: WColors.green),
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: 24),
            GreenButton(
              label: 'Log in',
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                Navigator.of(context).pushAndRemoveUntil(slideRoute(const MainShell()), (_) => false);
              },
            ),
          ],
        ),
      ),
      bottom: _Footer(
        'New to Wpay?',
        'Create an account',
        () => Navigator.of(context).pushReplacement(slideRoute(const SignUpScreen())),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _mail = TextEditingController();
  bool _agree = false;

  @override
  void dispose() {
    _mail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GreenPage(
      title: 'Sign up',
      showBack: Navigator.of(context).canPop(),
      headerExtra: const _Subtitle('Create your Wpay account in less than a minute.'),
      body: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            LineField(label: 'Full Name', validator: (v) => (v ?? '').trim().isEmpty ? 'Enter your name' : null),
            const SizedBox(height: 16),
            LineField(
              label: 'Email Address',
              controller: _mail,
              keyboardType: TextInputType.emailAddress,
              validator: _email,
            ),
            const SizedBox(height: 16),
            const LineField(label: 'Password', obscure: true, validator: _password),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => setState(() => _agree = !_agree),
              child: Row(
                children: [
                  Checkbox(
                    value: _agree,
                    activeColor: WColors.green,
                    onChanged: (v) => setState(() => _agree = v ?? false),
                  ),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(color: WColors.grey, fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(color: WColors.green),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(color: WColors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GreenButton(
              label: 'Sign up',
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                if (!_agree) return toast(context, 'Please accept the Terms of Service');
                Navigator.push(context, slideRoute(EmailVerifyScreen(email: _mail.text.trim(), forSignUp: true)));
              },
            ),
          ],
        ),
      ),
      bottom: _Footer(
        'Already have an account?',
        'Log in',
        () => Navigator.of(context).pushReplacement(slideRoute(const LoginScreen())),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _mail = TextEditingController();

  @override
  void dispose() {
    _mail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GreenPage(
      title: 'Forgot Password',
      headerExtra: const _Subtitle('Enter the email linked to your account and we\'ll send you a code.'),
      body: Form(
        key: _form,
        child: LineField(
          label: 'Email Address',
          controller: _mail,
          keyboardType: TextInputType.emailAddress,
          validator: _email,
        ),
      ),
      bottom: GreenButton(
        label: 'Send Code',
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          Navigator.push(context, slideRoute(EmailVerifyScreen(email: _mail.text.trim(), forSignUp: false)));
        },
      ),
    );
  }
}

class EmailVerifyScreen extends StatefulWidget {
  const EmailVerifyScreen({super.key, required this.email, required this.forSignUp});

  final String email;
  final bool forSignUp;

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  final _code = TextEditingController();
  final _focus = FocusNode();
  int _left = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restart();
    _code.addListener(() => setState(() {}));
  }

  void _restart() {
    _timer?.cancel();
    setState(() => _left = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 1) t.cancel();
      setState(() => _left--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _verify() {
    final next = widget.forSignUp ? const FaceIdScreen() : const NewPasswordScreen();
    Navigator.push(context, slideRoute(next));
  }

  @override
  Widget build(BuildContext context) {
    final code = _code.text;
    return GreenPage(
      title: 'Email Verification',
      headerExtra: _Subtitle('Enter the 4-digit code we sent to\n${widget.email}'),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // The four boxes are drawn underneath a real (invisible) text field the same size,
          // so tapping them opens the keyboard on every platform.
          Stack(
            children: [
              IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 0; i < 4; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 62,
                        height: 66,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i < code.length ? WColors.greenSoft : WColors.field,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: i == code.length ? WColors.green : Colors.transparent, width: 1.5),
                        ),
                        child: Text(
                          i < code.length ? code[i] : '',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: _code,
                    focusNode: _focus,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            _left > 0 ? 'Resend code in 00:${_left.toString().padLeft(2, '0')}' : 'Didn\'t get the code?',
            style: const TextStyle(color: WColors.grey),
          ),
          TextButton(
            onPressed: _left > 0
                ? null
                : () {
                    _restart();
                    toast(context, 'New code sent to ${widget.email}');
                  },
            style: TextButton.styleFrom(foregroundColor: WColors.green),
            child: const Text('Resend Code', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      bottom: GreenButton(label: 'Verify', onPressed: code.length == 4 ? _verify : null),
    );
  }
}

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _pw = TextEditingController();

  @override
  void dispose() {
    _pw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GreenPage(
      title: 'New Password',
      headerExtra: const _Subtitle('Create a new password for your account.'),
      body: Form(
        key: _form,
        child: Column(
          children: [
            LineField(label: 'New Password', controller: _pw, obscure: true, validator: _password),
            const SizedBox(height: 16),
            LineField(
              label: 'Confirm Password',
              obscure: true,
              validator: (v) => v == _pw.text ? null : 'Passwords do not match',
            ),
          ],
        ),
      ),
      bottom: GreenButton(
        label: 'Save Password',
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          toast(context, 'Password updated. Please log in.');
          Navigator.of(context).pushAndRemoveUntil(slideRoute(const LoginScreen()), (_) => false);
        },
      ),
    );
  }
}

/// Face ID Verification: ring of ticks fills up while "scanning".
class FaceIdScreen extends StatefulWidget {
  const FaceIdScreen({super.key});

  @override
  State<FaceIdScreen> createState() => _FaceIdScreenState();
}

class _FaceIdScreenState extends State<FaceIdScreen> with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
  bool _done = false;

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    await _anim.forward(from: 0);
    if (!mounted) return;
    setState(() => _done = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(slideRoute(const MainShell()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WColors.forest,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: StripePainter())),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  const SizedBox(
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: HeaderIconButton(icon: Icons.chevron_left_rounded, tooltip: 'Back'),
                        ),
                        Text(
                          'Face ID Verification',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _done ? 'Verified! Taking you to your wallet…' : 'Please put your phone in front of your face',
                    style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.45),
                  ),
                  Expanded(
                    child: Align(
                      alignment: const Alignment(0, -0.35),
                      child: AnimatedBuilder(
                        animation: _anim,
                        builder: (context, _) => SizedBox(
                          width: 290,
                          height: 290,
                          child: CustomPaint(
                            painter: TickRingPainter(_anim.value),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _done
                                    ? const Icon(
                                        Icons.check_rounded,
                                        key: ValueKey(true),
                                        size: 96,
                                        color: WColors.green,
                                      )
                                    : const SizedBox(
                                        key: ValueKey(false),
                                        width: 104,
                                        height: 104,
                                        child: CustomPaint(painter: FaceScanPainter()),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GreenButton(label: 'Scan My Face', onPressed: _anim.isAnimating || _done ? null : _scan),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
