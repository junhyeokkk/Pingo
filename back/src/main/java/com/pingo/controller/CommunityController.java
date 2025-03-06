package com.pingo.controller;

import com.pingo.entity.community.DatingGuide;
import com.pingo.entity.community.PlaceReview;
import com.pingo.service.communityService.CommunityService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@Controller
public class CommunityController {

    final private CommunityService communityService;

    // 정렬로 PlaceReview 조회
    @GetMapping("/community/place")
    public ResponseEntity<?> searchPlaceReview(@RequestParam("cateSort") String cateSort,
                                               @RequestParam("searchSort") String searchSort,
                                               @RequestParam("keyword") String keyword) {

        return communityService.searchPlaceReview(cateSort, searchSort, keyword);
    }

    // 정렬로 PlaceReview 조회 with location
    @GetMapping("/community/place/location")
    public ResponseEntity<?> searchPlaceReviewWithLocation(@RequestParam("cateSort") String cateSort,
                                               @RequestParam("latitude") double latitude,
                                               @RequestParam("longitude") double longitude) {

        return communityService.searchPlaceReviewWithLocation(cateSort, latitude, longitude);
    }


    // PlaceReview 장소 이미지 크롤링
    @PostMapping("/community/place/crawling")
    public ResponseEntity<?> crawlingPlaceImage(@RequestBody Map<String, String> reqData) {
        String placeUrl = reqData.get("placeUrl");
        return communityService.crawlingPlaceImage(placeUrl);
    }

    // PlaceReview 삽입
    @PostMapping("/community/place")
    public ResponseEntity<?> insertPlaceReview(@RequestPart("placeReview") PlaceReview placeReview,
                                               @RequestPart("placeImage") MultipartFile placeImage) {

        return communityService.insertPlaceReview(placeReview, placeImage);
    }

    // PlaceReview 좋아요
    @PostMapping("/community/place/heart")
    public ResponseEntity<?> checkPlaceHeart(@RequestBody Map<String, String> reqData) {

        String userNo = reqData.get("userNo");
        String prNo = reqData.get("prNo");

        return communityService.checkPlaceHeart(userNo, prNo);
    }

    // DatingGuide 최초 조회
    @GetMapping("/community/guide/init")
    public ResponseEntity<?> selectDatingGuideForInit() {
        return communityService.selectDatingGuideForInit();
    }

    // 개별 DatingGuide 정렬로 조회
    @GetMapping("/community/guide/sort")
    public ResponseEntity<?> selectDatingGuideWithSort(@RequestParam("cate") String cate,
                                                       @RequestParam("sort") String sort) {

        return communityService.selectDatingGuideWithSort(cate, sort);
    }

    // DatingGuide 작성
    @PostMapping("/community/guide")
    public ResponseEntity<?> insertDatingGuide(@RequestPart("datingGuide") DatingGuide datingGuide,
                                               @RequestPart("guideImage") MultipartFile guideImage) {

        return communityService.insertDatingGuide(datingGuide, guideImage);
    }

    // DatingGuide 좋아요
    @PostMapping("/community/guide/heart")
    public ResponseEntity<?> checkDatingGuideHeart(@RequestBody Map<String, String> reqData) {

        String userNo = reqData.get("userNo");
        String dgNo = reqData.get("dgNo");

        return communityService.checkDatingGuideHeart(userNo, dgNo);
    }

    // 장소 공유 채팅 조회
    @GetMapping("/community/chat")
    public ResponseEntity<?> searchPlaceForChat(@RequestParam("placeName") String placeName,
                                                @RequestParam("placeAddress") String placeAddress) {
        return communityService.searchPlaceForChat(placeName, placeAddress);
    }
}