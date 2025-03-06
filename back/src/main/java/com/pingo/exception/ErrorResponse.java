package com.pingo.exception;

import java.time.LocalDateTime;

/*
 *  ※ ErrorResponse Class
 *     - 예외 처리 후 클라이언트에게 반환할 응답 데이터를 캡슐화하는 역할
 *     - 예외가 발생했을 때 클라이언트가 이해할 수 있는 일관된 형식의 에러 정보를 제공하기 위함
 *     - 상태 코드, 에러 코드, 메시지를 객체 형태로 관리하여 유지보수성을 향상
 * 
 *     √ 직렬화 (Serialization)
 *       - 객체를 저장하거나 네트워크를 통해 전송할 수 있는 형식으로 변환하는 과정
 *       - Spring Boot와 같은 프레임워크에서는 Java 객체를 JSON, XML 등의 형식으로 변환하는 직렬화가 필요
 *       - Spring Boot는 Jackson 라이브러리를 사용하여 객체를 JSON으로 변환
 *       - Jackson과 같은 JSON 라이브러리가 객체를 JSON으로 변환할 때, 객체의 필드 값을 읽기 위해 getter 메서드를 사용
 *       - Java의 캡슐화 원칙 때문에, 필드에 직접 접근할 수 없으므로 Jackson은 getter를 통해 필드 값을 읽음
 * 
 *     √ Jackson 직렬화 과정
 *       - Java 객체의 각 필드 값을 가져오려고 시도
 *       - 각 필드에 대해 get<FieldName>() 형식의 메서드를 찾음
 *       - 찾은 getter를 호출하여 값을 가져와 JSON으로 변환
 *       - getter가 없는 경우 InvalidDefinitionException 발생
 */

public class ErrorResponse {
    private int status;            // HTTP 상태 코드
    private String code;           // 애플리케이션 에러 코드
    private String message;        // 에러 메시지
    private LocalDateTime timestamp; // 에러 발생 시각

    public ErrorResponse(int status, String code, String message) {
        this.status = status;
        this.code = code;
        this.message = message;
        this.timestamp = LocalDateTime.now(); // 현재 시각 자동 설정
    }

    // Getter 메서드 (직렬화를 위해 필수)
    public int getStatus() {
        return status;
    }

    public String getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }
    
    public LocalDateTime getTimestamp() {
        return timestamp;
    }
}
