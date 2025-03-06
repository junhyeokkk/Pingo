import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';
import 'package:pingo_front/ui/pages/main_page/SettingsPage.dart';

AppBar CommonAppBar(context, WidgetRef ref) {
  return AppBar(
    title: Row(
      children: [
        Image.asset('assets/images/pingo1.png', width: 40),
        Text(
          'Pingo',
          style: TextStyle(fontSize: 30, color: Colors.black),
        ),
      ],
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () {
            ref.read(sessionProvider.notifier).logout();
          },
          icon: Icon(Icons.logout),
        ),
      ),
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
