package com.pingo.entity.keywords;

import lombok.Getter;
import lombok.ToString;

import java.util.ArrayList;
import java.util.List;
@Getter
@ToString
public class KeywordGroup {
    private String kwId;
    private String kwName;
    private String kwMessage;
    private List<Keyword> childKeyword;

    public KeywordGroup(String kwId, String kwName, String kwMessage) {
        this.kwId = kwId;
        this.kwName = kwName;
        this.kwMessage = kwMessage;
        this.childKeyword = new ArrayList<>();
    }

    public void addChildKeyword(Keyword keyword) {
        if (this.kwId.equals(keyword.getKwParentId())) {
            this.childKeyword.add(keyword);
        }
    }
}
