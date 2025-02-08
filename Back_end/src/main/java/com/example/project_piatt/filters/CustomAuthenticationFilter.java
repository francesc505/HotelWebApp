package com.example.project_piatt.filters;


import com.example.project_piatt.Repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

import static org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR;
import static org.springframework.http.MediaType.APPLICATION_JSON_VALUE;


public class CustomAuthenticationFilter extends UsernamePasswordAuthenticationFilter {
    // determina chi è l'utente e che privilegi possiede
    private static final String BAD_CREDENTIAL_MESSAGE = "Authentication failed for username: %s and password: %s";
    private final AuthenticationManager authenticationManager; // gestisce il processo di autenticazione
    public CustomAuthenticationFilter(AuthenticationManager authenticationManager, UserRepository userRepository) {
        this.authenticationManager = authenticationManager;
        this.userRepository = userRepository;
    }

    private UserRepository userRepository;

    @SneakyThrows
    @Override
    public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response)
            throws AuthenticationException {
        // sovrascrive l'attemptAuthentication per elaborare i dati di autenticazione provenienti dalla richiesta http

        String username = null;
        String password = null;
        try {
            ObjectMapper objectMapper = new ObjectMapper(); // utilizzato per leggere il corpo della richiesta
            Map<String, String> map = objectMapper.readValue(request.getInputStream(), Map.class);
            username = map.get("username");
            password = map.get("password");
//            log.debug("Login with username: {}", username);
            return authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(username, password));
        }
        catch (AuthenticationException e) {
            //log.error(String.format(BAD_CREDENTIAL_MESSAGE, username, password), e);
            throw e;
        }
        catch (Exception e) {
            response.setStatus(INTERNAL_SERVER_ERROR.value());
            Map<String, String> error = new HashMap<>();
            error.put("errorMessage", e.getMessage());
            response.setContentType(APPLICATION_JSON_VALUE);

            new ObjectMapper().writeValue(response.getOutputStream(), error);
            throw new RuntimeException(String.format("Error in attemptAuthentication with username %s and password %s", username, password), e);
        }
    }

    @Override
    protected void successfulAuthentication(HttpServletRequest request, HttpServletResponse response, FilterChain chain,
                                            Authentication authentication) throws IOException, ServletException {
        // il metodo viene richiamato quando l'autenticazione va a buon fine

        User user = (User)authentication.getPrincipal(); //ottiene l'utente autenticato dalla sessione
        com.example.project_piatt.Entity.User dbUser = userRepository.findByUsername(user.getUsername()).get(); // ottiene piu dati relativi all'utente
        String accessToken = JwtUtil.createAccessToken(dbUser, request.getRequestURL().toString(),
                user.getAuthorities().stream().map(GrantedAuthority::getAuthority).collect(Collectors.toList()));
        String refreshToken = JwtUtil.createRefreshToken(user.getUsername());
        response.addHeader("access_token", accessToken);
        response.addHeader("refresh_token", refreshToken);
        HashMap<String,String> responseObject = new HashMap<>();
        responseObject.put("access_token", accessToken);
        responseObject.put("refresh_token", refreshToken);

        ObjectMapper mapper = new ObjectMapper();
        response.setContentType(APPLICATION_JSON_VALUE);
        mapper.writeValue(response.getOutputStream(), responseObject);
    }

    @Override
    protected void unsuccessfulAuthentication(HttpServletRequest request, HttpServletResponse response, AuthenticationException failed) throws IOException, ServletException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        ObjectMapper mapper = new ObjectMapper();
        Map<String, String> error = new HashMap<>();
        error.put("errorMessage", "Bad credentials");
        response.setContentType(APPLICATION_JSON_VALUE);
        mapper.writeValue(response.getOutputStream(), error);
    }
}