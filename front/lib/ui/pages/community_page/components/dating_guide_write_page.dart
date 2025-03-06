import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pingo_front/data/models/community_model/dating_guide.dart';
import 'package:pingo_front/data/view_models/community_view_model/dating_guide_view_model.dart';
import 'package:pingo_front/ui/widgets/common_appbar_line.dart';

class DatingGuideWritePage extends ConsumerStatefulWidget {
  String userNo;
  DatingGuideWritePage(this.userNo, {super.key});

  @override
  ConsumerState<DatingGuideWritePage> createState() =>
      _DatingGuideWritePageState();
}

class _DatingGuideWritePageState extends ConsumerState<DatingGuideWritePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentsController = TextEditingController();
  int selectedCate = 1;
  late Map<String, int> cateMap;
  File? _guideImage;
  late final String sessionUserNo;

  @override
  void initState() {
    super.initState();
    cateMap = datingGuideCate;
  }

  // picker 라이브러리를 이용한 이미지 파일 처리 함수
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _guideImage = File(pickedFile.path);
      });
    }
  }

  // 게시글 작성 전송 버튼
  void _submitGuide() async {
    if (_guideImage == null ||
        _titleController.text.trim().isEmpty ||
        _contentsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("모든 항목을 입력해주세요."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Map<String, dynamic> data = {
      'title': _titleController.text.trim(),
      'contents': _contentsController.text.trim(),
      'category': selectedCate,
      'userNo': widget.userNo,
    };

    DatingGuideViewModel dgViewModel =
        ref.read(datingGuideViewModelProvider.notifier);
    bool result = await dgViewModel.insertDatingGuide(data, _guideImage!);

    if (result) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("게시글 작성에 실패했습니다."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double cntWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            bottom: CommonAppbarLine(),
            title: Text(
              '데이팅 가이드 작성',
              style: TextStyle(fontSize: 16),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                FocusScope.of(context).unfocus(); // 키보드 닫기
                Navigator.of(context).pop(); // 뒤로 가기
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileBox(cntWidth),
                  const SizedBox(height: 24),
                  _textInputBox('제목', '제목을 입력하세요', _titleController,
                      isTitle: true),
                  const SizedBox(height: 24),
                  _categorySelectBox('카테고리'),
                  const SizedBox(height: 24),
                  _textInputBox('내용', '내용을 입력하세요', _contentsController),
                  SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom / 10),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _submitButton(),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBox(double cntWidth) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '게시글 이미지',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: _pickProfileImage,
              child: Container(
                width: double.infinity,
                height: cntWidth * 3 / 5,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _guideImage == null
                    ? Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colors.black38,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          _guideImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textInputBox(
      String title, String textHint, TextEditingController controller,
      {bool isTitle = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: isTitle ? 50 : 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: TextField(
            controller: controller,
            maxLines: isTitle ? 1 : null,
            expands: !isTitle,
            keyboardType:
                isTitle ? TextInputType.text : TextInputType.multiline,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: InputBorder.none,
              hintText: textHint,
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        )
      ],
    );
  }

  Widget _categorySelectBox(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...cateMap.entries.map(
              (entry) {
                return _categoryBtn(entry.key, entry.value);
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _categoryBtn(String cateName, int cateNo) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            selectedCate = cateNo;
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor:
              selectedCate == cateNo ? Color(0xFF906FB7) : Colors.white,
          side: BorderSide(
              color: selectedCate == cateNo ? Color(0xFF906FB7) : Colors.grey,
              width: 1),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          cateName,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: selectedCate == cateNo ? Colors.white : Colors.black,
              ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF906FB7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        onPressed: () => _submitGuide(),
        child: Text(
          '작성 완료',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
