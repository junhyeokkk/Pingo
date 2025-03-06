import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pingo_front/data/models/community_model/dating_guide.dart';
import 'package:pingo_front/data/view_models/community_view_model/dating_guide_view_model.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';
import 'package:pingo_front/ui/widgets/custom_image.dart';

class DatingGuideViewPage extends ConsumerStatefulWidget {
  final DatingGuide datingGuide;
  const DatingGuideViewPage(this.datingGuide, {super.key});

  @override
  ConsumerState<DatingGuideViewPage> createState() =>
      _DatingGuideViewPageState();
}

class _DatingGuideViewPageState extends ConsumerState<DatingGuideViewPage> {
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0; // 앱바 배경 투명도

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _clickThumbUp() async {
    String? userNo = ref.read(sessionProvider).userNo;
    String result = await ref
        .read(datingGuideViewModelProvider.notifier)
        .clickThumbUp(userNo!, widget.datingGuide.dgNo!);

    if (result == 'increase') {
      ref
          .read(datingGuideViewModelProvider)[widget.datingGuide.category]
          ?.changeDatingGuideHeart(widget.datingGuide.dgNo!, 1);
    } else {
      ref
          .read(datingGuideViewModelProvider)[widget.datingGuide.category]
          ?.changeDatingGuideHeart(widget.datingGuide.dgNo!, -1);
    }
    setState(() {});
  }

  void _scrollListener() {
    double offset = _scrollController.offset;
    double newOpacity = (offset / 200).clamp(0.0, 1.0); // 200px 스크롤 시 완전 불투명

    setState(() {
      _appBarOpacity = newOpacity;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _guideImageBox(),
                _guideContentsBox(),
              ],
            ),
          ),
          // 앱바
          _guideCustomAppbar(),
        ],
      ),
    );
  }

  Widget _guideImageBox() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 400,
          child: CustomImage().token(widget.datingGuide.thumb!),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomImage().token(widget.datingGuide.userProfile!),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.datingGuide.userName!,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _guideContentsBox() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.datingGuide.category!,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            widget.datingGuide.title!,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  _clickThumbUp();
                },
                child: Icon(Icons.thumb_up_outlined,
                    color: Colors.redAccent, size: 14),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.datingGuide.heart!}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 12),
              Text(
                DateFormat('yy-MM-dd HH:mm')
                    .format(widget.datingGuide.regDate!),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black54),
              ),
            ],
          ),
          Divider(color: Colors.grey, thickness: 1),
          Text(
            widget.datingGuide.contents!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _guideCustomAppbar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        padding: EdgeInsets.only(left: 16, right: 16, top: 30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_appBarOpacity),
          boxShadow: _appBarOpacity > 0.1
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                FocusScope.of(context).unfocus();
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
