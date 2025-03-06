package com.pingo.mapper;

import com.pingo.dto.profile.MainProfileResponseDTO;
import com.pingo.entity.users.Userlocation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface LocationMapper {

    // 기존 사용자 위치 조회 (Oracle에서 Redis 동기화를 위해 사용)
    Userlocation getUserLocation(@Param("userNo") String userNo);


    // 유저 위치 저장 (있으면 UPDATE, 없으면 INSERT)
    void updateUserLocation(@Param("userNo") String userNo,
                            @Param("latitude") double latitude,
                            @Param("longitude") double longitude);

    // 반경 내 유저 검색
    List<MainProfileResponseDTO> findNearbyUsers(@Param("userNo") String userNo,
                                                 @Param("distanceKm") int distanceKm);

}
