import './OnePlace.css'
import {useParams} from 'react-router-dom';
import React, {useEffect, useState} from 'react';
import { Form } from '@themesberg/react-bootstrap';
import SliderImages from '../../components/sliderImages/SliderImages';
import Button from 'react-bootstrap/Button';
import Map from '../../components/map/Map';
import axios from "axios";
import ReactDOM from 'react-dom';
import {toast, ToastContainer} from "react-toastify";
import 'react-toastify/dist/ReactToastify.css';
import {FacebookEmbed} from 'react-social-media-embed';
import {API_BASE_URL_2} from "../../API";
import ReactPlayer from "react-player";
import FacebookPlayer from 'react-facebook-player';
import ReactStars from "react-rating-stars-component/dist/react-stars";
import NewPlace from "../newPlace/newPlace";
import UpdatePlace from "../updatePlace/UpdatePlace";
import {FaEdit} from "react-icons/fa";



export default function OnePlace({currentUser}) {
    const baseUrl = API_BASE_URL_2 + 'place/';

    const {id} = useParams()
    const placeId = id;
    const toastId2 = React.useRef(null);

    const [data, setData] = useState(null);


    const notify = () => toastId2.current = toast("Guardando", {autoClose: false});
    const update = () => toast.update(toastId2.current, {
        render: "Cambios guardados",
        type: toast.TYPE.INFO,
        autoClose: 2000
    });


    const [isRevisar, setIsRevisar] = useState(false);
    const [isAceptado, setIsAceptado] = useState(false);
    const [isRechazado, setIsRechazado] = useState(false);
    const [isArchivado, setIsArchivado] = useState(false);
    const [comentarios, setComentarios] = useState([]);
    const [edicion, setEdicion] = useState(false);
    const [titulo, setTitulo] = useState("");
    const [descripcion, setDescripcion] = useState("");
    const [categoria, setCategoria] = useState("");
    const [uploadedFiles, setUploadedFiles] = useState([]);
    const [fileLimit, setFileLimit] = useState(false);
    let location = {}
    let slides = []

    useEffect(() => {
        if (data === null) {
            toast.loading("Cargando informacion", {
                position: toast.POSITION.TOP_CENTER,
                progressClassName: 'success-progress-bar',
                toastId: 1
            });
            axios.get(API_BASE_URL_2 + `recurso/todos?lugarId=${placeId}&userId=${currentUser.id}`).then((response) => {
                console.log(response.data)
                if (response.data.length === 0) {
                    toast.update(1, {
                        render: "No se encontro el recurso",
                        type: toast.TYPE.ERROR,
                        isLoading: false,
                        autoClose: 2000
                    });
                } else {
                    setData(response.data[0])
                    toast.update(1, {
                        render: "Informacion cargada",
                        type: toast.TYPE.SUCCESS,
                        isLoading: false,
                        autoClose: 1000
                    });

                    axios.get(API_BASE_URL_2 + `comentario?lugarId=${placeId}`).then(
                        (response) => {
                            console.log(response.data);
                            setComentarios(response.data)
                        }
                    )
                }
            }).catch((e) => {
                toast.update(1, {
                    render: "Error obteniendo el recurso",
                    type: toast.TYPE.ERROR,
                    isLoading: false,
                    autoClose: 2000
                });
                console.log(e)
            });
        }
    }, []);


    if (data !== null) {
        location = {
            address: parseFloat(data.nombre),
            lng: parseFloat(data.coordenadas.latitud),
            lat: parseFloat(data.coordenadas.longitud),
        }
    }

    useEffect(() => {
        if (data != null) {
            if (data.status === "revisar") {
                setIsRevisar(true);
                setIsAceptado(false);
                setIsArchivado(false);
                setIsRechazado(false);
            } else if (data.status === "aceptado") {
                setIsAceptado(true)
                setIsRevisar(false);
                setIsArchivado(false);
                setIsRechazado(false);
            } else if (data.status === "archivado") {
                setIsArchivado(true);
                setIsRevisar(false);
                setIsAceptado(false);
                setIsRechazado(false);
            } else if (data.status === "rechazado") {
                setIsRechazado(true);
                setIsRevisar(false);
                setIsAceptado(false);
                setIsArchivado(false);
            }

        }

    }, [data]);


    const onAceptar = () => {
        notify();
        axios.post(baseUrl + "aceptar", {}, {params: {placeId: data.placeId}})
            .then((response) => {
                console.log(response);
                update();
                setIsRevisar(false);

            }).catch(error => {
            toast.update(toastId2.current, {render: "Error! " + error, type: toast.TYPE.ERROR, autoClose: 5000});
            console.log('error' + error)
        });
    }

    const actualizarRecurso = (dataLugar) => {

        console.log(dataLugar);
        notify();
        axios.post(API_BASE_URL_2 + "admin/actualizar", {
            "estado": dataLugar.estado,
            "nombre": dataLugar.nombre,
            "descripcion": dataLugar.descripcion,
            "placeid": dataLugar.placeid
        },)
            .then((response) => {
                update();
                setIsRevisar(false);
            }).catch(error => {
            toast.update(toastId2.current, {render: "Error! " + error, type: toast.TYPE.ERROR, autoClose: 5000});
            console.log('error' + error)
        });
    }

    const reelImagenes = (imagenes, altura) => {
        return (
            <div className={"scrolling-wrapper"}>
                {imagenes.map((image) =>
                    <div className={"card"} style={{height: altura.toString() + "px"}}><img src={image} alt={"a"}/>
                    </div>
                )}
            </div>
        );

    }
    const reelVideos = (videos, ancho) => {
        return (
            <div className={"scrolling-wrapper"}>
                {videos.map((image) =>
                    <FacebookPlayer
                        className={"fb-video"}
                        width={ancho.toString() + "px"}
                        id={image}
                        videoId={image}
                        appId={"2720769541388315"}
                        onReady={() => {
                        }}
                    />
                )}
            </div>
        );
    }

    const reelComentarios = (comentarios) => {
        return (
            <div className={"scrolling-wrapper"}>
                {comentarios.map((comentario) =>
                        <div style={{padding:"1em" ,margin:"1em", border:"1px solid #f2f2f2", borderRadius:"1em"}}>
                            <div style={{display: "flex", flexDirection: "row", justifyContent: "space-between"}}>
                                <div>
                                    <img style={{width: "40px", height: "40px", borderRadius: "100%", objectFit: "cover"}}
                                         src={comentario.user.foto} alt={"profile"}/>
                                    <p>{comentario.user.nombre}</p>
                                </div>
                                <div>
                                    <ReactStars
                                        edit={false}
                                        value={comentario.puntaje}
                                        onChange={() => {
                                        }}
                                        size={24}
                                        activeColor="#ffd700"
                                    />
                                </div>
                            </div>
                            <p>{comentario.comentario}</p>
                            <div className={"media-comentarios"}>
                                {
                                    comentario["imagenes"].map((imagen)=><img  style={{paddingRight:"10px", maxHeight:"300px"}} src={imagen} alt={"s"}/>)
                                }
                                {comentario.video.map((image)=>
                                    <FacebookPlayer
                                                    className={"fb-video"}
                                                   width={"200px"}
                                                    id={image}
                                                   videoId={ image }
                                                    appId={ "2720769541388315" }
                                                   onReady={()=>{} }
                                              />
                                            )}
                            </div>


                        </div>
                )}






            </div>
        );
    }

    return (
        <div className="one-place">
            {
                data === null
                    ? <h1>Cargando</h1>
                    :
                    <div>{

                        isAceptado ? <div className='float-buttons'>
                                <Button variant="secondary" onClick={() => actualizarRecurso({
                                    "estado": "archivado",
                                    "nombre": data.nombre,
                                    "descripcion": data.descripcion,
                                    "placeid": placeId
                                })}>Archivar </Button>
                            </div>
                            : null
                    }
                        {
                            isRechazado || isArchivado ? <div className='float-buttons'>
                                    <Button variant="secondary" onClick={() => actualizarRecurso({
                                        "estado": "revisar",
                                        "nombre": data.nombre,
                                        "descripcion": data.descripcion,
                                        "placeid": placeId
                                    })}>Revisar </Button>
                                </div>
                                : null
                        }
                        {
                            isRevisar ? <div className='float-buttons'>


                                    <Button variant="danger" onClick={() => actualizarRecurso({
                                        "estado": "rechazado",
                                        "nombre": data.nombre,
                                        "descripcion": data.descripcion,
                                        "placeid": placeId
                                    })}>Rechazar</Button>
                                    <Button variant="success" onClick={() => actualizarRecurso({
                                        "estado": "aceptado",
                                        "nombre": data.nombre,
                                        "descripcion": data.descripcion,
                                        "placeid": placeId
                                    })}>Aceptar </Button>
                                    <Button variant="secondary" onClick={() => actualizarRecurso({
                                        "estado": "archivado",
                                        "nombre": data.nombre,
                                        "descripcion": data.descripcion,
                                        "placeid": placeId
                                    })}>Archivar </Button>
                                </div>
                                : null
                        }


                        <div className='images-reel'>
                            <SliderImages imageList={data.imagenesPaths ? data.imagenesPaths : []}></SliderImages>
                        </div>
                        <div className='place-content'>

                            <Button style={{zIndex:"99"}} variant="outline-info" className=" boton-editar m-1" onClick={()=>setEdicion(!edicion)}><FaEdit/>  Editar</Button>

                            {
                                edicion
                                ? <UpdatePlace data={data}/>
                                    :<>
                                        <h1>{data.nombre ? data.nombre : "Sin titulo"} </h1>
                                        <p className={"subtitulo"}>Descripcion</p>
                                        <p>{data.descripcion}</p>

                                        <p className={"subtitulo"}>Locacion</p>
                                        {
                                            data != null && <Map location={location} zoomLevel={12} data={data}/>
                                        }
                                        <p className={"subtitulo"}>Imagenes</p>
                                        {reelImagenes(data["imagenesPaths"], 200)}

                                        <p className={"subtitulo"}>Videos</p>
                                        {reelVideos(data["fbVideoIds"], 300)}

                                        <p className={"subtitulo"}>Comentarios</p>

                                    </>

                            }

                            {comentarios !== undefined && reelComentarios(comentarios)}
                        </div>

                    </div>

            }
        </div>
    );
}
