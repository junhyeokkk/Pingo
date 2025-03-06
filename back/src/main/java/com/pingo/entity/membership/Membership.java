package com.pingo.entity.membership;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Getter
@ToString
@AllArgsConstructor
@NoArgsConstructor
public class Membership {
    private String msNo;
    private String title;
    private int period;
    private String contents;
    private int price;
}
