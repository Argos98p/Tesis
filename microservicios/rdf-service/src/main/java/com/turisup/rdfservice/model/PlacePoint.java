package com.turisup.rdfservice.model;

import lombok.Data;

@Data
public class PlacePoint {
    double latitude;
    double longitude;

    public PlacePoint(double latitude, double longitude) {
        this.latitude = latitude;
        this.longitude = longitude;
    }
}
