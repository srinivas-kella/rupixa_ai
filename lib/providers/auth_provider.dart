import 'package:flutter/material.dart';

import '../core/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;

  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));

      if (email == 'admin@gmail.com' && password == '123456') {
        await StorageService.saveToken('dummy_token');

        isLoading = false;
        notifyListeners();

        return true;
      }

      isLoading = false;
      notifyListeners();

      return false;
    } catch (e) {
      isLoading = false;
      notifyListeners();

      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearToken();
  }
}
