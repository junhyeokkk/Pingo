import 'package:flutter/material.dart';

import '../../../../data/models/user_model/mypage_menu.dart';

class MypageBox extends StatelessWidget {
  final List<MypageMenu> myPageMenuList;

  MypageBox({required this.myPageMenuList});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(
            myPageMenuList.length,
            (index) => _buildRowIconItem(
              myPageMenuList[index].title,
              myPageMenuList[index].iconData,
              context,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowIconItem(String title, IconData iconData, context) {
    return Container(
      height: 50,
      child: Row(
        children: [
          Icon(iconData, size: 17),
          const SizedBox(width: 20),
          Text(title, style: Theme.of(context).textTheme.headlineMedium)
        ], // :TODO 04수정
      ),
    );
  }
}
