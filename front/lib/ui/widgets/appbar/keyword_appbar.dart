import 'package:flutter/material.dart';
import 'package:pingo_front/ui/pages/main_page/SettingsPage.dart';
import 'package:pingo_front/ui/widgets/common_appbar_line.dart';

AppBar keywordAppbar(context) {
  return AppBar(
    bottom: CommonAppbarLine(),
    scrolledUnderElevation: 0,
    title: Row(
      children: [
        Text(
          '키워드',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ],
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
          icon: Icon(Icons.settings),
        ),
      ),
    ],
    backgroundColor: Colors.white,
  );
}
