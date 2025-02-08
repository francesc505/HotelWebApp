package com.example.project_piatt.Service;


import com.example.project_piatt.Entity.Booking;
import com.example.project_piatt.Entity.Room;
import com.example.project_piatt.Mapper.BookingDtoMapper;
import com.example.project_piatt.Mapper.RoomDtoMapper;
import com.example.project_piatt.Model.RoomDTO;
import com.example.project_piatt.Repository.BookRepository;
import com.example.project_piatt.Repository.RoomRepository;
import jakarta.persistence.LockModeType;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.*;

@Service
@RequiredArgsConstructor
public class RoomService {

    private final RoomDtoMapper roomDtoMapper;
    private  final RoomRepository roomRepository;
   // private final AvailableRepository availableRepository;
    private final BookingDtoMapper bookingDtoMapper;
    private final BookRepository bookRepository;
    public List<Room> viewAll() {
        return roomRepository.findAll();
    }

    @Transactional
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    public boolean add(RoomDTO roomDTO) {
//        System.out.println(roomDTO.toString());
        // Esegui la query per controllare se è già presente o meno ( o vedere come gestire diversamente )

        String nome = roomDtoMapper.toEntity(roomDTO).getNome();
        Optional<Room> room  = roomRepository.findByNome(nome);

        if(room.isEmpty()) {
            Room room1 = new Room();
            room1.setId(roomDTO.getId());
            room1.setDescrizione(roomDTO.getDescrizione());
            room1.setNome(roomDTO.getNome());
            room1.setPrezzo(roomDTO.getPrezzo());
            room1.setPersone(roomDTO.getPersone());
            room1.setImageName(roomDTO.getImageName());
            room1.setTipo(roomDTO.getTipo());
            roomRepository.save(room1);
            // se posso aggiungere la stanza anche la tabella delle disponibilità dovrà essere modificata :
            return true;
        }
        return false;
    }

    @Transactional
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    public boolean applyEdits(RoomDTO roomDTO) {
        // Recupera la stanza esistente dal repository
        Optional<Room> roomOptional = roomRepository.findByNome(roomDTO.getNome());

        if (roomOptional.isPresent()) {
            // Recupera la stanza esistente
            Room existingRoom = roomOptional.get();

            // Aggiorna i campi con i nuovi valori
            existingRoom.setNome(roomDTO.getNome());
            existingRoom.setTipo(roomDTO.getTipo());
            existingRoom.setDescrizione(roomDTO.getDescrizione());
            existingRoom.setPrezzo(roomDTO.getPrezzo());
            existingRoom.setImageName(roomDTO.getImageName());
            roomRepository.save(existingRoom);
            return true;
        }
        return false;
    }

    @Transactional
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    public ResponseEntity<String> delete(Long id) {
        Optional<Room> room = roomRepository.findById(id);
        if(room.isPresent()){
          roomRepository.deleteById(id);
            return ResponseEntity.ok("stanza eliminata con successo");
        }
        return ResponseEntity.badRequest().body("impossibile eliminare la stanza");
    }


    @Transactional
    public List<Room> checkDates(LocalDate inizio, LocalDate fine) {

        List<Room> rooms = roomRepository.findAll(); // lo devo mettere con il lock in lettura ???
        // per ogni stanza presente:
        List<Room> last = new ArrayList<>();
        for (Room room : rooms) {
            Optional<List<Booking>> booking = bookRepository
                    .availableVersioning(room.getId(), inizio, fine);

            // se ci sono prenotazioni con quella data:
            if (booking.isPresent()) {
                int nRooms = 0;
                // devo controllare le stanze che non contiene, perchè se non sono presenti allora sicuramente sono disponibili

                for (Booking booking1 : booking.get()) {
                    nRooms += booking1.getNRooms();
                }
                if (nRooms >= 10) break; // posso bloccare il ciclo perchè sicuramente questa stanza non la posso inserire
                // altrimenti devo salvarlo:
                last.add(room);
            } else {
                // allora è vuota, non ci sono prenotazioni con quella data, vuol dire che posso aggiungere la stanza.
                last.add(room);
            }
        }// nessuna stanza è presente
        return last;
    }
}