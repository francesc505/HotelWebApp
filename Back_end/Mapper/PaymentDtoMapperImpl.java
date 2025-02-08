package com.example.project_piatt.Mapper;

import com.example.project_piatt.Entity.Payment;
import com.example.project_piatt.Model.PaymentDTO;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2024-12-12T10:41:10+0100",
    comments = "version: 1.5.3.Final, compiler: IncrementalProcessingEnvironment from gradle-language-java-8.10.2.jar, environment: Java 17.0.13 (Amazon.com Inc.)"
)
@Component
public class PaymentDtoMapperImpl implements PaymentDtoMapper {

    @Override
    public PaymentDTO toDto(Payment payment) {
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

    @Override
    public Payment toEntity(PaymentDTO paymentDTO) {
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
}
