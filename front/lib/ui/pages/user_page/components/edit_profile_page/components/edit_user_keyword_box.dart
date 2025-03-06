import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/data/models/keyword_model/keyword.dart';
import 'package:pingo_front/ui/pages/user_page/components/edit_profile_page/components/select_user_keyword_box.dart';

class EditUserKeywordBox extends ConsumerStatefulWidget {
  final List<Keyword> myKeywordList;
  final List<Keyword> favoriteKeywordList;
  const EditUserKeywordBox(this.myKeywordList, this.favoriteKeywordList,
      {super.key});

  @override
  ConsumerState<EditUserKeywordBox> createState() => _EditUserKeywordBoxState();
}

class _EditUserKeywordBoxState extends ConsumerState<EditUserKeywordBox> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '키워드',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 2),
            _buildInformationBox(context, '나의 키워드', widget.myKeywordList),
            _buildInformationBox(
                context, '원하는 키워드', widget.favoriteKeywordList),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationBox(
      BuildContext context, String title, List<Keyword> keywordList) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.black54,
                    ),
              ),
              InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectUserKeywordBox(keywordList),
                    ),
                  );
                  setState(() {});
                },
                child: Text(
                  '수정',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _keywordBox(keywordList),
        ],
      ),
    );
  }

  Widget _keywordBox(List<Keyword> keywordList) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(
        keywordList.length,
        (index) => _keywordBtn(keywordList[index]),
      ),
    );
  }

  Widget _keywordBtn(Keyword keyword) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12, width: 1),
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child:
          Text(keyword.kwName!, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
