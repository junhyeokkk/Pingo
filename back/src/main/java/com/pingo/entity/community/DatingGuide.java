package com.pingo.entity.community;

import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@ToString
@AllArgsConstructor
@NoArgsConstructor
public class DatingGuide {
    private String dgNo;
    private String title;
    private String contents;
    private String thumb;
    private int category;
    private String userNo;
    private int heart;
    private LocalDateTime regDate;

    public void createDgNo() {
        if(this.dgNo == null) {
            this.dgNo = "DG" + createNo();
        }else {
            throw new BusinessException(ExceptionCode.DUPLICATE_DATING_GUIDE_NO);
        }
    }

    public String createThumbName() {
        if(this.thumb == null) {
            return "GI" + createNo();
        }else {
            throw new BusinessException(ExceptionCode.DUPLICATE_GUIDE_IMAGE_NO);
        }
    }
    private String createNo() {
        return UUID.randomUUID().toString().substring(0, 8);
    }
    public void insertThumb(String imageUrl) {
        this.thumb = imageUrl;
    }

}
