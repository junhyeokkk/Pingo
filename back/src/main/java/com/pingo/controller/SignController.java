package com.pingo.controller;

import com.pingo.service.signService.SignService;
import com.pingo.service.userService.EmailService;
import jakarta.mail.MessagingException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@RestController
public class SignController {

    final private SignService signService;

    @PostMapping("/permit/signin")
    public ResponseEntity<?> login(@RequestBody Map<String, String> userInfo) {
        log.info("Login attempt - userId: {}", userInfo.get("userId"));

        // 위치 정보 추가
        double latitude = Double.parseDouble(userInfo.get("latitude"));
        double longitude = Double.parseDouble(userInfo.get("longitude"));

        // 로그인 서비스 호출 후 응답 받아오기
        return signService.signInProcess(userInfo.get("userId"), userInfo.get("userPw"),latitude,longitude);
    }

    // 회원가입시 아이디 중복 검증
    @GetMapping("/permit/validateId")
    public ResponseEntity<?> validateId(@RequestParam String inputId) {
        log.info("inputId : " + inputId);
        return signService.validateId(inputId);
    }

    // 회원가입시 닉네임 중복 검사
    @GetMapping("/permit/validateNick")
    public ResponseEntity<?> validateNick(@RequestParam String inputNick) {
        log.info("inputNick : " + inputNick);
        return signService.validateNick(inputNick);
    }

    // 회원가입시 3차 키워드 조회
    @GetMapping("/permit/3ndKeyword")
    public ResponseEntity<?> select3ndKeyword() {
        return signService.select3ndKeyword();
    }

    // 회원가입
    @PostMapping("/permit/signup")
    public ResponseEntity<?> signup(@RequestPart("userSignUp") String userSignUp,
                                    @RequestPart("image") MultipartFile profileImage,
                                    @RequestPart("latitude") double latitude,
                                    @RequestPart("longitude") double longitude) {

        return signService.signUpProcess(userSignUp, profileImage, latitude, longitude);
    }
    
    // 회원가입 이메일 인증코드 발송
    @PostMapping("/permit/sendemailforsignup")
    public ResponseEntity<?> verifyEmailForSignup(@RequestBody String userEmail, HttpSession session) throws MessagingException {

        return signService.verifyEmailForSignUp(userEmail, session);
    }
}
