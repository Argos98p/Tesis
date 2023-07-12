package com.turisup.rdfservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

@SpringBootApplication
@EnableEurekaClient
public class RdfServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(RdfServiceApplication.class, args);
	}

}
