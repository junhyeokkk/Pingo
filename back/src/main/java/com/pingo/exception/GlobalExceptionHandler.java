package com.pingo.exception;

import com.pingo.dto.ResponseDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import lombok.extern.slf4j.Slf4j;

/*
 *  ※ GlobalExceptionHandler Class
 *     - Spring Boot에서 애플리케이션 전반에 걸쳐 발생하는 예외를 한 곳에서 처리하기 위함
 *     - @ControllerAdvice와 @ExceptionHandler 어노테이션을 활용하여 구현
 *     - 모든 컨트롤러에서 발생하는 예외를 전역적으로 처리하여, 예외 처리 코드를 중복 없이 관리
 * 
 *     √ @ControllerAdvice
 *       - 컨트롤러(@Controller) 전역에서 발생하는 예외를 처리할 수 있도록 해주는 어노테이션
 *       - @RestControllerAdvice를 사용하면 자동으로 @ResponseBody를 추가하여 JSON 형식의 응답 반환
 *       - Restfull 구조에서 Service, Repositroy, Entity 등 어떤 클래스에서 예외가 발생해도 Controller를 통함
 * 
 *     √ @ExceptionHandler
 *       - 특정 예외를 처리하는 메서드에 붙이는 어노테이션
 *       - 메서드는 처리할 예외 클래스 타입을 지정하고, 예외 발생 시 실행
 *       - 아래 코드에서 @ExceptionHandler(BusinessException.class)의 뜻은 BusinessException 발생 시
 *         BusinessException을 handleBusinessException 메서드를 이용해 처리하겠다는 뜻
 *       - 비즈니스 로직에서 [throw new BusinessException(~~)] 발생 시 BusinessException을 감지해
 *         handleBusinessException 메서드에서 BusinessException을 처리하겠다는 뜻
 */

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<?> handleBusinessException(BusinessException ex) {
        ErrorResponse errorResponse = new ErrorResponse(
            ex.getStatus(),
            ex.getCode(),
            ex.getMessage()
        );

        return ResponseEntity
                .status(ex.getStatus())
                .body(ResponseDTO.of("2","실패",errorResponse));
    }
}
