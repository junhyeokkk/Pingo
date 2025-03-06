package com.pingo.mapper;

import com.pingo.dto.profile.MainProfileResponseDTO;
import com.pingo.entity.match.Matching;
import com.pingo.entity.users.Userlocation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface MatchingMapper {

    // 매칭 테이블 삽입
    void insertMatching(Matching matching);

}
