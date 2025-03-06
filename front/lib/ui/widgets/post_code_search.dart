import 'package:flutter/material.dart';
import 'package:daum_postcode_search/daum_postcode_search.dart';
import 'package:daum_postcode_search/data_model.dart';

class PostCodeSearchScreen extends StatefulWidget {
  final void Function(DataModel)? onSelected; // 선택된 주소를 전달할 콜백

  const PostCodeSearchScreen({Key? key, this.onSelected}) : super(key: key);

  @override
  _PostCodeSearchScreenState createState() => _PostCodeSearchScreenState();
}

class _PostCodeSearchScreenState extends State<PostCodeSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("주소 검색")),
      body: DaumPostcodeSearch(),
    );
  }
}
