package com.pingo.entity.keywords;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Getter
@ToString
@AllArgsConstructor
@NoArgsConstructor
public class Keyword {
    private String kwId;
    private String kwName;
    private String kwParentId;
    private String kwMessage;
    private String kwLevel;
}
