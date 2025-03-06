package com.pingo.entity.users;

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
public class UserImage {
    private String imageNo;
    private String imageUrl;
    private String imageProfile;
    private String userNo;

    // imageNo 생성 로직 (중복 호출시 예외 처리)
    public String createImageNo() {
        if(this.imageNo == null) {
            String uuid = UUID.randomUUID().toString();
            return "UI" + uuid.substring(0, 8);
        }else {
            throw new BusinessException(ExceptionCode.DUPLICATE_IMAGE_NO);
        }
    }

    public void makeImageNo() {
        this.imageNo = createImageNo();
    }
}
