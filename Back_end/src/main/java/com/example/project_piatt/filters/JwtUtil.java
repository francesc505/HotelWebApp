package com.example.project_piatt.filters;

import com.example.project_piatt.Entity.User;
import com.nimbusds.jose.*;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jose.crypto.MACVerifier;
import com.nimbusds.jose.jwk.source.ImmutableSecret;
import com.nimbusds.jose.proc.BadJOSEException;
import com.nimbusds.jose.proc.JWSKeySelector;
import com.nimbusds.jose.proc.JWSVerificationKeySelector;
import com.nimbusds.jose.proc.SecurityContext;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import com.nimbusds.jwt.proc.ConfigurableJWTProcessor;
import com.nimbusds.jwt.proc.DefaultJWTProcessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.text.ParseException;
import java.time.Instant;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

public abstract class  JwtUtil {

    private static final int expireHourToken = 24; // durata del token di accesso (in ore)
    private static final int expireHourRefreshToken = 72; // durata del token di aggiornamento (in ore)

    // chiave utilizzata per firmare i token
    private static final String SECRET = "24BEA5703448DB31F59FFBE165AF49D45EB23A2F49A1EC145D48D7C1891C6AAB";

    public static String createAccessToken(User user, String issuer, List<String> roles) { // jwt di accesso
        try {
            Date issueTime = Date.from(Instant.now());
            JWTClaimsSet claims = new JWTClaimsSet.Builder() // mettiamo le info dell'utente nel claim del token
                    .subject(user.getUsername())
                    .issuer(issuer) // emittente del token
                    .claim("roles", roles)
                    .claim("id",user.getId())
                    .claim("name", user.getCognome()+" "+user.getNome())
                    .claim("email", user.getEmail()!=null?user.getEmail():"")
                    .expirationTime(Date.from(issueTime.toInstant().plusSeconds(expireHourToken * 3600)))
                    .issueTime(issueTime) //emissione
                    .notBeforeTime(issueTime) // quando diventa valido
                    .build();

            Payload payload = new Payload(claims.toJSONObject());

            JWSObject jwsObject = new JWSObject(new JWSHeader(JWSAlgorithm.HS256),
                    payload);

            jwsObject.sign(new MACSigner(SECRET));
            return jwsObject.serialize();
        }
        catch (JOSEException e) {
            throw new RuntimeException("Error to create JWT", e);
        }
    }

    public static String createRefreshToken(String username) { // refresh del token per un utente specifico
        try {
            Date issueTime = Date.from(Instant.now()); // indica l'ora in cui è stato emesso il token
            JWTClaimsSet claims = new JWTClaimsSet.Builder()
                    .subject(username)
                    .issueTime(issueTime)
                    .notBeforeTime(issueTime)
                    .expirationTime(Date.from(issueTime.toInstant().plusSeconds(expireHourRefreshToken * 3600))) // calcolo della scadenza del token
                    .build();

            Payload payload = new Payload(claims.toJSONObject());

            JWSObject jwsObject = new JWSObject(new JWSHeader(JWSAlgorithm.HS256),
                    payload);

            jwsObject.sign(new MACSigner(SECRET));
            return jwsObject.serialize();
        }
        catch (JOSEException e) {
            throw new RuntimeException("Error to create JWT", e);
        }
    }

    public static UsernamePasswordAuthenticationToken parseToken(String token) throws JOSEException, ParseException,
            BadJOSEException { // verifica e decodifica un token jwt ricevuto per l'autenticazione

        byte[] secretKey = SECRET.getBytes();
        SignedJWT signedJWT = SignedJWT.parse(token); // analizziamo il token , che è verificato con MACVerifier
        signedJWT.verify(new MACVerifier(secretKey));
        ConfigurableJWTProcessor<SecurityContext> jwtProcessor = new DefaultJWTProcessor<>(); //si occupa di eleborare e decodificare il token JWT,  validando i dati e i claims

        JWSKeySelector<SecurityContext> keySelector = new JWSVerificationKeySelector<>(JWSAlgorithm.HS256,
                new ImmutableSecret<>(secretKey));
        jwtProcessor.setJWSKeySelector(keySelector);
        jwtProcessor.process(signedJWT, null);

        JWTClaimsSet claims = signedJWT.getJWTClaimsSet(); //estrazione dei claims

// se il token non è ancora valido
        if (claims.getNotBeforeTime() == null || claims.getNotBeforeTime().after(new Date())) { // quando è possibile utilizzarla.
            throw new BadJOSEException("Invalid Token or Token Expired.");
        }
// o è scaduto
        if (claims.getExpirationTime() == null || claims.getExpirationTime().before(new Date())) { // quando termina la sua validità.
            throw new BadJOSEException("Invalid Token or Token Expired.");
        }
//altrimenti
        String username = claims.getSubject();
        var roles = (List<String>) claims.getClaim("roles");
        var authorities = roles == null ? null : roles.stream()
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toList());
        return new UsernamePasswordAuthenticationToken(username, null, authorities);
    }

}
