package com.turisup.rdfservice.utils;

import org.json.simple.JSONObject;

import javax.activation.MimetypesFileTypeMap;
import java.awt.geom.Point2D;
import java.io.File;

public class Utils {

    public static Point2D.Double literalToPoint(String pointLiteral){
        // String myPoint = pointLiteral.toString();
        String aux = pointLiteral.substring(pointLiteral.indexOf("(")+1, pointLiteral.indexOf(")"));
        String [] aux2 = aux.split(" ");
        return new Point2D.Double(Double.parseDouble(aux2[0]), Double.parseDouble(aux2[1]));
    }


    public static String getTypeOfFile(String filepath){

        File f = new File(filepath);
        String mimetype= new MimetypesFileTypeMap().getContentType(f);
        String type = mimetype.split("/")[0];
        System.out.println(type);
        if(type.equals("image"))
            return "isImage";
        else if(type.equals("application"))
            return "isVideo";
        return "noValid";
    }



    public static double distanceGeo(double lat1,
                                     double lat2, double lon1,
                                     double lon2)
    {

        // The math module contains a function
        // named toRadians which converts from
        // degrees to radians.
        lon1 = Math.toRadians(lon1);
        lon2 = Math.toRadians(lon2);
        lat1 = Math.toRadians(lat1);
        lat2 = Math.toRadians(lat2);

        // Haversine formula
        double dlon = lon2 - lon1;
        double dlat = lat2 - lat1;
        double a = Math.pow(Math.sin(dlat / 2), 2)
                + Math.cos(lat1) * Math.cos(lat2)
                * Math.pow(Math.sin(dlon / 2),2);

        double c = 2 * Math.asin(Math.sqrt(a));

        // Radius of earth in kilometers. Use 3956
        // for miles
        double r = 6371;

        // calculate the result
        return(c * r);
    }
}