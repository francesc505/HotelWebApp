package com.example.project_piatt.filters;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import static org.springframework.http.HttpHeaders.AUTHORIZATION;
import static org.springframework.http.HttpStatus.FORBIDDEN;
import static org.springframework.http.MediaType.APPLICATION_JSON_VALUE;

public class CustomAuthorizationFilter extends OncePerRequestFilter { //andiamo a gestire una sola richiesta per volta
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        //gestire la verifica e l'autorizzazione dei token JWT (JSON Web Token) per ogni richiesta HTTP, tranne quelle
        // destinate al login e al refresh del token.

        String token = null;
        String regex = "^/user/([A-Za-z0-9\u00C0-\u024F\u0300-\u036F\u1E00-\u1EFF_-]+)/changePassword/NoToken$";

        System.out.println(request.getServletPath());
        if(request.getServletPath().equals("/login") || request.getServletPath().equals("/refreshToken") || request.getServletPath().matches(regex)
            || request.getServletPath().equals("/user") ||  request.getServletPath().equals("/ws"))  { // esclusione delle rotte
            filterChain.doFilter(request, response);
        } else {
            String authorizationHeader = request.getHeader(AUTHORIZATION); // legge l'header di autorizzazione
            if(authorizationHeader != null && authorizationHeader.startsWith("Bearer")) {
                try {
                    token = authorizationHeader.substring("Bearer ".length()); // rimuove la parte BEARER dall'header ( estraggo il token)
                    UsernamePasswordAuthenticationToken authenticationToken = JwtUtil.parseToken(token);// valida e decodifica il token
                    SecurityContextHolder.getContext().setAuthentication(authenticationToken); // imposta l'autenticazione nel contesto di sicurezza
                    filterChain.doFilter(request, response);
                }
                catch (Exception e) {
                    //log.error(String.format("Error auth token: %s", token), e);
                    System.out.println("qua 1");
                    response.setStatus(FORBIDDEN.value()); // errore 403
                    Map<String, String> error = new HashMap<>();
                    error.put("errorMessage", e.getMessage());
                    response.setContentType(APPLICATION_JSON_VALUE);
                    new ObjectMapper().writeValue(response.getOutputStream(), error);
                }
            } else {
                filterChain.doFilter(request, response);
            }
        }
    }
}