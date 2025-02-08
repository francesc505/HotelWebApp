package com.example.project_piatt.Service;


import com.example.project_piatt.Entity.Booking;
import com.example.project_piatt.Entity.Room;
import com.example.project_piatt.Entity.User;
import com.example.project_piatt.Enum.BookEnum;
import com.example.project_piatt.Mapper.BookingDtoMapper;
import com.example.project_piatt.Model.BookingDTO;
import com.example.project_piatt.Repository.BookRepository;
import com.example.project_piatt.Repository.RoomRepository;
import com.example.project_piatt.Repository.UserRepository;
import jakarta.persistence.LockModeType;
import jakarta.persistence.OptimisticLockException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class BookService {

    private final BookRepository bookRepository;
    private final BookingDtoMapper bookingDtoMapper;
    private final RoomRepository roomRepository;
    private final UserRepository userRepository;

    public boolean add(BookingDTO bookingDTO) {
        bookRepository.save(bookingDtoMapper.toEntity(bookingDTO));
        return true;
    }

    @Transactional
    public boolean editBooking(BookingDTO bookingDTO, LocalDate inizio, LocalDate fine) { // devo avere il bookingDTO della prenotazione che è stata gia effettuate e la data di inizio e di fine della nuova prenotazione
        System.out.println(bookingDTO.toString());
        if (editHelp(bookingDTO, bookingDTO.getNRooms())){

            Optional<Booking> booking = bookRepository.findById(bookingDTO.getId());
            if (booking.isPresent()) {
                booking.get().setStartDate(inizio);
                booking.get().setEndDate(fine);
                bookRepository.save(booking.get());

                return true;
            }
            return false;
        }
        return false;
    }

    @Transactional
    public boolean editHelp(BookingDTO bookingDTO, int nStanze) {

        Optional<Room> room = roomRepository.findById(bookingDTO.getRoomId());
        Optional<User> user = userRepository.findById(bookingDTO.getUserId());

        if (room.isPresent() && user.isPresent()) {
            Optional<List<Booking>> booking = bookRepository
                    .bookVersioning(room.get().getId(), bookingDTO.getStartDate(), bookingDTO.getEndDate());
            int nRoomsBooked = 0;

            if (booking.isPresent() && !booking.get().isEmpty()) {
                for (Booking booking1 : booking.get()) {
                    nRoomsBooked += booking1.getNRooms();
                }
                if ((nRoomsBooked - nStanze) <= 10) {
                    System.out.println("no di sicuro");
                    return true;
                }
                return false;
            } else {
                return true;
            }
        }
        return false;
    }


    public List<BookingDTO> checkMyBooks(Long id) {
        Optional<List<Booking>> bookingList = bookRepository.findAllByUserId(id);
        if (bookingList.isPresent()) {
            List<Booking> list = bookingList.get();
            // System.out.println(list +" lista");
            List<Booking> bl = new ArrayList<>();
            for (Booking value : list) {

                Booking booking = new Booking();
                booking.setId(value.getId());
                booking.setUserId(value.getUser().getId());
                booking.setRoomId(value.getRoom().getId());
                booking.setStartDate(value.getStartDate());
                booking.setEndDate(value.getEndDate());
                booking.setStatus(value.getStatus());
                booking.setTotalPrice(value.getTotalPrice());
                booking.setNRooms(value.getNRooms());
                booking.setPaymentList(value.getPaymentList());

                bl.add(booking);
            }
            System.out.println(bl);
            return BookingDtoMapper.tryListToDTO(bl);
        }
        return null;
    }


    public List<BookingDTO> todayList(LocalDate today) {
        List<Booking> lista = bookRepository.findAllByStartDate(today);
        if(!lista.isEmpty()) {
            return BookingDtoMapper.tryListToDTO(lista);
        }
        return null;
    }


    @Transactional
    public boolean newBookCheck(BookingDTO bookingDTO, int nStanze) {
        // devo prima verificare la disponibilità.
        Optional<Room> room = roomRepository.findById(bookingDTO.getRoomId());
        Optional<User> user = userRepository.findById(bookingDTO.getUserId());

        if (room.isPresent() && user.isPresent()) {
            Optional<List<Booking>> booking = bookRepository
                    .availableVersioning(room.get().getId(), bookingDTO.getStartDate(), bookingDTO.getEndDate());

            int nRoomsBooked = 0;
            if (booking.isPresent() && !booking.get().isEmpty()) {
                System.out.println(booking.get().toString());
                for (Booking booking1 : booking.get()) {
                    System.out.println(booking1.getUser().getId());
                    if (booking1.getUser().getId().equals(user.get().getId()))
                        return false; // se è presente lo stesso id allora ci sono sovrapposizioni di prenotazioni
                    nRoomsBooked += booking1.getNRooms();
                }
                if (nRoomsBooked > 10 || (nRoomsBooked + nStanze) > 10) return false;

                return true;
            } else {
                // la prenotazione è empty, questa è la prima prenotazione per quella data
                return true;
            }
        }
        return false;
    }


    public void bookRoom(BookingDTO bookingDTO, Long userId, Room room, int nStanze) { // non ripeto l'utente piu volte ( inserire qui la current version )
        // se sono qui, vuol dire che la versione è stata effettuata correttamente e che non ci sono sovrapposizioni di date e
        // che quindi l'utente non ha nessun'altra prenotazione in quelle date, ma soprattutto le stanze sono disponibili.
        System.out.println(room.toString() + " nella prenotazione nel DB......");

        Booking booking1 = new Booking();

        booking1.setEndDate(bookingDTO.getEndDate());
        booking1.setStartDate(bookingDTO.getStartDate());
        booking1.setNRooms(nStanze);
        booking1.setStatus(BookEnum.WAITING);
        booking1.setTotalPrice(bookingDTO.getTotalPrice());
        booking1.setUserId(userId);
        booking1.setRoomId(room.getId());

        bookRepository.save(booking1);
    }

    @Transactional
    public boolean bookingRoom(BookingDTO bookingDTO,  int nStanze) {
        int nRoomsBooked = 0;
        Optional<Room> room = roomRepository.findById(bookingDTO.getRoomId());
        if(room.isPresent()) {
            Optional<List<Booking>> bookings = bookRepository.bookVersioning(room.get().getId(), bookingDTO.getStartDate(), bookingDTO.getEndDate());
            if (bookings.isPresent() && !bookings.get().isEmpty()) {

                for (Booking booking1 : bookings.get()) {
                    if (booking1.getUser().getId().equals(bookingDTO.getUserId()))
                        return false; // se è presente lo stesso id allora ci sono sovrapposizioni di prenotazioni (vedere query)
                    nRoomsBooked += booking1.getNRooms();
                }
                System.out.println(room.toString() + " nella prenotazione 1");

                if (nRoomsBooked > 10 || (nRoomsBooked + nStanze) > 10) return false;
                bookRoom(bookingDTO, bookingDTO.getUserId(), room.get(), nStanze);
                return true;
            } else {
                // la prenotazione è empty, questa è la prima prenotazione per quella data
                bookRoom(bookingDTO, bookingDTO.getUserId(), room.get(), nStanze);
                return true;
            }
        }return false;
    }


    @Transactional
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    public boolean removeBook(BookingDTO bookingDTO) { // id dell'utente
        Booking booking = bookingDtoMapper.toEntity(bookingDTO);
        Optional<Booking> book = bookRepository.findById(booking.getId());
        if (book.isPresent()) {
            bookRepository.delete(bookingDtoMapper.toEntity(bookingDTO));
           return true;
        }
        return false;
    }
}