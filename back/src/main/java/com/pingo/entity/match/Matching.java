package com.pingo.entity.match;

import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@ToString
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Matching {
    private String matchNo;
    private String userANo;
    private String userBNo;
    private LocalDateTime matchingTime;

    // matching 엔티티 생성
    public Matching (String userANo, String userBNo) {
        this.matchNo = createMatchNo();
        this.userANo = userANo;
        this.userBNo = userBNo;
        this.matchingTime = LocalDateTime.now();
    }

    // matchNo 생성 로직 (중복 호출시 예외 처리)
    public String createMatchNo() {
        if(this.matchNo == null) {
            String uuid = UUID.randomUUID().toString();
            return "MT" + uuid.substring(0, 8);
        }else {
            throw new BusinessException(ExceptionCode.DUPLICATE_MATCH_NO);
        }
    }


}
