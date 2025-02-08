package com.example.project_piatt.Controller;

import com.example.project_piatt.Entity.Role;
import com.example.project_piatt.Entity.User;
import com.example.project_piatt.Mapper.UserDtoMapper;
import com.example.project_piatt.Model.NewUserDTO;
import com.example.project_piatt.Model.PasswordDTO;
import com.example.project_piatt.Model.RoleDTO;
import com.example.project_piatt.Model.UserDTO;
import com.example.project_piatt.Repository.UserRepository;
import com.example.project_piatt.Service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.ErrorResponse;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;

@SecurityScheme(name = "Bearer", type = SecuritySchemeType.HTTP, scheme = "bearer", bearerFormat = "JWT")
@Tag(name = "user", description = "the user API")
@RestController
@RequestMapping("/user")
@Validated
@RequiredArgsConstructor
@ResponseBody
public class UserController {
    private static final String VIEWALLMANAGERS = "viewAll/Managers";
    private static final String CHANGE_USER_PASSWORD = "/{username}/changePassword";
    private static final String CHANGE_USER_PASSWORD_NO_TOKEN = "/{username}/changePassword/NoToken";
    private static final String USERPARAMETERS = "/giveUserParams/{username}";
    private static final String CHANGEPARAMETERS = "/change";

    // only for the admin and Manager:
    private static final String ASSIGN_ROLE = "/{userId}/assignRole/{roleName}";
    private static final String REMOVE_ROLE = "/{userId}/removeRole/{roleName}";
    private static final String VIEWROLES = "/view/manager/roles/{id}";


    private final UserService userService;
    private final UserRepository userRepository;
    private final UserDtoMapper userDtoMapper;



    @PostMapping(consumes = {"application/json"})
    public ResponseEntity<UserDTO> createUser(@RequestBody NewUserDTO userDTO) {
        return new ResponseEntity(userService.createUser(userDTO), HttpStatus.CREATED);
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @GetMapping(value = VIEWROLES)
    @Transactional
    public Set<Role> viewRoles(@PathVariable Long id) {
        Optional<User> user = userRepository.findById(id);
        return user.map(User::getRoles).orElse(null);
    }



    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('CUSTOMER')")
    @PostMapping(value = CHANGE_USER_PASSWORD, consumes = {"application/json"})
    public ResponseEntity<UserDTO> changeUserPassword(@PathVariable String username, @RequestBody PasswordDTO passwordDTO) {
        return  ResponseEntity.ok(userService.changePassword(username,passwordDTO));
    }


    @PostMapping(value = CHANGE_USER_PASSWORD_NO_TOKEN, consumes = {"application/json"})
    public ResponseEntity<UserDTO> changeUserPasswordNoToken(@PathVariable String username, @RequestBody PasswordDTO passwordDTO) {
        return  ResponseEntity.ok(userService.changePassword(username,passwordDTO));
    }


    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('CUSTOMER')")
    @GetMapping(value = USERPARAMETERS )
    public UserDTO userParams(@PathVariable String username) {
        Optional<User> user = userRepository.findByUsername(username);
        return user.map(userDtoMapper::toDto).orElse(null);
    }


    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('CUSTOMER')")
    @PutMapping(value = CHANGEPARAMETERS,consumes = { "application/json" })
    public ResponseEntity<String> changeParams(@RequestBody UserDTO userDTO) {
        System.out.println(userDTO.toString());
        if(userService.changeParams(userDTO))
            return  ResponseEntity.ok("modifiche effettuate correttamente");
        return ResponseEntity.badRequest().body("impossibile effettuare i cambiamenti");
    }


    @PreAuthorize("hasAuthority('ADMIN')")
    @PostMapping(value = ASSIGN_ROLE)
    public ResponseEntity<RoleDTO> assignRole(@PathVariable Long userId, @PathVariable String roleName) {
        System.out.println("Ci sono ");
        return  ResponseEntity.ok(userService.assignOrRemoveRole(userId,roleName,false));
    }


    @PreAuthorize("hasAuthority('ADMIN')")
    @PostMapping(value = REMOVE_ROLE)
    public ResponseEntity<RoleDTO> removeRole(@PathVariable Long userId, @PathVariable String roleName) {
        return  ResponseEntity.ok(userService.assignOrRemoveRole(userId,roleName,true));
    }


    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('MANAGER')")
    @GetMapping(value = VIEWALLMANAGERS)
    public ArrayList<User> viewAllManagers(){
        return userService.allManagers();
    }
}