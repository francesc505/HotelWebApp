package com.example.project_piatt.Repository;

import com.example.project_piatt.Entity.Room;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Repository
public interface RoomRepository extends JpaRepository<Room, Long> {
    Optional<Room> findByNome(String nome);

    @Query("SELECT r FROM Room r " +
            "WHERE r.tipo = :type AND r.persone <= :persone AND r.prezzo <= :price")
    Optional<ArrayList<Room>> findByParams(@Param("price") int price,
                                           @Param("type") String type,
                                           @Param("persone") int persone);

}