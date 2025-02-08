package com.example.project_piatt.Mapper;

import com.example.project_piatt.Entity.Role;
import com.example.project_piatt.Enum.RoleEnum;
import com.example.project_piatt.Model.RoleDTO;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2024-12-12T10:41:10+0100",
    comments = "version: 1.5.3.Final, compiler: IncrementalProcessingEnvironment from gradle-language-java-8.10.2.jar, environment: Java 17.0.13 (Amazon.com Inc.)"
)
@Component
public class RoleDtoMapperImpl implements RoleDtoMapper {

    @Override
    public RoleDTO toDto(Role role) {
        if ( role == null ) {
            return null;
        }

        RoleDTO.RoleDTOBuilder roleDTO = RoleDTO.builder();

        roleDTO.id( role.getId() );
        if ( role.getRoleName() != null ) {
            roleDTO.roleName( role.getRoleName().name() );
        }

        return roleDTO.build();
    }

    @Override
    public Role toEntity(RoleDTO role) {
        if ( role == null ) {
            return null;
        }

        Role role1 = new Role();

        role1.setId( role.getId() );
        if ( role.getRoleName() != null ) {
            role1.setRoleName( Enum.valueOf( RoleEnum.class, role.getRoleName() ) );
        }

        return role1;
    }

    @Override
    public List<RoleDTO> toDtoList(List<Role> roles) {
        if ( roles == null ) {
            return null;
        }

        List<RoleDTO> list = new ArrayList<RoleDTO>( roles.size() );
        for ( Role role : roles ) {
            list.add( toDto( role ) );
        }

        return list;
    }

    @Override
    public List<Role> toEntityList(List<RoleDTO> roleDTOs) {
        if ( roleDTOs == null ) {
            return null;
        }

        List<Role> list = new ArrayList<Role>( roleDTOs.size() );
        for ( RoleDTO roleDTO : roleDTOs ) {
            list.add( toEntity( roleDTO ) );
        }

        return list;
    }
}
