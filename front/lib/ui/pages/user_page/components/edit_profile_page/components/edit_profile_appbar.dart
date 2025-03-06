import 'package:flutter/material.dart';
import '../../../../../widgets/common_appbar_line.dart';

AppBar EditProfileAppBar(context) {
  return AppBar(
    bottom: CommonAppbarLine(),
    backgroundColor: Colors.white,
    scrolledUnderElevation: 0,
    title: Text(
      '프로필 수정',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    ),
    centerTitle: true,
  );
}
