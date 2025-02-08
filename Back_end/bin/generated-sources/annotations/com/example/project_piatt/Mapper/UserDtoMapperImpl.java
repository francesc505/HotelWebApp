package com.example.project_piatt.Mapper;

import com.example.project_piatt.Entity.User;
import com.example.project_piatt.Model.UserDTO;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-02-08T15:38:42+0100",
    comments = "version: 1.5.3.Final, compiler: Eclipse JDT (IDE) 3.41.0.z20250115-2156, environment: Java 21.0.5 (Eclipse Adoptium)"
)
@Component
public class UserDtoMapperImpl implements UserDtoMapper {

    @Override
    public UserDTO toDto(User user) {
        if ( user == null ) {
            return null;
        }

        UserDTO.UserDTOBuilder userDTO = UserDTO.builder();

        userDTO.cognome( user.getCognome() );
        userDTO.email( user.getEmail() );
        userDTO.id( user.getId() );
        userDTO.nome( user.getNome() );
        userDTO.username( user.getUsername() );

        return userDTO.build();
    }

    @Override
    public User toEntity(UserDTO userDTO) {
        if ( userDTO == null ) {
            return null;
        }

        User user = new User();

        user.setCognome( userDTO.getCognome() );
        user.setEmail( userDTO.getEmail() );
        user.setId( userDTO.getId() );
        user.setNome( userDTO.getNome() );
        user.setUsername( userDTO.getUsername() );

        return user;
    }
}
