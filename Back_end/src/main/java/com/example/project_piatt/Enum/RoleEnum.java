package com.example.project_piatt.Enum;

public enum RoleEnum {

    ADMIN("ADMIN"),
    MANAGER("MANAGER"),

    CUSTOMER("CUSTOMER");

    private String status;

    RoleEnum(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }

    public static RoleEnum getRoleEnumByValue(String value){
        for (RoleEnum usage : RoleEnum.values()) {
            if (usage.getStatus().equalsIgnoreCase(value)) {
                return usage;
            }
        }
        return null;
    }
}
