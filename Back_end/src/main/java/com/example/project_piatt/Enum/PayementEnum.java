package com.example.project_piatt.Enum;

public enum PayementEnum {
    PROCESSING("PROCESSING"),
    ACCEPTED("ACCEPTED"),

    REFUSED("REFUSED");

    private String status;

    PayementEnum(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }

    public static PayementEnum getBookEnumByValue(String value){
        for (PayementEnum usage : PayementEnum.values()) {
            if (usage.getStatus().equalsIgnoreCase(value)) {
                return usage;
            }
        }
        return null;
    }

}
