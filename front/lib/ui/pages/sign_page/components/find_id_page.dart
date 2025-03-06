import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/view_models/user_view_model/user_view_model.dart';
import '../../../widgets/find_id_appbar.dart';
import 'find_pw_page.dart';

class FindIdPage extends ConsumerStatefulWidget {
  const FindIdPage({super.key});

  @override
  ConsumerState<FindIdPage> createState() => _FindIdPageState();
}

class _FindIdPageState extends ConsumerState<FindIdPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  late final userNotifier;

  String information = '';
  String isCertification = 'prev'; // prev - 인증 전 / doing - 인증 중 / end - 인증 완료

  @override
  void initState() {
    super.initState();
    userNotifier = ref.read(userViewModelProvider.notifier); // userNotifier 초기화
  }

  // 이메일 인증번호 발송
  void _verificationBtn() async {
    String userEmail = _userEmailController.text.trim();

    if (userEmail.isNotEmpty) {
      int result = await userNotifier.verifyEmail(userEmail);

      setState(() {
        if (result == 1) {
          if (isCertification == 'prev' && result == 1) {
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
      int result = await userNotifier.verifyCode(userEmail, verificationCode);

      setState(() {
        if (isCertification == 'doing' && result == 1) {
          isCertification = 'end';
          checkValidation();
        } else if (isCertification == 'doing' && result == 2) {
          information = '인증코드가 일치하지 않습니다.';
        } else if (isCertification == 'doing' && result == 3) {
          information = '서버 오류';
        }
      });
    }
  }

  // ID 찾는 로직
  void checkValidation() async {
    String userName = _userNameController.text.trim();
    String userEmail = _userEmailController.text.trim();

    if (userName.isEmpty || userEmail.isEmpty) {
      setState(() {
        information = '모든 항목을 입력해주세요.';
      });
      return;
    }

    Map<String, dynamic> result =
        await userNotifier.findUserId(userName, userEmail);

    setState(() {
      if (result["status"] == 1) {
        information = "찾은 아이디: ${result["userId"]}"; // 찾은 아이디를 표시
      } else if (result["status"] == 2) {
        information = '이름은 2~10자의 한글만 가능합니다';
      } else if (result["status"] == 3) {
        information = '해당하는 계정이 존재하지 않습니다.';
      } else if (result["status"] == 4) {
        information = '서버 오류';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: findIdAppBar(context),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textInputBox('이름', '2~10자의 한글', false, _userNameController),
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
                information.isNotEmpty
                    ? Text(
                        information,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontWeight: FontWeight.bold, color: Colors.red),
                      )
                    : SizedBox(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // 버튼 사이 간격 조정
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.grey, // 메인으로 버튼 색상 (다르게 설정 가능)
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context); // 메인 페이지로 이동 (pop으로 뒤로 가기)
                          },
                          child: Text(
                            '메인으로',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // 버튼 간격 조정
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF906FB7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FindPwPage()),
                            );
                          },
                          child: Text(
                            '비밀번호 찾기',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 이름 입력 위젯
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
