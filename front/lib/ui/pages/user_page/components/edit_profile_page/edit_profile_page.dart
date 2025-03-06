import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/ui/pages/user_page/components/edit_profile_page/components/edit_user_email.dart';
import 'package:pingo_front/ui/pages/user_page/components/edit_profile_page/components/edit_user_keyword_box.dart';
import '../../../../../data/models/user_model/user_mypage_info.dart';
import '../../../../../data/view_models/sign_view_model/signin_view_model.dart';
import '../../../../../data/view_models/user_view_model/user_view_model.dart';
import 'components/edit_profile_appbar.dart';
import 'components/edit_personal_information_box.dart';
import 'components/edit_self_introduction_box.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late String userNo;
  late UserMypageInfo copyUserInfo;
  bool isEmailCertified = false; // 이메일 인증 여부 상태 추가

  @override
  void initState() {
    super.initState();
    userNo = ref.read(sessionProvider).userNo!;
    ref.read(userViewModelProvider.notifier).fetchMyPageInfo(userNo);
  }

  // 수정 완료 버튼 눌렀을 때 실행되는 함수
  void _submitUserInfo() async {
    await ref
        .read(userViewModelProvider.notifier)
        .submitUpdateInfo(copyUserInfo);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = ref.read(userViewModelProvider.notifier);
    final userMypageInfo = ref.watch(userViewModelProvider);

    copyUserInfo = UserMypageInfo().copyWith(userMypageInfo);

    return Scaffold(
      body: SafeArea(
        child: Scaffold(
          appBar: EditProfileAppBar(context),
          backgroundColor: Colors.black12,
          body: ListView(
            children: [
              const SizedBox(height: 8.0),
              EditUserEmail(
                copyUserInfo.users!.userEmail ?? '',
                userNotifier,
                onCertified: (bool isCertified) {
                  setState(() {
                    isEmailCertified = isCertified; // 이메일 인증 상태 업데이트
                  });
                },
              ),
              const SizedBox(height: 8.0),
              EditPersonalInformationBox(copyUserInfo.userInfo!),
              const SizedBox(height: 8.0),
              EditUserKeywordBox(copyUserInfo.myKeywordList!,
                  copyUserInfo.favoriteKeywordList!),
              const SizedBox(height: 8.0),
              EditSelfIntroductionBox(copyUserInfo),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: _submitButton(),
      ),
    );
  }

  Widget _submitButton() {
    bool isButtonEnabled = isEmailCertified;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled ? Color(0xFF906FB7) : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        onPressed: isButtonEnabled ? () => _submitUserInfo() : null,
        child: Text(
          '수정 완료',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
