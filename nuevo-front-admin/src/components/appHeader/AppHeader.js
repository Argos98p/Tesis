import React, {Component} from 'react';
import {Link, NavLink, useNavigate} from 'react-router-dom';
import './AppHeader.css';
import { FaBeer, FaKey, FaUser} from 'react-icons/fa';
import {BiLogOut} from 'react-icons/bi';

import {toast, ToastContainer} from "react-toastify";
import sleep from "../../utils/Sleep";
const AppHeader = ({authenticated, onLogout}) => {
    const navigate = useNavigate();
    const notifySuccess = () => toast.success('Usuario deslogueado', {
        position: "top-right",
        autoClose: 2000,
        hideProgressBar: false,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: "light",
    });
    const logout = async () => {
        notifySuccess();
        await sleep(3000);
        onLogout();
        navigate("/login");
    }
    return ( 
        <div className={` header sticky ${!authenticated ? "blanco" : "header-bg"}`}>
            <div className={` ${!authenticated ? "header-titulo" : ""}`}>Turis UP</div>
            <div className={'header-botones'}>
                {
                authenticated ? 
                    <>
                        <div className={` header-item `}>
                            <Link to="/profile" className={` header-item ${!authenticated ? "" : "texto-negro"}`}>
                                
                                Profile</Link>
                        </div>
                        <div className={'header-item'}>
                            <a onClick={()=>logout()}>
                                <BiLogOut></BiLogOut>
                                Logout</a>
                        </div>
                    </>
                 : 
                    <>
                        <div className={'header-item'}>
                            <Link to={"/login"}>
                               <FaKey></FaKey>
                                Ingresar</Link>
                        </div>
                        {
                            /*
                            * <div className={'header-item'}>
                            <Link to={"/signup"}>

                              <FaUser></FaUser>  Registrarse</Link>
                        </div>
                            *
                            * */
                        }

                    </>
                
            } </div>
        </div>
        
    
        
    );

  
}

export default AppHeader;
