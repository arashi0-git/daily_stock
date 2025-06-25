import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // ユーザー登録
  Future<User> register(UserCreate userCreate) async {
    final response = await _apiService.post('/auth/register', data: userCreate.toJson());
    return User.fromJson(response.data);
  }

  // ログイン
  Future<Token> login(UserLogin userLogin) async {
    final response = await _apiService.post('/auth/login', data: userLogin.toJson());
    final token = Token.fromJson(response.data);
    
    // トークンを保存
    await _apiService.saveToken(token.accessToken);
    
    return token;
  }

  // ログアウト
  Future<void> logout() async {
    await _apiService.clearToken();
  }

  // 現在のユーザー情報を取得
  Future<User> getCurrentUser() async {
    final response = await _apiService.get('/auth/me');
    return User.fromJson(response.data);
  }

  // トークンの有効性を確認
  Future<bool> verifyToken() async {
    try {
      await _apiService.get('/auth/verify-token');
      return true;
    } catch (e) {
      return false;
    }
  }

  // トークンが保存されているかチェック
  Future<bool> hasToken() async {
    final token = await _apiService.getToken();
    return token != null;
  }
} 