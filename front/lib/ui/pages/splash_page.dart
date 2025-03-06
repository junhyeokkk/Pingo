import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();

    _checkLoginStates();
  }

  Future<void> _checkLoginStates() async {
    try {
      await ref.read(sessionProvider.notifier).checkLoginState();
    } catch (e) {
      logger.e(e.toString());
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    // 2초 동안 대기 후 로그인 페이지 이동 처리
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.popAndPushNamed(context, '/signin');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/bb0005.jpg'),
            Text(
              '대기',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
