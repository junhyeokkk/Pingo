import 'package:flutter/material.dart';
import 'package:pingo_front/data/models/keyword_model/keyword.dart';

// step7 가입하는 회원의 이상형 성향 키워드 선택
class UserFavoriteKeywordStep extends StatefulWidget {
  final Function nextStep;
  final dynamic userData;
  final dynamic signupNotifier;

  const UserFavoriteKeywordStep(
      this.nextStep, this.userData, this.signupNotifier,
      {super.key});

  @override
  State<UserFavoriteKeywordStep> createState() =>
      _UserFavoriteKeywordStepState();
}

class _UserFavoriteKeywordStepState extends State<UserFavoriteKeywordStep> {
  late Future<List<Keyword>> keywordFuture;
  List<String> selectedKeywordIds = [];

  @override
  void initState() {
    super.initState();
    keywordFuture = widget.signupNotifier.fetch3ndKeyword();
  }

  // 선택한 키워드 검증 함수
  void checkValidation() async {
    if (selectedKeywordIds.length != 10) {
      return;
    }
    int result = await widget.signupNotifier
        .validationFavoriteKeywordInfo(selectedKeywordIds);

    if (result == 1) {
      setState(() {
        widget.nextStep();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '당신의 이상형을 알려주세요!',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '키워드를 선택하세요 (최대 10개)',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: FutureBuilder<List<Keyword>>(
              future: keywordFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // 로딩 중
                } else if (snapshot.hasError) {
                  return Text("데이터를 불러오는 중 오류 발생: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("키워드 데이터가 없습니다.");
                }

                List<Keyword> keywords = snapshot.data!;

                return SingleChildScrollView(
                  child: _buildSelectionBox(keywords),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "선택한 키워드: ${selectedKeywordIds.length} / 10",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF906FB7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              onPressed: selectedKeywordIds.length == 10
                  ? () => checkValidation()
                  : null,
              child: Text(
                '다음',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 성향 키워드 선택 박스 위젯 (부모)
  Widget _buildSelectionBox(List<Keyword> keywords) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.start,
      children: keywords.map((keyword) {
        bool isSelected = selectedKeywordIds.contains(keyword.kwId);

        // 각각의 성향 키워드 위젯 (자식)
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedKeywordIds.remove(keyword.kwId);
              } else {
                if (selectedKeywordIds.length < 10) {
                  selectedKeywordIds.add(keyword.kwId!);
                }
              }
            });
          },
          child: IntrinsicWidth(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(
                    color: isSelected ? Color(0xFF906FB7) : Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
                color: isSelected ? Color(0xFF906FB7) : Colors.white,
              ),
              alignment: Alignment.center,
              child: Text(
                keyword.kwName!,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
