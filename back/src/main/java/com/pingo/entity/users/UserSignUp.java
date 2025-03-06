package com.pingo.entity.users;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Getter
@ToString
@AllArgsConstructor
@NoArgsConstructor
public class UserSignUp {
    private Users users;
    private UserInfo userInfo;
    private String userMyKeyword;
    private String userFavoriteKeyword;
}
