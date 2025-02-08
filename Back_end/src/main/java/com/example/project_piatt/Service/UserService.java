package com.example.project_piatt.Service;

import com.example.project_piatt.Entity.Role;
import com.example.project_piatt.Entity.User;
import com.example.project_piatt.Enum.RoleEnum;
import com.example.project_piatt.Exceptions.BadResourceException;
import com.example.project_piatt.Exceptions.ResourceConflictException;
import com.example.project_piatt.Exceptions.ResourceNotFoundException;
import com.example.project_piatt.Mapper.BookingDtoMapper;
import com.example.project_piatt.Mapper.RoleDtoMapper;
import com.example.project_piatt.Mapper.UserDtoMapper;
import com.example.project_piatt.Model.*;
import com.example.project_piatt.Repository.RoleRepository;
import com.example.project_piatt.Repository.UserRepository;
import com.example.project_piatt.filters.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nimbusds.jose.JOSEException;
import com.nimbusds.jose.proc.BadJOSEException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.context.support.BeanDefinitionDsl;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.security.Principal;
import java.text.ParseException;
import java.util.*;
import java.util.stream.Collectors;

import static org.springframework.http.HttpHeaders.AUTHORIZATION;
import static org.springframework.http.HttpStatus.FORBIDDEN;
import static org.springframework.util.MimeTypeUtils.APPLICATION_JSON_VALUE;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final UserDtoMapper userDtoMapper;
    private final RoleDtoMapper roleDtoMapper;
    private final PasswordEncoder passwordEncoder;
    private final RoleRepository roleRepository;
    private final UserDetailService userDetailService;
    private final BookingDtoMapper bookingDtoMapper;


    public void refreshToken(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String authorizationHeader = request.getHeader(AUTHORIZATION);
        if(authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            try {
                Map<String, String> tokenMap = doRefreshToken(authorizationHeader, request.getRequestURL().toString());
                response.addHeader("access_token", tokenMap.get("access_token"));
                response.addHeader("refresh_token", tokenMap.get("refresh_token"));

                ObjectMapper mapper = new ObjectMapper();
                response.setContentType(MediaType.APPLICATION_JSON_VALUE);
                mapper.writeValue(response.getOutputStream(), tokenMap);
            }
            catch (Exception e) {
                //log.error(String.format("Error refresh token: %s", authorizationHeader), e);
                response.setStatus(FORBIDDEN.value());
                Map<String, String> error = new HashMap<>();
                error.put("errorMessage", e.getMessage());
                response.setContentType(APPLICATION_JSON_VALUE);
                new ObjectMapper().writeValue(response.getOutputStream(), error);
            }
        } else {
            throw new RuntimeException("Refresh token is missing");
        }
    }

    private Map<String,String> doRefreshToken(String authorizationHeader, String issuer) throws BadJOSEException,
            ParseException, JOSEException {

        String refreshToken = authorizationHeader.substring("Bearer ".length());
        UsernamePasswordAuthenticationToken authenticationToken = JwtUtil.parseToken(refreshToken);
        String username = authenticationToken.getName();
        User userEntity =userRepository.findByUsername(username).get();
        List<String> roles = userEntity.getRoles().stream().map(role -> role.getRoleName().getStatus()).collect(Collectors.toList());

        String accessToken = JwtUtil.createAccessToken( userEntity, issuer, roles);

        return Map.of("access_token", accessToken, "refresh_token", refreshToken);
    }


    public UserDTO createUser(NewUserDTO userDTO) {
        // Search if user is already present
        if (userRepository.findByUsername(userDTO.getUsername()).isEmpty()) {
            User user = userDtoMapper.toEntity(userDTO);
            user.setPassword(passwordEncoder.encode(userDTO.getPassword()));
            user.setId(null);

            user = userRepository.saveAndFlush(user);

            //devo prima creare l'utente e dopo aggiungere il ruolo

            if(user.getEmail() != "^(?!.*@azienda\\.it$).+$\n"){
                System.out.println("inserimento ruolo");
                RoleDTO roleDTO = assignOrRemoveRole(user.getId(), "CUSTOMER", false);
                System.out.println("fine inserimento");
            }else{
                RoleDTO roleDTO = assignOrRemoveRole(user.getId(), "MANAGER", false);
            }
            System.out.println(user.getRoles());

            return userDtoMapper.toDto(user);
        }
        throw new ResourceConflictException("Username already exists");
    }

    public UserDTO changePassword(String username, PasswordDTO passwordDTO) {
        User userEntity = userRepository.findByUsername(username).orElseThrow(() ->new ResourceNotFoundException("User not found"));
        userEntity.setPassword(passwordEncoder.encode(passwordDTO.getPassword()));
        userEntity = userRepository.saveAndFlush(userEntity);
        return userDtoMapper.toDto(userEntity);
    }


    public RoleDTO assignOrRemoveRole(Long userId, String roleName, boolean remove) {
        System.out.println(roleName);
        System.out.println(userId);

        RoleDTO returner = null;
        Optional<User> optionalUser = userRepository.findById(userId);
        RoleEnum myRole = null;
        try {
            myRole =  RoleEnum.valueOf(roleName);
        } catch (IllegalArgumentException ex) {
            throw  new BadResourceException("Invalid role name");
        }
        Optional<Role> optionalRole = roleRepository.findByRoleName(myRole);
        if (optionalUser.isPresent() && optionalRole.isPresent()) {
            Role role = optionalRole.get();
            User user = optionalUser.get();
            if (remove) {
                user.getRoles().remove(role);
            } else {
                user.getRoles().add(role);
            }
            userRepository.saveAndFlush(user);
            returner = roleDtoMapper.toDto(role);
        }
        return returner;
    }

    public boolean changeParams(UserDTO userDTO) {
        Optional<User> optUser = userRepository.findById(userDTO.getId());
        if(optUser.isPresent()){
            System.out.println("presente");
            User user = optUser.get();
            user.setNome(userDTO.getNome());
            user.setCognome(userDTO.getCognome());
            user.setUsername(userDTO.getUsername());
            user.setEmail(userDTO.getEmail());
            List<BookingDTO> bookingDTO = userDTO.getBookingDTOList();
            user.setBookings(bookingDtoMapper.toList(bookingDTO));
            userRepository.save(user);
            return true;
        }
        System.out.println("utente non presente");
        return false;
    }


    public ArrayList<User> allManagers() {
        ArrayList<User> users = (ArrayList<User>) userRepository.findAll();
        RoleEnum myRole =  RoleEnum.valueOf("MANAGER");
        Optional<Role> optionalRole = roleRepository.findByRoleName(myRole);
        if(optionalRole.isPresent()) {
            Role role = optionalRole.get();
            users.removeIf(user -> !user.getRoles().contains(role));
            return  users;
        }
        return null;
    }
}
