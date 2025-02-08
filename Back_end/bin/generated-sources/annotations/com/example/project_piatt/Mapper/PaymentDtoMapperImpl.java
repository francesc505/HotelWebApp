package com.example.project_piatt.Mapper;

import com.example.project_piatt.Entity.Payment;
import com.example.project_piatt.Model.PaymentDTO;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-02-08T15:38:42+0100",
    comments = "version: 1.5.3.Final, compiler: Eclipse JDT (IDE) 3.41.0.z20250115-2156, environment: Java 21.0.5 (Eclipse Adoptium)"
)
@Component
public class PaymentDtoMapperImpl implements PaymentDtoMapper {

    @Override
    public PaymentDTO toDto(Payment payment) {
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

    @Override
    public Payment toEntity(PaymentDTO paymentDTO) {
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
}
