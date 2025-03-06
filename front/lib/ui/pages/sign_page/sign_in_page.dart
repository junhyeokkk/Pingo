import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';
import 'package:pingo_front/ui/pages/sign_page/sign_up_page/sign_up_page2.dart';
import 'components/find_id_page.dart';
import 'components/find_pw_page.dart';

class SignInPage extends ConsumerStatefulWidget {
  SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userPwController = TextEditingController();

  String? _idError; // 아이디 에러 메시지
  String? _pwError; // 비밀번호 에러 메시지

  // 아이디 정규식 검증
  bool _validateUserId(String userId) {
    final RegExp regex = RegExp(r'^[a-zA-Z0-9]{6,12}$');
    return regex.hasMatch(userId);
  }

  // 비밀번호 정규식 검증
  bool _validateUserPw(String userPw) {
    final RegExp regex = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*()-_+=])[A-Za-z\d!@#$%^&*()-_+=]{8,14}$');
    return regex.hasMatch(userPw);
  }

  // 로그인 버튼 클릭 시 실행되는 함수
  void _onLoginPressed() async {
    setState(() {
      _idError = _validateUserId(_userIdController.text.trim())
          ? null
          : "아이디는 영문 대소문자, 숫자로 6~12자여야 합니다.";
      _pwError = _validateUserPw(_userPwController.text.trim())
          ? null
          : "비밀번호는 8~14자이며, 영문 + 숫자 + 특수문자를 포함해야 합니다.";
    });

    if (_idError == null && _pwError == null) {
      try {
        await ref.read(sessionProvider.notifier).login(
              _userIdController.text.trim(),
              _userPwController.text.trim(),
            );
      } catch (e) {
        setState(() {
          _pwError = "아이디 또는 비밀번호가 일치하지 않습니다.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SigninViewModel signinViewModel = ref.read(sessionProvider.notifier);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/pingo1.png',
                    width: 200,
                    height: 200,
                  ),
                  // 아이디 입력 필드
                  TextField(
                    controller: _userIdController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '아이디를 입력하세요.',
                      hintStyle: TextStyle(color: Colors.grey),
                      errorText: _idError,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 비밀번호 입력 필드
                  TextField(
                    controller: _userPwController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '비밀번호를 입력하세요.',
                      hintStyle: TextStyle(color: Colors.grey),
                      errorText: _pwError,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),

                  // 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF906FB7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      onPressed: _onLoginPressed, // 로그인 버튼 클릭 시 검증 실행
                      child: Text(
                        '로그인',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFindUserInfo(
                        context,
                        FindIdPage(),
                        '아이디 찾기',
                      ),
                      const SizedBox(width: 16.0),
                      _buildFindUserInfo(
                        context,
                        FindPwPage(),
                        '비밀번호 찾기',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '계정이 없으신가요? ',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      _buildFindUserInfo(
                        context,
                        SignUpPage2(),
                        '회원가입',
                      ),
                    ],
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom / 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFindUserInfo(context, link, findTitle) {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => link),
              );
            },
            child: Text(
              findTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
