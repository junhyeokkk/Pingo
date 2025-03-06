package com.pingo.security.jwt;

import jakarta.servlet.http.HttpServletResponse;
import lombok.Getter;
import org.springframework.http.MediaType;

import java.io.IOException;

public class JwtMyException extends RuntimeException{

    JWT_ERROR jwtError;

    @Getter
    public enum JWT_ERROR {
        BADTYPE(401, "JWT type is not Bearer or is null"),
        MALFORM(402, "JWT malformed"),
        BADSIGN(403, "JWT has bad signatured"),
        EXPIRED(404, "JWT expired");

        private int status;
        private String message;

        JWT_ERROR(int status, String message){
            this.status = status;
            this.message = message;
        }
    }

    public JwtMyException(JWT_ERROR jwtError){
        super(jwtError.name());
        this.jwtError = jwtError;
    }

    public void sendResponseError(HttpServletResponse resp) throws IOException {
        resp.setStatus(jwtError.getStatus());
        resp.setContentType(MediaType.APPLICATION_JSON_VALUE);
        resp.getWriter().println(jwtError.getMessage());
    }
}