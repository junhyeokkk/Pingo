import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/data/models/community_model/dating_guide.dart';
import 'package:pingo_front/data/models/community_model/dating_guide_search.dart';
import 'package:pingo_front/data/view_models/community_view_model/dating_guide_view_model.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';
import 'package:pingo_front/ui/pages/community_page/components/dating_guide_view_page.dart';
import 'package:pingo_front/ui/pages/community_page/components/dating_guide_write_page.dart';
import 'package:pingo_front/ui/widgets/custom_image.dart';

class DatingGuidePage extends ConsumerStatefulWidget {
  const DatingGuidePage({super.key});

  @override
  ConsumerState<DatingGuidePage> createState() => _DatingGuidePageState();
}

class _DatingGuidePageState extends ConsumerState<DatingGuidePage> {
  late final String sessionUserNo;
  late final DatingGuideViewModel datingGuideViewModel;

  @override
  void initState() {
    super.initState();
    sessionUserNo = ref.read(sessionProvider).userNo!;
    datingGuideViewModel = ref.read(datingGuideViewModelProvider.notifier);
  }

  void changeSearchSort(String newSort, int category, String cateName) async {
    await datingGuideViewModel.changeSearchSort(newSort, category, cateName);

    setState(() {});
  }

  void moveToWritePage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DatingGuideWritePage(sessionUserNo),
      ),
    );

    // 게시글 작성 성공 시 스낵바 표시
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("게시글이 성공적으로 작성되었습니다."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void moveToViewPage(BuildContext context, datingGuide) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DatingGuideViewPage(datingGuide),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Map<String, DatingGuideSearch> dgsMap =
        ref.watch(datingGuideViewModelProvider);

    double cntWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...dgsMap.entries.map(
                (entry) {
                  return SizedBox(
                    height: 306,
                    child: guideGroup(cntWidth, entry.value),
                  );
                },
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Color(0xFF906FB7),
            onPressed: () => moveToWritePage(context),
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget guideGroup(double cntWidth, DatingGuideSearch guideGroup) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 16.0, bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guideGroup.category ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        changeSearchSort('popular', guideGroup.cateNo!,
                            guideGroup.category!);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: BorderDirectional(
                            bottom: BorderSide(
                              width: 2,
                              color: guideGroup.sort == 'popular'
                                  ? Color(0xFF906FB7)
                                  : Colors.white,
                            ),
                          ),
                        ),
                        child: Text(
                          '인기순',
                          style: TextStyle(
                              color: guideGroup.sort == 'popular'
                                  ? Color(0xFF906FB7)
                                  : Colors.black,
                              fontWeight: guideGroup.sort == 'popular'
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        changeSearchSort(
                            'newest', guideGroup.cateNo!, guideGroup.category!);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: BorderDirectional(
                            bottom: BorderSide(
                              width: 2,
                              color: guideGroup.sort == 'newest'
                                  ? Colors.redAccent
                                  : Colors.white,
                            ),
                          ),
                        ),
                        child: Text(
                          '최신순',
                          style: TextStyle(
                              color: guideGroup.sort == 'newest'
                                  ? Colors.redAccent
                                  : Colors.black,
                              fontWeight: guideGroup.sort == 'newest'
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: Text(guideGroup.cateDesc!,
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...List.generate(
                  guideGroup.datingGuideList!.length,
                  (index) {
                    return guideBox(
                        cntWidth, guideGroup.datingGuideList![index]);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget guideBox(double cntWidth, DatingGuide datingGuide) {
    return GestureDetector(
      onTap: () => moveToViewPage(context, datingGuide),
      child: Container(
        width: cntWidth * 6 / 10,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              width: cntWidth * 6 / 10,
              height: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: CustomImage().token(datingGuide.thumb ?? ''),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    datingGuide.title ?? '',
                    style: Theme.of(context).textTheme.headlineMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                  image: CustomImage()
                                      .provider(datingGuide.userProfile ?? ''),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(datingGuide.userName ?? '',
                              style: Theme.of(context).textTheme.headlineSmall),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.heart,
                            size: 20,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text('${datingGuide.heart}'),
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
