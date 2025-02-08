package com.example.project_piatt.Mapper;

import com.example.project_piatt.Entity.User;
import com.example.project_piatt.Model.UserDTO;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface UserDtoMapper {
    UserDTO toDto(User user);
    User toEntity(UserDTO userDTO);

}
