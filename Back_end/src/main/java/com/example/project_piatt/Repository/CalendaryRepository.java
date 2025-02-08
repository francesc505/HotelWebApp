package com.example.project_piatt.Repository;

import com.example.project_piatt.Entity.Room;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CalendaryRepository extends JpaRepository<Room, Long> {


}
