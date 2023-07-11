import { Form } from '@themesberg/react-bootstrap';
import MapPicker from 'react-google-map-picker'
import {useState} from "react";
import { Button } from '@themesberg/react-bootstrap';


const DefaultLocation = { lat: -2.902, lng: -79.0113};


const DefaultZoom = 10;
export default function NewPlace(){
    const [defaultLocation, setDefaultLocation] = useState(DefaultLocation);

    const [location, setLocation] = useState(defaultLocation);
    const [titulo, setTitulo] = useState("");
    const [descripcion, setDescripcion] = useState("");
    const [categoria, setCategoria] = useState("");
    const [uploadedFiles, setUploadedFiles] = useState([]);
    const [fileLimit, setFileLimit] = useState(false);

    const [zoom, setZoom] = useState(DefaultZoom);

    const handleFileEvent= (e) => {
        const chosenFiles = Array.prototype.slice.call(e.target.files);
        handleUploadFiles(chosenFiles);
    }

    const handleUploadFiles = files => {
        const uploaded = [...uploadedFiles];
        let limitExceeded = false;
        files.some((file)=>{
            if(uploaded.findIndex((f)=>f.name === file.name)===-1){
                uploaded.push(file);
                if(uploaded.length === 100000) setFileLimit(true);
                if(uploaded.length >100000){
                    setFileLimit(false);
                    limitExceeded = true;
                    return true;
                }
            }
        })
        if (!limitExceeded) setUploadedFiles(uploaded);
    }

    const handleChangeTitulo= event => {
        setTitulo(event.target.value);
        console.log('value titulo:', event.target.value);
    };

    const handleChangeDescripcion= event => {
        setDescripcion(event.target.value);
        console.log('value descripcion:', event.target.value);
    };

    const handleChangeCategoria= event => {
        setCategoria(event.target.value);
        console.log('value categoria:', event.target.value);
    };



    function handleChangeLocation (lat, lng){
        setLocation({lat:lat, lng:lng});
    }
    function handleChangeZoom (newZoom){
        setZoom(newZoom);
    }

    function handleResetLocation(){
        setDefaultLocation({ ... DefaultLocation});
        setZoom(DefaultZoom);
    }
    return (
        <div className=" mx-4  ">
            <Form >
                <Form.Group className="mb" >
                    <Form.Label>Nombre </Form.Label>
                    <Form.Control type="text" placeholder="Hosteria Dos Chorreras" value={titulo} onChange={handleChangeTitulo}/>

                </Form.Group>
                <Form.Group className={"mt-2"}>
                    <Form.Label>Descripcion</Form.Label>
                    <Form.Control  style={{ height:"85px"}} as="textarea" rows="4" placeholder="Escribe una descripcion..." />
                </Form.Group>

                <Form.Group className="mt-2">
                    <Form.Label>Categoria</Form.Label>
                    <Form.Select >
                        <option defaultValue>Seleccione una categoria</option>
                        <option>Iglesia</option>
                        <option>Laguna</option>
                        <option>Hotel</option>
                        <option>Montaña</option>
                        <option>Teatro</option>
                        <option>Restaurant</option>
                    </Form.Select>
                </Form.Group>

                <Form.Group className="mt-2">
                    <Form.Label>Indica la ubicacion del recurso</Form.Label>
                    <div className={"row"}>
                        <div className={"col-md-8"}>
                            <MapPicker defaultLocation={defaultLocation}
                                       zoom={zoom}
                                       mapTypeId="roadmap"
                                       style={{height:'700px'}}
                                       onChangeLocation={handleChangeLocation}
                                       onChangeZoom={handleChangeZoom}
                                       apiKey='AIzaSyD9m7bZ0SieFUTH7PdJakPdV2cZwIkbXFo'/>
                        </div>
                        <div className={"col-md-4"}>
                            <Form.Group className="mt-2">
                                <Form.Label>Latitud </Form.Label>
                                <Form.Control type="text" placeholder="latitud" value={location.lat} />
                            </Form.Group>
                            <Form.Group className="mt-2">
                                <Form.Label> Longitud</Form.Label>
                                <Form.Control type="text" placeholder="latitud" value={location.lng} />
                            </Form.Group>
                        </div>
                    </div>

                </Form.Group>


                <Form.Group className="mt-4">
                    <Form.Label>Suba imagenes o videos del recurso</Form.Label>
                    <Form.Control type="file" accept="image/*, video/*" multiple={"multiple"} onChange={handleFileEvent} disabled={fileLimit}/>
                </Form.Group>

                <Form.Group className="mt-5 ">
                    <div style={{display:"flex", justifyContent:"center",alignItems:"center"}}>
                        <Button variant="success" className="m-1">CREAR RECURSO</Button>
                    </div>

                </Form.Group>




            </Form>

        </div>

    );
}