package com.pingo.entity.membership;

import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@ToString
@AllArgsConstructor
@NoArgsConstructor
public class UserMembership {
    private String umNo;
    private String userNo;
    private String msNo;
    private LocalDateTime payDate;
    private LocalDateTime expDate;
    private String state;

    public void createMembershipInfo(String msNo, String userNo) {
        this.umNo = createMsNo();
        this.msNo = msNo;
        this.userNo = userNo;
        this.payDate = LocalDateTime.now();
        this.expDate = calculateExpDate(msNo);
        this.state = "ACTIVE";
    }

    private String createMsNo() {
        String uuid = UUID.randomUUID().toString();
        return "UM" + uuid.substring(0, 8);
    }

    private LocalDateTime calculateExpDate(String msNo) {
        switch (msNo) {
            case "MS00000001":
                return this.payDate.plusDays(7).toLocalDate().atStartOfDay();
            case "MS00000002":
                return this.payDate.plusDays(30).toLocalDate().atStartOfDay();
            case "MS00000003":
                return this.payDate.plusDays(90).toLocalDate().atStartOfDay();
            default:
                throw new BusinessException(ExceptionCode.NOT_FOUND_MEMBERSHIP);
        }
    }
}
