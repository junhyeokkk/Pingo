import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/global_model/session_user.dart';
import 'package:pingo_front/data/models/membership_model/membership.dart';
import 'package:pingo_front/data/models/membership_model/user_membership.dart';
import 'package:pingo_front/data/repository/membership_repository/membership_repository.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';
import 'package:pingo_front/ui/pages/membership_Page/payment_page.dart';

class MembershipPage extends ConsumerStatefulWidget {
  const MembershipPage({super.key});

  @override
  ConsumerState<MembershipPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<MembershipPage> {
  final MembershipRepository _repository = MembershipRepository();
  Future<List<Membership>>? _membershipFuture;
  late UserMembership? userMembership;
  List<Color> couponColors = [
    Colors.lightBlueAccent,
    Colors.lightGreenAccent,
    Colors.orangeAccent
  ];
  Membership? selectedMembership;
  late SessionUser sessionUser;

  @override
  void initState() {
    super.initState();
    sessionUser = ref.read(sessionProvider);
    _loadMembershipData();
  }

  Future<void> _loadMembershipData() async {
    var result = await _repository.fetchSelectMemberShip(sessionUser.userNo!);
    setState(() {
      userMembership = result.item1;
      _membershipFuture = Future.value(result.item2);
    });
  }

  void _clickCoupon(Membership membership) {
    selectedMembership = membership;
    setState(() {});
  }

  void _clickPayment() async {
    logger.i(selectedMembership);
    if (selectedMembership == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("결제하실 구독권을 선택해주세요."),
          backgroundColor: Color(0xFF906FB7),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (userMembership != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("이미 구독중인 상품이 존재합니다."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(selectedMembership),
      ),
    );
    logger.e(result);
    if (result != null) {
      if (result["status"] == "fail") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("결제에 실패했습니다. 다시 시도해주세요."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        Navigator.pop(
            context, {"status": "success", "membership": selectedMembership});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Pingo 구독권 구매',
              style: TextStyle(fontSize: 16),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder(
                future: _membershipFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("데이터 로드 실패"));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text("멤버십 정보 없음"));
                  }

                  List<Membership> memberships = snapshot.data!;

                  return Column(
                    children: [
                      Text(
                        'Pingo 유료 구독으로 \n더 많은 기능을 경험해보세요!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(
                        memberships.length,
                        (index) {
                          return _couponBox(memberships[index], Colors.grey);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _explainRow('무제한 SUPER PING'),
                            const SizedBox(height: 8),
                            _explainRow('나를 PING한 사람 프로필 보기'),
                            const SizedBox(height: 8),
                            _explainRow('상대와의 최대거리 200KM'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _paymentBtn(),
          ),
        ),
      ),
    );
  }

  Widget _explainRow(String explain) {
    return Row(
      children: [
        Icon(Icons.check),
        const SizedBox(width: 8),
        Text(explain, style: Theme.of(context).textTheme.headlineMedium)
      ],
    );
  }

  Widget _paymentBtn() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF906FB7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        onPressed: () async {
          _clickPayment();
        },
        child: Text(
          '${selectedMembership != null ? NumberFormat('#,###').format(selectedMembership?.price) : 0} 원  결제하기',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _couponBox(Membership membership, Color backColor) {
    return InkWell(
      splashColor: Colors.transparent, // 물결 효과 제거
      highlightColor: Colors.transparent, // 클릭 시 배경 강조 제거
      onTap: () {
        _clickCoupon(membership);
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 140,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 45),
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              color: membership.msNo == selectedMembership?.msNo
                  ? Color(0xFF906FB7)
                  : backColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  membership.title!,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: membership.msNo == selectedMembership?.msNo
                          ? Colors.black
                          : Colors.black54),
                ),
                Text(
                  '${NumberFormat('#,###').format(membership.price)} 원',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: membership.msNo == selectedMembership?.msNo
                          ? Colors.black
                          : Colors.black54),
                ),
              ],
            ),
          ),
          Positioned(
            top: 35,
            left: -20,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(35)),
              ),
            ),
          ),
          Positioned(
            right: 65,
            top: 0,
            child: Container(
              width: 5,
              height: 140,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Positioned(
            right: 20,
            top: 0,
            child: Container(
              width: 40,
              height: 140,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          if (membership.msNo == selectedMembership?.msNo)
            Positioned(
              right: 20,
              top: 0,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.check),
              ),
            ),
        ],
      ),
    );
  }

  /// 하단 모달 팝업
  void _showBottomPopup(BuildContext context,
      {required String title,
      required String message,
      required IconData icon,
      required Color color}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 10),
              Text(title,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 5),
              Text(message, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("확인"),
              ),
            ],
          ),
        );
      },
    );
  }
}
