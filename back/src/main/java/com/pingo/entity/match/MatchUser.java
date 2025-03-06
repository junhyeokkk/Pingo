package com.pingo.entity.match;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Getter
@ToString
@AllArgsConstructor
@NoArgsConstructor
public class MatchUser {
    private String userName;
    private String userBirth;
    private String imageUrl;
}
