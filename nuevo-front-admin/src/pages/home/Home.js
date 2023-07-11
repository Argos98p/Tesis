
import "./home.css";
import { useEffect, useState } from "react";
import MyCard from "../../components/myCard/MyCard";
import Colors from "../../utils/Colors";

import axios from "axios";

import { API_BASE_URL_2 } from "../../API";
import { useNavigate } from "react-router-dom";

export default function Home({ authenticated, currentUser }) {

    const [userAdminResource, setUserAdminResource] = useState(null);
    const [org, setOrg] = useState([]);
    const [regiones, setRegiones] = useState([])
    const navigate = useNavigate();
    const distinct = (items, predicate) => items.filter((uniqueItem, index) =>
        items.findIndex(item =>
            predicate(item) === predicate(uniqueItem)) === index);



    useEffect(() => {
        if (currentUser) {
            axios.get(API_BASE_URL_2 + `admin/recursos?userId=${currentUser.id}`).then((response) => {

                let op = response.data;
                
                const res = op.reduce((a,b) => {
                    const found = a.find(e => e.id == b.id);
                    return found ? found.region.push(b.region) : a.push({...b, region:[b.region]}), a;
                  }, [])
                  
                  setOrg(res)
                  console.log(res);
            });
        }
    }, [currentUser]);

    const onCardClick = (element, tipo,org) => {
        
        if (tipo == "region") {
            console.log("region");
            navigate(`/admin/region/${element.region.id}`, { state: { element: element } })
        } else {
            navigate(`/admin/organizacion/${element.organization.id}`, { state: { organizacion: element} })
        }


    }

    return (
        <div className="home">
            <p className={"titulo"}>!Hola <b>{currentUser ? currentUser.name : ""}</b> que gusto tenerte de vuelta¡ </p>
            <div>
                <p className={"subtitulo"}>Organizaciones a las que perteneces</p>
                <div className={'cards-container'}>
                    {org.map((element) =>
                        <MyCard key={element.organization.id} onCardClick={() => onCardClick(element, "org")} color={Colors.random()} element={element.organization}></MyCard>
                    )}
                </div>

                { 
                        org.length ===0 ? <p style={{color:"red",fontSize:"12px"}}>Parece que tu usuario aun no ha sido vinculado a niguna organización</p> : null
                    }

            </div>

            {
                /**
                 * 
                 * <div className={"sectores"}>
                <p className={"subtitulo"}>Sectores administrados</p>
                <div className={'cards-container'}>
                    {regiones.map((element)=>
                        <MyCard key={element.id} onCardClick={() => onCardClick(element,"region")} color={Colors.random()} element={element}></MyCard>
                    )}
                </div>
            </div>
                 * 
                 */
            }


            {
                /*
                     <img className={'logo'} src={"/images/logoFinal.png"} />
    
                * */
            }
        </div>
    );
}
