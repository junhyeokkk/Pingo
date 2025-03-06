import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/data/models/keyword_model/keyword.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signup_view_model.dart';

class SelectUserKeywordBox extends ConsumerStatefulWidget {
  final List<Keyword> selectedKeyword;
  const SelectUserKeywordBox(this.selectedKeyword, {super.key});

  @override
  ConsumerState<SelectUserKeywordBox> createState() =>
      _SelectUserKeywordBoxState();
}

class _SelectUserKeywordBoxState extends ConsumerState<SelectUserKeywordBox> {
  late Future<List<Keyword>> keywordFuture;

  @override
  void initState() {
    super.initState();
    selectKeywordList();
  }

  void selectKeywordList() {
    keywordFuture =
        ref.read(signupViewModelProvider.notifier).fetch3ndKeyword();
  }

  void _clickKeywordBtn(Keyword keyword, bool isSelected) {
    if (isSelected) {
      widget.selectedKeyword.removeWhere((each) {
        return each.kwId == keyword.kwId;
      });
    } else {
      if (widget.selectedKeyword.length >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('최대 10개의 키워드만 선택할 수 있습니다!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        widget.selectedKeyword.add(keyword);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('키워드 선택'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Keyword>>(
            future: keywordFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('에러 발생: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('데이터가 없습니다.'));
              }

              final keywords = snapshot.data!;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  keywords.length,
                  (index) => _keywordBtn(keywords[index]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _keywordBtn(Keyword keyword) {
    bool isSelected =
        widget.selectedKeyword.any((each) => each.kwId == keyword.kwId);

    return InkWell(
      onTap: () {
        _clickKeywordBtn(keyword, isSelected);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? Color(0xFF906FB7) : Colors.black12, width: 1),
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
          color: isSelected ? Color(0xFF906FB7) : Colors.white,
        ),
        child: Text(
          keyword.kwName!,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isSelected ? Colors.white : Colors.black,
              ),
        ),
      ),
    );
  }
}
