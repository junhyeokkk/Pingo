import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/setting_model/AppSettings.dart';
import 'package:pingo_front/data/view_models/main_view_model/main_page_viewmodel.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';
import 'package:pingo_front/ui/widgets/appbar/main_appbar.dart';
import 'components/ProfileCard.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage>
    with SingleTickerProviderStateMixin {
  late MainPageViewModel viewModel;

  // 멤버 로드
  @override
  void initState() {
    super.initState();
    _initializeSettings(); // 비동기 함수 호출
  }

  Future<void> _initializeSettings() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = ref.read(mainPageViewModelProvider.notifier);
      final sessionUser = ref.read(sessionProvider);
      final userId = sessionUser?.userNo ?? "guest"; // 유저 ID가 없으면 "guest" 사용
      final settings = ref.read(settingsProvider(userId));

      // AnimationController 설정
      if (!viewModel.isAnimationControllerSet) {
        viewModel.attachAnimationController(AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
          lowerBound: -1.5,
          upperBound: 1.5,
        ));
      }

      // sessionUser.userNo가 존재하면 설정된 최대 거리 값으로 유저 데이터 로드
      if (sessionUser.userNo != null) {
        viewModel.loadNearbyUsers(sessionUser.userNo!, settings.maxDistance);
        logger.i(
            "loadNearbyUsers 실행됨: userNo=${sessionUser.userNo}, maxDistance=${settings.maxDistance} km");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionUser = ref.watch(sessionProvider);
    final viewModel = ref.watch(mainPageViewModelProvider.notifier);
    final userList = ref.watch(mainPageViewModelProvider);
    final size = MediaQuery.of(context).size;
    final userId = sessionUser?.userNo ?? "guest";
    final settings = ref.watch(settingsProvider(userId));

    // maxDistance가 변경될 때 유저 목록 자동 갱신
    ref.listen(settingsProvider(userId), (previous, next) {
      if (previous?.maxDistance != next.maxDistance) {
        if (sessionUser.userNo != null) {
          viewModel.loadNearbyUsers(sessionUser.userNo!, next.maxDistance);
          logger.i("유저 목록 갱신됨: maxDistance=${next.maxDistance} km");
        }
      }
    });

    logger.i("[메인페이지] 현재 userList 길이: ${userList.length}");

    return Scaffold(
      appBar: mainAppbar(context),
      backgroundColor: Colors.white,
      body: userList.isEmpty
          ? Center(child: CircularProgressIndicator()) // 로딩 표시 추가
          : GestureDetector(
              onPanUpdate: viewModel.onPanUpdate,
              onPanEnd: (_) =>
                  viewModel.onPanEnd(size, sessionUser?.userNo ?? ''),
              child: AnimatedBuilder(
                animation: viewModel.animationController,
                builder: (context, child) {
                  final offset = Offset(
                    viewModel.animationController.value * size.width,
                    viewModel.posY * size.height,
                  );

                  return Stack(
                    children: [
                      if (viewModel.noMoreUsers)
                        Center(
                          child: Text(
                            "주변에 유저가 없습니다",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        )
                      else if (userList.isNotEmpty) ...[
                        if (userList.length > 1)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: ProfileCard(
                                profile: userList[
                                    (viewModel.currentProfileIndex + 1) %
                                        userList.length],
                              ),
                            ),
                          ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Transform.translate(
                                offset: offset,
                                child: Stack(
                                  children: [
                                    ProfileCard(
                                        profile: userList[
                                            viewModel.currentProfileIndex]),
                                    _buildSwipeStamp(viewModel),
                                  ],
                                )),
                          ),
                        ),
                      ]
                    ],
                  );
                },
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(sessionUser?.userNo ?? ''),
    );
  }

  // PING/PANG/SUPERPING 도장 표시 위젯
  Widget _buildSwipeStamp(MainPageViewModel viewModel) {
    if (viewModel.stampText == null) return SizedBox();

    // 기본 위치 설정
    double stampTop = 100; // 기본 위치
    double? stampLeft; // 왼쪽 정렬용
    double? stampRight; // 오른쪽 정렬용

    // 위치 조정 로직
    if (viewModel.stampText == "SUPERPING!") {
      stampTop += 350; // SUPERPING!을 아래로 이동
      stampLeft = 100;
    } else if (viewModel.stampText == "PANG!") {
      stampLeft = 0; //
    } else if (viewModel.stampText == "PING!") {
      stampRight = 0; //
    }

    return Positioned(
      top: stampTop, // 스탬프 마다 위치 다르게 반영
      left: stampLeft,
      right: stampRight,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: 1.0,
        child: Transform.rotate(
          angle: viewModel.rotation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: viewModel.stampColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              viewModel.stampText!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(String userNo) {
    final viewModel = ref.watch(mainPageViewModelProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // _buildSwipeButton(Icons.replay, Colors.grey, -1, viewModel.undoSwipe),
          _buildSwipeButton(
              Icons.close,
              Colors.pink,
              0,
              () => viewModel.animateAndSwitchCard(-1.5, userNo,
                  direction: 'PANG')),
          _buildSwipeButton(
              Icons.star,
              Colors.blue,
              2,
              () => viewModel.animateAndSwitchCard(0, userNo,
                  direction: 'SUPERPING')),
          _buildSwipeButton(
              Icons.favorite,
              Colors.green,
              1,
              () => viewModel.animateAndSwitchCard(1.5, userNo,
                  direction: 'PING')),
        ],
      ),
    );
  }

  Widget _buildSwipeButton(
      IconData icon, Color color, int index, VoidCallback onTap) {
    final viewModel = ref.watch(mainPageViewModelProvider.notifier);
    final isHighlighted = viewModel.highlightedButton == index;

    return GestureDetector(
      onTap: () {
        viewModel.setHighlightedButton(index);
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: isHighlighted ? 80 : 60,
        height: isHighlighted ? 80 : 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: isHighlighted
              ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 20)]
              : [],
        ),
        child: Icon(icon, color: Colors.white, size: 35),
      ),
    );
  }
}
