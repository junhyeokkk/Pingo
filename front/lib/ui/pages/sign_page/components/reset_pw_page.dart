import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/data/view_models/user_view_model/user_view_model.dart';

import '../../../widgets/find_pw_appbar.dart';

class ResetPwPage extends ConsumerStatefulWidget {
  const ResetPwPage({super.key});

  @override
  ConsumerState<ResetPwPage> createState() => _ResetPwPageState();
}

class _ResetPwPageState extends ConsumerState<ResetPwPage> {
  final TextEditingController _userPw1Controller = TextEditingController();
  final TextEditingController _userPw2Controller = TextEditingController();

  late final userNotifier;
  String information = '';
  bool isButtonEnabled = false; // 버튼 활성화 상태 변수 추가

  @override
  void initState() {
    super.initState();
    userNotifier = ref.read(userViewModelProvider.notifier); // ref 사용 가능

    // 입력값이 변경될 때마다 버튼 상태 업데이트
    _userPw1Controller.addListener(_updateButtonState);
    _userPw2Controller.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _userPw1Controller.dispose();
    _userPw2Controller.dispose();
    super.dispose();
  }

  // 입력값이 변경될 때마다 버튼 활성화 상태 업데이트
  void _updateButtonState() {
    setState(() {
      isButtonEnabled = _userPw1Controller.text.trim().isNotEmpty &&
          _userPw2Controller.text.trim().isNotEmpty;
    });
  }

  // 유저 비밀번호 재설정
  void checkValidation() async {
    String userPw1 = _userPw1Controller.text.trim();
    String userPw2 = _userPw2Controller.text.trim();

    if (userPw1.isEmpty || userPw2.isEmpty) {
      setState(() {
        information = '모든 항목을 입력해주세요.';
      });
      return;
    }

    int result = await userNotifier.resetUserPw(userPw1, userPw2);

    setState(() {
      if (result == 1) {
        _resetPwSuccessDialog();
      } else if (result == 2) {
        information = '비밀번호는 8~14자리의 영문, 숫자, 특수문자만 가능하며 첫 글자는 대문자 알파벳이어야 합니다.';
      } else if (result == 3) {
        information = '입력한 비밀번호가 일치하지 않습니다.';
      } else if (result == 4) {
        information = '비밀번호 재설정 실패';
      } else if (result == 5) {
        information = '서버 오류';
      }
    });
  }

  // 비밀번호 성공 알람창
  void _resetPwSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("비밀번호 변경 완료"),
          content: Text("비밀번호가 변경되었습니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text(
                "확인",
                style: TextStyle(color: Color(0xFF906FB7)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: findPwAppBar(context),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textInputBox(
                  '비밀번호',
                  '첫 글자는 대문자 알파벳, 영문+숫자+특수문자 (8~14자리)',
                  true,
                  _userPw1Controller,
                ),
                const SizedBox(height: 20),
                _textInputBox(
                  '비밀번호 확인',
                  '첫 글자는 대문자 알파벳, 영문+숫자+특수문자 (8~14자리)',
                  true,
                  _userPw2Controller,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonEnabled
                          ? Color(0xFF906FB7)
                          : Colors.grey, // 비활성화 시 회색
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    onPressed: isButtonEnabled
                        ? () => checkValidation()
                        : null, // 상태 기반 활성화
                    child: Text(
                      '비밀번호 재설정',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                              fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 비밀번호 입력 위젯
  Widget _textInputBox(String title, String textHint, bool obscure,
      TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4.0),
        TextField(
          controller: controller,
          onChanged: (value) => _updateButtonState(), // 변경 감지
          decoration: InputDecoration(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            filled: true,
            fillColor: Colors.white,
            hintText: textHint,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          obscureText: obscure,
        ),
      ],
    );
  }
}
