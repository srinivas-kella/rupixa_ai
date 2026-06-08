import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/app_security_service.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/notification_service.dart';
import '../../providers/budget_provider.dart';
import '../../providers/theme_provider.dart';
import '../../routes/app_routes.dart';

const Color _primary = Color(0xFF5B67FF);
const Color _secondary = Color(0xFF00A6A6);
const Color _accent = Color(0xFFFFB020);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool biometrics = false;
  bool cloudBackup = true;
  bool backupInProgress = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      notifications = prefs.getBool('notifications') ?? true;
      biometrics = prefs.getBool(AppSecurityService.appLockEnabledKey) ?? false;
      cloudBackup = prefs.getBool(BackupService.cloudBackupEnabledKey) ?? true;
      isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _setNotificationsEnabled(bool value) async {
    await HapticFeedback.selectionClick();

    if (value) {
      final granted = await NotificationService.requestPermission();

      if (!mounted) return;

      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notification permission was not granted.',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
        return;
      }
    } else {
      await NotificationService.cancelAll();
    }

    if (!mounted) return;

    setState(() => notifications = value);

    await _saveSetting('notifications', value);
  }

  Future<void> _setAppLockEnabled(bool value) async {
    await HapticFeedback.selectionClick();

    if (value) {
      final pin = await _showPinDialog(
        title: 'Create app PIN',
        message: 'Choose a 4 to 8 digit PIN for unlocking Rupixa.',
        confirmLabel: 'Enable',
      );

      if (pin == null) return;

      await AppSecurityService.enableAppLock(pin);
    } else {
      final pin = await _showPinDialog(
        title: 'Disable app lock',
        message: 'Enter your current PIN to turn app lock off.',
        confirmLabel: 'Disable',
      );

      if (pin == null) return;

      final valid = await AppSecurityService.verifyPin(pin);

      if (!mounted) return;

      if (!valid) {
        _showSnack('Incorrect PIN. App lock is still enabled.');
        return;
      }

      await AppSecurityService.disableAppLock();
    }

    if (!mounted) return;

    setState(() => biometrics = value);
  }

  Future<void> _setCloudBackupEnabled(bool value) async {
    await HapticFeedback.selectionClick();

    if (backupInProgress) return;

    if (!value) {
      await BackupService.setEnabled(false);

      if (!mounted) return;

      setState(() => cloudBackup = false);
      _showSnack('Cloud backup disabled.');
      return;
    }

    setState(() => backupInProgress = true);

    try {
      await BackupService.backupNow();

      if (!mounted) return;

      setState(() => cloudBackup = true);
      _showSnack('Cloud backup completed.');
    } catch (error) {
      if (!mounted) return;

      _showSnack(error.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) {
        setState(() => backupInProgress = false);
      }
    }
  }

  Future<void> _backupNow() async {
    if (backupInProgress) return;

    await HapticFeedback.selectionClick();

    setState(() => backupInProgress = true);

    try {
      await BackupService.backupNow();

      if (!mounted) return;

      setState(() => cloudBackup = true);
      _showSnack('Backup completed successfully.');
    } catch (error) {
      if (!mounted) return;

      _showSnack(error.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) {
        setState(() => backupInProgress = false);
      }
    }
  }

  Future<void> _sendTestNotification() async {
    await HapticFeedback.selectionClick();

    final granted = await NotificationService.requestPermission();

    if (!mounted) return;

    if (!granted) {
      _showSnack('Notification permission was not granted.');
      return;
    }

    await NotificationService.scheduleBillReminder(
      id: 999,
      title: 'Test Reminder',
      body: 'Scheduled reminder working',
      scheduledDate: DateTime.now().add(const Duration(minutes: 1)),
    );

    _showSnack('Reminder scheduled for 1 minute from now.');
  }

  Future<void> _showBudgetSheet() async {
    final budgetProvider = context.read<BudgetProvider>();
    final controller = TextEditingController(
      text: budgetProvider.monthlyBudget.toStringAsFixed(0),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly budget',
                style: GoogleFonts.poppins(
                  color: colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget amount',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () async {
                    final amount = double.tryParse(controller.text.trim());

                    if (amount == null || amount <= 0) return;

                    await budgetProvider.setBudget(amount);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }

                    if (mounted) {
                      _showSnack('Monthly budget updated.');
                    }
                  },
                  child: Text(
                    'Save budget',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
  }

  Future<void> _resetPreferences() async {
    final themeProvider = context.read<ThemeProvider>();

    await HapticFeedback.selectionClick();

    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset preferences', style: GoogleFonts.poppins()),
          content: Text(
            'This resets theme, notification, backup, and app-lock settings. Your expenses and bills are not deleted.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await NotificationService.cancelAll();
    await AppSecurityService.disableAppLock();
    await BackupService.setEnabled(false);
    await _saveSetting('notifications', false);

    if (!mounted) return;

    await themeProvider.setThemeMode(ThemeMode.system);

    if (!mounted) return;

    setState(() {
      notifications = false;
      biometrics = false;
      cloudBackup = false;
    });

    _showSnack('Preferences reset.');
  }

  Future<void> _showEditProfileSheet(User? user) async {
    if (user == null) {
      _showSnack('Please login to edit your profile.');
      return;
    }

    final nameController = TextEditingController(text: user.displayName ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit profile',
                style: GoogleFonts.poppins(
                  color: colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();

                    if (name.isEmpty) return;

                    await user.updateDisplayName(name);
                    await user.reload();

                    if (context.mounted) {
                      Navigator.pop(context);
                    }

                    if (mounted) {
                      setState(() {});
                      _showSnack('Profile updated.');
                    }
                  },
                  child: Text(
                    'Save profile',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    nameController.dispose();
  }

  Future<String?> _showPinDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final controller = TextEditingController();
    String? error;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title, style: GoogleFonts.poppins()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, style: GoogleFonts.poppins(fontSize: 13)),

                    const SizedBox(height: 14),

                    Material(
                      color: Colors.transparent,
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          counterText: '',
                          errorText: error,
                          hintText: 'PIN',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final pin = controller.text.trim();

                    if (pin.length < 4) {
                      setDialogState(() {
                        error = 'Use at least 4 digits.';
                      });
                      return;
                    }

                    Navigator.pop(context, pin);
                  },
                  child: Text(confirmLabel),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    return result;
  }

  Future<void> _showSupportSheet() async {
    final user = FirebaseAuth.instance.currentUser;
    final userLine = user == null ? 'Guest user' : 'User ID: ${user.uid}';

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help & support',
                style: GoogleFonts.poppins(
                  color: colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'For account, billing, or sync help, share the support details below with the Rupixa team.',
                style: GoogleFonts.poppins(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              _SupportCopyTile(label: 'Email', value: 'support@rupixa.ai'),
              const SizedBox(height: 10),
              _SupportCopyTile(label: 'App', value: 'Rupixa AI v1.0.0'),
              const SizedBox(height: 10),
              _SupportCopyTile(label: 'Account', value: userLine),
            ],
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.poppins())),
    );
  }

  Future<void> _showLogoutDialog() async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            'Are you sure you want to logout from Rupixa AI?',
            style: GoogleFonts.poppins(),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            onPressed: () async {
              Navigator.pop(context);

              await FirebaseAuth.instance.signOut();

              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = colorScheme.brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CupertinoActivityIndicator()),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              elevation: 0,
              toolbarHeight: 86,
              expandedHeight: 132,
              collapsedHeight: 86,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final collapsed = constraints.biggest.height <= 96;

                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: collapsed ? 18 : 0,
                        sigmaY: collapsed ? 18 : 0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              (isDark
                                      ? const Color(0xFF101623)
                                      : const Color(0xFFF7F8FC))
                                  .withValues(alpha: collapsed ? 0.90 : 1),
                          border: Border(
                            bottom: BorderSide(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Settings',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          color: colorScheme.onSurface,
                                          fontSize: collapsed ? 25 : 33,
                                          fontWeight: FontWeight.w800,
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Account, privacy, sync, and appearance',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                _HeaderStatusBadge(
                                  isDark: isDark,
                                  mode: themeProvider.currentTheme,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 124),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      initialData: FirebaseAuth.instance.currentUser,
                      builder: (context, snapshot) {
                        return _ProfilePanel(user: snapshot.data);
                      },
                    ),
                    const SizedBox(height: 18),
                    _ThemeModePanel(
                      selectedMode: themeProvider.currentTheme,
                      onChanged: (mode) async {
                        await HapticFeedback.selectionClick();
                        await themeProvider.setThemeMode(mode);
                      },
                    ),
                    const SizedBox(height: 22),
                    _SectionLabel(title: 'Preferences'),
                    const SizedBox(height: 10),
                    _SettingsGroup(
                      children: [
                        _SwitchRow(
                          icon: CupertinoIcons.bell_fill,
                          iconColor: _accent,
                          title: 'Notifications',
                          subtitle: 'Bills, budgets, and activity alerts',
                          value: notifications,
                          onChanged: _setNotificationsEnabled,
                        ),
                        _ActionRow(
                          icon: CupertinoIcons.paperplane_fill,
                          iconColor: const Color(0xFF1587D4),
                          title: 'Test notification',
                          subtitle: 'Send a sample alert now',
                          onTap: _sendTestNotification,
                        ),
                        _ActionRow(
                          icon: CupertinoIcons.sparkles,
                          iconColor: _primary,
                          title: 'Smart insights',
                          subtitle: 'Open AI spending recommendations',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            context.push('/insights');
                          },
                        ),
                        _ActionRow(
                          icon: CupertinoIcons.doc_chart_fill,
                          iconColor: const Color(0xFF0E9F6E),
                          title: 'Monthly reports',
                          subtitle: 'Open report and PDF export tools',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            context.push('/monthlyReport');
                          },
                        ),
                        _ActionRow(
                          icon: CupertinoIcons.speedometer,
                          iconColor: const Color(0xFF0E9F6E),
                          title: 'Monthly budget',
                          subtitle: 'Update analytics budget target',
                          onTap: _showBudgetSheet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _SectionLabel(title: 'Security & Sync'),
                    const SizedBox(height: 10),
                    _SettingsGroup(
                      children: [
                        _SwitchRow(
                          icon: CupertinoIcons.lock_shield_fill,
                          iconColor: const Color(0xFF0E9F6E),
                          title: 'App lock',
                          subtitle: 'Unlock Rupixa with your private PIN',
                          value: biometrics,
                          onChanged: _setAppLockEnabled,
                        ),
                        _SwitchRow(
                          icon: CupertinoIcons.cloud_fill,
                          iconColor: const Color(0xFF1587D4),
                          title: 'Cloud backup',
                          subtitle: backupInProgress
                              ? 'Backing up expenses and bills...'
                              : 'Sync local records to Firestore',
                          value: cloudBackup,
                          onChanged: _setCloudBackupEnabled,
                        ),
                        _ActionRow(
                          icon: CupertinoIcons.cloud_upload_fill,
                          iconColor: const Color(0xFF1587D4),
                          title: 'Backup now',
                          subtitle: backupInProgress
                              ? 'Backup is currently running'
                              : 'Upload current bills and expenses',
                          onTap: _backupNow,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _SectionLabel(title: 'Account'),
                    const SizedBox(height: 10),
                    _SettingsGroup(
                      children: [
                        _ActionRow(
                          icon: CupertinoIcons.person_crop_circle_fill,
                          iconColor: _secondary,
                          title: 'Profile',
                          subtitle: 'Update your Firebase display name',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _showEditProfileSheet(
                              FirebaseAuth.instance.currentUser,
                            );
                          },
                        ),
                        _ActionRow(
                          icon: CupertinoIcons.question_circle_fill,
                          iconColor: const Color(0xFF64748B),
                          title: 'Help & support',
                          subtitle: 'Copy support and account details',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _showSupportSheet();
                          },
                        ),
                        _ActionRow(
                          icon: CupertinoIcons.refresh_bold,
                          iconColor: const Color(0xFFE5484D),
                          title: 'Reset preferences',
                          subtitle:
                              'Restore app settings without deleting data',
                          onTap: _resetPreferences,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _LogoutButton(onTap: _showLogoutDialog),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStatusBadge extends StatelessWidget {
  const _HeaderStatusBadge({required this.isDark, required this.mode});

  final bool isDark;
  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'Auto',
    };

    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Tooltip(
        message: '$label theme',
        child: Icon(
          isDark ? CupertinoIcons.moon_stars_fill : CupertinoIcons.sun_max_fill,
          color: isDark ? const Color(0xFFFFD166) : _primary,
          size: 24,
        ),
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Guest User';
    final email = user?.email ?? 'No email connected';
    final photoUrl = user?.photoURL;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: colorScheme.brightness == Brightness.dark ? 0.18 : 0.06,
            ),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 31,
            backgroundColor: _primary.withValues(alpha: 0.12),
            backgroundImage: photoUrl == null ? null : NetworkImage(photoUrl),
            child: photoUrl == null
                ? const Icon(
                    CupertinoIcons.person_fill,
                    color: _primary,
                    size: 30,
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF0E9F6E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Live',
              style: GoogleFonts.poppins(
                color: const Color(0xFF0E9F6E),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModePanel extends StatelessWidget {
  const _ThemeModePanel({required this.selectedMode, required this.onChanged});

  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: CupertinoIcons.paintbrush_fill, color: _primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme mode',
                      style: GoogleFonts.poppins(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Changes apply instantly across the app',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              selected: {selectedMode},
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(CupertinoIcons.sun_max_fill, size: 17),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(CupertinoIcons.moon_stars_fill, size: 17),
                  label: Text('Dark'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(CupertinoIcons.device_phone_portrait, size: 17),
                  label: Text('System'),
                ),
              ],
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                  GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              onSelectionChanged: (selection) => onChanged(selection.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              Divider(
                height: 1,
                indent: 70,
                color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
          ],
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _IconBox(icon: icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: colorScheme.onSurface,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CupertinoSwitch(
            value: value,
            activeTrackColor: _primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            _IconBox(icon: icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurface,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_forward,
              color: colorScheme.onSurfaceVariant,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportCopyTile extends StatelessWidget {
  const _SupportCopyTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: value));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label copied', style: GoogleFonts.poppins()),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.60),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.doc_on_doc_fill,
              color: colorScheme.primary,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFE5484D),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(CupertinoIcons.square_arrow_right_fill, size: 20),
        label: Text(
          'Logout',
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        onPressed: () async {
          await HapticFeedback.mediumImpact();
          onTap();
        },
      ),
    );
  }
}
