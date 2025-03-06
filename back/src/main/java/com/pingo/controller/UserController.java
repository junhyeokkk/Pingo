package com.pingo.controller;

import com.pingo.entity.users.UserMypageInfo;
import com.pingo.service.ImageService;
import com.pingo.service.userService.UserService;
import jakarta.mail.MessagingException;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@Controller
public class UserController {

    private final UserService userService;

    // 사용자 정보 조회
    @GetMapping("/user")
    public ResponseEntity<?> getMyPageInfo(@RequestParam("userNo") String userNo) {

        return userService.getUserInfo(userNo);
    }

    // http 통신 -> Header에는 Content-Type을 작성한다
    // 일반적으로 텍스트 데이터를 주고 받을 때는 content-type : application/json
    // 이미지를 주고 받기 위해서는 content-type : multipart/form-data
    // 유저 이미지 추가
    @PostMapping("/user/image")
    public ResponseEntity<?> addUserImage(@RequestPart("userNo") String userNo, @RequestPart("userImageForAdd") MultipartFile userImageForAdd) {

        return userService.addUserImage(userNo, userImageForAdd);
    }

    // 유저의 서브이미지를 메인이미지로 설정
    @PutMapping("/user/image")
    public ResponseEntity<?> setMainImage(@RequestBody Map<String, String> reqData) {

        String currentMainImageNo = (String) reqData.get("currentMainImageNo");
        String newMainImageNo = (String) reqData.get("newMainImageNo");

        return userService.setMainImage(currentMainImageNo, newMainImageNo);
    }

    // 유저 이미지 삭제
    @DeleteMapping("/user/image")
    public ResponseEntity<?> deleteUserImage(@RequestBody Map<String, String> reqData) {

        String ImageNoForDelete = (String) reqData.get("ImageNoForDelete");

        return userService.deleteUserImage(ImageNoForDelete);
    }

    // 유저 정보 수정
    @PostMapping("/user/info")
    public ResponseEntity<?> updateUserInfo(@RequestBody UserMypageInfo userMypageInfo) {

        log.info("userMypageInfo : " + userMypageInfo);

        return userService.updateUserInfo(userMypageInfo);
    }

    // 이메일 인증코드 발송
    @PostMapping("/permit/sendemail")
    public ResponseEntity<?> verifyEmail(@RequestBody String userEmail, HttpSession session) throws MessagingException {

        return userService.verifyEmail(userEmail, session);
    }

    // 이메일 인증코드 확인
    @PostMapping("/permit/checkcode")
    public ResponseEntity<?> checkCode(@RequestBody Map<String, String> requestBody) {
        String sessionId = requestBody.get("sessionId"); // 클라이언트가 보낸 세션 ID
        if (sessionId == null || sessionId.isEmpty()) {
            log.info("세션 ID 없음");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("세션 ID가 없습니다.");
        }

        String userEmail = requestBody.get("userEmail");
        String code = requestBody.get("code");

        return userService.checkCode(userEmail, code, sessionId); // sessionId를 전달
    }

    // ID 찾기
    @GetMapping("permit/finduserid")
    public ResponseEntity<?> findUserId(@RequestParam String userName, @RequestParam String userEmail) {
        return userService.findUserId(userName, userEmail);
    }

    // 유저 비밀번호 재설정으로 이동
    @GetMapping("permit/finduserpw")
    public ResponseEntity<?> findUserPw(@RequestParam String userId, @RequestParam String userEmail) {
        return userService.findUserPw(userId, userEmail);
    }

    // 유저 비밀번호 재설정
    @PutMapping("permit/resetuserpw")
    public ResponseEntity<?> resetUserPw(@RequestBody Map<String, String> requestDataForResetUserPw) {

        return userService.resetUserPw(requestDataForResetUserPw.get("userNo"), requestDataForResetUserPw.get("userPw"));
    }
}
