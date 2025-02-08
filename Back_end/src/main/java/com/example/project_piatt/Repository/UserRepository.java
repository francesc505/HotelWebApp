package com.example.project_piatt.Repository;

import com.example.project_piatt.Entity.Role;
import com.example.project_piatt.Entity.User;
import com.example.project_piatt.Model.BookingDTO;
import com.example.project_piatt.Model.UserDTO;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);



}