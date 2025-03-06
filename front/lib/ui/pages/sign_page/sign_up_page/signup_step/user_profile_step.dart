import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// step4 회원 프로필 사진 업로드
class UserProfileStep extends StatefulWidget {
  final Function nextStep;
  final dynamic userData;
  final dynamic signupNotifier;

  const UserProfileStep(this.nextStep, this.userData, this.signupNotifier,
      {super.key});

  @override
  State<UserProfileStep> createState() => _UserProfileStepState();
}

class _UserProfileStepState extends State<UserProfileStep> {
  File? _profileImage;

  // picker 라이브러리를 이용한 이미지 파일 처리 함수
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // 이미지 검증 함수
  void checkValidation() {
    if (_profileImage != null) {
      int result = widget.signupNotifier.validationProfile(_profileImage);

      if (result == 1) {
        widget.nextStep();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '프로필 사진을 등록해주세요!',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          _buildProfileBox(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _profileImage == null ? Colors.grey : Color(0xFF906FB7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              onPressed: _profileImage == null ? null : checkValidation,
              child: Text(
                '다음',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 프로필 사진 업로드 위젯
  Widget _buildProfileBox() {
    return GestureDetector(
      onTap: _pickProfileImage,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _profileImage == null
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
                  _profileImage!,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}
