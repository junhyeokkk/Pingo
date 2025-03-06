package com.pingo.entity.community;

import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.util.UUID;

@Getter
@ToString
@AllArgsConstructor
@NoArgsConstructor
public class PlaceReview {
    private String prNo;
    private String placeName;
    private String thumb;
    private String addressName;
    private String roadAddressName;
    private String userNo;
    private String contents;
    private String category;
    private double latitude;
    private double longitude;
    private int heart;

    public void createPrNo() {
        if(this.prNo == null) {
            this.prNo = "PR" + createNo();
        }else {
            throw new BusinessException(ExceptionCode.DUPLICATE_PLACE_REVIEW_NO);
        }
    }

    public String createThumbName() {
        if(this.thumb == null) {
            return "PI" + createNo();
        }else {
            throw new BusinessException(ExceptionCode.DUPLICATE_REVIEW_IMAGE_NO);
        }
    }

    private String createNo() {
        return UUID.randomUUID().toString().substring(0, 8);
    }

    public void insertThumb(String imageUrl) {
        this.thumb = imageUrl;
    }
}
