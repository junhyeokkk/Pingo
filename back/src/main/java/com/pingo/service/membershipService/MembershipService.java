package com.pingo.service.membershipService;

import com.pingo.dto.ResponseDTO;
import com.pingo.entity.membership.Membership;
import com.pingo.entity.membership.UserMembership;
import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import com.pingo.mapper.MembershipMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.*;

@Slf4j
@RequiredArgsConstructor
@Service
public class MembershipService {

    final private MembershipMapper membershipMapper;

    // 멤버쉽 조회
    public ResponseEntity<?> getMembership(String userNo) {
        Optional<UserMembership> userMembership = membershipMapper.selectUserMembership(userNo);
        List<Membership> membershipList = membershipMapper.selectMembership();

        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("membership", membershipList);

        if (userMembership.isEmpty()) {
            resultMap.put("userMembership", null);
        }else {
            resultMap.put("userMembership", userMembership.get());
        }

        return ResponseEntity.ok().body(ResponseDTO.of("1", "성공", resultMap));
    }

    // 멤버쉽 등록
    public ResponseEntity<?> setMembership(String msNo, String userNo) {

        try {
            Optional<UserMembership> userMembership = membershipMapper.selectUserMembership(userNo);

            if (userMembership.isPresent()) {
                throw new BusinessException(ExceptionCode.DUPLICATE_MEMBERSHIP);
            }

            UserMembership newMembership = new UserMembership();
            newMembership.createMembershipInfo(msNo, userNo);

            membershipMapper.insertUserMembership(newMembership);

            return ResponseEntity.ok().body(ResponseDTO.of("1","성공",newMembership.getExpDate().toString()));
        } catch (Exception e) {
            throw new BusinessException(ExceptionCode.MEMBERSHIP_PROCESS_FAIL);
        }
    }

}
