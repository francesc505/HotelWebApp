package com.example.project_piatt.Controller;


import com.example.project_piatt.Entity.Booking;
import com.example.project_piatt.Entity.Room;
import com.example.project_piatt.Entity.User;
import com.example.project_piatt.Mapper.BookingDtoMapper;
import com.example.project_piatt.Mapper.RoomDtoMapper;
import com.example.project_piatt.Mapper.UserDtoMapper;
import com.example.project_piatt.Model.BookingDTO;
import com.example.project_piatt.Model.UserDTO;
import com.example.project_piatt.Repository.BookRepository;
import com.example.project_piatt.Repository.RoomRepository;
import com.example.project_piatt.Repository.UserRepository;
import com.example.project_piatt.Service.BookService;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
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
@Tag(name = "room", description = "the user API")
@RestController
@RequestMapping("/booking")
@Validated
@RequiredArgsConstructor
@ResponseBody
public class BookController {
    private static final String BOOK = "/finalBook/{nStanze}";
    private static final String REMOVEBOOK = "/removeBookRoom";
    private static final String CHECKAVAIABILITY = "/newBook/{nStanze}";
    private static final String REMOVETRY = "/removeTry";
    private static final String EDITBOOK = "/editBook/{inizio}/{fine}/{nRooms}";
    private static final String VIEWALLBOOKS = "/viewAllBooks";
    private static final String VIEWMYBOOKS = "{id}/viewMine";
    private static final String VIEWALLTODAY = "/view/today";
    private static final String USERINFO = "/{id}/userInfo";
    private static final String SEEALLREMOVEREQUESTS = "/seeAllRemoveRequests";
    private static final String NODELETE = "/impossible/delete";
    private static final String NODELETECUSTOMER = "/{id}/noDeleted";

    private final BookService bookService;
    private final BookRepository bookRepository;
    private final UserRepository userRepository;
    private final UserDtoMapper userDtoMapper;
    private final RoomRepository roomRepository;

    private final List<BookingDTO> removeRequests = new ArrayList<>();
    private final List<BookingDTO> noDelete = new ArrayList<>();


    @PreAuthorize("hasAuthority('CUSTOMER')")
    @PostMapping(value = REMOVETRY, consumes = {"application/json"})
    public ResponseEntity<String> tryToRemoveBook(@RequestBody BookingDTO bookingDTO) {
        System.out.println(bookingDTO + " primo");
        if (removeRequests.contains(bookingDTO)) // gestisco il fatto che più richieste di rimozione possono essere inviate
        // ma ne mantengo sempre 1, per evitare la comparsa di più richieste all'admin
        {
            return ResponseEntity.ok("richiesta inoltrata all'hotel, la verifica avverrà al piu presto");
        } else {

            if ((LocalDate.now().isEqual(bookingDTO.getStartDate())
                    && LocalDate.now().getYear() == bookingDTO.getStartDate().getYear() ))
                return ResponseEntity.badRequest()
                        .body("Non è possibile cancellare la prenotazione il giorno stesso, in caso contattare telefonicamente l'hotel");
            removeRequests.add(bookingDTO);
            System.out.println(removeRequests);
            return ResponseEntity.ok("richiesta inoltrata all'hotel, la verifica avverrà al piu presto");
        }
    }
// potrei creare una funzione che viene chiamata per rimuovere le prenotazioni vecchie.
    // devono pero risultare pagate !.

    @PreAuthorize("hasAuthority('MANAGER') or hasAuthority('ADMIN')")
    @PostMapping(value = NODELETE)
    public void noDelete(@RequestBody BookingDTO bookingDTO) {
        System.out.println(bookingDTO);
        //removeRequests.remove(bookingDTO);
        noDelete.add(bookingDTO);
    }


    @PreAuthorize("hasAuthority('CUSTOMER')")
    @GetMapping(value = NODELETECUSTOMER)
    public List<BookingDTO> getNoDelete(@PathVariable Long id) {
        List<BookingDTO> bookingDTOList = new ArrayList<>();
        for (BookingDTO b : noDelete) {
            if (b.getUserId().equals(id)) bookingDTOList.add(b);
        }
        return bookingDTOList;
    }

    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('MANAGER')")
    @GetMapping(value = SEEALLREMOVEREQUESTS)
    public List<BookingDTO> getRemoveRequests() {
        return removeRequests;
    }


    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('MANAGER')")
    @DeleteMapping(value = REMOVEBOOK)
    public ResponseEntity<String> removeBook(@RequestBody BookingDTO bookingDTO) {

        if (!bookingDTO.getStartDate().equals(LocalDate.now()) && bookService.removeBook(bookingDTO)) {
            removeRequests.remove(bookingDTO); // la rimuovo dalle richieste.
            return ResponseEntity.ok("prenotazione eliminata correttamente");
        }
        return ResponseEntity.badRequest().body("impossibile eliminare la prenotazione");
    }


    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('MANAGER') or hasAuthority('CUSTOMER')") // potrei gestirlo come la rimozione della prenotazione !!!
    @PutMapping (value = EDITBOOK)
    public ResponseEntity<String> editBook(@RequestBody BookingDTO bookingDTO, @PathVariable LocalDate inizio, @PathVariable LocalDate fine, @PathVariable int nRooms ){ // ad esempio se l'utente vuole arrivare un giorno dopo o andarsene prima...
        System.out.println(bookingDTO.toString());
        bookingDTO.setNRooms(nRooms);
        if(bookService.editBooking(bookingDTO, inizio, fine)) {
            return ResponseEntity.ok("prenotazione modificata correttamente"); // non mando la richiesta come l'eliminazione ma verifico direttamente se è possibile modificarla in base alle date
        }
        return ResponseEntity.badRequest().body("impossibile modificare la prenotazione");
    }


    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('MANAGER') or hasAuthority('CUSTOMER')")
    @GetMapping(value = VIEWMYBOOKS)
    public List<BookingDTO> viewAllSpecificUser(@PathVariable Long id) {
        List<BookingDTO> bookingDTO = bookService.checkMyBooks(id);
        System.out.println(bookingDTO.get(0));
        return bookingDTO;
    }

    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('MANAGER') ")
    @GetMapping(value = VIEWALLBOOKS)
    public List<Booking> viewAll() { // ad esempio se l'utente vuole arrivare un giorno dopo o andarsene prima...
        return bookRepository.findAll();
    }


    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('MANAGER') ")
    @GetMapping(value = VIEWALLTODAY)
    public List<BookingDTO> viewToday() {
        LocalDate today = LocalDate.now();
        return bookService.todayList(today);
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @GetMapping(value = USERINFO)
    public UserDTO viewUserInfo(@PathVariable Long id) {
        Optional<Booking> booking = bookRepository.findById(id);
        if (booking.isPresent()) {
            Booking booking1 = booking.get();
            Optional<User> user = userRepository.findByUsername(booking1.getUser().getUsername());
            return user.map(userDtoMapper::toDto).orElse(null);
        }
        return null;
    }

    @PreAuthorize("hasAuthority('CUSTOMER')")
    @GetMapping(value = "/{id}/giveMeValue")
    public Long giveRoomId(@PathVariable Long id) {
        Optional<Booking> booking = bookRepository.findById(id);
        return booking.map(value -> value.getRoom().getId()).orElse(null);
    }


    @PreAuthorize("hasAuthority('CUSTOMER')")
    @PostMapping(value = CHECKAVAIABILITY) // verifica la disponibilità delle stanze richieste
    public ResponseEntity<String> newBooking(@RequestBody BookingDTO bookingDTO, @PathVariable int nStanze) {
        if (roomRepository.findById(bookingDTO.getRoomId()).isPresent()) {
            // posso procedere alla prenotazione
            if (bookService.newBookCheck(bookingDTO, nStanze)) {
                System.out.println("disponibile");
                return ResponseEntity.ok("disponibilità confermata per le date stabilite");
            }
            return ResponseEntity.badRequest().body("impossibile verificare la disponibilità per quelle date, un'altra prenotazione risulta essere presente");
        }
        return ResponseEntity.badRequest().body("non disponibile");
    }

    @PreAuthorize("hasAuthority('CUSTOMER')")
    @PostMapping(value = BOOK)
    @Transactional
    public boolean lastBook(@RequestBody BookingDTO bookingDTO, @PathVariable int nStanze) {
        if(bookingDTO.getStartDate().getYear() <  LocalDate.now().getYear()) return false;
        return bookService.bookingRoom(bookingDTO, nStanze);
    }
}