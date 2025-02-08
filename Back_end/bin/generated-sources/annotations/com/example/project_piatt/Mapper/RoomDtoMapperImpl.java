package com.example.project_piatt.Mapper;

import com.example.project_piatt.Entity.Room;
import com.example.project_piatt.Model.RoomDTO;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-02-08T15:38:42+0100",
    comments = "version: 1.5.3.Final, compiler: Eclipse JDT (IDE) 3.41.0.z20250115-2156, environment: Java 21.0.5 (Eclipse Adoptium)"
)
@Component
public class RoomDtoMapperImpl implements RoomDtoMapper {

    @Override
    public RoomDTO toDto(Room room) {
        if ( room == null ) {
            return null;
        }

        RoomDTO.RoomDTOBuilder roomDTO = RoomDTO.builder();

        roomDTO.descrizione( room.getDescrizione() );
        roomDTO.id( room.getId() );
        roomDTO.imageName( room.getImageName() );
        roomDTO.nome( room.getNome() );
        roomDTO.persone( room.getPersone() );
        roomDTO.prezzo( room.getPrezzo() );
        roomDTO.tipo( room.getTipo() );

        return roomDTO.build();
    }

    @Override
    public Room toEntity(RoomDTO roomDTO) {
        if ( roomDTO == null ) {
            return null;
        }

        Room room = new Room();

        room.setDescrizione( roomDTO.getDescrizione() );
        room.setId( roomDTO.getId() );
        room.setImageName( roomDTO.getImageName() );
        room.setNome( roomDTO.getNome() );
        room.setPersone( roomDTO.getPersone() );
        room.setPrezzo( roomDTO.getPrezzo() );
        room.setTipo( roomDTO.getTipo() );

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
