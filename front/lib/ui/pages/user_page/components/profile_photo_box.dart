import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pingo_front/data/models/user_model/user_image.dart';
import 'package:pingo_front/data/models/user_model/user_mypage_info.dart';
import 'package:pingo_front/data/view_models/user_view_model/user_view_model.dart';
import 'package:pingo_front/ui/widgets/custom_image.dart';

class ProfilePhotoBox extends ConsumerStatefulWidget {
  final UserMypageInfo userMypageInfo;
  final UserViewModel userViewModelNotifier;

  const ProfilePhotoBox(this.userMypageInfo, this.userViewModelNotifier,
      {super.key});

  @override
  ConsumerState<ProfilePhotoBox> createState() => _ProfilePhotoBoxState();
}

class _ProfilePhotoBoxState extends ConsumerState<ProfilePhotoBox> {
  File? _profileImage;

  // picker 라이브러리를 이용한 이미지 파일 처리 함수
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      widget.userViewModelNotifier
          .uploadUserImage(context, File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    List<UserImage> images = widget.userMypageInfo.userImageList ?? [];

    // 대표 이미지와 일반 이미지 분리
    UserImage? mainImage;
    List<UserImage> subImages = [];

    for (var image in images) {
      if (image.imageProfile == 'T') {
        mainImage = image;
      } else {
        subImages.add(image);
      }
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Wrap(
          spacing: 4.0,
          runSpacing: 4.0,
          children: [
            _buildMainImage(totalWidth, mainImage),
            for (int i = 0; i < 5; i++)
              _buildSubImage(context, i,
                  i < subImages.length ? subImages[i] : null, totalWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildMainImage(double totalWidth, UserImage? userImage) {
    return Stack(
      children: [
        Container(
          width: totalWidth / 3 - 6,
          height: (totalWidth / 3 - 6) / 3 * 4,
          decoration: BoxDecoration(color: Colors.grey[300]),
          child: userImage != null
              ? ClipRRect(
                  child: CustomImage().token(userImage!.imageUrl!),
                )
              : Center(
                  child: Icon(Icons.person, size: 50, color: Colors.grey),
                ),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: Container(
            width: 24,
            height: 24,
            child: Center(
              child: Icon(
                Icons.star_rounded,
                color: Colors.yellow,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 8,
                    color: Colors.black87,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubImage(BuildContext context, int index, UserImage? userImage,
      double totalWidth) {
    return Stack(
      children: [
        Container(
          width: totalWidth / 3 - 6,
          height: (totalWidth / 3 - 6) / 3 * 4,
          decoration: BoxDecoration(color: Colors.grey[300]),
          child: userImage != null
              ? ClipRRect(
                  child: CustomImage().token(userImage!.imageUrl!),
                )
              : Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        _pickProfileImage();
                      },
                    ),
                  ),
                ),
        ),
        if (userImage != null)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 24,
              height: 24,
              child: Center(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    CupertinoIcons.ellipsis,
                    size: 20,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 8,
                        color: Colors.black87,
                      )
                    ],
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  if (userImage != null) {
                                    final userViewModel = ref
                                        .read(userViewModelProvider.notifier);

                                    String? currentMainImageNo =
                                        widget.userMypageInfo.userImageList
                                            ?.firstWhere(
                                              (img) => img.imageProfile == 'T',
                                              orElse: () => UserImage(),
                                            )
                                            .imageNo;

                                    String? newMainImageNo = userImage.imageNo;

                                    if (currentMainImageNo != null &&
                                        newMainImageNo != null) {
                                      await userViewModel.setMainImage(
                                          currentMainImageNo,
                                          newMainImageNo,
                                          context);
                                    }
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: Text('대표이미지로 지정'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (userImage != null) {
                                    final userViewModel = ref
                                        .read(userViewModelProvider.notifier);

                                    String? ImageNoForDelete =
                                        userImage.imageNo;

                                    if (ImageNoForDelete != null) {
                                      await userViewModel.deleteUserImage(
                                        context,
                                        ImageNoForDelete,
                                      );
                                    }
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: Text('삭제'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
