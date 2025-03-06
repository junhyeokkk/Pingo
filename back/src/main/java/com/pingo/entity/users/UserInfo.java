package com.pingo.entity.users;

import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.time.LocalDateTime;
import java.util.regex.Pattern;

@Getter
@ToString
@AllArgsConstructor
@NoArgsConstructor
public class UserInfo {
    private String userNo;
    private LocalDateTime userBirth;
    private int userHeight;
    private String userAddress;
    private String user1stJob;
    private String user2ndJob;
    private String userReligion;
    private String userDrinking;
    private String userSmoking;
    private String userBloodType;

    public UserInfo validatedSignUpUserInfoData() {

        // 검증하는 로직
        // 1. 생년월일 검증
        // 생년월일은 오늘 날짜보다 이후일 수 없음
        if (this.userBirth.isAfter(LocalDateTime.now())) {
            throw new BusinessException(ExceptionCode.INVALID_USER_BIRTH);
        }

        return this;
    }

    public void insertUserNo(String userNo) {
        this.userNo = userNo;
    }
}
