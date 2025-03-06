package com.pingo.mapper;

import com.pingo.entity.membership.Membership;
import com.pingo.entity.membership.UserMembership;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Optional;

@Mapper
public interface MembershipMapper {
    // 유저 멤버쉽 조회
    public Optional<UserMembership> selectUserMembership(@Param("userNo") String userNo);

    // 멤버쉽 조회
    public List<Membership> selectMembership();

    // 멤버쉽 등록
    public void insertUserMembership(UserMembership membership);
}
