import React, {useEffect, useState} from "react";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
    faCashRegister,
    faChartLine,
    faCloudUploadAlt, faComment,
    faPlaceOfWorship,
    faPlus,
    faRocket, faSearchLocation, faStar,
    faTasks,
    faUserShield
} from '@fortawesome/free-solid-svg-icons';
import { Col, Row, Button, Dropdown, ButtonGroup } from '@themesberg/react-bootstrap';

import { CounterWidget, CircleChartWidget, BarChartWidget, TeamMembersWidget, ProgressTrackWidget, RankingWidget, SalesValueWidget, SalesValueWidgetPhone, AcquisitionWidget } from "../../components/dashboard/Widgets";
import { PageVisitsTable } from "../../components/dashboard/Tables";
import { trafficShares, totalOrders } from "../../data/charts";
import axios from "axios";
import data from "bootstrap/js/src/dom/data";

export default function MyDashboard(){
    const [placeSelected, setPlaceSelected] = useState("Selecione un lugar");
    const [placeSelectedId, setPlaceSelectedId] = useState("");
    const [places, setPlaces] = useState([]);



    useEffect(() => {
        axios.get("http://localhost:8083/places").then(
            (resp)=>{
                if(resp.status===200){
                    setPlaces(resp.data);
                    setPlaces(resp.data);
                }
            }
        ).catch((e)=>console.log(e))

    },[  ]);

    let getAvgRate = (places )=>{

        console.log(places)
        let n=0;
        let sum = 0;
        for (let place of places){
            if(place["numComentarios"]!==0){
                n=n+1;
                sum=sum+place["numComentarios"];
            }
        }
        return (sum/n).toFixed(2);
    }

    return (
        <>

            <Row className="justify-content-md-center">

                <Col xs={12} className="mb-4 d-sm-none">
                    <SalesValueWidgetPhone
                        title="Sales Value"
                        value="10,567"
                        percentage={10.57}
                    />
                </Col>
                <Col xs={12} sm={6} xl={4} className="mb-4">
                    <CounterWidget
                        category="Recursos"
                        title={places.length}

                        icon={faPlaceOfWorship}
                        iconColor="shape-secondary"
                    />
                </Col>

                <Col xs={12} sm={6} xl={4} className="mb-4">
                    <CounterWidget
                        category="Comentarios"
                        title={places
                            .map(obj => obj["numComentarios"])
                            .reduce((accumulator, current) => accumulator + current, 0)}

                        icon={faComment}
                        iconColor="shape-tertiary"
                    />
                </Col>
                <Col xs={12} sm={6} xl={4} className="mb-4">
                    <CounterWidget
                        category="Media de Calificaciones"
                        title={getAvgRate(places)}

                        icon={faStar}
                        iconColor="shape-tertiary"
                    />
                </Col>
                {<Col xs={12} sm={6} xl={4} className="mb-4"/>}
                {/*    <CircleChartWidget*/}
                {/*        title="Traffic Share"*/}
                {/*        data={trafficShares} />*/}
                {/*</Col>*/}


            </Row>
            <div className="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center py-4">


                {/*<ButtonGroup>*/}
                {/*    <Button variant="outline-primary" size="sm">Share</Button>*/}
                {/*    <Button variant="outline-primary" size="sm">Export</Button>*/}
                {/*</ButtonGroup>*/}
            </div>

            <Row>
                <Col xs={12} xl={12} className="mb-4">
                    <Row>

                        <Col xs={12} xl={12} className="mb-4">
                            <Row>
                                <Col xs={12} className="mb-4">
                                    <PageVisitsTable places={places} />
                                </Col>

                                {/*<Col xs={12} lg={6} className="mb-4">*/}
                                {/*    <TeamMembersWidget />*/}
                                {/*</Col>/}

                                {/<Col xs={12} lg={6} className="mb-4">/}
                                {/*    <ProgressTrackWidget />*/}
                                {/*</Col>*/}
                            </Row>
                        </Col>

                        <Col xs={12} xl={4}>
                            <Row>

                                {/*<Col xs={12} className="mb-4">*/}
                                {/*    <BarChartWidget*/}
                                {/*        title="Total orders"*/}
                                {/*        value={452}*/}
                                {/*        percentage={18.2}*/}
                                {/*        data={totalOrders} />*/}
                                {/*</Col>*/}

                                {/*<Col xs={12} className="px-0 mb-4">*/}
                                {/*    <RankingWidget />*/}
                                {/*</Col>*/}

                                {/*<Col xs={12} className="px-0">*/}
                                {/*    <AcquisitionWidget />*/}
                                {/*</Col>*/}
                            </Row>
                        </Col>
                    </Row>
                </Col>
                <Col xs={12} className="mb-4 d-none d-sm-block">
                    <Dropdown className="btn-toolbar">
                        <Dropdown.Toggle as={Button} variant="primary" size="sm" className="me-2">
                            <FontAwesomeIcon icon={faSearchLocation} className="me-2" />{placeSelected}
                        </Dropdown.Toggle>

                        <Dropdown.Menu className="dashboard-dropdown dropdown-menu-left mt-2">

                            {places.map((place) => <Dropdown.Item onSelect={()=> {
                                setPlaceSelectedId(place.id);
                                setPlaceSelected(place.nombre)
                            }} className="fw-bold">
                                <FontAwesomeIcon icon={faPlaceOfWorship} className="me-2" /> {place.nombre}
                            </Dropdown.Item>)}

                        </Dropdown.Menu>
                    </Dropdown>
                    <br/>
                    {
                        (placeSelectedId!=="")?<SalesValueWidget placeId={placeSelectedId}
                                                                 placeNombre={placeSelected}
                                                                 title="Sales Value"
                                                                 value="10,567"
                                                                 percentage={10.57}
                            />
                            : <p>Selecione un recurso</p>
                    }

                </Col>
            </Row>
        </>
    );
};