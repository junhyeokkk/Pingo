import 'package:flutter/material.dart';
import 'package:pingo_front/data/models/main_model/Profile.dart';
import 'package:pingo_front/ui/pages/main_page/ProfileDetailPage.dart';
import 'package:pingo_front/ui/widgets/custom_image.dart';

class ProfileCard extends StatefulWidget {
  final Profile profile;

  const ProfileCard({required this.profile, Key? key}) : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  int currentImageIndex = 0; // 현재 표시 중인 이미지 인덱스
  bool isDetailVisible = false; // 상세 정보 표시 여부

  void _showNextImage() {
    setState(() {
      currentImageIndex =
          (currentImageIndex + 1) % widget.profile.ImageList.length;
    });
  }

  void _showPreviousImage() {
    setState(() {
      currentImageIndex =
          (currentImageIndex - 1) % widget.profile.ImageList.length;
      if (currentImageIndex < 0) {
        currentImageIndex = widget.profile.ImageList.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        // 프로필 이미지 (좌우 터치로 넘기기)
        GestureDetector(
          onTapUp: (TapUpDetails details) {
            final tapPosition = details.globalPosition.dx;
            final screenWidth = size.width;

            if (tapPosition < screenWidth / 2) {
              _showPreviousImage(); //  왼쪽 탭 → 이전 이미지
            } else {
              _showNextImage(); // 오른쪽 탭 → 다음 이미지
            }
          },
          child: Material(
            elevation: 10,
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomImage()
                      .token(widget.profile.ImageList[currentImageIndex]),
                ),

                // 하단 반투명 → 검정색 그라디언트 효과 추가
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                          Colors.black,
                        ],
                        stops: [0.6, 0.75, 0.9, 1.0],
                      ),
                    ),
                  ),
                ),

                // 이미지 인디케이터 (현재 사진 위치)
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        List.generate(widget.profile.ImageList.length, (index) {
                      return Container(
                        width: 20,
                        height: 5,
                        margin: EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: currentImageIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    }),
                  ),
                ),

                // 프로필 정보 (하단)
                Positioned(
                  bottom: 40,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '접속 중',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${widget.profile.name}, ${widget.profile.age}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.white70, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '3.85km',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 상세 보기 버튼
                Positioned(
                  bottom: 50,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration:
                              Duration(milliseconds: 500), // 애니메이션 속도
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ProfileDetailPage(
                                      profile: widget.profile,
                                      isFromMainPage: true),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var begin = Offset(0.0, 1.0); // 아래에서 올라오는 효과
                            var end = Offset.zero;
                            var curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var fadeTween =
                                Tween(begin: 0.0, end: 1.0); // 페이드 효과 추가

                            return FadeTransition(
                              opacity: animation.drive(fadeTween),
                              child: SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300), // 부드러운 애니메이션 효과
                      curve: Curves.easeOut,
                      child: ScaleTransition(
                        scale: AlwaysStoppedAnimation(1.1), // 버튼 클릭 시 살짝 커지는 효과
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 22, // 기존보다 살짝 키움
                          child: Icon(Icons.keyboard_arrow_up,
                              color: Colors.black, size: 28), // 아이콘 크기 조정
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
