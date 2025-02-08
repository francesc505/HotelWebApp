package com.example.project_piatt.Service;

import com.example.project_piatt.Entity.Booking;
import com.example.project_piatt.Entity.Payment;
import com.example.project_piatt.Enum.BookEnum;
import com.example.project_piatt.Enum.PayementEnum;
import com.example.project_piatt.Mapper.BookingDtoMapper;
import com.example.project_piatt.Model.BookingDTO;
import com.example.project_piatt.Repository.BookRepository;
import com.example.project_piatt.Repository.PaymentRepository;
import jakarta.persistence.LockModeType;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PaymentService {
    private final PaymentRepository paymentRepository;
    private final BookRepository bookRepository;
    private final BookingDtoMapper bookingDtoMapper;


    @Transactional
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    public String doPayment(BookingDTO bookingDTO, int amount, String type, int nRooms) {
        System.out.println("PAGAMENTO: " + bookingDTO.toString());
        Optional<Payment> paymentOptional =  paymentRepository.findByBooking_Id(bookingDTO.getId());
        if(paymentOptional.isPresent()){
            //allora ha già effettuato altri pagamenti
            Payment payment = paymentOptional.get();
            if(payment.getTotalAmount() !=  bookingDTO.getTotalPrice()){
                if((payment.getTotalAmount()+amount) <= bookingDTO.getTotalPrice()) {
                    // devo salvare tutti i dati
                    payment.setTotalAmount(payment.getTotalAmount()+amount);
                    payment.setPaymentState(PayementEnum.ACCEPTED);
                    payment.setTransaction_type(type);
                    paymentRepository.save(payment);


                    bookingDTO.setStatus(BookEnum.TERMINATED);
                    bookingDTO.setNRooms(nRooms);
                    bookRepository.save(bookingDtoMapper.toEntity(bookingDTO));

                    return "pagamento effettuato correttamente";
                }
                return "pagamento già effettuato";
            }
            return "pagamento già effettuato";
        }else{
            // è la prima volta che effettua il pagamento
            Payment payment = new Payment();
            payment.setDate(LocalDate.now());
            payment.setUserId((bookingDTO.getUserId()));
            payment.setBookingId(bookingDTO.getId());

            if(amount ==  bookingDTO.getTotalPrice()){
                payment.setTotalAmount(amount);

                bookingDTO.setStatus(BookEnum.TERMINATED);
                bookingDTO.setNRooms(nRooms);
                bookRepository.save(bookingDtoMapper.toEntity(bookingDTO));
                payment.setPaymentState(PayementEnum.ACCEPTED);
            }else {
                payment.setTotalAmount(amount);
                payment.setPaymentState(PayementEnum.PROCESSING);
            }
            payment.setTransaction_type(type);
            paymentRepository.save(payment);
            return "pagamento effettuato";
        }
    }


    @Transactional
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    public int toPay(Long bookingId) {
        Optional<Payment> paymentOptional = paymentRepository.findByBooking_Id(bookingId);
        Optional<Booking> booking = bookRepository.findById(bookingId);
        if(paymentOptional.isPresent() && booking.isPresent()){
            return  booking.get().getTotalPrice() - paymentOptional.get().getTotalAmount();
        }
        return 0;
    }
}
