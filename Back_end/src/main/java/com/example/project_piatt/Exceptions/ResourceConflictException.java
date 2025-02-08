package com.example.project_piatt.Exceptions;

public class ResourceConflictException extends RuntimeException{
    public ResourceConflictException() {
    }
    public ResourceConflictException(String message) {
        super(message);
    }
}
