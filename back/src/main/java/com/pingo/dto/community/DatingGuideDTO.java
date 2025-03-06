package com.pingo.dto.community;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.time.LocalDateTime;

@Getter
@ToString
@AllArgsConstructor
@NoArgsConstructor
public class DatingGuideDTO {
    private String dgNo;
    private String title;
    private String contents;
    private String thumb;
    private String userNo;
    private int heart;
    private LocalDateTime regDate;
    private String cateName;
    private int cateNo;
    private String userName;
    private String imageUrl;
}