package com.pingo.entity.users;

import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import lombok.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.regex.Pattern;
@Slf4j
@Getter
@ToString
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class Users {
    private String userNo;
    private String userId;
    private String userPw;
    private String userName;
    private String userNick;
    private String userGender;
    private String userState;
    private String userRole;
    private LocalDateTime userrDate;
    private String userEmail;

    // 아이디 검증
    public Users validatedSignUpUserData() {

        // 검증하는 로직
        // 1. 아이디 검증
        if (!Pattern.matches("^[a-zA-Z0-9]{6,12}$", this.userId)) {
            // 거짓
            throw new BusinessException(ExceptionCode.INVALID_USER_ID);
        }

        // 2. 비밀번호 검증
        if (!Pattern.matches("^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*()-_+=])[A-Za-z\\d!@#$%^&*()-_+=]{8,14}$", this.userPw)) {
            // 거짓
            throw new BusinessException(ExceptionCode.INVALID_USER_PW);
        }

        // 3. 이름 검증
        if (!Pattern.matches("^[가-힣]{2,10}$", this.userName)) {
            // 거짓
            throw new BusinessException(ExceptionCode.INVALID_USER_NAME);
        }

        // 4. 닉네임 검증
        if (!Pattern.matches("^[가-힣a-zA-Z]{2,10}$", this.userNick)) {
            // 거짓
            throw new BusinessException(ExceptionCode.INVALID_USER_NICK);
        }

        // 5. 성별 검증 (M or F)
        if (!"M".equals(this.userGender) && !"F".equals(this.userGender)) {
            // 거짓
            throw new BusinessException(ExceptionCode.INVALID_USER_GENDER);
        }

        // 6. 상태 검증
        this.userState = "OK";

        // 7. 역할 검증
        this.userRole = "USER";

        // 8. 가입일 검증
        this.userrDate = LocalDateTime.now();

        // 9. 이메일 검증
        if (!Pattern.matches("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", this.userEmail)) {
            // 거짓
            throw new BusinessException(ExceptionCode.INVALID_USER_EMAIL);
        }

        // 10. 모든 검증 완료 시 userNo (pk) 생성
        this.userNo = createUserNo();

        return this;
    }

    // userNo 생성 로직 (중복 호출시 예외 처리)
    public String createUserNo() {
        if(this.userNo == null) {
            String uuid = UUID.randomUUID().toString();
            return "US" + uuid.substring(0, 8);
        }else {
            throw new BusinessException(ExceptionCode.DUPLICATE_USER_NO);
        }
    }

    public void setEncodingPw(String encodingPw) {
        this.userPw = encodingPw;
    }

}
