package com.turisup.authservice.service;

import com.turisup.authservice.dto.AuthUserDto;
import com.turisup.authservice.dto.NewUserDto;
import com.turisup.authservice.dto.RequestDto;
import com.turisup.authservice.dto.TokenDto;
import com.turisup.authservice.entity.AuthProvider;
import com.turisup.authservice.entity.AuthUser;
import com.turisup.authservice.repository.AuthUserRepository;
import com.turisup.authservice.security.JwtProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AuthUserService {

    @Autowired
    AuthUserRepository authUserRepository;

    @Autowired
    PasswordEncoder passwordEncoder;

    @Autowired
    JwtProvider jwtProvider;

    public AuthUser save(NewUserDto dto) {
        Optional<AuthUser> user =authUserRepository.findByEmail(dto.getEmail());
        if(user.isPresent())
            return null;
        String password = passwordEncoder.encode(dto.getPassword());
        AuthUser authUser = AuthUser.builder()
                .userName(dto.getUserName())
                .email(dto.getEmail())
                .imageUrl(dto.getImageUrl())
                .provider(AuthProvider.local)
                .providerId("")
                .password(password)
                .role(dto.getRole())
                .emailVerified("")
                .build();
        return authUserRepository.save(authUser);
    }

    public TokenDto login(AuthUserDto dto) {
        Optional<AuthUser> user = authUserRepository.findByEmail(dto.getEmail());
        if(!user.isPresent())
            return null;
        if(passwordEncoder.matches(dto.getPassword(), user.get().getPassword()))
            return new TokenDto(jwtProvider.createToken(user.get()));
        return null;
    }

    public TokenDto validate(String token, RequestDto dto) {
        if(!jwtProvider.validate(token, dto))
            return null;
        String email = jwtProvider.getEmailFromToken(token);
        if(!authUserRepository.findByEmail(email).isPresent())
            return null;
        return new TokenDto(token);
    }
}
