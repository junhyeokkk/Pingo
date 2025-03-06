package com.pingo.controller;

import com.pingo.entity.membership.Membership;
import com.pingo.service.membershipService.MembershipService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@Controller
public class MembershipController {

    final private MembershipService membershipService;

    // 멤버쉽 조회
    @GetMapping("/membership")
    public ResponseEntity<?> getMembership(@RequestParam("userNo") String userNo) {
        return membershipService.getMembership(userNo);
    }

    // 멤버쉽 등록
    @PostMapping("/membership")
    public ResponseEntity<?> setMembership(@RequestBody Map<String, String> reqData) {

        String msNo = reqData.get("msNo");
        String userNo = reqData.get("userNo");

        log.info(msNo + " | " + userNo);

        return membershipService.setMembership(msNo, userNo);
    }
}
