# Pingo - 소개팅 앱 프로젝트 (Flutter, Spring Boot)

<img src = "./Pingo 사진.png">

Pingo 프로젝트는 사용자 주변의 사람들과 프로필을 확인하고, 호감을 표시하여 매칭이 이루어지면 대화를 통해 인연을 만들어가는 소셜 데이팅 서비스입니다.  
단순히 호감 표시와 채팅 기능에 그치는 것이 아니라, 장소 추천, 커뮤니티 기능 등을 통해 매칭 이후에도 지속적으로 관계를 발전시킬 수 있도록 다양한 서비스를 제공합니다.

## 📌 프로젝트 개요
- **프로젝트명:** Pingo (소개팅 앱)
- **개발 기간:** 2025.01.20 ~ 2025.03.06
- **팀원:** 박임재, 최준혁, 정지현, 이준석 (총 4명)

- **시연 영상:** [YouTube](https://www.youtube.com/watch?v=b9xO2-tBJ1s)
- **발표 자료:** (https://www.canva.com/design/DAGglvEUMs8/WOk68xmx20-9XcPX8QR_Ug/edit?utm_content=DAGglvEUMs8&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

---

## 📱 주요 기능

### 🗺️ 위치 기반 유저 매칭
- **Geolocator** 라이브러리를 활용한 GPS 데이터 실시간 수집
- 500m 이상 이동 시 **Redis + Oracle**을 활용하여 실시간 데이터 업데이트
- **Oracle SDO_GEOM**을 활용하여 반경 내 유저 검색 및 거리 기준 정렬

### 🔥 스와이프 기반 매칭 시스템
- **좌/우 스와이프** (PING/좋아요, PANG/싫어요), **위쪽 스와이프** (SUPERPING/매우 좋아요) 적용
- **Kafka + CompletableFuture**를 활용한 비동기 이벤트 처리
- **매칭 성사 시 자동 채팅방 생성** 및 **WebSocket**을 통한 실시간 알림 전송

### 🎯 사용자 맞춤 필터링 및 설정 관리
- **Riverpod**을 활용한 상태 관리 및 UI 자동 갱신
- 최대 거리, 연령대, 필터링 옵션 등 **사용자 맞춤 추천 시스템 적용**
- **프리미엄 사용자 기능 차별화** (고급 필터, 프로필 사진 확장, 좋아요 유저 목록 공개)

### 💌 시그널 페이지 (나를 좋아요한 유저 조회)
- **무료 사용자:** 일반 좋아요(PING) 유저 블러 처리  
- **프리미엄 사용자:** 모든 좋아요 유저 정보 확인 가능

### 💳 결제 시스템
- **프리미엄 멤버십 가입을 위한 결제 기능 제공**
- 무료 사용자와 프리미엄 사용자 기능 차별화

### 🏠 장소 추천 기능
- 사용자의 위치를 기반으로 **데이트 장소 추천**
- **Kakao Map API**를 활용한 위치 검색 및 표시

### 💬 실시간 채팅
- **STOMP WebSocket**을 이용한 실시간 채팅 기능 구현
- 메시지 전송 및 읽기 기능 제공

---

## 🛠️ 사용 기술

### **Frontend**
- **Flutter** - 크로스 플랫폼 UI 프레임워크
- **Dart** - Flutter 애플리케이션 개발 언어
- **Riverpod** - 상태 관리 라이브러리
- **Dio** - 네트워크 요청 최적화
- **Geolocator** - GPS 및 위치 추적
- **STOMP (stomp_dart_client)** - WebSocket 메시징 프로토콜 지원
- **Flutter Secure Storage** - 보안 저장소
- **Kakao Map Plugin** - 위치 기반 UI 및 장소 검색
- **Shared Preferences** - 사용자 설정 저장

### **Backend**
- **Spring Boot** - 확장성과 유지보수성이 뛰어난 백엔드 프레임워크
- **MyBatis** - SQL 데이터 매핑
- **Spring WebSocket** - 실시간 알림 및 채팅 기능
- **Spring Security / JWT** - 인증 및 권한 관리
- **Redis** - 데이터 캐싱 및 성능 최적화
- **Kafka** - 대규모 데이터 로깅 및 비동기 메시지 처리
- **MongoDB** - NoSQL 데이터베이스
- **Oracle DB** - 관계형 데이터 관리
- **Gmail SMTP** - 이메일 인증 및 알림 기능

### **Infra & DevOps**
- **Docker** - 컨테이너 기반 환경 구성
- **AWS EC2** - 클라우드 서버 운영
- **GitHub Actions** - CI/CD 자동화 구축

---

## 🏆 내가 기여한 부분

### 1️⃣ 위치 기반 서비스 및 유저 매칭 시스템 구축
- **Redis + Oracle을 활용한 위치 데이터 실시간 조회 및 관리**
- 500m 이상 이동 시 Redis에 반영 & 일정 주기로 Oracle 업데이트
- **Oracle SDO_GEOM** 활용하여 반경 내 유저 검색 및 거리 기준 정렬
- **Geolocator**를 활용하여 GPS 데이터 실시간 수집 및 UI 반영

### 2️⃣ 스와이프 기반 매칭 시스템 구현
- **스와이프 이벤트 & 애니메이션 적용** (PING, PANG, SUPERPING)
- **Kafka + CompletableFuture**를 활용한 비동기 이벤트 처리
- **매칭 성사 시 자동 채팅방 생성** 및 **WebSocket**을 통한 실시간 알림 전송

### 3️⃣ 사용자 맞춤 필터링 및 설정 관리
- **SharedPreferences**를 활용한 사용자 맞춤 설정 저장
- **프리미엄 사용자 기능 차별화** (거리 제한 해제, 프로필 확장, 필터 세분화 등)
- **설정 변경 시 UI 즉시 업데이트** 및 유저 추천 목록 자동 갱신

### 4️⃣ 시그널 페이지 (나를 좋아요한 유저 조회)
- **무료 사용자:** 일반 좋아요(PING) 유저 블러 처리  
- **프리미엄 사용자:** 모든 좋아요 유저 정보 확인 가능


---

## 📬 연락처
- **이메일:** loveu9911111@gmail.com
- **전화번호:** 010-3450-7418

---
