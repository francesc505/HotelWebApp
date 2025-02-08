package com.example.project_piatt.Controller;

import com.example.project_piatt.Entity.Room;
import com.example.project_piatt.Mapper.RoomDtoMapper;
import com.example.project_piatt.Model.RoomDTO;
import com.example.project_piatt.Repository.RoomRepository;
import com.example.project_piatt.Service.RoomService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@SecurityScheme(name = "Bearer", type = SecuritySchemeType.HTTP, scheme = "bearer", bearerFormat = "JWT")
@Tag(name = "user", description = "the user API")
@RestController
@RequestMapping("/room")
@Validated
@RequiredArgsConstructor
@ResponseBody
public class RoomController {
    private static final String ADDROOM = "/addRoom";
    private static final String VIEW = "/viewAll";
    private static  final String DELETE = "{id}/delete";
    private static final String FINDROOM = "/find/room/{price}/{type}/{persone}";
    private static final String FINDROOMBYDATES = "/find/room/{inizio}/{fine}";
    private static final String FINDROOMBYALLPARAMS = "/find/room/{inizio}/{fine}/{price}/{type}/{persone}";

    private final RoomService roomService;
    private  final RoomDtoMapper roomDtoMapper;
    private final RoomRepository roomRepository;


    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('CUSTOMER')")
    @GetMapping(value = VIEW)
    List<RoomDTO> viewRooms(){
        List<Room> room = roomService.viewAll();
        return  roomDtoMapper.toDtoList(room);
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @PostMapping(value = ADDROOM, consumes = { "application/json" }) // bisogna modificare: "available"
    ResponseEntity<String> ro(@RequestBody RoomDTO roomDTO){
        if(!roomService.add(roomDTO))
            return  ResponseEntity.badRequest().body("la stanza non è stata inserita correttamente");
        return ResponseEntity.ok("stanza inserita correttamente");
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @PutMapping(value = "/edit/room",  consumes = { "application/json" })
    ResponseEntity<String> editRoom(@RequestBody RoomDTO roomDTO){
        if(roomService.applyEdits(roomDTO)) {
            System.out.println("inviato");

            return ResponseEntity.ok("modifiche apportate correttamente");
        }
        return ResponseEntity.badRequest().body("stanza non presente");
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @DeleteMapping(value = DELETE)
    ResponseEntity<String> deleteRoom(@PathVariable Long id){
        return roomService.delete(id);
    }

    @PreAuthorize("hasAuthority('CUSTOMER')")
    @GetMapping(value = FINDROOM )
    @Transactional
    public List<RoomDTO> find(@PathVariable int price, @PathVariable String type,@PathVariable int persone){
        Optional<ArrayList<Room>> room = roomRepository.findByParams(price, type, persone);
        return room.map(roomDtoMapper::toDtoList).orElse(null);
    }


    @PreAuthorize("hasAuthority('CUSTOMER')")
    @GetMapping(value = FINDROOMBYDATES)
    public List<RoomDTO> findByDates(@PathVariable LocalDate inizio, @PathVariable LocalDate fine){
        return roomDtoMapper.toDtoList(roomService.checkDates(inizio, fine));
    }


    @PreAuthorize("hasAuthority('CUSTOMER')")
    @GetMapping(value = FINDROOMBYALLPARAMS)
    @Transactional
    public List<RoomDTO> findByAllParams(@PathVariable LocalDate inizio, @PathVariable LocalDate fine,
                                         @PathVariable int price, @PathVariable String type,@PathVariable int persone) {
       Optional<ArrayList<Room>> rooms =  roomRepository.findByParams(price, type, persone);
        if(rooms.isPresent()) {
            List<Room> rooms1 = roomService.checkDates(inizio, fine);
            System.out.println("seconda lista: "+rooms1);

            //faccio l'intersezione dei risultati
            List<Room> roomList = new ArrayList<>();
            for (Room room : rooms.get()) {
                if (rooms1.contains(room)) roomList.add(room);
            }
            return roomDtoMapper.toDtoList(roomList);
        }
        return null;
    }
}