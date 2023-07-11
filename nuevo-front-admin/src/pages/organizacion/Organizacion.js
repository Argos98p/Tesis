import "./organizacion.css"
import React, {useEffect, useRef, useState} from "react";

import {toast} from "react-toastify";
import Colors from "../../utils/Colors";
import MyCard from "../../components/myCard/MyCard";
import {useLocation, useNavigate, useParams} from "react-router-dom";
import {useTable} from "react-table";


import {Container, InputGroup} from "reactstrap"
import "bootstrap/dist/css/bootstrap.min.css"
import BTable from 'react-bootstrap/Table';
import {Button, Dropdown, Form, SplitButton} from "react-bootstrap";

import {BiCurrentLocation, BiPlus, BiUserCircle} from "react-icons/bi";
import {GpsFixedRounded} from "@mui/icons-material";
import axios from "axios";
import {API_BASE_URL_2, API_BASE_URL_users} from "../../API";
import {Menu, MenuItem, Sidebar, useProSidebar} from "react-pro-sidebar";
import {FaArrowRight, FaBars} from "react-icons/fa";
import {AiFillCheckCircle, AiOutlineHome} from "react-icons/ai";
import {MdOutlineCancel} from "react-icons/md";
import {BsClockHistory, BsFillArchiveFill} from "react-icons/bs";

const Organizacion = () => {
    const navigate = useNavigate();
    const [emailBuscar, setEmailBuscar] = useState("");
    const [emailExist, setEmailExists] = useState(null);
    const [userData, setUserData] = useState(null)
    const [view, setView] = useState(1);
    const emailRef = useRef("");


    const {state} = useLocation();
    const {organizacion} = state;
    const [usuarios, setUsuarios] = useState([]);

    const columns = React.useMemo(
        () => [
            {
                Header: 'Id',
                accessor: 'id', // accessor is the "key" in the data
            },
            {
                Header: 'Nombre',
                accessor: 'nombre',
            },
            {
                Header: 'Correo',
                accessor: 'correo',
            },
        ],
        []
    )


    const {
        getTableProps,
        getTableBodyProps,
        headerGroups,
        rows,
        prepareRow,
    } = useTable({columns, data: usuarios})
    const toastId = React.useRef(null);

    const notify = () => toastId.current = toast("Cargando recursos", {autoClose: false});

    const update = () => toast.update(toastId.current, {
        render: "Recursos cargados",
        type: toast.TYPE.SUCCESS,
        autoClose: 2000
    });

    const noData = () => toast.update(toastId.current, {
        render: "Sin recursos disponibles",
        type: toast.TYPE.INFO,
        autoClose: 2000
    });

    const error = () => toast.update(toastId.current, {
        render: "Error obteniendo los recursos",
        type: toast.TYPE.ERROR,
        autoClose: 2000
    });


    const onCardClick = (element) => {
        navigate(`/admin/region/${element.id}`, {state: {element: element}})
    }

    const vincularUsuario = (correo, id) => {
        toast.loading("Cargando", {
            position: toast.POSITION.TOP_CENTER,
            progressClassName: 'success-progress-bar',
            toastId: 1
        });

        axios.post(API_BASE_URL_users + "users/update", {email: correo, role: "admin"})
            .then(response => {
                if (response.status === 200) {
                    axios.post(API_BASE_URL_users + "user/matchOrganization", {
                        userID: id,
                        organizationID: organizacion.organization.id
                    })
                        .then((response) => {
                            if (response.status === 200) {
                                toast.update(1, {
                                    render: "Cambios realizados",
                                    type: toast.TYPE.SUCCESS,
                                    isLoading: false,
                                    autoClose: 800
                                });
                                setEmailExists(null);
                                setUserData(null);
                            }
                        })
                        .catch(e => {
                            console.log(e);
                            toast.update(1, {
                                render: "Error: " + e,
                                type: toast.TYPE.ERROR,
                                isLoading: false,
                                autoClose: 2000
                            });
                        })
                }
            })
            .catch(e => {
                console.log(e);
                toast.update(1, {render: "Error: " + e, type: toast.TYPE.ERROR, isLoading: false, autoClose: 2000});
            });

    }

    const buscarCorreo = () => {
        toast.loading("Buscando", {
            position: toast.POSITION.TOP_CENTER,
            progressClassName: 'success-progress-bar',
            toastId: 3
        });
        axios.get(API_BASE_URL_users + "users/search", {params: {correo: emailRef.current.value}})
            .then((response) => {
                if (response.status === 200) {
                    setUserData(response.data);
                    setEmailExists(true);
                    toast.update(3, {
                        render: "Usuario  encontrado",
                        type: toast.TYPE.SUCCESS,
                        isLoading: false,
                        autoClose: 1000
                    });

                } else if (response.status === 404) {
                    toast.update(3, {
                        render: "Usuario no encontrado",
                        type: toast.TYPE.INFO,
                        isLoading: false,
                        autoClose: 1000
                    });

                    setUserData({})
                    setEmailExists(null);
                }
            })
            .catch((e) => {
                console.log(error);
                toast.update(3, {
                    render: "Usuario no encontrado",
                    type: toast.TYPE.INFO,
                    isLoading: false,
                    autoClose: 1000
                });
            })


    }


    useEffect(() => {
        if (view === 2) {
            toast.loading("Cargando usuarios", {
                position: toast.POSITION.TOP_CENTER,
                progressClassName: 'success-progress-bar',
                toastId: 2
            });
            axios.get(API_BASE_URL_2 + 'admin/users/inOrg', {params: {orgId: organizacion.organization.id}})
                .then((response) => {
                    if (response.status === 200) {
                        setUsuarios(response.data)
                        toast.update(2, {
                            render: "Usuarios Cargados",
                            type: toast.TYPE.SUCCESS,
                            isLoading: false,
                            autoClose: 500
                        });

                    }
                })
                .catch(e => {
                    console.log(e);
                    toast.update(2, {render: "Error: " + e, type: toast.TYPE.ERROR, isLoading: false, autoClose: 2000});
                });
        }

    }, [view]);

    const UsuariosInOrganization = () => {
        return (<div>
            <h5 className="subtitulo">Usuarios</h5>
            <Container style={{marginTop: 20}}>
                <BTable striped bordered hover size="sm" {...getTableProps()}>
                    <thead>
                    {headerGroups.map(headerGroup => (
                        <tr {...headerGroup.getHeaderGroupProps()}>
                            {headerGroup.headers.map(column => (
                                <th {...column.getHeaderProps()}>
                                    {column.render('Header')}
                                </th>
                            ))}
                        </tr>
                    ))}
                    </thead>
                    <tbody>
                    {rows.map((row, i) => {
                        prepareRow(row)
                        return (
                            <tr {...row.getRowProps()}>
                                {row.cells.map(cell => {
                                    return (
                                        <td {...cell.getCellProps()}>
                                            {cell.render('Cell')}
                                        </td>
                                    )
                                })}
                            </tr>
                        )
                    })}
                    </tbody>
                </BTable>
            </Container>

        </div>);
    }

    const RegionesAdministradas = () => {
        return (
            <>
                <p className="subtitulo">Regiones administradas</p>
                <div className={'organizacion-cards-container'}>
                    {organizacion.region.map((element) =>
                        <MyCard key={element.id} onCardClick={() => onCardClick(element)} color={Colors.random()}
                                element={element}></MyCard>
                    )}


                </div>
            </>
        );

    }

    const NuevoUsuario = () => {


        return <div className="content-buscar-usuario">
            <h5 className="subtitulo">Busque al usuario por el correo</h5>
            <InputGroup className="mb-3">
                <Form.Control ref={emailRef}
                              type="email" pattern="/^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$/" required="true"
                              aria-label="Text input with dropdown button"/>
                <Button onClick={() => buscarCorreo()}>Buscar</Button>
            </InputGroup>
            <div>
                {
                    emailExist !== null
                        ? <div>
                            <p>Usuario encontrado: <b>{userData.name}</b></p>
                            <Button onClick={() => vincularUsuario(userData.email, userData.id)}>Añadir este
                                usuario</Button>
                        </div>

                        : null
                }
            </div>
        </div>
    }
    const {collapseSidebar, collapsed, toggleSidebar, broken} = useProSidebar();
    useEffect(() => {
        if (broken) collapseSidebar();
    }, [broken, collapseSidebar]);

    return (
        <div style={{display: 'flex', height: '100%', minHeight: '400px'}}>


            <Sidebar breakPoint="700px" customBreakPoint={"700px"} backgroundColor={"rgb(251, 251, 255)"} rootStyles={{
                position: "sticky", top:"43px", maxHeight:"100vh",zIndex:"999"}}>

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
                    <MenuItem active={view===1} onClick={()=>{setView(1); setEmailExists(null);setUserData({})}} icon={<BiCurrentLocation/>}>Regiones</MenuItem>
                    <MenuItem active={view===2} onClick={()=>setView(2)}  icon={<BiUserCircle/>}>Usuarios</MenuItem>
                    <MenuItem active={view===3} onClick={()=>setView(3)}  icon={<BiPlus/>}>Añadir administrador</MenuItem>
                </Menu>
            </Sidebar>
            <main style={{padding: 10}}>

                {broken && (

                    <div className={"icon-sidebar-expand-region"} onClick={() => toggleSidebar()}>
                        <FaArrowRight color={" #ffffff"} size={24}></FaArrowRight>
                    </div>

                )}

                <div className="organizacion">
                    <div className="organization-content">
                        <h1 style={{textAlign: "center"}} className={"titulo"}>{organizacion.organization.nombre}</h1>
                        {view === 2 && <UsuariosInOrganization/>}
                        {view === 1 && <RegionesAdministradas/>}
                        {view === 3 && <NuevoUsuario/>}

                    </div>
                </div>


            </main>
        </div>


    );
}

export default Organizacion;