package com.pingo.controller;

import com.pingo.dto.ResponseDTO;
import com.pingo.dto.swipe.SwipeRequest;
import com.pingo.service.swipeService.SwipeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@Controller
public class SwipeController {
    private final SwipeService swipeService;

    @PostMapping("/insertSwipe")
    public ResponseEntity<?> insertSwipe(@RequestBody SwipeRequest swipeRequest) {

        log.info("스위프트 저장 로직 입성");
        log.info("리퀘스트 ㅂ보자" + swipeRequest.toString());

        return swipeService.saveSwipe(swipeRequest);
    }
}
