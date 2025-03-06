package com.pingo.exception;

/*
 *  ※ BusinessException Class
 *     - 비즈니스 로직과 연관된 RuntimeException을 관리하는 Class
 *     - 비즈니스 로직에서 발생할 수 있는 다양한 예외를 캡슐화하기 위한 Class
 *     - ExceptionCode Class와 연계하여 예외 객체를 구조적으로 관리
 */

public class BusinessException extends RuntimeException{

    private final ExceptionCode exceptionCode;

    public BusinessException(ExceptionCode exceptionCode) {
        super(exceptionCode.getMessage());
        this.exceptionCode = exceptionCode;
    }

    public int getStatus() {
        return exceptionCode.getStatus();
    }

    public String getCode() {
        return exceptionCode.getCode();
    }

    public String getMessage() {
        return exceptionCode.getMessage();
    }
}
