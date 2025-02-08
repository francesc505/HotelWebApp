package com.example.project_piatt.Model;

import com.example.project_piatt.Enum.BookEnum;
import jakarta.persistence.Version;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BookingDTO {
    private Long id;
    private Long userId;  // ID dell'utente (invece di includere l'oggetto User intero)
    private Long roomId;  // ID della stanza (invece di includere l'oggetto Room intero)
    private LocalDate startDate;
    private LocalDate endDate;
    private int totalPrice;
    private BookEnum status;  // Stato della prenotazione
    private int nRooms;
   // private int version;
    private List<PaymentDTO> paymentList;

    @Override
    public String toString() {
        return "BookingDTO{" +
                "id=" + id +
                ", userId=" + userId +
                ", roomId=" + roomId +
                ", startDate=" + startDate +
                ", endDate=" + endDate +
                ", totalPrice=" + totalPrice +
                ", status=" + status +
                ", nRooms=" + nRooms +
              //  ", version=" + version +
                ", paymentList=" + paymentList +
                '}';
    }
}