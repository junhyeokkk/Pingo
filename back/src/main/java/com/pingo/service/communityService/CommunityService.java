package com.pingo.service.communityService;

import com.pingo.dto.ResponseDTO;
import com.pingo.dto.community.DatingGuideDTO;
import com.pingo.dto.community.DatingGuideSearchDTO;
import com.pingo.dto.community.PlaceReviewDTO;
import com.pingo.entity.community.DatingGuide;
import com.pingo.entity.community.DatingGuideCate;
import com.pingo.entity.community.PlaceReview;
import com.pingo.mapper.CommunityMapper;
import com.pingo.service.ImageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.*;

@Slf4j
@RequiredArgsConstructor
@Service
public class CommunityService {

    final private ImageService imageService;
    final private CommunityMapper communityMapper;
    final private PlaceCrawlingService placeCrawlingService;

    // 정렬로 PlaceReview 조회
    public ResponseEntity<?> searchPlaceReview(String cateSort, String searchSort, String keyword) {
        if (keyword == null || keyword.isEmpty()) {
            List<PlaceReviewDTO> placeReviewList = communityMapper.selectPlaceReviewWithSort(cateSort, searchSort);

            return ResponseEntity.ok().body(ResponseDTO.of("1","성공",placeReviewList));
        }else {
            List<PlaceReviewDTO> placeReviewList = communityMapper.selectPlaceReviewWithKeyword(keyword);

            return ResponseEntity.ok().body(ResponseDTO.of("1","성공",placeReviewList));
        }
    }

    // 정렬로 PlaceReview 조회 with location
    public ResponseEntity<?> searchPlaceReviewWithLocation(String cateSort, double latitude, double longitude) {
        List<PlaceReviewDTO> placeReviewList = communityMapper.selectPlaceReviewWithLocation(cateSort, latitude, longitude);

        return ResponseEntity.ok().body(ResponseDTO.of("1","성공",placeReviewList));

    }

    // PlaceReview 장소 이미지 크롤링
    public ResponseEntity<?> crawlingPlaceImage(String placeUrl) {

        byte[] imageData = placeCrawlingService.crawlingPlaceImage(placeUrl);
        String base64Image = imageData != null ? Base64.getEncoder().encodeToString(imageData) : null;

        return ResponseEntity.ok().body(ResponseDTO.of("1","성공",base64Image));
    }

    // PlaceReview 삽입
    public ResponseEntity<?> insertPlaceReview(PlaceReview placeReview, MultipartFile placeImage) {
        // 이미지 저장
        placeReview.createPrNo();
        String thumbName = placeReview.createThumbName();
        String placeImagePath = "placeImages" + File.separator + placeReview.getPrNo();
        String imageUrl = imageService.imageUpload(placeImage, placeImagePath, thumbName);

        // 내용 저장
        placeReview.insertThumb(imageUrl);
        communityMapper.insertPlaceReview(placeReview);
        
        return ResponseEntity.ok().body(ResponseDTO.of("1", "성공", true));
    }

    // PlaceReview 좋아요
    @Transactional
    public ResponseEntity<?> checkPlaceHeart(String userNo, String prNo) {
        Optional<String> prNoStrOpt = communityMapper.selectPlaceHeart(userNo);

        // 내가 좋아요한 목록 List 변환
        List<String> prNoList = new ArrayList<>();
        if (prNoStrOpt.isPresent()) {
            String[] prNoArray = prNoStrOpt.get().split("_");
            Collections.addAll(prNoList, prNoArray);
        }

        boolean isRemoved = prNoList.remove(prNo);
        if (!isRemoved) {
            prNoList.add(prNo);
        }

        String newPrNoStr = String.join("_", prNoList);

        if (isRemoved) {
            communityMapper.placeDecreaseHeart(prNo);
        } else {
            communityMapper.placeIncreaseHeart(prNo);
        }

        if (prNoStrOpt.isPresent()) {
            if (newPrNoStr.isEmpty()) {
                communityMapper.deletePlaceReviewHeart(userNo);
            }else {
                communityMapper.updatePlaceReviewHeart(userNo, newPrNoStr);
            }
        } else {
            communityMapper.insertPlaceReviewHeart(userNo, newPrNoStr);
        }

        if (isRemoved) {
            return ResponseEntity.ok().body(ResponseDTO.of("1","성공","decrease"));
        }else {
            return ResponseEntity.ok().body(ResponseDTO.of("1","성공","increase"));
        }
    }

    // DatingGuide 최초 조회
    public ResponseEntity<?> selectDatingGuideForInit() {
        List<DatingGuideDTO> datingGuideList = communityMapper.selectDatingGuideForInit();
        List<DatingGuideCate> datingGuideCate = communityMapper.selectDatingGuideCate();

        // Category Map
        Map<Integer, String> cateDescMap = new HashMap<>();
        for (DatingGuideCate cate : datingGuideCate) {
            cateDescMap.put(cate.getCateId(), cate.getCateDesc());
        }

        // Dating Guide List Map
        Map<String, DatingGuideSearchDTO> guideMap = new HashMap<>();
        for (DatingGuideDTO each : datingGuideList) {
            if (!guideMap.containsKey(each.getCateName())) {
                String cateDesc = cateDescMap.getOrDefault(each.getCateNo(), "");
                guideMap.put(each.getCateName(), new DatingGuideSearchDTO(each.getCateName(), each.getCateNo(), cateDesc));
            }
            guideMap.get(each.getCateName()).addDatingGuideList(each);
        }

        return ResponseEntity.ok().body(ResponseDTO.of("1","성공", guideMap));
    }

    // 개별 DatingGuide 정렬로 조회
    public ResponseEntity<?> selectDatingGuideWithSort(String cate, String sort) {
        List<DatingGuideDTO> datingGuideList = communityMapper.selectDatingGuideWithSort(cate, sort);

        return ResponseEntity.ok().body(ResponseDTO.of("1", "성공", datingGuideList));
    }

    // DatingGuide 작성
    public ResponseEntity<?> insertDatingGuide(DatingGuide datingGuide, MultipartFile guideImage) {
        // 이미지 저장
        datingGuide.createDgNo();
        String thumbName = datingGuide.createThumbName();
        String placeImagePath = "datingGuideImages" + File.separator + datingGuide.getDgNo();
        String imageUrl = imageService.imageUpload(guideImage, placeImagePath, thumbName);

        // 내용 저장
        datingGuide.insertThumb(imageUrl);
        communityMapper.insertDatingGuide(datingGuide);

        return ResponseEntity.ok().body(ResponseDTO.of("1", "성공", true));
    }

    // DatingGuide 좋아요
    @Transactional
    public ResponseEntity<?> checkDatingGuideHeart(String userNo, String dgNo) {
        Optional<String> dgNoStrOpt = communityMapper.selectDatingGuideHeart(userNo);

        // 내가 좋아요한 목록 List 변환
        List<String> dgNoList = new ArrayList<>();
        if (dgNoStrOpt.isPresent()) {
            String[] dgNoArray = dgNoStrOpt.get().split("_");
            Collections.addAll(dgNoList, dgNoArray);
        }

        boolean isRemoved = dgNoList.remove(dgNo);
        if (!isRemoved) {
            dgNoList.add(dgNo);
        }

        String newDgNoStr = String.join("_", dgNoList);

        if (isRemoved) {
            communityMapper.decreaseHeart(dgNo);
        } else {
            communityMapper.increaseHeart(dgNo);
        }

        if (dgNoStrOpt.isPresent()) {
            if (newDgNoStr.isEmpty()) {
                communityMapper.deleteDatingGuideHeart(userNo);
            }else {
                communityMapper.updateDatingGuideHeart(userNo, newDgNoStr);
            }
        } else {
            communityMapper.insertDatingGuideHeart(userNo, newDgNoStr);
        }

        if (isRemoved) {
            return ResponseEntity.ok().body(ResponseDTO.of("1","성공","decrease"));
        }else {
            return ResponseEntity.ok().body(ResponseDTO.of("1","성공","increase"));
        }
    }

    // 장소 공유 채팅 조회
    public ResponseEntity<?> searchPlaceForChat(String placeName, String placeAddress) {

        PlaceReview placeReview = communityMapper.selectPlaceReviewForChat(placeName, placeAddress);

        return ResponseEntity.ok().body(ResponseDTO.of("1","성공",placeReview));
    }
}
