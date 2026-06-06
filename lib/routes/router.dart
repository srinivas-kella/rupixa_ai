import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:rupixa_ai/models/expense_model.dart';
import 'package:rupixa_ai/screens/analytics/monthly_report_screen.dart';
import 'package:rupixa_ai/screens/bills/add_bill_screen.dart';
import 'package:rupixa_ai/screens/expenses/add_expense_screen.dart';
import 'package:rupixa_ai/screens/expenses/edit_expense_screen.dart';
import 'package:rupixa_ai/screens/expenses/expenses_screen.dart';
import 'package:rupixa_ai/screens/insights/insights_screen.dart';
import 'package:rupixa_ai/screens/navigation/bottom_nav_screen.dart';

import '../screens/auth/login_screen.dart';
import '../screens/splash/splash_screen.dart';

import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,

  routes: [
    GoRoute(
      path: AppRoutes.splash,

      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: AppRoutes.login,

      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: AppRoutes.home,

      builder: (context, state) => const BottomNavScreen(),
    ),

    GoRoute(
      path: AppRoutes.dashboard,

      builder: (context, state) => const BottomNavScreen(),
    ),

    GoRoute(
      path: '/addExpense',

      builder: (context, state) => const AddExpenseScreen(),
    ),

    GoRoute(
      path: '/editExpense',

      pageBuilder: (context, state) {
        final expense = state.extra as ExpenseModel;

        return CustomTransitionPage(
          key: state.pageKey,

          child: EditExpenseScreen(expense: expense),

          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),

                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,

                      curve: Curves.easeOutCubic,
                    ),
                  ),

              child: child,
            );
          },
        );
      },
    ),

    GoRoute(
      path: '/monthlyReport',

      pageBuilder: (context, state) {
        return CustomTransitionPage(
          child: const MonthlyReportScreen(),

          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return CupertinoPageTransition(
              primaryRouteAnimation: animation,

              secondaryRouteAnimation: secondaryAnimation,

              linearTransition: true,

              child: child,
            );
          },
        );
      },
    ),

    GoRoute(
      path: '/insights',
      builder: (context, state) => const InsightsScreen(),
    ),

    GoRoute(
      path: '/addBill',

      builder: (context, state) => const AddBillScreen(),
    ),

    GoRoute(
      path: '/expenses',
      builder: (context, state) => const ExpensesScreen(),
    ),
  ],
);
