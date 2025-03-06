package com.pingo.entity.users;

import com.pingo.entity.keywords.Keyword;
import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Getter
@ToString
@AllArgsConstructor
@NoArgsConstructor
public class UserMypageInfo {

    private Users users;
    private UserInfo userInfo;
    private List<UserImage> userImageList;
    private List<Keyword> myKeywordList;
    private List<Keyword> favoriteKeywordList;
    private String userIntroduction;

    public void inputUserImage(List<UserImage> userImageList) {
        this.userImageList = userImageList;
    }

    public void inputUserKeyword(Map<String, List<Keyword>> userKeyword) {
        this.myKeywordList = userKeyword.get("my");
        this.favoriteKeywordList = userKeyword.get("favorite");
    }

    public void inputUserIntroduction(String introduction) {
        this.userIntroduction = introduction;
    }
}
