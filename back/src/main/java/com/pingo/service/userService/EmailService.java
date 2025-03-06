package com.pingo.service.userService;

import com.pingo.dto.ResponseDTO;
import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import com.pingo.util.SessionManager;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.mail.MailException;
import org.springframework.stereotype.Service;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.MessagingException;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.javamail.JavaMailSender;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender javaMailSender;
    private static final String senderEmail = "pingo250120@gmail.com";

    // 1. 인증코드 생성
    public String createVerificationCode() {
        String uuid = UUID.randomUUID().toString();
        return uuid.substring(0, 8);
    }
    
    // 2. 인증코드 이메일 생성
    public MimeMessage createVerificationEmail(String userEmail, String code) throws MessagingException {
        MimeMessage message = javaMailSender.createMimeMessage();

        message.setFrom(senderEmail);
        message.setRecipients(MimeMessage.RecipientType.TO, userEmail);
        message.setSubject("이메일 인증코드", "UTF-8");

        String body = "";
        body += "<h1>인증코드 : " + code + "</h1>";
        body += "<h3>안녕하세요!</h3>";
        body += "<h3>Pingo 이메일 확인 메일입니다.</h3>";
        body += "<h2>※중요: 인증코드는 10분후에 만료됩니다. 10분 내로 입력하여 주시기 바랍니다.</h2>";
        message.setText(body, "UTF-8", "html");

        return message;
    }

    // 인증코드 이메일 발송
    public String sendVerificationEmail(String userEmail, HttpSession session) throws MessagingException {
        String code = createVerificationCode();
        MimeMessage message = createVerificationEmail(userEmail, code);

        try {
            javaMailSender.send(message);
            session.setAttribute(userEmail, code);
            session.setMaxInactiveInterval(600);

            String sessionId = session.getId(); // 세션 ID 저장

            // SessionManager에 세션 저장
            SessionManager.addSession(session);

            log.info("[세션 저장] 이메일: {}, 저장된 코드: {}", userEmail, code);
            log.info("[세션 유지 시간] {}초, 세션 ID: {}", session.getMaxInactiveInterval(), sessionId);

            // sessionId만 반환
            return sessionId;
        } catch (MailException e) {
            throw new BusinessException(ExceptionCode.EMAIL_SEND_FAILED);
        }
    }


    // ----------------------------------------------------------------

    // 이메일 인증번호 확인 메서드
    public ResponseEntity<?> checkCode(String userEmail, String code, String sessionId) {
        // 클라이언트가 보낸 세션 ID로 세션 조회
        HttpSession session = SessionManager.getSession(sessionId);

        if (session == null) {
            throw new BusinessException(ExceptionCode.INVALID_SESSION);
        }

        try {
            // 세션에서 해당 이메일의 인증번호 가져오기
            String sessionCode = (String) session.getAttribute(userEmail);
            log.info("🔹 세션에서 가져온 인증 코드: {}", sessionCode);

            // 인증번호가 존재하고, 입력된 코드와 일치하면 성공 응답 반환
            if (sessionCode != null && sessionCode.equals(code)) {
                return ResponseEntity.ok().body(ResponseDTO.of("1", "인증 성공", true));
            } else {
                throw new BusinessException(ExceptionCode.VERIFICATION_CODE_MISMATCH);
            }
        } catch (Exception e) {
            throw new BusinessException(ExceptionCode.CODE_CHECK_FAILED);
        }
    }
}
