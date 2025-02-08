package com.example.project_piatt.Mapper;

import com.example.project_piatt.Entity.Room;
import com.example.project_piatt.Model.RoomDTO;
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
public class RoomDtoMapperImpl implements RoomDtoMapper {

    @Override
    public RoomDTO toDto(Room room) {
        if ( room == null ) {
            return null;
        }

        RoomDTO.RoomDTOBuilder roomDTO = RoomDTO.builder();

        roomDTO.id( room.getId() );
        roomDTO.nome( room.getNome() );
        roomDTO.tipo( room.getTipo() );
        roomDTO.descrizione( room.getDescrizione() );
        roomDTO.prezzo( room.getPrezzo() );
        roomDTO.imageName( room.getImageName() );
        roomDTO.persone( room.getPersone() );

        return roomDTO.build();
    }

    @Override
    public Room toEntity(RoomDTO roomDTO) {
        if ( roomDTO == null ) {
            return null;
        }

        Room room = new Room();

        room.setId( roomDTO.getId() );
        room.setNome( roomDTO.getNome() );
        room.setTipo( roomDTO.getTipo() );
        room.setDescrizione( roomDTO.getDescrizione() );
        room.setPrezzo( roomDTO.getPrezzo() );
        room.setImageName( roomDTO.getImageName() );
        room.setPersone( roomDTO.getPersone() );

        return room;
    }

    @Override
    public List<RoomDTO> toDtoList(List<Room> room) {
        if ( room == null ) {
            return null;
        }

        List<RoomDTO> list = new ArrayList<RoomDTO>( room.size() );
        for ( Room room1 : room ) {
            list.add( toDto( room1 ) );
        }

        return list;
    }
}
