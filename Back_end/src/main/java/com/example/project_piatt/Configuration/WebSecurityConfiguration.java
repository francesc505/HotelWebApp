package com.example.project_piatt.Configuration;


import com.example.project_piatt.filters.CustomAuthenticationFilter;
import com.example.project_piatt.filters.CustomAuthorizationFilter;
import com.example.project_piatt.Repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.Collections;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(jsr250Enabled = true,prePostEnabled = true,securedEnabled = true)//abilita: @RolesAllowed,
//PreAuthorize e @PostAuthorize, e @Secured per il controllo dell'accesso
public class WebSecurityConfiguration implements WebMvcConfigurer {

    @Autowired
    private UserRepository userRepository;

    private final static String regex = "^/user/([A-Za-z0-9\u00C0-\u024F\u0300-\u036F\u1E00-\u1EFF_-]+)/changePassword/NoToken$";

    @Bean
    BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }//cifrare e confrontare le password

    @Bean // è il componente centrale per gestire l'autenticazione
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }


    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http, AuthenticationManager authenticationManager) throws Exception {
// HTTPSECURITY, permette di definire come spring security deve proteggere l'applicazione
        http
                .cors().configurationSource(new CorsConfigurationSource() {

                    @Override
                    public CorsConfiguration getCorsConfiguration(HttpServletRequest request) {
                        CorsConfiguration config = new CorsConfiguration();
                        config.setAllowedHeaders(Collections.singletonList("*")); // accetta le richieste da qualsiasi origine
                        config.setAllowedMethods(Collections.singletonList("*"));
                        config.addAllowedOrigin("*");
                        config.setAllowCredentials(false);
                        return config;
                    }
                }).and()
                .csrf().disable() // disabilitiamo la protezione csrf
                .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                // impostazione della gestione su stateless
                .and()
                .authorizeHttpRequests((authz) -> authz
                        .requestMatchers("/user").permitAll()
                        .requestMatchers(request -> request.getServletPath().matches(regex)).permitAll()
                        .requestMatchers("/api-docs").permitAll()
                        .requestMatchers("/api-docs/**").permitAll()
//                        .requestMatchers("/swagger-ui/**").permitAll()
//                        .requestMatchers("/swagger-resources/**").permitAll()
//                        .requestMatchers("/swagger-resources").permitAll()
//                        .requestMatchers("/ws/*").permitAll()
                        .anyRequest().authenticated()

                )
                .addFilter(new CustomAuthenticationFilter(authenticationManager,userRepository))
                .addFilterBefore(new CustomAuthorizationFilter(), UsernamePasswordAuthenticationFilter.class)
                .headers().cacheControl();// le risposte non devono essere memorizzare nella cache del browser

        return http.build();
    }


}