import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/community_model/kakao_search.dart';
import 'package:pingo_front/data/models/community_model/place_review.dart';
import 'package:pingo_front/data/view_models/community_view_model/place_review_search_view_model.dart';
import 'package:path_provider/path_provider.dart';

class PlaceWritePage extends StatefulWidget {
  String userNo;
  PlaceReviewSearchViewModel kakaoSearchProvider;
  PlaceWritePage(this.kakaoSearchProvider, this.userNo, {super.key});

  @override
  State<PlaceWritePage> createState() => _PlaceWritePageState();
}

class _PlaceWritePageState extends State<PlaceWritePage> {
  late KakaoSearch kakaoSearch;
  final TextEditingController _textController = TextEditingController();
  File? _placeImage;
  bool _isLoading = true; // 서버 이미지 로딩 여부

  @override
  void initState() {
    super.initState();
    kakaoSearch = widget.kakaoSearchProvider.lastSearch;

    if (kakaoSearch.placeUrl != null) {
      _fetchServerImage(kakaoSearch.placeUrl!);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 📝 서버에서 Base64 이미지 받아와 File로 변환하는 함수
  Future<void> _fetchServerImage(String url) async {
    try {
      String? base64Image =
          await widget.kakaoSearchProvider.crawlingPlaceImage(url);
      if (base64Image != null) {
        Uint8List bytes = base64Decode(base64Image);
        File file = await _saveImageToFile(bytes);

        setState(() {
          _placeImage = file; // 서버에서 받은 이미지를 File로 저장
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('서버 이미지 가져오기 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 📝 Uint8List 데이터를 파일로 변환하는 함수
  Future<File> _saveImageToFile(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/place_image.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  // picker 라이브러리를 이용한 이미지 파일 처리 함수
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _placeImage = File(pickedFile.path);
      });
    }
  }

  // 유효성 검증 후 게시글 작성
  void checkValidation() async {
    if (_placeImage == null || _textController.text.trim() == '') {
      logger.e('이미지와 한줄평을 등록하세요');
      return;
    }

    PlaceReview placeReview = PlaceReview(
      null,
      kakaoSearch.placeName,
      null,
      kakaoSearch.addressName,
      kakaoSearch.roadAddressName,
      widget.userNo,
      _textController.text.trim(),
      kakaoSearch.category,
      kakaoSearch.latitude,
      kakaoSearch.longitude,
      0,
      null,
      null,
    );

    Map<String, dynamic> data = {
      'placeReview': placeReview,
      'placeImage': _placeImage,
    };

    bool result = await widget.kakaoSearchProvider.insertPlaceReview(data);

    if (result) {
      FocusScope.of(context).unfocus();
      Navigator.pop(
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double cntWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("추천 장소 등록"),
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
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Text(
                  '다른 사용자를 위해 장소를 추천해보세요!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                _buildProfileBox(cntWidth),
                const SizedBox(height: 8),
                Text('클릭하여 이미지를 변경할 수 있습니다.'),
                const SizedBox(height: 32),
                Text(
                  kakaoSearch.placeName ?? '이름 없음',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                Text(
                  kakaoSearch.addressName ?? '주소 없음',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '한 줄평 작성',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _placeImage == null ||
                              _textController.text.trim() == ''
                          ? Colors.grey
                          : Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    onPressed: () => checkValidation(),
                    child: Text(
                      '작성',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom / 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBox(double cntWidth) {
    return GestureDetector(
      onTap: _pickProfileImage,
      child: Container(
        width: double.infinity,
        height: cntWidth * 2 / 3,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(), // 로딩 표시
              )
            : (_placeImage == null
                ? Center(
                    child: Icon(
                      Icons.add_a_photo,
                      size: 50,
                      color: Colors.black38,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      _placeImage!,
                      fit: BoxFit.cover,
                    ),
                  )),
      ),
    );
  }
}
