package com.pingo.service.signService;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.pingo.dto.ResponseDTO;
import com.pingo.entity.keywords.Keyword;
import com.pingo.entity.membership.UserMembership;
import com.pingo.entity.users.UserImage;
import com.pingo.entity.users.UserInfo;
import com.pingo.entity.users.UserSignUp;
import com.pingo.entity.users.Users;
import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import com.pingo.mapper.MembershipMapper;
import com.pingo.mapper.SignMapper;
import com.pingo.mapper.UserMapper;
import com.pingo.security.MyUserDetails;
import com.pingo.security.jwt.JwtProvider;
import com.pingo.service.keywordServices.KeywordService;
import com.pingo.service.mainService.LocationService;
import com.pingo.service.userService.EmailService;
import com.pingo.util.RedisTestService;
import com.pingo.service.ImageService;
import jakarta.mail.MessagingException;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor
@Service
public class SignService {

    private final SignMapper signMapper;
    private final UserMapper userMapper;
    private final AuthenticationManager authenticationManager;
    private final JwtProvider jwtProvider;
    private final PasswordEncoder passwordEncoder;
    private final LocationService locationService;
    private final ImageService imageService;
    private final MembershipMapper membershipMapper;
    private final KeywordService keywordService;
    private final EmailService emailService;

    // 로그인 프로세스 @Transactional 추가 및 위치정보 업데이트 로직 추가 (준혁)
    @Transactional
    public ResponseEntity<?> signInProcess(String userId, String userPw, double latitude, double longitude) {

        try {
            log.info("signInProcess.........시작");

            // 인증용 객체 생성
            UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(userId, userPw);
            // DB 조회
            // AuthenticationManager -> AuthenticationProvider(s) -> UserDetailsService -> DB 조회까지 이 한줄로 해결
            Authentication authentication = authenticationManager.authenticate(authenticationToken);
            // 인증된 사용자 정보 가져오기
            MyUserDetails userDetails = (MyUserDetails) authentication.getPrincipal();
            Users users = userDetails.getUsers();

            // 토큰 발급
            String accessToken = jwtProvider.createToken(users, 1);
            String refreshToken = jwtProvider.createToken(users, 7);

            // 멤버쉽 정보 조회
            Optional<UserMembership> userMembership = membershipMapper.selectUserMembership(users.getUserNo());

            Map<String, Object> userMap = new HashMap<>();

            userMap.put("userNo", users.getUserNo());
            userMap.put("userRole", users.getUserRole());
            userMap.put("accessToken", accessToken);
            userMap.put("refreshToken", refreshToken);

            if (userMembership.isPresent()) {
                userMap.put("expDate", userMembership.get().getExpDate());
            }

            // 위치 정보 저장 추가
            locationService.updateUserLocation(users.getUserNo(), latitude, longitude);

            log.info("signInProcess.........종료");

            return ResponseEntity.ok().body(ResponseDTO.of("1","성공",userMap));
        } catch (Exception e) {
            log.info(e.getMessage());
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(e.getMessage());
        }
    }

    // 회원가입시 아이디 중복 검사
    public ResponseEntity<?> validateId(String inputId) {
        int result = signMapper.selectUserIdForValidateId(inputId);
        if(result > 0) {
            return ResponseEntity.ok().body(ResponseDTO.of("2", "실패", false));
        }else {
            return ResponseEntity.ok().body(ResponseDTO.of("1", "성공", true));
        }
    }

    // 회원가입시 아이디 중복 검사
    public ResponseEntity<?> validateNick(String inputNick) {
        int result = signMapper.selectUserNickForValidateNick(inputNick);
        if(result > 0) {
            return ResponseEntity.ok().body(ResponseDTO.of("2", "실패", false));
        }else {
            return ResponseEntity.ok().body(ResponseDTO.of("1", "성공", true));
        }
    }

    // 회원 가입시 선택할 키워드 조회
    public ResponseEntity<?> select3ndKeyword() {
        List<Keyword> keywordList = signMapper.select3ndKeyword();
        if (keywordList.isEmpty()) {
            return ResponseEntity.ok().body(ResponseDTO.of("2", "실패", false));
        } else {
            return ResponseEntity.ok().body(ResponseDTO.of("1", "성공", keywordList));
        }
    }

    // 회원가입
    @Transactional
    public ResponseEntity<?> signUpProcess(String userSignUp, MultipartFile profileImage, double latitude, double longitude) {

        try {
            // 0. userSignUp이 String이니까 이걸 객체로 변환하기 (제이슨 변환기)
            ObjectMapper objectMapper = new ObjectMapper();
            objectMapper.registerModule(new JavaTimeModule());
            UserSignUp userSignUpData = objectMapper.readValue(userSignUp, UserSignUp.class);

            // 1-1. user 값 검증
            Users validatedUsers = userSignUpData.getUsers().validatedSignUpUserData();
            int duplicateIdCount = signMapper.selectUserIdForValidateId(validatedUsers.getUserId());
            if (duplicateIdCount > 0) {
                throw new BusinessException(ExceptionCode.DUPLICATE_USER_NO);
            }

            // 1-2. 저장하기 전에 비밀번호 암호화 하기
            // Users users = userSignUpData.getUsers();
            // String userPw = users.getUserPw();
            // passwordEncoder.encode(userPw);
            String encodedPw = passwordEncoder.encode(validatedUsers.getUserPw());
            validatedUsers.setEncodingPw(encodedPw);
            log.info("검증 다된 users : " + validatedUsers);

            // 1-3. users 테이블에 정보 넣기
            signMapper.insertUserForSignUp(validatedUsers);

            // 2-2. userInfo 값 검증
            UserInfo validatedUserInfo = userSignUpData.getUserInfo().validatedSignUpUserInfoData();
            validatedUserInfo.insertUserNo(validatedUsers.getUserNo());
            log.info("유저 상세 정보 : " + validatedUserInfo);

            // 2-2. userInfo 테이블에 정보 넣기
            signMapper.insertUserInfoForSignUp(validatedUserInfo);

            // 3-1. 이미지 서버에 저장하기
            UserImage userImage = new UserImage();
            userImage.makeImageNo();
            String imageNo = userImage.getImageNo();

            String userImagePath = "users" + File.separator + validatedUsers.getUserNo();
            String imageUrl = imageService.imageUpload(profileImage, userImagePath, imageNo);

            // 3-2. 이미지 디비에 저장하기
            userMapper.addUserImage(imageNo, imageUrl, "T", validatedUsers.getUserNo());

            // 4. 유저 키워드 저장하기
            keywordService.insertUserKeywordForSignUp(validatedUsers.getUserNo(), userSignUpData.getUserMyKeyword(), userSignUpData.getUserFavoriteKeyword());

            // 5. 위치정보 저장하기
            locationService.updateUserLocation(validatedUsers.getUserNo(), latitude, longitude);

            // 6. 유저 소개 테이블 정보 추가
            signMapper.insertUserIntroduction(validatedUsers.getUserNo());

            // 다 성공하면 ok 반환
            return ResponseEntity.ok().body(ResponseDTO.of("1","성공",true));

        }catch (Exception e) {
            log.error(e.getMessage());
            throw new BusinessException(ExceptionCode.SIGN_UP_FAIL);
        }
    }

    // 회원가입 이메일 인증코드 발송
    public ResponseEntity<?> verifyEmailForSignUp(String userEmail, HttpSession session) throws MessagingException {

        // 이메일 중복 여부 체크
        int duplicateEmailCount = signMapper.selectUserEmailForValidateEmail(userEmail);
        if (duplicateEmailCount > 0) {
            throw new BusinessException(ExceptionCode.DUPLICATE_USER_EMAIL);
        }

        // 이메일 인증코드 발송
        String sessionId = emailService.sendVerificationEmail(userEmail, session);
        return ResponseEntity.ok().body(ResponseDTO.of("1","성공",sessionId));
    }
}
