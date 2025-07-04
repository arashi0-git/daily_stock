import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.login(
          _usernameController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;

        // ログイン成功時はホーム画面に遷移
        context.go('/home');
      } catch (e) {
        if (!mounted) return;

        final errorMessage = e.toString().replaceAll('Exception: ', '');

        // 新規登録を促すエラーの場合、専用ダイアログを表示
        if (errorMessage.contains('登録されていません') ||
            errorMessage.contains('新規登録を行ってください')) {
          _showRegistrationPromptDialog(errorMessage);
        } else {
          // その他のエラーは従来通りスナックバーで表示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ログインに失敗しました: $errorMessage'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: '新規登録',
                textColor: Colors.white,
                onPressed: () => context.go('/register'),
              ),
            ),
          );
        }
      }
    }
  }

  void _showRegistrationPromptDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.info_outline,
            color: Colors.blue,
            size: 48,
          ),
          title: const Text('アカウントが見つかりません'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'このユーザー名はまだ登録されていません。\n新しいアカウントを作成しますか？',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                '📝 新規登録は無料で、数秒で完了します',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 入力済みのユーザー名を引き継いで登録画面へ
                context.go(
                    '/register?username=${_usernameController.text.trim()}');
              },
              child: const Text('新規登録する'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // アプリタイトル
                      Text(
                        '日用品管理アプリ',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ログインして在庫を管理しましょう',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 32),

                      // ユーザー名入力
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'ユーザー名',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'ユーザー名を入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // パスワード入力
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'パスワード',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'パスワードを入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // ログインボタン
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading ? null : _login,
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text('ログイン'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // 新規登録リンク
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('アカウントをお持ちでない方は'),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: const Text('新規登録'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
