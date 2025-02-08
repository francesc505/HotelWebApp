package com.example.project_piatt.Model;

import com.example.project_piatt.Entity.Booking;
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
public class RoomDTO {
    private Long id;
    private String nome;
    private String tipo;
    private String descrizione;
    private int prezzo;
    private String imageName;
    //private int modifica;
  //  private int version;
    private String persone;
   // private List<BookingDTO> bookingDTOList;
}
