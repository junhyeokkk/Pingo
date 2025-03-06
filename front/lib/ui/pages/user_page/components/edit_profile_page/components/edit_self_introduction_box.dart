import 'package:flutter/material.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/user_model/user_mypage_info.dart';

class EditSelfIntroductionBox extends StatefulWidget {
  final UserMypageInfo copyUserInfo; // 객체를 직접 받도록 수정

  const EditSelfIntroductionBox(this.copyUserInfo, {super.key});

  @override
  _EditSelfIntroductionBoxState createState() =>
      _EditSelfIntroductionBoxState();
}

class _EditSelfIntroductionBoxState extends State<EditSelfIntroductionBox> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.copyUserInfo.userIntroduction ?? '');

    // 변경 감지를 위한 리스너 추가
    _controller.addListener(() {
      widget.copyUserInfo.userIntroduction = _controller.text;
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.i('자기소개: ${widget.copyUserInfo.userIntroduction}');

    return Card(
      elevation: 0.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            Text(
              '자기소개',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4.0),
            TextSelectionTheme(
              data: TextSelectionThemeData(
                cursorColor: Color(0xFF906FB7), // 커서 색상 변경
                selectionColor: Color(0xFF906FB7).withOpacity(0.4), // 선택된 영역 색상
                selectionHandleColor:
                    Color(0xFF906FB7), // 선택 핸들러 색상 (커서 아래 둥근 점)
              ),
              child: TextField(
                controller: _controller,
                maxLines: 5,
                maxLength: 1000,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xFF906FB7), // 커서 색상
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF906FB7)), // 포커스 시 테두리 색상 변경
                  ),
                  hintText: '자기소개를 입력하세요',
                  contentPadding: EdgeInsets.all(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
