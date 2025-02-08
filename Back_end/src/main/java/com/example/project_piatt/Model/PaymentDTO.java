package com.example.project_piatt.Model;

import com.example.project_piatt.Enum.PayementEnum;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentDTO {
    private Long id;
    private Long userId; // ID dell'utente (invece dell'oggetto User)
    private String transactionType;
    private PayementEnum paymentState;
    private LocalDate date;
    private int totalAmount;
}
