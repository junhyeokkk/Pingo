package com.pingo.security;

import com.pingo.entity.users.Users;
import com.pingo.mapper.SignMapper;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@Slf4j
@AllArgsConstructor
// 알아서 DB 조회까지
public class SecurityUserService implements UserDetailsService {

    private final SignMapper signMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        log.info("SecurityUserService.........");
        Optional<Users> selectedUsers = signMapper.findByUserIdForSignIn(username);
        UserDetails userDetails = null;
        if (selectedUsers.isPresent()) {
            userDetails = MyUserDetails.builder().users(selectedUsers.get()).build();
        }
        return userDetails;
    }
}
