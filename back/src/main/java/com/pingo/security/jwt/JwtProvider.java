package com.pingo.security.jwt;

import com.pingo.entity.users.Users;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.Getter;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
// JWT는 크게 헤더, 내용, 서명으로 나뉨
// Header 에는 데이터 타입과 해쉬 알고리즘이 들어감
// Payload(내용) 에 들어갈 정보들을 claim 이라고 부른다
// Signature(서명) 헤더의 인코딩값과 내용의 인코딩값을 합친 후 주어진 비밀키로 해쉬(암호화해서 나온 결과값) 하여 생성한다
@Slf4j
@Getter
@Component
public class JwtProvider {
    private String issuer;  // 토큰 발급자
    private SecretKey secretKey;    // 암호화 사용할 때 쓰는 키

    
    public JwtProvider(@Value("${jwt.issuer}") String issuer,
                       @Value("${jwt.secret}") String secretKey) {
        this.issuer = issuer;
        this.secretKey = Keys.hmacShaKeyFor(secretKey.getBytes());

    }

    // 토큰 생성
    public String createToken(Users users, int days) {
        log.info("createToken.........11");

        // 발급일 생성
        Date issuedDate = new Date();
        // 만료일 생성 : 추가될 날짜를 받아서 초로 바꾸고 발급일에 더함
        Date expireDate = new Date(issuedDate.getTime() + Duration.ofDays(days).toMillis()); 
        
        // 클레임 생성
        Claims claims = Jwts.claims();
        claims.put("userNo", users.getUserNo());
        claims.put("userRole", users.getUserRole());

        // 토큰 생성
        String token = Jwts.builder()
                .setHeaderParam(Header.TYPE, Header.JWT_TYPE)
                .setIssuer(issuer)
                .setIssuedAt(issuedDate)
                .setExpiration(expireDate)
                .addClaims(claims)
                .signWith(secretKey, SignatureAlgorithm.HS256)
                .compact();
        log.info("createToken.........22");
        return token;
    }

    // 복호화 하는 과정
    public Claims getClaims(String token) {
        return Jwts
                .parserBuilder()
                .setSigningKey(secretKey)
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
    
    public Authentication getAuthentication(String token) {
        // 클레임에서 사용자, 권한 가져오기(하나하나 꺼내는 과정)
        Claims claims = getClaims(token);
        String userNo = (String) claims.get("userNo");  // 자료구조형식중에 map이 있고 이걸 사용했기에 get을 사용
        String userRole = (String) claims.get("userRole");
        
        // 권한목록 생성
        List<GrantedAuthority> authorities = new ArrayList<>();
        authorities.add(new SimpleGrantedAuthority(userRole));
        
        // 사용자 인증객체 생성
        Users principal = Users.builder()
                .userNo(userNo)
                .userRole(userRole)
                .build();

        return new UsernamePasswordAuthenticationToken(principal, token, authorities);
    }

    public boolean validateToken(String token) {
        try {
           Jwts.parserBuilder()
                   .setSigningKey(secretKey)
                   .build()
                   .parseClaimsJws(token);
           return true;
        }catch (SecurityException | MalformedJwtException e){
            // 잘못된 JWT 서명일 경우
            log.info("MalformedJwtException..." + e.getMessage());
            throw new JwtMyException(JwtMyException.JWT_ERROR.MALFORM);

        }catch (ExpiredJwtException e){
            // 만료된 JWT 경우
            log.info("ExpiredJwtException..." + e.getMessage());
            throw new JwtMyException(JwtMyException.JWT_ERROR.EXPIRED);

        }catch (UnsupportedJwtException e){
            // 지원되지 않은 JWT 경우
            log.info("UnsupportedJwtException..." + e.getMessage());
            throw new JwtMyException(JwtMyException.JWT_ERROR.BADTYPE);

        }catch (IllegalArgumentException e){
            // 잘못된 JWT 경우
            log.info("IllegalArgumentException..." + e.getMessage());
            throw new JwtMyException(JwtMyException.JWT_ERROR.BADSIGN);
        }
    }
}
