package com.pingo.mapper;

import com.pingo.entity.keywords.Keyword;
import com.pingo.entity.users.UserKeyword;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface KeywordMapper {
    // 키워드 카테고리 목록 조회
    public List<Keyword> selectKeywordListFor2ndCategory();

    // 특정 키워드의 자식 키워드 조회
    public List<String> selectChildKeyword(@Param("kwParentId") String kwParentId);

    // 회원 키워드 목록 조회 (1명)
    public UserKeyword selectUserKeyword(@Param("userNo") String userNo);

    // 회원 키워드 목록 조회 (여러명 Map<String, Object> 구조 인데 Object에는 List<String> 구조로 userNo값)
    public List<UserKeyword> selectMultiUserKeyword(Map<String, Object> params);

    // 회원 키워드 저장 (회원가입)
    public void insertUserKeywordForSignUp(@Param("userNo") String userNo,
                                           @Param("userMyKeyword") String userMyKeyword,
                                           @Param("userFavoriteKeyword") String userFavoriteKeyword);
}
