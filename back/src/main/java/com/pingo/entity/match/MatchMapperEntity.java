package com.pingo.entity.match;

import lombok.*;

@Getter
@ToString
@NoArgsConstructor
@Builder
public class MatchMapperEntity {

    private String userNo;
    private String matchUserNo;
    private String matchNo;

    // 커스텀 생성자
    public MatchMapperEntity(String userNo, String matchUserNo, String matchNo) {
        this.userNo = userNo;
        this.matchUserNo = matchUserNo;
        this.matchNo = matchNo;
    }
}
