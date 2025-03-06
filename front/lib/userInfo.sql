-- 테이블 생성 쿼리문
--- 유저 테이블 생성
CREATE TABLE "users"
(
	"userNo"		VARCHAR2(10)	PRIMARY KEY,
	"userId"		VARCHAR2(12)	NOT NULL,
	"userPw"		VARCHAR2(255)	NOT NULL,
	"userName"		VARCHAR2(10)	NOT NULL,
	"userNick"		VARCHAR2(10)	NOT NULL,
	"userGender"	CHAR(1)			NOT NULL,
	"userBirth"		DATE			NOT NULL,
	"userState"		CHAR(4)			NOT NULL,
	"userrDate"		TIMESTAMP		NOT NULL,
)

--- 유저이미지 테이블 생성
CREATE TABLE "userImage"
(
	"imageNo"		INTEGER			PRIMARY KEY,
	"imageUrl"		VARCHAR2(20)	NOT NULL,
	"imageProfile"	VARCHAR2(8)		NOT NULL,
	"userNo"		VARCHAR2(10)	NOT NULL,
)
---- userNo 외래키 설정


--- 유저 상세 정보 테이블 생성



-- 설정 쿼리문

