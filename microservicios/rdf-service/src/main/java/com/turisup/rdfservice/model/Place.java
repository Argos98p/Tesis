package com.turisup.rdfservice.model;

import lombok.Data;

import java.util.ArrayList;

@Data
public class Place {
    String id;
    String name;

    PlacePoint coordinates;
    String description;
    String category;
    String userId;
    ArrayList<String> imagesPaths;
    ArrayList<String> fbImagesIds;
    ArrayList<String> fbVideoIds;

    public Place(String id, String name, PlacePoint coordinates, String description, String category, String userId, ArrayList<String> imagesPaths, ArrayList<String> fbImagesIds, ArrayList<String> fbVideoIds) {
        this.id = id;
        this.name = name;
        this.coordinates = coordinates;
        this.description = description;
        this.category = category;
        this.userId = userId;
        this.imagesPaths = imagesPaths;
        this.fbImagesIds = fbImagesIds;
        this.fbVideoIds = fbVideoIds;
    }
}


