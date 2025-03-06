import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/keyword_model/keyword.dart';
import 'package:pingo_front/data/models/main_model/ProfileDetail.dart';
import 'package:pingo_front/data/models/user_model/user_info.dart';
import 'package:pingo_front/data/models/user_model/user_mypage_info.dart';
import 'package:pingo_front/data/models/user_model/users.dart';
import 'package:pingo_front/data/repository/user_repository/user_repository.dart';

class UserViewModel extends Notifier<UserMypageInfo> {
  final UserRepository _repository;
  UserViewModel(this._repository);

  // 인증코드 세션
  String? sessionId;

  // 유저 비밀번호 재설정용 userNo 저장
  String? resetUserNo;

  @override
  UserMypageInfo build() {
    return UserMypageInfo();
  }

  Future<void> fetchMyPageInfo(String userNo) async {
    try {
      final userInfo = await _repository.fetchMyPageInfo(userNo);

      logger.i(userInfo);
      state = userInfo;
    } catch (e) {
      logger.e('Failed to fetch user info: $e');
    }
  }

  // 이메일 업데이트 기능 추가 (copyWith 사용)
  void updateUserEmail(String newEmail) {
    if (state.users != null) {
      state = state.copyWith(
        UserMypageInfo(
          users: state.users!.copyWith(userEmail: newEmail),
        ),
      );
      logger.d("이메일 변경됨: ${state.users!.userEmail}");
    }
  }

  // 유저 정보 수정
  Future<void> submitUpdateInfo(UserMypageInfo updateInfo) async {
    try {
      bool isSuccess =
          await _repository.fetchSubmitUpdateInfo(updateInfo.toJson());

      if (isSuccess) {
        await fetchMyPageInfo(updateInfo.users!.userNo!);
        logger.i("유저 정보 수정 성공");
      }
    } catch (e) {
      logger.e("submitUpdateInfo에서 오류 발생: $e");
    }
  }

  // 대표 이미지 변경 기능 추가
  Future<void> setMainImage(String currentMainImageNo, String newMainImageNo,
      BuildContext context) async {
    try {
      bool success = await _repository.updateMainProfileImage(
          currentMainImageNo, newMainImageNo);

      if (success) {
        // 상태 업데이트
        state = UserMypageInfo(
          users: state.users,
          userInfo: state.userInfo,
          userImageList: state.userImageList?.map((userImage) {
            if (userImage.imageNo == currentMainImageNo) {
              return userImage.copyWith(imageProfile: 'F'); // 기존 대표 이미지 해제
            } else if (userImage.imageNo == newMainImageNo) {
              return userImage.copyWith(imageProfile: 'T'); // 새 대표 이미지 설정
            }
            return userImage;
          }).toList(),
        );

        // 대표 이미지 변경 성공 알림
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "대표 이미지가 변경되었습니다.",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // 대표 이미지 변경 실패 알림
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("대표 이미지 변경에 실패했습니다. 다시 시도해주세요."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        logger.e("대표 이미지 변경 실패: 서버에서 false 응답");
      }
    } catch (e) {
      // 네트워크 오류 또는 예외 발생 시 알림 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("네트워크 오류가 발생했습니다. 다시 시도해주세요."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      logger.e('대표 이미지 변경 중 오류 발생: $e');
    }
  }

  // 유저 이미지 추가
  Future<void> uploadUserImage(BuildContext context, File imageFile) async {
    final String? userNo = state.userInfo?.userNo;

    bool result = await _repository.uploadUserImage(userNo!, imageFile);

    if (result) {
      fetchMyPageInfo(userNo);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지가 추가되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 추가를 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 유저 이미지 삭제
  Future<void> deleteUserImage(
      BuildContext context, String ImageNoForDelete) async {
    final String? userNo = state.userInfo?.userNo;

    bool result = await _repository.deleteUserImage(ImageNoForDelete);

    if (result) {
      fetchMyPageInfo(userNo!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지가 삭제되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 삭제를 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 이메일 인증번호 발송
  Future<int> verifyEmail(String userEmail) async {
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (emailRegex.hasMatch(userEmail)) {
      try {
        String? sessionIdForCode =
            await _repository.fetchVerifyEmail(userEmail);

        if (sessionIdForCode != null) {
          sessionId = sessionIdForCode;
          logger.d("세션 ID 저장됨: $sessionId");
          return 1;
        } else {
          return 3;
        }
      } catch (e) {
        logger.e('Failed to fetch verifyEmail: $e');
        return 4;
      }
    } else {
      return 2;
    }
  }

  // 이메일 인증번호 체크
  Future<int> verifyCode(String userEmail, String code) async {
    try {
      if (sessionId == null) {
        logger.e("세션 ID 없음");
        return 3;
      }

      Map<String, dynamic> requestData = {
        "userEmail": userEmail,
        "code": code,
        "sessionId": sessionId // 세션 ID 함께 전송
      };

      bool isSuccess = await _repository.fetchVerifyCode(requestData);
      if (isSuccess) {
        return 1; // 인증 성공
      } else {
        return 2; // 인증번호 불일치
      }
    } catch (e) {
      logger.e('Failed to fetch verifyCode: $e');
      return 3; // 서버 오류
    }
  }

// 유저 아이디 찾기
  Future<Map<String, dynamic>> findUserId(
      String userName, String userEmail) async {
    final RegExp nameRegex = RegExp(r'^[가-힣]{2,10}$');

    // 이름 유효성 검사
    if (!nameRegex.hasMatch(userName)) {
      return {"status": 2, "userId": null}; // 이름이 유효하지 않음
    }

    try {
      Map<String, dynamic> requestData = {
        "userName": userName,
        "userEmail": userEmail,
      };

      String? foundUserID = await _repository.fetchFindUserId(requestData);

      if (foundUserID != null) {
        return {"status": 1, "userId": foundUserID}; // 정상적으로 아이디 찾음
      } else {
        return {"status": 3, "userId": null}; // 계정이 존재하지 않음
      }
    } catch (e) {
      logger.e('Failed to fetch verifyCode: $e');
      return {"status": 4, "userId": null}; // 서버 오류 발생
    }
  }

  // 유저 비밀번호 재설정으로 이동
  Future<int> findUserPw(String userId, String userEmail) async {
    try {
      Map<String, dynamic> requestData = {
        "userId": userId,
        "userEmail": userEmail,
      };

      String? userNo = await _repository.fetchFindUserPw(requestData);
      if (userNo != null) {
        resetUserNo = userNo;
        return 1; // 계정 존재
      } else {
        return 2; // 계정 존재하지 않음
      }
    } catch (e) {
      logger.e('Failed to fetch verifyCode: $e');
      return 3; // 서버 오류
    }
  }

  // 유저 비밀번호 재설정
  Future<int> resetUserPw(String userPw1, String userPw2) async {
    final RegExp passwordRegex = RegExp(
        r'^[A-Z](?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*])[a-zA-Z\d!@#$%^&*]{7,13}$');
    if (passwordRegex.hasMatch(userPw1)) {
      if (userPw1 == userPw2) {
        try {
          Map<String, dynamic> requestData = {
            "userNo": resetUserNo,
            "userPw": userPw1,
          };

          bool isSuccess = await _repository.fetchResetUserPw(requestData);
          if (isSuccess) {
            return 1; // 비밀번호 재설정 성공
          } else {
            return 4; // 비밀번호 재설정 실패
          }
        } catch (e) {
          logger.e('Failed to fetch verifyCode: $e');
          return 5; // 서버 오류
        }
      } else {
        return 3; // userPw1 과 userPw2 가 불일치
      }
    } else {
      return 2; // 비밀번호 형식에 맞지 않음
    }
  }
}

final userViewModelProvider = NotifierProvider<UserViewModel, UserMypageInfo>(
  () => UserViewModel(UserRepository()),
);

/**
 * Class의 정의? -> 붕어빵틀 -> 객체를 찍어내는 틀, 설계도
 * 객체란? -> 현실 세계에 존재하는 사물이나 개념을 프로그래밍을 위해 나타낸 것?
 * ex) 사람 객체 -> 이름이 있고, 나이도 있고, 밥도 먹고, 똥도 싸고...
 * Class의 구성요소는?
 * - 필드 (속성)
 * - 메서드 (행위)
 *
 * Class Person {
 *    String name;
 *    int age;
 *
 *    void eat() {
 *       print('밥 먹음');
 *    }
 *
 *    void work() {
 *       print('일함');
 *    }
 *
 *    void setAge(int newAge) {
 *       this.age = newAge;
 *    }
 * }
 *
 * Person person1 = new Person('홍길동', 34);
 * Person person2 = new Person('장보고', 44);
 * person1.eat();
 * person2.work();
 *
 * person2.setAge(54);
 *
 *
 */
