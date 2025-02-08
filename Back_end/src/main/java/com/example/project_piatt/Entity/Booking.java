package com.example.project_piatt.Entity;

import com.example.project_piatt.Enum.BookEnum;
import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Booking {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JsonIgnore  // Evita la serializzazione di Room nella parte di Booking
    private Room room;

    @ManyToOne(fetch = FetchType.EAGER)
    @JsonIgnore  // Evita la serializzazione di User nella parte di Booking
    private User user;

    private LocalDate startDate;
    private LocalDate endDate;
    private int totalPrice;
    private BookEnum status;

    @JsonProperty("nRooms")
    private int nRooms;

    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JsonBackReference  // Gestisce la serializzazione dalla parte di Payment
    private List<Payment> paymentList;

    @JsonProperty("userId")
    public void setUserId(Long userId) {
        if (userId != null) {
            this.user = new User();
            this.user.setId(userId);
        }
    }

    @JsonProperty("roomId")
    public void setRoomId(Long roomId) {
        if (roomId != null) {
            this.room = new Room();
            this.room.setId(roomId);
        }
    }

    @Override
    public String toString() {
        return "Booking{" +
                "id=" + id +
                ", room=" + room.getId() +
                ", user=" + user.getId() +
                ", startDate=" + startDate +
                ", endDate=" + endDate +
                ", totalPrice=" + totalPrice +
                ", status=" + status +
                ", nRooms=" + nRooms +
                ", paymentList=" + paymentList +
                '}';
    }
}
