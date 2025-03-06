import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/data/view_models/user_view_model/user_view_model.dart';

import '../../../widgets/find_pw_appbar.dart';
import 'reset_pw_page.dart';

class FindPwPage extends ConsumerStatefulWidget {
  const FindPwPage({super.key});

  @override
  ConsumerState<FindPwPage> createState() => _FindPwPageState();
}

class _FindPwPageState extends ConsumerState<FindPwPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  String information = '';
  String isCertification = 'prev'; // prev - 인증 전 / doing - 인증 중 / end - 인증 완료

  // 이메일 인증번호 발송
  void _verificationBtn() async {
    final userNotifier =
        ref.read(userViewModelProvider.notifier); // ref.read() 직접 사용

    String userEmail = _userEmailController.text.trim();
    if (userEmail.isNotEmpty) {
      int result = await userNotifier.verifyEmail(userEmail);

      setState(() {
        if (result == 1) {
          if (isCertification == 'prev') {
            isCertification = 'doing';
          }
          information = '';
        } else if (result == 2) {
          information = 'example@email.com 형식만 가능합니다.';
        } else if (result == 3) {
          information = '이미 사용중인 중복된 이메일입니다.';
        } else if (result == 4) {
          information = '서버 오류';
        }
      });
    }
  }

  // 이메일 인증번호 체크
  void _checkVerificationCodeBtn() async {
    final userNotifier =
        ref.read(userViewModelProvider.notifier); // ref.read() 직접 사용

    String userEmail = _userEmailController.text.trim();
    String verificationCode = _verificationCodeController.text.trim();

    if (userEmail.isNotEmpty && verificationCode.isNotEmpty) {
      int result = await userNotifier.verifyCode(userEmail, verificationCode);

      setState(() {
        if (isCertification == 'doing' && result == 1) {
          isCertification = 'end';
          information = '';
        } else if (isCertification == 'doing' && result == 2) {
          information = '인증코드가 일치하지 않습니다.';
        } else if (isCertification == 'doing' && result == 3) {
          information = '서버 오류';
        }
      });
    }
  }

  // 유저 비밀번호 재설정으로 이동
  void checkValidation() async {
    final userNotifier =
        ref.read(userViewModelProvider.notifier); // ref.read() 직접 사용

    String userId = _userIdController.text.trim();
    String userEmail = _userEmailController.text.trim();

    if (userId.isEmpty || userEmail.isEmpty) {
      setState(() {
        information = '모든 항목을 입력해주세요.';
      });
      return;
    }

    int result = await userNotifier.findUserPw(userId, userEmail);

    setState(() {
      if (result == 1) {
        // 비밀번호 재설정 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResetPwPage()),
        );
      } else if (result == 2) {
        information = '아이디는 6~12자리의 영문, 숫자 조합만 가능합니다.';
      } else if (result == 3) {
        information = '해당하는 계정이 존재하지 않습니다.';
      } else if (result == 4) {
        information = '서버 오류';
      }
    });
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
                    '아이디', '영문+숫자 (6~12자리)', false, _userIdController),
                const SizedBox(height: 20),
                _emailInputBox('이메일', 'example@email.com', false,
                    _userEmailController, '인증', _verificationBtn),
                const SizedBox(height: 4),
                if (isCertification == 'doing')
                  _emailInputBox(
                      null,
                      '인증번호',
                      false,
                      _verificationCodeController,
                      '확인',
                      _checkVerificationCodeBtn),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (_userIdController.text.trim().isNotEmpty &&
                                  _userEmailController.text.trim().isNotEmpty &&
                                  isCertification == 'end')
                              ? Color(0xFF906FB7)
                              : Colors.grey, // 조건 충족되지 않으면 비활성화 색상
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    onPressed: (_userIdController.text.trim().isNotEmpty &&
                            _userEmailController.text.trim().isNotEmpty &&
                            isCertification == 'end')
                        ? () => checkValidation()
                        : null, // 조건 충족되지 않으면 버튼 비활성화
                    child: Text(
                      '비밀번호 재설정으로 이동',
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

  // 아이디 입력 위젯
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

  // 이메일 입력 위젯
  Widget _emailInputBox(String? title, String textHint, bool obscure,
      TextEditingController controller, String btnName, Function btnFunction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: textHint,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                obscureText: obscure,
              ),
            ),
            InkWell(
              onTap: () => btnFunction(),
              child: Container(
                width: 60,
                height: 50,
                margin: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: Color(0xFF906FB7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    btnName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
