package com.example.project_piatt.Configuration;

import com.example.project_piatt.Controller.CalendaryController;
import com.example.project_piatt.Entity.Role;
import com.example.project_piatt.Entity.Room;
import com.example.project_piatt.Entity.User;
import com.example.project_piatt.Enum.RoleEnum;
import com.example.project_piatt.Repository.CalendaryRepository;
import com.example.project_piatt.Repository.RoleRepository;
import com.example.project_piatt.Repository.UserRepository;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

@Component
public class StartupDataLoader implements ApplicationListener<ContextRefreshedEvent> {



    public StartupDataLoader(RoleRepository roleRepository, UserRepository userRepository,
                             PasswordEncoder passwordEncoder, CalendaryRepository calendaryRepository) {
        this.roleRepository = roleRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.calendaryRepository = calendaryRepository;
    }

    private Boolean alreadySetup=false;
    private UserRepository userRepository;
    private RoleRepository roleRepository;
    private PasswordEncoder passwordEncoder;
    private final CalendaryRepository calendaryRepository;


    @Override
    @Transactional
    public void onApplicationEvent(ContextRefreshedEvent event) {
        if (alreadySetup)
            return;

        Role adminRole = createRoleIfNotFound("ADMIN");
        Role customerRole= createRoleIfNotFound("CUSTOMER");
        Role managerRole= createRoleIfNotFound("MANAGER");

        Optional<User> userOptional = userRepository.findByUsername("admin");
        //Optional<Room> roomOptional = RoomRepository.getAll();
        if (userOptional.isEmpty()) {
            User user = new User();
            user.setUsername("admin");
            user.setCognome("Admin");
            user.setNome("Admin");
            user.setPassword(passwordEncoder.encode("admin"));
            user.getRoles().add(adminRole);
            userRepository.saveAndFlush(user);


            user = new User();
            user.setUsername("customer");
            user.setNome("Customer");
            user.setCognome("Customer");
            user.setPassword(passwordEncoder.encode("customer"));
            user.getRoles().add(customerRole);
            userRepository.saveAndFlush(user);


            user = new User();
            user.setUsername("manager");
            user.setCognome("Manager");
            user.setNome("Manager");
            user.setPassword(passwordEncoder.encode("manager"));
            user.getRoles().add(managerRole);
            userRepository.saveAndFlush(user);

        }
        alreadySetup = true;
    }

    @Transactional
    Role createRoleIfNotFound(String name) {
        Role role = null;
        Optional<Role> roleOptional = roleRepository.findByRoleName(RoleEnum.valueOf(name));

        if (roleOptional.isEmpty()) {
            role = new Role();
            role.setRoleName(RoleEnum.valueOf(name));
            roleRepository.saveAndFlush(role);
        } else {
            role = roleOptional.get();
        }
        return role;
    }




}
