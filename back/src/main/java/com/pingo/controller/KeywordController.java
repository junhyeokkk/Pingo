package com.pingo.controller;

import com.pingo.service.keywordServices.KeywordService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Slf4j
@RequiredArgsConstructor
@Controller
public class KeywordController {

    final private KeywordService keywordService;

    // 2차 키워드 카테고리까지 조회 for Keyword_Page
    @GetMapping("/keyword") //keywordList?
    public ResponseEntity<?> selectKeywordListFor2ndCategory() {

        return keywordService.selectKeywordListFor2ndCategory();
    }

    // keyword page에서 키워드 선택
    @GetMapping("/recommend")
    public ResponseEntity<?> recommendBasedOnKeywords(@RequestParam("userNo") String userNo, @RequestParam("sKwId") String sKwId) {

        int distanceKm = 10;

        return keywordService.recommendBasedOnKeywords(userNo, sKwId, distanceKm);
    }
}
