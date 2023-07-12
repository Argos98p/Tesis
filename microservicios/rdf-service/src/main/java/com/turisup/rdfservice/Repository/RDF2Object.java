package com.turisup.rdfservice.Repository;

import com.turisup.rdfservice.model.*;
import com.turisup.rdfservice.utils.Utils;
import org.apache.jena.query.QuerySolution;

import java.awt.geom.Point2D;
import java.util.ArrayList;
import java.util.Arrays;

public class RDF2Object {
    public static Place toPlace(QuerySolution soln, Double latitud, Double longitud){
        if (soln.getLiteral("orgName") == null){
            return null;
        }
        //ATRIBUTOS DE LA ORGANIZACION
        String orgName = soln.getLiteral("orgName").toString();
        String orgId= soln.getResource("org").getLocalName();

        //ATRIBUTOS DE LA REGION

        String region = "";
        String regionId = "";
        if( soln.getLiteral("regionName") != null && soln.getResource("region")!=null){
            region = soln.getLiteral("regionName").toString();
            regionId= soln.getResource("region").getLocalName();
        }


        //ATRIBUTOS DEL USUARIO
        String creadoPor= soln.getResource("creator").toString().replace("http://turis-ucuenca/user/","");
        String nombreCreador=soln.getLiteral("creatorName").toString();
        String imageUser = soln.getResource("creatorImage").toString();


        //ATRIBUTOS DEL LUGAR


        String placeId = soln.getResource("place").toString().replace("http://turis-ucuenca/lugar/","");
        String status = soln.getLiteral("placeStatus").toString();
        String titulo = soln.getLiteral("placeName").toString();
        String descripcion = soln.getLiteral("placeDescription").toString();
        String favorito = soln.getLiteral("favorite").toString();
        String date = soln.getLiteral("placeDate").toString().replace("^^http://www.w3.org/2001/XMLSchema#dateTime","");
        Point2D.Double placePoint= Utils.literalToPoint(soln.getLiteral("placePoint").toString());
        PlacePoint mypoint = new PlacePoint(placePoint.x,placePoint.y);


        ArrayList<String> facebookVideoIds = new ArrayList<>();
        if(soln.getLiteral("facebookVideoIds")!=null){
            facebookVideoIds= new ArrayList( Arrays.asList( soln.getLiteral("facebookVideoIds").toString().split(",") ) );
            facebookVideoIds.remove("http://www.w3.org/1999/02/22-rdf-syntax-ns#Bag");
            facebookVideoIds.remove("http://www.w3.org/2000/01/rdf-schema#Container");
        }
        ArrayList<String> facebookImagesIds= new ArrayList( Arrays.asList( soln.getLiteral("facebooImagesIds").toString().split(",") ) );
        facebookImagesIds.remove("http://www.w3.org/1999/02/22-rdf-syntax-ns#Bag");
        facebookImagesIds.remove("http://www.w3.org/2000/01/rdf-schema#Container");

        ArrayList<String> imagesUrl =  new ArrayList( Arrays.asList( soln.getLiteral("images").toString().replace("\"","").split(",") ) );

        String placeCategory =  "sin categoria";
        if(soln.getLiteral("placeCategory")!=null){
            placeCategory = soln.getLiteral("placeCategory").toString();
        }
        double rate = 0.0;
        if(soln.getLiteral("rate")!=null ){
            rate=soln.getLiteral("rate").getDouble();
            if(rate == 0.0){
                rate = 0.0;
            }
        }

        double distance = 9999.0;
        if(longitud!=null && latitud!=null){

            distance= Utils.distanceGeo(mypoint.getLatitude(),longitud,mypoint.getLongitude(),latitud);
        }
        /*
        if(soln.getLiteral("distance")!=null){
            distance =Double.parseDouble( soln.getLiteral("distance").toString())/1000;
        }*/

        int numComentarios = 0;
        if(soln.getLiteral("placeCategory")!= null){
            numComentarios = soln.getLiteral("comments").getInt();
        }

        return new Place(
                placeId,titulo,mypoint,descripcion,placeCategory,creadoPor,imagesUrl,facebookImagesIds,facebookVideoIds
        );
    }
}
