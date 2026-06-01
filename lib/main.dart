import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:rupixa_ai/firebase_options.dart';
import 'package:rupixa_ai/models/bill_model.dart';

import 'app.dart';

import 'models/expense_model.dart';

import 'providers/auth_provider.dart';
import 'providers/bill_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/theme_provider.dart';

import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// =========================================
  /// LOCK PORTRAIT
  /// =========================================

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  /// =========================================
  /// PREMIUM SYSTEM UI
  /// =========================================

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,

      statusBarBrightness: Brightness.light,

      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  /// =========================================
  /// 120HZ SMOOTH RENDERING
  /// =========================================

  PaintingBinding.instance.imageCache.maximumSize = 100;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 100;

  /// =========================================
  /// FIREBASE
  /// =========================================

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// =========================================
  /// HIVE
  /// =========================================

  await Hive.initFlutter();

  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(BillModelAdapter());

  await Hive.openBox<ExpenseModel>('expensesBox');
  await Hive.openBox<BillModel>('billsBox');

  /// =========================================
  /// NOTIFICATIONS
  /// =========================================

  await NotificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => ExpenseProvider()),

        ChangeNotifierProvider(create: (_) => BillProvider()),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],

      child: const MyApp(),
    ),
  );
}
