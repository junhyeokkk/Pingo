package com.pingo.controller;

import com.pingo.dto.ResponseDTO;
import com.pingo.dto.location.LocationRequest;
import com.pingo.service.mainService.LocationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Controller
public class LocationController {

    private final LocationService locationService;

    // 위치 업데이트 API
    @PostMapping("/location/update")
    public ResponseEntity<?> updateUserLocation(@RequestBody LocationRequest request) {
        locationService.updateUserLocation(request.getUserNo(), request.getLatitude(), request.getLongitude());
        return ResponseEntity.ok(ResponseDTO.of("1","성공",true));
    }

    // 반경 내 유저 검색 API
    @GetMapping("/user/nearby")
    public ResponseEntity<?>  getNearbyUsers(
            @RequestParam String userNo,
            @RequestParam int distanceKm
    ) {
        log.info("유저 검색 api 입성");
        log.info("파라미터 확인 : " + userNo + distanceKm);
        return locationService.getNearbyUsersForMain(userNo, distanceKm);
    }
}
