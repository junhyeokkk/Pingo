import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditUserEmail extends ConsumerStatefulWidget {
  final String userEmail;
  final dynamic userNotifier;
  final Function(bool) onCertified; // 인증 완료 여부 전달하는 콜백 추가

  const EditUserEmail(this.userEmail, this.userNotifier,
      {super.key, required this.onCertified});

  @override
  ConsumerState<EditUserEmail> createState() => _EditUserEmailState();
}

class _EditUserEmailState extends ConsumerState<EditUserEmail> {
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  String information = '';
  String isCertification = 'prev';

  @override
  void initState() {
    super.initState();
    _userEmailController.text = widget.userEmail; // 초기값 설정
  }

  // 이메일 인증번호 발송
  void _verificationBtn() async {
    String userEmail = _userEmailController.text.trim();

    if (userEmail.isNotEmpty) {
      int result = await widget.userNotifier.verifyEmail(userEmail);

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
    String userEmail = _userEmailController.text.trim();
    String verificationCode = _verificationCodeController.text.trim();

    if (userEmail.isNotEmpty && verificationCode.isNotEmpty) {
      int result =
          await widget.userNotifier.verifyCode(userEmail, verificationCode);

      setState(() {
        if (isCertification == 'doing' && result == 1) {
          isCertification = 'end';
          widget.userNotifier.updateUserEmail(userEmail); // 변경된 이메일 적용
          widget.onCertified(true); // 인증 성공 상태 전달
          information = '';
        } else if (isCertification == 'doing' && result == 2) {
          information = '인증코드가 일치하지 않습니다.';
        } else if (isCertification == 'doing' && result == 3) {
          information = '서버 오류';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이메일',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4.0),
            _emailInputBox(_userEmailController.text, 'example@email.com',
                false, _userEmailController, '인증', _verificationBtn),
            const SizedBox(height: 4),
            if (isCertification == 'doing')
              _emailInputBox(null, '인증번호', false, _verificationCodeController,
                  '확인', _checkVerificationCodeBtn),
          ],
        ),
      ),
    );
  }

  // 이메일 입력 위젯
  Widget _emailInputBox(String? initialValue, String textHint, bool obscure,
      TextEditingController controller, String btnName, Function btnFunction) {
    if (initialValue != null && initialValue.isNotEmpty) {
      controller.text = initialValue;
    }

    return Row(
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
              hintText: (initialValue == null || initialValue.isEmpty)
                  ? textHint
                  : null,
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
                borderRadius: BorderRadius.circular(4)),
            child: Center(
              child: Text(
                btnName,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
