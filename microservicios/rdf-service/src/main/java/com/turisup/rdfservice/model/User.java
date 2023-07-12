package com.turisup.rdfservice.model;

public class User {
    String id;
    String name;
    String email;
    String imageUrl;

    public User(String id, String email,String name, String imageUrl) {
        this.id = id;
        this.email = email;
        this.name = name;
        this.imageUrl = imageUrl;
    }
}
