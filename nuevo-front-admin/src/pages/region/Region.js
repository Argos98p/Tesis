import "./region.css"
import {Link, Outlet, Route, Routes, useLocation, useNavigate, useParams} from "react-router-dom";
import React, {useEffect, useState} from "react";
import axios from "axios";
import {API_BASE_URL_2} from "../../API";
import {Grid, Icon, menuClasses} from "@mui/material";
import {MDBCard, MDBCardBody, MDBCardImage, MDBCardText, MDBCardTitle, MDBRipple} from "mdb-react-ui-kit";
import TextTruncate from "react-text-truncate";
import {toast} from "react-toastify";
import {AiFillCheckCircle, AiOutlineHome} from "react-icons/ai"
import {BsClockHistory, BsFillArchiveFill} from "react-icons/bs"
import {MdOutlineCancel} from "react-icons/md"
import Popup from 'reactjs-popup';
import 'reactjs-popup/dist/index.css';
import OnePlace from "../onePlace/OnePlace";
import {ProSidebarProvider, SubMenu, useProSidebar} from 'react-pro-sidebar';
import {Sidebar, Menu, MenuItem} from 'react-pro-sidebar';
import {
    FaArrowRight,
    FaBars, FaChartArea,
    FaCheck, FaPlaceOfWorship
} from "react-icons/fa";
import MyDashboard from "../dashboard/MyDashboard";
import {Navigate} from "react-router-dom";
import NewPlace from "../newPlace/newPlace";

const RegionPage = ({currentUser}) => {
    const [view, setView] = useState(1);
    const location = useLocation();
    // const {element} = state ??{};
    console.log(location)
    const navigate = useNavigate();
    const [lugares, setLugares] = useState([]);
    const [estadoLugar, setEstadoLugar] = useState("");
    const [lugarSeleccionado, setLugarSelececionado] = useState(null);
    const [open, setOpen] = useState(false);
    const [newPlaceSelect, setNewPlaceSelect] = useState(false);
    const closeModal = () => {
        setOpen(false)
    };
    const [refresh, setRefresh] = useState(false)
    const {collapseSidebar, collapsed, toggleSidebar, broken} = useProSidebar();
    const [isDashboardSelect, setIsDashboardSelect] = useState(true);
    const params = useParams();
    const lugarId = params.id;


    useEffect(() => {
        if (broken) collapseSidebar();
    }, [broken, collapseSidebar]);


    useEffect(() => {


        if (estadoLugar !== "") {

            const id3 = toast.loading("Porfavor espere...", {
                toastId: 'success1',
            })
            axios.get(API_BASE_URL_2 + `recurso/todos?regionId=${lugarId}&estadoLugar=${estadoLugar}&userId=${currentUser.id}`).then((response) => {
                setLugares(response.data)
                if (response.data.length === 0) {
                    //noData()
                    toast.update(id3, {
                        render: "No se encontraron recursos",
                        type: "info",
                        isLoading: false,
                        toastId: "success1",
                        autoClose: 700
                    });
                } else {
                    //update()
                    toast.update(id3, {
                        render: "Recursos cargados",
                        type: "success",
                        isLoading: false,
                        toastId: "success1",
                        autoClose: 700
                    });
                }
            }).catch((e) => {
                toast.update(id3, {
                    render: "Error recibiendo los recursos",
                    type: "error",
                    isLoading: false,
                    toastId: "success1",
                    autoClose: 700
                });
                console.log(e)
            });

        }

        return () => {

            setRefresh(false);
        };
    }, [estadoLugar])


    const redirectToPlacePage = (id) => {
        setLugarSelececionado(id);
        navigate(`/admin/recurso/${id}`);
    }

    return (
        <>{broken && (

            <div className={"icon-sidebar-expand-region"} onClick={() => toggleSidebar()}>
                <FaArrowRight color={" #ffffff"} size={24}></FaArrowRight>
            </div>

        )}
            <div style={{display: 'flex', height: '100%', minHeight: '400px'}}>
                <Sidebar breakPoint="700px" customBreakPoint={"700px"} backgroundColor={"rgb(251, 251, 255)"}
                         rootStyles={{
                             position: "sticky",
                             top: "43px",
                             minHeight: "95vh",
                             maxHeight: "10vh",
                             height: "100vh",
                             zIndex: "999"
                         }}>
                    <Menu
                        menuItemStyles={{
                            button: ({level, active, disabled}) => {
                                // only apply styles on first level elements of the tree
                                if (level === 0)
                                    return {
                                        color: active ? '#0f96f6' : '#555555',
                                        backgroundColor: active ? '#F0F0FF' : undefined,
                                    };
                            },
                        }}
                    >
                        <div className={"header-sidebar-org"} onClick={() => collapseSidebar()}>
                            <div className={"icon-sidebar"}>
                                <FaBars color={" #ffffff"} size={24}></FaBars>
                            </div>
                            {
                                collapsed ? null : <p>Turis Up</p>
                            }
                        </div>
                        <MenuItem onClick={() => navigate("/admin/home")} icon={<AiOutlineHome/>}>Home</MenuItem>
                        <MenuItem active={isDashboardSelect} icon={<FaChartArea/>} onClick={() => {
                            setIsDashboardSelect(true);
                            setEstadoLugar("");
                            setNewPlaceSelect(false);

                        }}>Analiticas</MenuItem>

                        <MenuItem active={newPlaceSelect} icon={<FaPlaceOfWorship/>} onClick={() => {
                            setIsDashboardSelect(false);
                            setEstadoLugar("");
                            setNewPlaceSelect(true);
                        }}>Nuevo recurso</MenuItem>


                        <MenuItem active={estadoLugar === "aceptado"} onClick={() => {
                            setEstadoLugar("aceptado");
                            setIsDashboardSelect(false)
                            setNewPlaceSelect(false);
                        }}
                                  icon={<AiFillCheckCircle/>}>Aceptado</MenuItem>
                        <MenuItem active={estadoLugar === "rechazado"} onClick={() => {
                            setEstadoLugar("rechazado");
                            setIsDashboardSelect(false)
                            setNewPlaceSelect(false);

                        }}
                                  icon={<MdOutlineCancel/>}>Rechazado</MenuItem>
                        <MenuItem active={estadoLugar === "revisar"} onClick={() => {
                            setEstadoLugar("revisar");
                            setIsDashboardSelect(false)
                            setNewPlaceSelect(false);

                        }}
                                  icon={<BsClockHistory/>}>Por revisar</MenuItem>
                        <MenuItem active={estadoLugar === "archivado"} onClick={() => {
                            setEstadoLugar("archivado");
                            setIsDashboardSelect(false)
                            setNewPlaceSelect(false);

                        }}
                                  icon={<BsFillArchiveFill/>}>Archivado</MenuItem>
                    </Menu>
                </Sidebar>


                <main style={{padding: 10, width:"100%"}}>


                    <div className="region-content" key={"content-region"}>
                        <h1 className={"titulo"}>{lugarId.replace("_region", "").toUpperCase()}</h1>
                        {

                            newPlaceSelect ? <NewPlace></NewPlace> :
                            isDashboardSelect
                                ? <MyDashboard></MyDashboard>
                                :
                                <>
                                    <div className="lugares-cards">
                                        {Array.from(lugares).map((item, index) => (
                                            <div style={{cursor: "pointer"}} className={"card-image"}
                                                 onClick={() => {
                                                     redirectToPlacePage(item.id)
                                                 }} key={item.id}>
                                                <MDBCard style={{"backgroundColor": '#fff'}}>
                                                    <MDBCardImage
                                                        src={item['imagenesPaths'] ? item['imagenesPaths'][0] : "https://kubalubra.is/wp-content/uploads/2017/11/default-thumbnail.jpg"}
                                                        fluid alt='...'/>
                                                    <a>
                                                        <div className='mask'
                                                             style={{backgroundColor: 'rgba(251, 251, 251, 0.15)'}}></div>
                                                    </a>
                                                    <MDBCardBody>
                                                        <MDBCardTitle><b>{item['nombre']}</b></MDBCardTitle>
                                                        <MDBCardText>
                                                            <TextTruncate
                                                                line={2}
                                                                element="span"
                                                                truncateText="…"
                                                                text={item['descripcion']}
                                                                textTruncateChild={<b
                                                                    style={{color: "blue", textDecoration: "underline"}}>Leer
                                                                    mas</b>}
                                                            />
                                                        </MDBCardText>
                                                    </MDBCardBody>
                                                </MDBCard>
                                            </div>
                                        ))}
                                    </div>
                                    {/*<Outlet></Outlet>*/}
                                    {/*<Routes>*/}

                                    {/*    <Route path={"/:id"} element={*/}

                                    {/*        <Popup className="region-popup" open={true} closeOnDocumentClick onClose={()=>navigate(-1)}>*/}
                                    {/*            <div className="modalp">*/}
                                    {/*                <OnePlace placeId={lugarSeleccionado} currentUser={currentUser}/>*/}
                                    {/*            </div>*/}
                                    {/*        </Popup>*/}
                                    {/*    }></Route>*/}
                                    {/*</Routes>*/}
                                </>
                        }
                    </div>
                </main>
            </div>
        </>
    );
}

export default RegionPage;


