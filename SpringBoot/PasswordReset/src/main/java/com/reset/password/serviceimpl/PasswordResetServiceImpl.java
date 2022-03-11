package com.reset.password.serviceimpl;


import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.reset.password.entity.PasswordReset;
import com.reset.password.repo.PasswordResetRepository;
import com.reset.password.service.IPasswordResetService;
@Service
public class PasswordResetServiceImpl implements IPasswordResetService {
	
	@Autowired
	PasswordResetRepository pResetRepository;

	@Override
	public String sendRequest(PasswordReset reset) {
		
		Optional<PasswordReset> optPassword=pResetRepository.findByEmailId(reset.getEmpEmailId());
		if (optPassword.isPresent()) {
			optPassword.get();
			return "Already exists";
		}else {
			pResetRepository.save(reset);
			return "checked";
		}
		
	}
}
