package com.pingo.mapper;

import com.pingo.dto.profile.CheckPingProfileResponseDTO;
import com.pingo.entity.swipe.Swipe;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SwipeMapper {

    // 스와이프 저장
    void insertUserSwipe(Swipe swipe);

    // 상대방 PING 조사여부
    boolean isSwipeMatched(@Param("fromUserNo") String fromUserNo, @Param("toUserNo") String toUserNo);

    // 나를 PING or SUPERPING 한 유저 조회
    List<CheckPingProfileResponseDTO> selectPingorSuperpingbyme(@Param("userNo") String userNo);
}
