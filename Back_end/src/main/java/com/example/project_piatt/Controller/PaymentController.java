package com.example.project_piatt.Controller;


import com.example.project_piatt.Model.BookingDTO;
import com.example.project_piatt.Repository.BookRepository;
import com.example.project_piatt.Service.PaymentService;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@SecurityScheme(name = "Bearer", type = SecuritySchemeType.HTTP, scheme = "bearer", bearerFormat = "JWT")
@Tag(name = "user", description = "the user API")
@RestController
@RequestMapping("/payment")
@Validated
@RequiredArgsConstructor
@ResponseBody
public class PaymentController {

    private final PaymentService paymentService;
    private final BookRepository bookRepository;


    @PreAuthorize("hasAuthority('CUSTOMER') or hasAuthority('MANAGER') or hasAuthority('ADMIN')")
    @PostMapping(value = "/dopayment/{amount}/{type}/{nRooms}", consumes = {"application/json"})
    public String getDoPayment(@RequestBody BookingDTO bookingDTO,
                               @PathVariable int amount,
                               @PathVariable String type,
                               @PathVariable int nRooms) {
        return paymentService.doPayment(bookingDTO, amount, type, nRooms);
    }

    @PreAuthorize("hasAuthority('CUSTOMER') or hasAuthority('MANAGER') or hasAuthority('ADMIN')")
    @GetMapping(value = "/toPay/{bookingId}", consumes = {"application/json"})
    public int toPay(@PathVariable Long bookingId ){
        return paymentService.toPay(bookingId);
    }

}
