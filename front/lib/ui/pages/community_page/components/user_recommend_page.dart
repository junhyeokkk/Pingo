import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRecommendPage extends ConsumerStatefulWidget {
  const UserRecommendPage({super.key});

  @override
  ConsumerState<UserRecommendPage> createState() => _UserRecommendPageState();
}

class _UserRecommendPageState extends ConsumerState<UserRecommendPage>
    with AutomaticKeepAliveClientMixin<UserRecommendPage> {
  @override
  bool get wantKeepAlive => true;

  //
  List<List<String>> example = [
    ['bb0001.jpg', 'bb0002.jpg', 'bb0003.jpg'],
    ['bb0004.jpg', 'bb0005.jpg', 'bb0006.jpg'],
    ['bb0007.jpg', 'bb0008.jpg', 'bb0009.jpg'],
    ['bb0010.jpg', 'bb0011.jpg', 'bb0012.jpg'],
    ['bb0001.jpg', 'bb0002.jpg', 'bb0003.jpg'],
    ['bb0004.jpg', 'bb0005.jpg', 'bb0006.jpg'],
    ['bb0007.jpg', 'bb0008.jpg', 'bb0009.jpg'],
    ['bb0010.jpg', 'bb0011.jpg', 'bb0012.jpg'],
  ];
  //

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: example.length,
            itemBuilder: (context, index) {
              if (index % 4 == 0) {
                return mixingRightRow(example[index]);
              } else if (index % 4 == 2) {
                return mixingLeftRow(example[index]);
              } else if (index % 4 == 1 || index % 4 == 3) {
                return normalRow(example[index]);
              }
            },
          )
        ],
      ),
    );
  }

  Widget normalRow(List<String> dataList) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenWidth / 3,
      child: Row(
        children: [
          ...List.generate(
            dataList.length,
            (index) => normalBox(dataList[index]),
          )
        ],
      ),
    );
  }

  Widget mixingRightRow(List<String> dataList) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: (screenWidth * 2) / 3,
      child: Row(
        children: [
          Column(
            children: [
              normalBox(dataList[0]),
              normalBox(dataList[1]),
            ],
          ),
          bigBox(dataList[2]),
        ],
      ),
    );
  }

  Widget mixingLeftRow(List<String> dataList) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: (screenWidth * 2) / 3,
      child: Row(
        children: [
          bigBox(dataList[2]),
          Column(
            children: [
              normalBox(dataList[0]),
              normalBox(dataList[1]),
            ],
          ),
        ],
      ),
    );
  }

  Widget normalBox(String data) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(1),
      width: screenWidth / 3,
      height: screenWidth / 3,
      child: Image.asset(
        'assets/images/sample/$data',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget bigBox(String data) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(1),
      width: (screenWidth * 2) / 3,
      height: (screenWidth * 2) / 3,
      child: Image.asset(
        'assets/images/sample/$data',
        fit: BoxFit.cover,
      ),
    );
  }
}
