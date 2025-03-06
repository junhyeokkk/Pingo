package com.pingo.service.mainService;

import com.pingo.dto.ResponseDTO;
import com.pingo.dto.profile.MainProfileResponseDTO;
import com.pingo.entity.users.Userlocation;
import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import com.pingo.mapper.LocationMapper;
import com.pingo.util.GeoUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.geo.Point;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class LocationService {

    private final LocationMapper locationMapper;
    private final StringRedisTemplate stringRedisTemplate;

    // 유저 위치 저장 <리팩토링 필요>
    @Transactional
    public void updateUserLocation(String userNo, Double latitude, Double longitude) {
        // 1. 유효성 검사
        if (userNo == null || userNo.trim().isEmpty()) {
            log.error("[오류] 사용자 번호 없음.");
            throw new BusinessException(ExceptionCode.MISSING_USER_NO);
        }

        if (latitude == null || longitude == null) {
            log.error("[오류] 위치 정보 없음.");
            throw new BusinessException(ExceptionCode.MISSING_LOCATION_INFO);
        }

        Point newPoint = new Point(longitude, latitude);
        log.info("[위치 저장 요청] userNo: {}, latitude: {}, longitude: {}", userNo, latitude, longitude);

        try {
            // 1. Redis에서 기존 위치 가져오기
            List<Point> existingPoints = stringRedisTemplate.opsForGeo().position("geo:user_locations", userNo);
            Point previousPoint = (existingPoints == null || existingPoints.isEmpty()) ? null : existingPoints.get(0);

            // 2. Redis에 없으면 Oracle에서 조회하여 다시 Redis에 저장
            if (previousPoint == null) {
                log.info("[Redis 미스] Redis에 데이터 없음 → Oracle에서 조회");
                Userlocation oracleLocation = locationMapper.getUserLocation(userNo);

                if (oracleLocation != null) {
                    previousPoint = new Point(oracleLocation.getLongitude(), oracleLocation.getLatitude());
                    stringRedisTemplate.opsForGeo().add("geo:user_locations", previousPoint, userNo);
                    log.info("[Redis 동기화] Oracle 데이터 Redis에 캐싱 완료 userNo: {}", userNo);
                } else {
                    log.info("[최초 위치 저장] Oracle에도 데이터 없음 → 새로운 데이터 삽입");
                    locationMapper.updateUserLocation(userNo, latitude, longitude);
                    stringRedisTemplate.opsForGeo().add("geo:user_locations", newPoint, userNo);
                    log.info("[Oracle & Redis 삽입 완료] userNo: {} -> ({}, {})", userNo, latitude, longitude);
                    return; // INSERT 후 종료
                }
            }

            // 3. Oracle에 없는 경우 예외 처리 (Redis에는 있는데 Oracle에 없는 상태)
            Userlocation oracleLocation = locationMapper.getUserLocation(userNo);
            if (oracleLocation == null) {
                log.warn("[데이터 불일치] Redis에는 있지만 Oracle에 없음 → Oracle에 삽입");
                locationMapper.updateUserLocation(userNo, latitude, longitude);
                log.info("[Oracle 삽입 완료] userNo: {} -> ({}, {})", userNo, latitude, longitude);
                return; // INSERT 후 종료
            }

            // 4. 위치 비교 후 500m 이상 이동 시만 Oracle 업데이트 실행
            if (previousPoint != null) {
                double distance = GeoUtils.calculateDistance(previousPoint, newPoint);
                log.info("[거리 계산] userNo: {}, 거리: {} km", userNo, distance);

                if (distance < 0.5) {
                    log.info("[Oracle 업데이트 스킵] 500m 미만 이동으로 DB 업데이트 안 함.");
                    return;
                }
            }

            // 5. Oracle에 위치 저장 (MERGE INTO 사용)
            locationMapper.updateUserLocation(userNo, latitude, longitude);
            log.info("[Oracle 위치 저장 완료] userNo: {} -> ({}, {})", userNo, latitude, longitude);

        } catch (Exception e) {
            log.error("[위치 저장 오류] userNo: {}, 오류: {}", userNo, e.getMessage(), e);
            throw new BusinessException(ExceptionCode.LOCATION_UPDATE_FAILED);
        }
    }


    // 반경 내 유저 검색
    public ResponseEntity<?> getNearbyUsersForMain(String userNo, int distanceKm) {
        log.info("getNearbyUsers 호출 - userNo: {}, distanceKm: {}", userNo, distanceKm);

        List<MainProfileResponseDTO> users = selectNearbyUsers(userNo, distanceKm);

        log.info("최종 유저 목록 반환 완료");
        return ResponseEntity.ok().body(ResponseDTO.of("1","성공", users));
    }

    // 반경 내 유저 검색
    public List<MainProfileResponseDTO> selectNearbyUsers(String userNo, int distanceKm) {
        List<MainProfileResponseDTO> users = locationMapper.findNearbyUsers(userNo, distanceKm);
        log.info("검색된 유저 수: {}", users.size());

        users.forEach(user -> {
            // 나이정보 set
            user.calculateAge(user.getUserBirth());
            log.info("유저 정보 - userNo: {}, userName: {}, images: {}, age: {}, status:{}, distance:{}",
                    user.getUserNo(), user.getUserName(), user.getImages() , user.getAge(), user.getStatus(), user.getDistance());

            //  images를 List<String>으로 변환하여 로그 출력
            user.getImagesAsList();
            log.info("변환된 이미지 리스트 - userNo: {}, images: {}", user.getUserNo(), user.getImageList());
        });
        return users;
    }
}
