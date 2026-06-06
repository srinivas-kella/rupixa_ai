import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/app_security_service.dart';

class AppLockGate extends StatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  final TextEditingController _pinController = TextEditingController();

  bool _checking = true;
  bool _locked = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshLockState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      AppSecurityService.isAppLockEnabled().then((enabled) {
        if (mounted && enabled) {
          setState(() => _locked = true);
        }
      });
    }

    if (state == AppLifecycleState.resumed) {
      _refreshLockState();
    }
  }

  Future<void> _refreshLockState() async {
    final enabled = await AppSecurityService.isAppLockEnabled();

    if (!mounted) return;

    setState(() {
      _checking = false;
      _locked = enabled;
      _error = null;
      _pinController.clear();
    });
  }

  Future<void> _unlock() async {
    final valid = await AppSecurityService.verifyPin(_pinController.text);

    if (!mounted) return;

    if (!valid) {
      setState(() => _error = 'Incorrect PIN');
      return;
    }

    setState(() {
      _locked = false;
      _error = null;
      _pinController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return widget.child;
    }

    if (!_locked) {
      return widget.child;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 76,
                    width: 76,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      CupertinoIcons.lock_shield_fill,
                      color: colorScheme.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Rupixa is locked',
                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your app PIN to continue.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _pinController,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      errorText: _error,
                      hintText: 'PIN',
                    ),
                    onSubmitted: (_) => _unlock(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _unlock,
                      child: Text(
                        'Unlock',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
