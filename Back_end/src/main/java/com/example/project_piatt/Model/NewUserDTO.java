package com.example.project_piatt.Model;

import lombok.*;

@EqualsAndHashCode(callSuper = true)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class NewUserDTO extends UserDTO {
    private String password;
}
