package com.pingo.dto;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

// 공통 Response DTO

@Getter
@RequiredArgsConstructor(staticName = "of")
public class ResponseDTO<T> {
    private final String resultCode; // 1 성공, 2 실패
    private final String message;
    private final T data; // 반환값이 없는 경우에는 TRUE/FALSE

    @Override
    public String toString() {
        return "ResponseDTO{" +
                "resultCode='" + resultCode + '\'' +
                ", message='" + message + '\'' +
                ", data=" + data +
                '}';
    }
}
