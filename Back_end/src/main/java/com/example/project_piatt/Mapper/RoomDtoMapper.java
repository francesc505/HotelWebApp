package com.example.project_piatt.Mapper;

import com.example.project_piatt.Entity.Room;
import com.example.project_piatt.Model.RoomDTO;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface RoomDtoMapper {
    RoomDTO toDto(Room room);
    Room toEntity(RoomDTO roomDTO);

    List<RoomDTO> toDtoList(List<Room> room);

}
