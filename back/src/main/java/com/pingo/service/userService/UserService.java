package com.pingo.service.userService;

import com.pingo.dto.ResponseDTO;
import com.pingo.entity.keywords.Keyword;
import com.pingo.entity.users.UserImage;
import com.pingo.entity.users.UserKeyword;
import com.pingo.entity.users.UserMypageInfo;
import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import com.pingo.mapper.UserMapper;
import com.pingo.service.ImageService;
import jakarta.mail.MessagingException;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@Service
public class UserService {

    final private ImageService imageService;
    final private UserMapper userMapper;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;

    // DetailPage를 위한 회원 상세정보 조회 <나중에 합쳐주세용~>
    public ResponseEntity<?> getInfo(String userNo) {
        try {
            // ★ 상세정보랑 소개정보는 join으로 합칠 수 있음
            // 유저 마이페이지 상세 정보 조회
            UserMypageInfo userMypageInfo = userMapper.getUserMypageInfo(userNo);
            log.info("userMypageInfo : " + userMypageInfo);

            // 유저 소개 정보 조회
            String userIntroduction = userMapper.selectUserIntroduction(userNo);
            userMypageInfo.inputUserIntroduction(userIntroduction);

            log.info("userMypageInfo : " + userMypageInfo);

            return ResponseEntity.ok().body(ResponseDTO.of("1","성공", userMypageInfo));
        }catch (Exception e) {
            log.error(e.getMessage());
            throw new BusinessException(ExceptionCode.USER_INFO_NOT_FOUND);
        }
    }

    // 마이페이지를 위한 회원 정보 조회
    @Transactional
    public ResponseEntity<?> getUserInfo(String userNo) {
        try {
            // ★ 상세정보랑 소개정보는 join으로 합칠 수 있음
            // 유저 마이페이지 상세 정보 조회
            UserMypageInfo userMypageInfo = userMapper.getUserMypageInfo(userNo);
            log.info("userMypageInfo : " + userMypageInfo);

            // 유저 소개 정보 조회
            String userIntroduction = userMapper.selectUserIntroduction(userNo);
            userMypageInfo.inputUserIntroduction(userIntroduction);

            // 유저 이미지 조회
            List<UserImage> userImages = userMapper.getUserImages(userNo);
            userMypageInfo.inputUserImage(userImages);

            // 유저 키워드 정보 조회
            UserKeyword userKeyword = userMapper.getUserKeyword(userNo);
            Map<String, List<Keyword>> userKeywordList = parseUserKeyword(userKeyword);
            userMypageInfo.inputUserKeyword(userKeywordList);

            log.info("userMypageInfo : " + userMypageInfo);

            return ResponseEntity.ok().body(ResponseDTO.of("1","성공", userMypageInfo));
        }catch (Exception e) {
            log.error(e.getMessage());
            throw new BusinessException(ExceptionCode.USER_INFO_NOT_FOUND);
        }
    }

    // 유저 키워드 정보 파싱
    private Map<String, List<Keyword>> parseUserKeyword(UserKeyword userKeyword) {
        // 나의 키워드
        String[] myKeywords = userKeyword.getMy().split("_");
        String[] favoriteKeywords = userKeyword.getFavorite().split("_");

        List<Keyword> myKeywordList = userMapper.getUserKeywordDetail(myKeywords);
        List<Keyword> favoriteKeywordList = userMapper.getUserKeywordDetail(favoriteKeywords);

        Map<String, List<Keyword>> resultMap = new HashMap<>();
        resultMap.put("my", myKeywordList);
        resultMap.put("favorite", favoriteKeywordList);

        return resultMap;
    }

    // 유저 이미지 추가
    public ResponseEntity<?> addUserImage(String userNo, MultipartFile userImageForAdd) {
        // 유저 번호에 해당하는 이미지 호출
        List<UserImage> userImages = userMapper.getUserImages(userNo);

        // 리스트에 담긴 사진 수
        int userImagecount = userImages.size();
        log.info("userImagecount : " + userImagecount);

        if (userImagecount < 6 ) {
            // 이미지 서버에 저장하기
            // 새로운 유저이미지 객체 생성
            UserImage userImage = new UserImage();

            // 이미지 번호 랜덤 생성
            userImage.makeImageNo();

            // 이미지 번호 호출
            String imageNo = userImage.getImageNo();

            // 이미지 경로 호출 후 업로드 로직
            String userImagePath = "users" + File.separator + userNo;
            String imageUrl = imageService.imageUpload(userImageForAdd, userImagePath, imageNo);

            // 이미지 디비에 저장하기
            userMapper.addUserImage(imageNo, imageUrl, "F", userNo);

            return ResponseEntity.ok().body(ResponseDTO.of("1","성공", true));
        } else {
            throw new BusinessException(ExceptionCode.FILE_UPLOAD_FAIL);
        }
    }

    // 유저의 서브이미지를 메인이미지로 설정
    @Transactional
    public ResponseEntity<?> setMainImage(String currentMainImageNo, String newMainImageNo) {

        // 대표이미지를 서브이미지로 설정
        userMapper.setMainImageAsSubImage(currentMainImageNo);

        // 선택한 서브이미지를 대표이미지로 설정
        userMapper.setSubImageAsMainImage(newMainImageNo);

        return ResponseEntity.ok().body(ResponseDTO.of("1","성공", true));
    }

    // 유저 이미지 삭제
    public ResponseEntity<?> deleteUserImage(String ImageNoForDelete) {

        userMapper.deleteUserImage(ImageNoForDelete);

        return ResponseEntity.ok().body(ResponseDTO.of("1","성공", true));
    }

    // 유저 정보 수정
    @Transactional
    public ResponseEntity<?> updateUserInfo(UserMypageInfo userMypageInfo) {
        try {
            // 1. usrs 의 이메일 저장
            userMapper.updateUserEmail(userMypageInfo.getUsers().getUserNo(), userMypageInfo.getUsers().getUserEmail());
            
            // 2. userInfo 저장
            userMapper.updateUserInfo(userMypageInfo.getUserInfo()); // <- 여기 회원 정보 있음

            // 3. userKeyword 저장
            String myKeyword = parseKeywordToString(userMypageInfo.getMyKeywordList());
            String favoriteKeyword = parseKeywordToString(userMypageInfo.getFavoriteKeywordList());
            userMapper.updateUserKeyword(userMypageInfo.getUsers().getUserNo(), myKeyword, favoriteKeyword);

            // 4. 자기 소개 저장
            userMapper.updateUserIntro(userMypageInfo.getUsers().getUserNo(), userMypageInfo.getUserIntroduction()); // <- 여기 회원 소개 있음

            return ResponseEntity.ok().body(ResponseDTO.of("1","성공",true));
        }catch (Exception e) {
            log.error(e.getMessage());
            throw new BusinessException(ExceptionCode.UPDATE_USER_INFO_FAIL);
        }
    }

    // 회원 키워드 리스트 문자열로 전환
    public String parseKeywordToString(List<Keyword> keywordList) {
        StringBuilder keywordStr = new StringBuilder();

        for (Keyword each : keywordList) {
            if (keywordStr.isEmpty()) {
                keywordStr.append(each.getKwId());
            }
            keywordStr.append("_").append(each.getKwId());
        }
        return keywordStr.toString();
    }

    // 이메일 인증코드 발송
    public ResponseEntity<?> verifyEmail(String userEmail, HttpSession session) throws MessagingException {

        // 이메일 인증코드 발송
        String sessionId = emailService.sendVerificationEmail(userEmail, session);
        return ResponseEntity.ok().body(ResponseDTO.of("1","성공",sessionId));
    }

    // 이메일 인증코드 확인
    public ResponseEntity<?> checkCode(String userEmail, String code, String sessionId) {
        return emailService.checkCode(userEmail, code, sessionId);
    }

    // 유저 아이디 찾기
    public ResponseEntity<?> findUserId(String userName, String userEmail) {
        try {
            String userId = userMapper.findUserId(userName, userEmail);
            return ResponseEntity.ok().body(ResponseDTO.of("1","성공", userId));
        } catch (Exception e) {
            throw new BusinessException(ExceptionCode.FIND_USER_ID_FAIL);
        }
    }

    // 유저 비밀번호 재설정으로 이동
    public ResponseEntity<?> findUserPw(String userId, String userEmail) {
        try {
            String userNo = userMapper.findUserPw(userId, userEmail);
            return ResponseEntity.ok().body(ResponseDTO.of("1","성공", userNo));
        } catch (Exception e) {
            throw new BusinessException(ExceptionCode.FIND_USER_PW_FAIL);
        }
    }

    // 유저 비밀번호 재설정
    public ResponseEntity<?> resetUserPw(String userNo, String userPw) {
        try {
            // 저장하기 전에 비밀번호 암호화 하기
            String encodedPw = passwordEncoder.encode(userPw);

            // 암호화 된 비밀번호 저장
            userMapper.resetUserPw(userNo, encodedPw);

            return ResponseEntity.ok().body(ResponseDTO.of("1","성공", true));
        } catch (Exception e) {
            throw new BusinessException(ExceptionCode.RESET_USER_PW_FAIL);
        }
    }
}
