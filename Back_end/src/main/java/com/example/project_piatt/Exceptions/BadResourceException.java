package com.example.project_piatt.Exceptions;

public class BadResourceException extends RuntimeException{
    public BadResourceException() {
    }
    public BadResourceException(String message) {
        super(message);
    }
}
