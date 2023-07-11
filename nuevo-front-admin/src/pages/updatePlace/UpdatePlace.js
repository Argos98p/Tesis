import {Form} from '@themesberg/react-bootstrap';
import MapPicker from 'react-google-map-picker'
import React, {useState} from "react";
import {Button} from '@themesberg/react-bootstrap';
import FacebookPlayer from "react-facebook-player";
import {FaTrash} from "react-icons/fa";


const DefaultLocation = {lat: -2.902, lng: -79.0113};


const DefaultZoom = 10;
export default function UpdatePlace({data}) {
    const [defaultLocation, setDefaultLocation] = useState({
        lat: data.coordenadas.longitud,
        lng: data.coordenadas.latitud
    });

    const [location, setLocation] = useState(defaultLocation);
    const [titulo, setTitulo] = useState(data.nombre);
    const [descripcion, setDescripcion] = useState(data.descripcion);
    const [categoria, setCategoria] = useState(data.categoria);
    const [uploadedFiles, setUploadedFiles] = useState([]);
    const [fileLimit, setFileLimit] = useState(false);

    const [zoom, setZoom] = useState(DefaultZoom);

    const handleFileEvent = (e) => {
        const chosenFiles = Array.prototype.slice.call(e.target.files);
        handleUploadFiles(chosenFiles);
    }

    const handleUploadFiles = files => {
        const uploaded = [...uploadedFiles];
        let limitExceeded = false;
        files.some((file) => {
            if (uploaded.findIndex((f) => f.name === file.name) === -1) {
                uploaded.push(file);
                if (uploaded.length === 100000) setFileLimit(true);
                if (uploaded.length > 100000) {
                    setFileLimit(false);
                    limitExceeded = true;
                    return true;
                }
            }
        })
        if (!limitExceeded) setUploadedFiles(uploaded);
    }

    const handleChangeTitulo = event => {
        setTitulo(event.target.value);
        console.log('value titulo:', event.target.value);
    };

    const handleChangeDescripcion = event => {
        setDescripcion(event.target.value);
        console.log('value descripcion:', event.target.value);
    };

    const handleChangeCategoria = event => {
        setCategoria(event.target.value);
        console.log('value categoria:', event.target.value);
    };


    function handleChangeLocation(lat, lng) {
        setLocation({lat: lat, lng: lng});
    }

    function handleChangeZoom(newZoom) {
        setZoom(newZoom);
    }

    function handleResetLocation() {
        setDefaultLocation({...DefaultLocation});
        setZoom(DefaultZoom);
    }

    return (
        <div className=" mx-4 mt-4 ">
            <Form>
                <Form.Group className="mb">
                    <Form.Label>Nombre </Form.Label>
                    <Form.Control type="text" placeholder="Hosteria Dos Chorreras" value={titulo}
                                  onChange={handleChangeTitulo}/>

                </Form.Group>
                <Form.Group className={"mt-2"}>
                    <Form.Label>Descripcion</Form.Label>
                    <Form.Control style={{height: "85px"}} as="textarea" rows="4" value={descripcion}
                                  placeholder="Escribe una descripcion..."/>
                </Form.Group>

                <Form.Group className="mt-2">
                    <Form.Label>Categoria</Form.Label>
                    <Form.Select value={categoria}>
                        <option defaultValue>Seleccione una categoria</option>
                        <option value={"iglesia"}>Iglesia</option>
                        <option value={"laguna"}>Laguna</option>
                        <option value={"hotel"}>Hotel</option>
                        <option value={"montaña"}>Montaña</option>
                        <option value={"teatro"}>Teatro</option>
                        <option value={"restaurant"}>Restaurant</option>
                    </Form.Select>
                </Form.Group>

                <Form.Group className="mt-2">
                    <Form.Label>Indica la ubicacion del recurso</Form.Label>
                    <div className={"row"}>
                        <div className={"col-md-8"}>
                            <MapPicker defaultLocation={defaultLocation}
                                       zoom={zoom}
                                       mapTypeId="roadmap"
                                       style={{height: '700px'}}
                                       onChangeLocation={handleChangeLocation}
                                       onChangeZoom={handleChangeZoom}
                                       apiKey='AIzaSyD9m7bZ0SieFUTH7PdJakPdV2cZwIkbXFo'/>
                        </div>
                        <div className={"col-md-4"}>
                            <Form.Group className="mt-2">
                                <Form.Label>Latitud </Form.Label>
                                <Form.Control type="text" placeholder="latitud" value={location.lat}/>
                            </Form.Group>
                            <Form.Group className="mt-2">
                                <Form.Label> Longitud</Form.Label>
                                <Form.Control type="text" placeholder="latitud" value={location.lng}/>
                            </Form.Group>
                        </div>
                    </div>

                </Form.Group>






                <Form.Group className="mt-5 ">
                    <Form.Label>Recursos multimedia</Form.Label>
                    <div className={"scrolling-wrapper"}>
                        {data["imagenesPaths"].map((image) =>
                            <div className={"card"} style={{height: "200px", position:"relative"}}>
                                <Button style={{position:"absolute",top:"3px", right:"3px"}} variant="danger" className="m-1"><FaTrash/></Button>
                                <img src={image} alt={"a"}/>
                            </div>
                        )}
                    </div>
                    <div className={"scrolling-wrapper"}>
                        {data["fbVideoIds"].map((image) =>
                            <div className={"card"} style={{maxHeight: "200px", position:"relative"}}>
                                <Button style={{position:"absolute",top:"3px", right:"3px", zIndex:"999"}} variant="danger" className="m-1"><FaTrash/></Button>
                                <FacebookPlayer
                                    className={"fb-video"}
                                    width={"250px"}
                                    id={image}
                                    videoId={image}
                                    appId={"2720769541388315"}
                                    onReady={() => {
                                    }}
                                />
                            </div>

                        )}
                    </div>
                </Form.Group>
                <Form.Group className="mt-4">
                    <Form.Label>Añade mas imagenes o videos</Form.Label>
                    <Form.Control type="file" accept="image/*, video/*" multiple={"multiple"} onChange={handleFileEvent}
                                  disabled={fileLimit}/>
                </Form.Group>

                <Form.Group className="mt-5 ">
                    <div style={{display: "flex", justifyContent: "center", alignItems: "center"}}>
                        <Button variant="success" className="m-1">ACTUALIZAR RECURSO</Button>
                    </div>
                </Form.Group>


            </Form>

        </div>

    );
}