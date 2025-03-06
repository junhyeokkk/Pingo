package com.pingo.controller;

import com.pingo.service.swipeService.SwipeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Slf4j
@RequiredArgsConstructor
@Controller
public class PingCheckController {

    private final SwipeService swipeService;

    // 멤버쉽 조회
    @GetMapping("/checkping")
    public ResponseEntity<?> checkping(@RequestParam("userNo") String userNo) {
        return swipeService.selectSuperPingOrPingByMe(userNo);
    }
}
