import 'package:flutter/material.dart';
import 'package:pingo_front/ui/widgets/common_appbar_line.dart';

AppBar communityAppbar(context) {
  return AppBar(
    bottom: CommonAppbarLine(),
    scrolledUnderElevation: 0,
    title: Row(
      children: [
        Text(
          '커뮤니티',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ],
    ),
    backgroundColor: Colors.white,
  );
}
