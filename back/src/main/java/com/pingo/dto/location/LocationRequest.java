package com.pingo.dto.location;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LocationRequest {
    private String userNo;  // 유저 번호
    private double latitude;  // 위도
    private double longitude;  // 경도
}