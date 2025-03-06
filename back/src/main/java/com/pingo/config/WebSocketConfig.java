package com.pingo.config;

import com.pingo.service.WebSocketChatHandler;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.config.annotation.*;
import org.springframework.web.socket.server.support.DefaultHandshakeHandler;

@Configuration
@EnableWebSocket
@RequiredArgsConstructor
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    // ★ 메서드 위에다가 주석으로 설명좀
    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) { // 구독
        config.enableSimpleBroker("/topic"); // @SendTo 서버가 클라이언트로 메세지를 보낼때 사용할 경로 지정 , 클라이언트가 /sub 구독하면, 서버에서 해당 클라이언트에게 메시지를 보내줄 수 있음. / 유저가 메세지 받기
        config.setApplicationDestinationPrefixes("/pub"); // @MessageMapping 클라이언트가 서버로 메세지를 보낼 때 사용할 경로 지정 , 클라이언트가 메세지를 보낼 때 !
    }

    // ★ 메서드 위에다가 주석으로 설명좀
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws").setAllowedOriginPatterns("*").setHandshakeHandler(new DefaultHandshakeHandler());
        // 테스트를 위해 와일드카드로 모든 도메인을 열어줌. ("*")에는 웹소캣 cors 정책으로 인해 허용 도메인을 지정해주어야한다.
    }
}

// STOMP는 핸들러를 직접 사용하지 않고 메시지를 @MessageMapping으로 처리하는 컨트롤러로 보낸다. 즉 세션은 생성이 되지만 직접 핸들러에서 다루지않고 STOMP가 관리하는 방식
// 핸들러에서 세션이 만들어 졌다 = 서버에서 발급해주는 것인데

// 요청이 들어오면 webSocketHandler 로 전달된다.
// 핸들러는 WebSocket 연결 이후의 모든 데이터를 처리하는 로직을 담당한다.

// 클라이언트가 ws:// 등의 url을 사용하여 서버에 요청을 하면 요청 헤더에 Connection: Upgrade**와 Upgrade: websocket가 추가된다
// 서버는 이 요청을 확인하고 WebSocket 핸드셰이크를통해 연결을 업그레이드 함

// 웹소캣 핸드셰이크 과정은 알아서 스프링 내부에서 처리가 됨
//registerWebSocketHandlers : 웹소캣 핸들러 등록을 하기 위한 메서드
//WebSocketHandlerRegistry registry : 해당 매개변수는 웹소캣의 엔드포인트와 관련된 설정을 등록할 수 있도로 도와줌
// setAllowedOrigins : 허용 도메인 주소 설정
//ex) ws://127.0.0.1:포트/핑고

//jsessionId : 서버오 ㅏ클라이언트 , 최초로 접근 : 헤더에 발급된 아이디, 최초요청시에 최초로 발급되는 커버