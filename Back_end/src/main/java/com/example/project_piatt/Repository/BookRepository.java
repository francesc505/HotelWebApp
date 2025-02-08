package com.example.project_piatt.Repository;


import com.example.project_piatt.Entity.Booking;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface BookRepository extends JpaRepository<Booking, Long> {

    @Query("SELECT b FROM Booking b WHERE b.user.id = :id")
    Optional<List<Booking>> findAllByUserId(@Param("id") Long id);


    @Query("SELECT b FROM Booking b WHERE b.startDate = :today")
    List<Booking> findAllByStartDate(@Param("today") LocalDate today);


    @Lock(LockModeType.OPTIMISTIC)
    @Query("SELECT b FROM Booking b WHERE " +
            "(b.startDate <= :endDate AND b.endDate >= :startDate) " +
            "AND b.room.id = :room")
    Optional<List<Booking>> availableVersioning(@Param("room") Long room,
                                                @Param("startDate") LocalDate startDate,
                                                @Param("endDate") LocalDate endDate);



    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT b FROM Booking b WHERE b.room.id = :nome AND (" +
            "(b.startDate <= :endDate AND b.endDate >= :startDate))")
    Optional<List<Booking>> bookVersioning(@Param("nome") Long id,
                                                @Param("startDate") LocalDate startDate,
                                                @Param("endDate") LocalDate endDate);

}