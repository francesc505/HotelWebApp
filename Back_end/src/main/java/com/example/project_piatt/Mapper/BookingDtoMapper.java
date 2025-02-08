package com.example.project_piatt.Mapper;

import com.example.project_piatt.Entity.Booking;
import com.example.project_piatt.Model.BookingDTO;
import org.mapstruct.Mapper;

import java.util.ArrayList;
import java.util.List;


@Mapper(componentModel = "spring")
public interface BookingDtoMapper {
        BookingDTO toDto(Booking booking);
        Booking toEntity(BookingDTO bookingDTO);
        List<Booking> toList(List<BookingDTO> bookingDTO);

        public static List<BookingDTO> tryListToDTO(List<Booking> booking) {
                List<BookingDTO> bookingDTOList = new ArrayList<>();
                for (int i = 0; i < booking.size(); i++) {
                        BookingDTO bookingDTO = new BookingDTO(); // Creazione di un nuovo oggetto per ogni iterazione
                        bookingDTO.setId(booking.get(i).getId());
                        if (booking.get(i).getUser() != null && booking.get(i).getUser().getId() != null) {
                                bookingDTO.setUserId(booking.get(i).getUser().getId());
                        }
                        if (booking.get(i).getRoom() != null && booking.get(i).getRoom().getId() != null) {
                                bookingDTO.setRoomId(booking.get(i).getRoom().getId());
                        }
                        bookingDTO.setStatus(booking.get(i).getStatus());
                        bookingDTO.setTotalPrice(booking.get(i).getTotalPrice());
                        bookingDTO.setStartDate(booking.get(i).getStartDate());
                        bookingDTO.setEndDate(booking.get(i).getEndDate());
                        bookingDTO.setNRooms(booking.get(i).getNRooms());
                        //bookingDTO.setPaymentList(); // Se necessario
                        bookingDTOList.add(bookingDTO);
                }
                return bookingDTOList;
        }

}
