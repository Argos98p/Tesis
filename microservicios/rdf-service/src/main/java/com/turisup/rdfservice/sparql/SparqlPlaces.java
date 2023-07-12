package com.turisup.rdfservice.sparql;

public class SparqlPlaces {


    public static String  all(String creatorId){

        return SparqlPrefixes.prefixes +
                "select ?creator ?creatorName  ?place ?creatorImage ?placeName ?placeCategory ?placeStatus ?placeDescription ?placeDate ?placePoint  (AVG(?rating) as ?rate) (COUNT(?rating) as ?comments) ?region ?regionName ?org  ?orgName ?favorite ?distance  ?facebooImagesIds ?facebookVideoIds ?images WHERE {\n" +
                "select ?creator ?creatorName  ?place ?creatorImage ?placeName ?placeCategory ?placeStatus ?placeDescription ?placeDate ?placePoint   ?region ?regionName ?org  ?orgName ?favorite ?distance  (GROUP_CONCAT(DISTINCT ?idImageFacebook ; SEPARATOR = ',') AS ?facebooImagesIds) (GROUP_CONCAT(DISTINCT ?idVideoFacebook ; SEPARATOR = ',') AS ?facebookVideoIds) (GROUP_CONCAT(DISTINCT ?images2 ; SEPARATOR = ',') AS ?images) ?rating WHERE {\n" +
                "    {\n" +
                "        ?place a tp:POI.\n" +
                "        ?place base2:status ?placeStatus.\n" +
                "        ?place dc:date ?placeDate.\n" +
                "        ?place base2:facebookId ?imagesFbNode.\n" +
                "        ?imagesFbNode rdfs:member ?idImageFacebook.\n" +
                "        ?place dc:title ?placeName.\n" +
                "        ?place dc:description ?placeDescription.\n" +
                "        ?place geo:hasGeometry ?geom.\n" +
                "        ?place base2:category ?placeCategory.\n" +
                "        ?geom geo:asWKT ?placePoint.\n" +
                "        ?place vcard:hasPhoto ?images2.\n" +
                "    }\n" +
                "    OPTIONAL{\n" +
                "        ?place fb:facebookVideoId ?videoFbNode.\n" +
                "        ?videoFbNode rdfs:member ?idVideoFacebook.\n" +
                "    }\n" +
                "    {\n" +
                "        ?region a :Region.\n" +
                "        ?region dc:title ?regionName.\n" +
                "        ?region geo:hasGeometry ?geoRegion.\n" +
                "        ?geoRegion geo:asWKT ?regionWKT .\n" +
                "    }\n" +
                "    FILTER geof:sfWithin(?placePoint,?regionWKT).\n" +
                "    {\n" +
                "        ?org a org:Organization.\n" +
                "        ?org dc:title ?orgName.\n" +
                "        \n" +
                "    }\n" +
                " OPTIONAL{\n" +
                "            ?comment a :Comentario.\n" +
                "            ?comment fb:place ?place. \n" +
                "            ?comment fb:rating ?rating.\n" +
                "            \n" +
                "        }"+
                "    {\n" +
                "        ?creator a foaf:Person.\n" +
                "        ?creator foaf:name ?creatorName.\n" +
                "        ?creator foaf:depiction ?creatorImage.  \n" +
                "    }\n" +
                "    ?place dc:creator ?creator.\n" +
                "    BIND (if(EXISTS{?place base2:isFavoriteOf <http://turis-ucuenca/user/"+ creatorId+">}, \"si\",\"no\") as ?favorite).\n" +
                "    ?region :isAdminBy ?org.\n" +
                "} GROUP BY ?creator ?creatorName  ?place ?creatorImage ?placeName ?placeCategory ?placeStatus ?placeDescription ?placeDate ?placePoint ?region ?regionName ?org  ?orgName ?favorite ?distance ?rating\n" +
                "}GROUP BY ?creator ?creatorName  ?place ?creatorImage ?placeName ?placeCategory ?placeStatus ?placeDescription ?placeDate ?placePoint  ?region ?regionName ?org  ?orgName ?favorite ?distance  ?facebooImagesIds ?facebookVideoIds ?images  ORDER BY  DESC(?rate) ";

    }
}
