package com.example.project_piatt.Repository;

import com.example.project_piatt.Entity.Payment;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import java.util.Optional;

public interface PaymentRepository extends JpaRepository<Payment,Long > {


    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<Payment> findByBooking_Id(Long bookingId);
}
