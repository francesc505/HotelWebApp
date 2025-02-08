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
    date = "2024-12-12T20:12:26+0100",
    comments = "version: 1.5.3.Final, compiler: IncrementalProcessingEnvironment from gradle-language-java-8.10.2.jar, environment: Java 17.0.13 (Amazon.com Inc.)"
)
@Component
public class BookingDtoMapperImpl implements BookingDtoMapper {

    @Override
    public BookingDTO toDto(Booking booking) {
        if ( booking == null ) {
            return null;
        }

        BookingDTO.BookingDTOBuilder bookingDTO = BookingDTO.builder();

        bookingDTO.id( booking.getId() );
        bookingDTO.startDate( booking.getStartDate() );
        bookingDTO.endDate( booking.getEndDate() );
        bookingDTO.totalPrice( booking.getTotalPrice() );
        bookingDTO.status( booking.getStatus() );
        bookingDTO.paymentList( paymentListToPaymentDTOList( booking.getPaymentList() ) );

        return bookingDTO.build();
    }

    @Override
    public Booking toEntity(BookingDTO bookingDTO) {
        if ( bookingDTO == null ) {
            return null;
        }

        Booking booking = new Booking();

        booking.setUserId( bookingDTO.getUserId() );
        booking.setRoomId( bookingDTO.getRoomId() );
        booking.setId( bookingDTO.getId() );
        booking.setStartDate( bookingDTO.getStartDate() );
        booking.setEndDate( bookingDTO.getEndDate() );
        booking.setTotalPrice( bookingDTO.getTotalPrice() );
        booking.setStatus( bookingDTO.getStatus() );
        booking.setNRooms( bookingDTO.getNRooms() );
        booking.setPaymentList( paymentDTOListToPaymentList( bookingDTO.getPaymentList() ) );

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

        paymentDTO.id( payment.getId() );
        paymentDTO.paymentState( payment.getPaymentState() );
        paymentDTO.date( payment.getDate() );
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

        payment.setUserId( paymentDTO.getUserId() );
        payment.setId( paymentDTO.getId() );
        payment.setPaymentState( paymentDTO.getPaymentState() );
        payment.setDate( paymentDTO.getDate() );
        payment.setTotalAmount( paymentDTO.getTotalAmount() );

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
