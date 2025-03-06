import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/membership_model/membership.dart';
import 'package:pingo_front/data/repository/membership_repository/membership_repository.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';
import 'package:pingo_front/data/view_models/user_view_model/user_view_model.dart';
import 'package:pingo_front/ui/pages/membership_Page/membership_page.dart';
import 'package:pingo_front/ui/widgets/appbar/user_appbar.dart';
import 'components/myinfo_box.dart';
import 'components/profile_photo_box.dart';

class UserPage extends ConsumerStatefulWidget {
  const UserPage({super.key});

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  late String userNo;
  bool paymentState = false;
  final MembershipRepository _repository = MembershipRepository();

  // stateful 위젯이 생성될 때 최초 1회만 실행하는 메서드
  @override
  void initState() {
    super.initState();
    userNo = ref.read(sessionProvider).userNo!;
    ref.read(userViewModelProvider.notifier).fetchMyPageInfo(userNo);
  }

  void logout() {
    ref.read(sessionProvider.notifier).logout();
  }

  Future<void> _userMembershipUpdate(Membership membership) async {
    Map<String, dynamic> reqData = {'msNo': membership.msNo, 'userNo': userNo};
    final String expDate = await _repository.fetchUpdateUserMembership(reqData);
    ref.read(sessionProvider.notifier).updateExpDate(expDate);
  }

  @override
  Widget build(BuildContext context) {
    final userViewModelNotifier =
        ref.read(userViewModelProvider.notifier); // 읽기 전용
    final userMypageInfo =
        ref.watch(userViewModelProvider); // 계속해서 감시 (즉, 추적 관리, 구독)

    return Scaffold(
      appBar: userAppbar(context, logout),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            children: [
              const SizedBox(height: 8.0),
              MyinfoBox(userMypageInfo),
              const SizedBox(height: 8.0),
              ProfilePhotoBox(userMypageInfo, userViewModelNotifier),
              const SizedBox(height: 8.0),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(color: Colors.black12, width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _menuBtn(
                          btnName: '로그아웃',
                          btnIcon: Icon(Icons.logout),
                          btnFunction:
                              ref.read(sessionProvider.notifier).logout,
                        ),
                        _menuBtn(
                          btnName: '결제',
                          btnIcon: Icon(Icons.payment),
                          btnFunction: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MembershipPage()),
                            );
                            if (result['status'] == 'success') {
                              setState(() {
                                paymentState = true;
                              });
                              await _userMembershipUpdate(result['membership']);

                              setState(() {
                                paymentState = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("결제가 성공적으로 완료되었습니다!"),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
            ],
          ),
          Visibility(
            visible: paymentState,
            child: Positioned(
              child: Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey.withOpacity(0.4),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text(
                          '결제 완료 처리 중입니다.',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _menuBtn(
      {required String btnName,
      required Icon btnIcon,
      required Function btnFunction}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      margin: EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () {
          btnFunction();
        },
        child: Row(
          children: [
            btnIcon,
            const SizedBox(width: 20),
            Text(btnName, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
