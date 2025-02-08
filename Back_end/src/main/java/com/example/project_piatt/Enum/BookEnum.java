package com.example.project_piatt.Enum;

import java.awt.print.Book;

public enum BookEnum {
   // PROCESSING("PROCESSING"),
    WAITING("WAITING_PAYMENT"),
    TERMINATED("PAYED");

    private String status;

    BookEnum(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }

    public static BookEnum getBookEnumByValue(String value){
        for (BookEnum usage : BookEnum.values()) {
            if (usage.getStatus().equalsIgnoreCase(value)) {
                return usage;
            }
        }
        return null;
    }

}
