import React, { useEffect } from 'react'
/*import locationIcon from '@iconify/icons-mdi/map-marker'*/
import GoogleMaps from "simple-react-google-maps"
import GoogleMapReact from 'google-map-react';




const Map = ({ location, zoomLevel,data }) => {
  const AnyReactComponent = ({ text,img }) => <div ><img   style={{width:'40px',height:'40px',border:"2px solid white", borderRadius:'100%',overflow:'hidden'}} src={img[0]}></img></div>;



  const defaultProps = {
    center: {
      lat: 10.99835602,
      lng: 77.01502627
    },
    zoom: 10
  };
  return (
    <div style={{width:'100%',height:'400px',borderRadius:'1em',overflow:'hidden'}}>

      <GoogleMapReact

      bootstrapURLKeys={{ key: "AIzaSyD9m7bZ0SieFUTH7PdJakPdV2cZwIkbXFo" }}
      defaultCenter={{lat: location.lat, lng: location.lng}}
      defaultZoom={12}
      >
      <AnyReactComponent
        lat={location.lat}
        lng={location.lng}
        text={data.nombre}
        img={data.imagenesPaths}
      />
      </GoogleMapReact>
    </div>
    
      
    );
  }

export default Map