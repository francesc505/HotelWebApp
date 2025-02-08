package com.example.project_piatt.Mapper;

import com.example.project_piatt.Entity.Payment;
import com.example.project_piatt.Model.PaymentDTO;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface PaymentDtoMapper {
    PaymentDTO toDto(Payment payment);
    Payment toEntity(PaymentDTO paymentDTO);
}
