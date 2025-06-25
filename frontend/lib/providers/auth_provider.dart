import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  // 初期化時にトークンをチェック
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (await _authService.hasToken()) {
        if (await _authService.verifyToken()) {
          _user = await _authService.getCurrentUser();
          _isAuthenticated = true;
        } else {
          await _authService.logout();
          _isAuthenticated = false;
        }
      }
    } catch (e) {
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ユーザー登録
  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCreate = UserCreate(
        username: username,
        email: email,
        password: password,
      );
      
      _user = await _authService.register(userCreate);
      
      // 登録後、自動的にログイン
      await login(username, password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  // ログイン
  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userLogin = UserLogin(
        username: username,
        password: password,
      );
      
      await _authService.login(userLogin);
      _user = await _authService.getCurrentUser();
      _isAuthenticated = true;
    } catch (e) {
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      throw e;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ログアウト
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // ユーザー情報を更新
  Future<void> refreshUser() async {
    if (_isAuthenticated) {
      try {
        _user = await _authService.getCurrentUser();
        notifyListeners();
      } catch (e) {
        // ユーザー情報の取得に失敗した場合はログアウト
        await logout();
      }
    }
  }
} 