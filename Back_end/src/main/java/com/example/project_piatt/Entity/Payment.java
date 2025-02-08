package com.example.project_piatt.Entity;

import com.example.project_piatt.Enum.PayementEnum;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.time.LocalDate;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JsonIgnore  // Evita la serializzazione di Booking nella parte di Payment
    private Booking booking;

    @ManyToOne(fetch = FetchType.LAZY)
    @JsonIgnore  // Evita la serializzazione di User nella parte di Payment
    private User user;

    private String transaction_type;
    private PayementEnum paymentState;
    private LocalDate date;
    private int totalAmount;

    @JsonProperty("user_id")
    public void setUserId(Long userId) {
        if (userId != null) {
            this.user = new User();
            this.user.setId(userId);
        }
    }

    @JsonProperty("booking_id")
    public void setBookingId(Long bookingId){
        if(bookingId != null){
            this.booking = new Booking();
            this.booking.setId(bookingId);
        }
    }
}
