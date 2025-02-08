package com.example.project_piatt.Mapper;


import com.example.project_piatt.Entity.Role;
import com.example.project_piatt.Model.RoleDTO;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface RoleDtoMapper {
    RoleDTO toDto(Role role);
    Role toEntity(RoleDTO role);

    List<RoleDTO> toDtoList(List<Role> roles);
    List<Role> toEntityList(List<RoleDTO> roleDTOs);

}
