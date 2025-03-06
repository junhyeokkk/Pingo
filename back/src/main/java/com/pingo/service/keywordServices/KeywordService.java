package com.pingo.service.keywordServices;

import com.pingo.dto.ResponseDTO;
import com.pingo.dto.profile.MainProfileResponseDTO;
import com.pingo.entity.keywords.Keyword;
import com.pingo.entity.keywords.KeywordGroup;
import com.pingo.entity.users.UserKeyword;
import com.pingo.mapper.KeywordMapper;
import com.pingo.service.mainService.LocationService;
import lombok.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Slf4j
@RequiredArgsConstructor
@Service
public class KeywordService {

    final private KeywordMapper keywordMapper;
    final private LocationService locationService;

    // [1] 2차 키워드 카테고리까지 조회 for Keyword_Page
    public ResponseEntity<?> selectKeywordListFor2ndCategory() {
        List<Keyword> keywordList = keywordMapper.selectKeywordListFor2ndCategory();

        Map<String, KeywordGroup> keywordGroup = transformKeywordListToGroupMap(keywordList);

        return ResponseEntity.ok().body(ResponseDTO.of("1", "성공", keywordGroup));
    }

    // [1-1] KeywordList 를 Map<String, KeywordGroup> 구조로 변경
    private Map<String, KeywordGroup> transformKeywordListToGroupMap(List<Keyword> keywordList) {
        Map<String, KeywordGroup> keywordGroup = new HashMap<>();
        for (Keyword item : keywordList) {
            if (item.getKwParentId() == null) {
                keywordGroup.put(item.getKwId(), new KeywordGroup(item.getKwId(), item.getKwName(), item.getKwMessage()));
            }else {
                KeywordGroup getKG = keywordGroup.get(item.getKwParentId());
                getKG.addChildKeyword(item);
            }
        }
        return keywordGroup;
    }

    // [2] Keyword Page에서 선택한 키워드에 알맞은 다른 사용자 추천 및 이상형 % 계산
    public ResponseEntity<?> recommendBasedOnKeywords(String userNo, String sKwId, int distanceKm) {
        // 1) 나의 키워드 정보 조회
        UserKeyword myKeyword = keywordMapper.selectUserKeyword(userNo);

        // 2) 내 주변 사람 목록 조회
        List<MainProfileResponseDTO> nearByUser = locationService.selectNearbyUsers(userNo, distanceKm);
        List<String> userNoList = new ArrayList<>();
        for (MainProfileResponseDTO each : nearByUser) {
            userNoList.add(each.getUserNo());
        }

        // 3) 내 주변 사람들의 키워드 조회
        Map<String, Object> userNos = new HashMap<>();
        userNos.put("userNos", userNoList);
        List<UserKeyword> otherKeyword = keywordMapper.selectMultiUserKeyword(userNos);

        // 4) 내가 선택한 키워드(sKwId) 의 하위 키워드 목록 조회
        List<String> selectedKeywordList = keywordMapper.selectChildKeyword(sKwId);

        // 데이터 가공
        List<String> myKeywordList = transformKeywordStrToList(myKeyword.getMy());
        //List<String> favoriteKeywordList = transformKeywordStrToList(myKeyword.getFavorite());

        // 5) 내 키워드와 주변 사람들 키워드 비교 (+알고리즘) 후 % 반환
        for (UserKeyword other : otherKeyword) {
            List<String> otherMyKeywordList = transformKeywordStrToList(other.getMy());
            List<String> otherFavoriteKeywordList = transformKeywordStrToList(other.getFavorite());

            // 상대의 키워드와 내가 선택한 키워드의 일치 정도 분석 (일치하는 키워드가 2개 이하면 해당 사람 추천X)
            Set<String> commonElements = new HashSet<>(selectedKeywordList);
            commonElements.retainAll(otherMyKeywordList);
            if (commonElements.size() < 2) {
                nearByUser.removeIf(each -> each.getUserNo().equals(other.getUserNo()));
                continue;
            }

            // 내가 상대를 마음에 들어할 수치
            double myPreference = keywordSimilarityCalculation(new HashSet<>(selectedKeywordList), new HashSet<>(otherMyKeywordList));

            // 상대가 나를 마음에 들어할 수치
            double otherPreference = keywordSimilarityCalculation(new HashSet<>(otherFavoriteKeywordList), new HashSet<>(myKeywordList));

            log.info("myPreference : " + myPreference);
            log.info("otherPreference : " + otherPreference);

            double preference = (myPreference + otherPreference) * 100;
            preference = Math.round(preference * 100.0) / 100.0;

            // preference값 임시 보정
            if (preference >= 100) {
                preference = 100;
            }
            log.info("preference : " + preference);
        }

        return ResponseEntity.ok().body(ResponseDTO.of("1","성공",nearByUser));
    }

    // str to list
    private List<String> transformKeywordStrToList(String keywordStr) {
        String[] keywordArr = keywordStr.split("_");
        return Arrays.asList(keywordArr);
    }

    // Jaccard Similarity (자카드 유사도)
    private double keywordSimilarityCalculation(Set<String> set1, Set<String> set2) {
        Set<String> intersection = new HashSet<>(set1);
        intersection.retainAll(set2); // 교집합

        Set<String> union = new HashSet<>(set1);
        union.addAll(set2); // 합집합

        return (double) intersection.size() / union.size();
    }

    // [3] User Keyword 저장
    public void insertUserKeywordForSignUp(String userNo, String userMyKeyword, String userFavoriteKeyword) {
        keywordMapper.insertUserKeywordForSignUp(userNo, userMyKeyword, userFavoriteKeyword);
    }
}
