package com.example.project_piatt.Mapper;

import com.example.project_piatt.Entity.Booking;
import com.example.project_piatt.Entity.Payment;
import com.example.project_piatt.Model.BookingDTO;
import com.example.project_piatt.Model.PaymentDTO;
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
public class BookingDtoMapperImpl implements BookingDtoMapper {

    @Override
    public BookingDTO toDto(Booking booking) {
        if ( booking == null ) {
            return null;
        }

        BookingDTO.BookingDTOBuilder bookingDTO = BookingDTO.builder();

        bookingDTO.endDate( booking.getEndDate() );
        bookingDTO.id( booking.getId() );
        bookingDTO.paymentList( paymentListToPaymentDTOList( booking.getPaymentList() ) );
        bookingDTO.startDate( booking.getStartDate() );
        bookingDTO.status( booking.getStatus() );
        bookingDTO.totalPrice( booking.getTotalPrice() );

        return bookingDTO.build();
    }

    @Override
    public Booking toEntity(BookingDTO bookingDTO) {
        if ( bookingDTO == null ) {
            return null;
        }

        Booking booking = new Booking();

        booking.setEndDate( bookingDTO.getEndDate() );
        booking.setId( bookingDTO.getId() );
        booking.setNRooms( bookingDTO.getNRooms() );
        booking.setPaymentList( paymentDTOListToPaymentList( bookingDTO.getPaymentList() ) );
        booking.setStartDate( bookingDTO.getStartDate() );
        booking.setStatus( bookingDTO.getStatus() );
        booking.setTotalPrice( bookingDTO.getTotalPrice() );
        booking.setUserId( bookingDTO.getUserId() );
        booking.setRoomId( bookingDTO.getRoomId() );

        return booking;
    }

    @Override
    public List<Booking> toList(List<BookingDTO> bookingDTO) {
        if ( bookingDTO == null ) {
            return null;
        }

        List<Booking> list = new ArrayList<Booking>( bookingDTO.size() );
        for ( BookingDTO bookingDTO1 : bookingDTO ) {
            list.add( toEntity( bookingDTO1 ) );
        }

        return list;
    }

    protected PaymentDTO paymentToPaymentDTO(Payment payment) {
        if ( payment == null ) {
            return null;
        }

        PaymentDTO.PaymentDTOBuilder paymentDTO = PaymentDTO.builder();

        paymentDTO.date( payment.getDate() );
        paymentDTO.id( payment.getId() );
        paymentDTO.paymentState( payment.getPaymentState() );
        paymentDTO.totalAmount( payment.getTotalAmount() );

        return paymentDTO.build();
    }

    protected List<PaymentDTO> paymentListToPaymentDTOList(List<Payment> list) {
        if ( list == null ) {
            return null;
        }

        List<PaymentDTO> list1 = new ArrayList<PaymentDTO>( list.size() );
        for ( Payment payment : list ) {
            list1.add( paymentToPaymentDTO( payment ) );
        }

        return list1;
    }

    protected Payment paymentDTOToPayment(PaymentDTO paymentDTO) {
        if ( paymentDTO == null ) {
            return null;
        }

        Payment payment = new Payment();

        payment.setDate( paymentDTO.getDate() );
        payment.setId( paymentDTO.getId() );
        payment.setPaymentState( paymentDTO.getPaymentState() );
        payment.setTotalAmount( paymentDTO.getTotalAmount() );
        payment.setUserId( paymentDTO.getUserId() );

        return payment;
    }

    protected List<Payment> paymentDTOListToPaymentList(List<PaymentDTO> list) {
        if ( list == null ) {
            return null;
        }

        List<Payment> list1 = new ArrayList<Payment>( list.size() );
        for ( PaymentDTO paymentDTO : list ) {
            list1.add( paymentDTOToPayment( paymentDTO ) );
        }

        return list1;
    }
}
