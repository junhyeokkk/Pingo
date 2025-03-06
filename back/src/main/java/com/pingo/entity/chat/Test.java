package com.pingo.entity.chat;

// 클래스
public class Test {
    // 필드
    String name;
    int age;

    // 생성자 (특수한 메서드)
    public Test(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public Test() {
    }

    // 메서드 (선언부[지시제어자 + 리턴타입 + 이름 + 매개변수] + 구현부{})
    public String getName() {
        return name;
    }
}
