package com.example.project_piatt.Repository;

import com.example.project_piatt.Entity.Role;
import com.example.project_piatt.Entity.User;
import com.example.project_piatt.Enum.RoleEnum;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RoleRepository extends JpaRepository<Role, Long> {

    Optional<Role> findByRoleName(RoleEnum roleEnum);
}
