import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import './screens/register/register_screen.dart';
import './screens/community/community_screen.dart';
import './screens/content/content_screen.dart';
import './screens/diary/diary_screen.dart';
import './screens/exercises/exercises_screen.dart';
import './screens/gamification/gamification_screen.dart';
import './screens/home/home_screen.dart';
import './screens/login/login_screen.dart';
import './screens/profile/profile_screen.dart';
import 'screens/map/map_screen.dart';
import './screens/password_recovery/password_recovery_screen.dart';
import './screens/verify_code/verify_code_screen.dart';
import './screens/reset_password/reset_password_screen.dart';
import './screens/theme/theme_provider.dart';
import './screens/theme/theme_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return MaterialApp(
                title: 'MindCare',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeProvider.themeMode,
                home: const AuthCheck(),
                routes: {
                  '/login': (context) => const LoginScreen(),
                  '/register': (context) => const RegisterScreen(),
                  '/password-recovery': (context) =>
                      const PasswordRecoveryScreen(),
                  '/verify-code': (context) => VerifyCodeScreen(
                        email: '',
                      ),
                  '/reset-password': (context) => ResetPasswordScreen(
                        email: '',
                        code: '',
                      ),
                  '/home': (context) => const HomeScreen(),
                  '/community': (context) => CommunityScreen(),
                  '/content': (context) => ContentScreen(),
                  '/diary': (context) => const DiaryScreen(),
                  '/exercises': (context) => ExercisesScreen(),
                  '/gamification': (context) => GamificationScreen(),
                  '/map': (context) => MapScreen(),
                  '/profile': (context) => UserProfileScreen(),
                },
              );
            },
          ),
        );
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  Future<bool> _isUserAuthenticated() async {
    final storage = const FlutterSecureStorage();
    String? token = await storage.read(key: 'authToken');

    if (token != null && token.isNotEmpty) {
      // Verifique se o token está expirado usando o JwtDecoder
      bool isExpired = JwtDecoder.isExpired(token);

      if (!isExpired) {
        // Se o token não estiver expirado, o usuário está autenticado
        return true;
      } else {
        // Se o token estiver expirado, apague-o para forçar o login
        await storage.delete(key: 'authToken');
      }
    }
    return false; // Retorna falso se o token estiver ausente ou expirado
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}