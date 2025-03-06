package com.pingo.dto;

import com.pingo.entity.users.UserInfo;
import com.pingo.entity.users.Users;
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
