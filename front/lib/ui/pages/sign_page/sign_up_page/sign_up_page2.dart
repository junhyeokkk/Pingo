import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signup_view_model.dart';
import 'package:pingo_front/ui/pages/sign_page/sign_up_page/signup_step/signup_complete_step.dart';
import 'package:pingo_front/ui/pages/sign_page/sign_up_page/signup_step/user_basic_info_step.dart';
import 'package:pingo_front/ui/pages/sign_page/sign_up_page/signup_step/user_favorite_keyword_step.dart';
import 'package:pingo_front/ui/pages/sign_page/sign_up_page/signup_step/user_my_keyword_step.dart';
import 'package:pingo_front/ui/pages/sign_page/sign_up_page/signup_step/user_profile_step.dart';
import 'package:pingo_front/ui/widgets/signup_appbar.dart';

import 'signup_step/user_detail_info_step.dart';
import 'signup_step/user_id_pw_step.dart';
import 'signup_step/user_term_step.dart';

// 새 회원가입 페이지
// 세세한 디테일 부족 -> 모든 예외 경우를 전부 검증하지 못함
class SignUpPage2 extends ConsumerStatefulWidget {
  const SignUpPage2({super.key});

  @override
  ConsumerState<SignUpPage2> createState() => _SignUpPage2State();
}

class _SignUpPage2State extends ConsumerState<SignUpPage2>
    with SingleTickerProviderStateMixin {
  int currentStep = 0;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero)
        .animate(_controller);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  // 다음 step으로 넘기는 함수
  void _nextStep() {
    setState(() {
      currentStep++;
      _controller.reset();
      _controller.forward();
    });
  }

  // 이전 step으로 돌아가는 함수
  void _prevStep() {
    setState(() {
      currentStep--;
      _controller.reset();
      _controller.forward();
    });
  }

  void _rollbackStep() {
    setState(() {
      currentStep = 0;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(signupViewModelProvider);
    final signupNotifier = ref.read(signupViewModelProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Scaffold(
          appBar: signupAppBar(context, currentStep, _prevStep),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                _signupNavigation(currentStep),
                const SizedBox(height: 40),
                IntrinsicHeight(
                  child: Center(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child:
                            _buildStepWidget(context, userData, signupNotifier),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom / 10),
              ],
            ),
          ),
          // // 임시 개발용 버튼
          // floatingActionButton: FloatingActionButton(
          //   onPressed: _nextStep,
          //   child: Icon(Icons.arrow_forward),
          // ),
        ),
      ),
    );
  }

  // currentStep에 따라 화면 전환하는 위젯
  Widget _buildStepWidget(BuildContext context, userData, signupNotifier) {
    switch (currentStep) {
      case 0:
        return userTermStep(context, _nextStep, userData);
      case 1:
        return UserIdPwStep(_nextStep, userData, signupNotifier);
      case 2:
        return UserBasicInfoStep(_nextStep, userData, signupNotifier);
      case 3:
        return UserProfileStep(_nextStep, userData, signupNotifier);
      case 4:
        return UserDetailInfoStep(_nextStep, userData, signupNotifier);
      case 5:
        return UserMyKeywordStep(_nextStep, userData, signupNotifier);
      case 6:
        return UserFavoriteKeywordStep(_nextStep, userData, signupNotifier);
      default:
        return SignupCompleteStep(
            _nextStep, _rollbackStep, userData, signupNotifier);
    }
  }

  // 상단의 회원가입 진행 상태 네비게이션 위젯
  Widget _signupNavigation(currentStep) {
    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 4,
            color: Color(0xFF906FB7),
          ),
          Positioned(
            top: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stepIcon(currentStep, 0, Icons.assignment, "이용약관"),
                _stepIcon(currentStep, 1, Icons.lock_outline, "계정정보"),
                _stepIcon(currentStep, 2, Icons.person, "회원정보"),
                _stepIcon(currentStep, 5, Icons.interests, "취향정보"),
                _stepIcon(currentStep, 7, Icons.check_circle, "완료"),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 상단 네비게이션 위젯의 개별 아이콘 위젯
  Widget _stepIcon(int currentStep, int index, IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color:
                index > currentStep ? Colors.grey.shade200 : Color(0xFF906FB7),
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              color: index > currentStep ? Colors.grey.shade500 : Colors.white),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
