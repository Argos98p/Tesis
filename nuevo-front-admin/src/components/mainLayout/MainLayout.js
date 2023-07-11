

import Sidebar from '../sidebar/Sidebar';
import './mainLayout.css'
import { BrowserRouter, Navigate, Outlet, Route, Routes as Switch } from "react-router-dom";
import { ToastContainer } from "react-toastify";
import React from "react";
const MainLayout = ({ authenticated, children, currentUser }) => {
    console.log("llega al main layout", authenticated)
    return (
        <div className="main-layout">
            {
                /**<Sidebar></Sidebar> */
            }
            

            <div className='main-layout-content'>

                <Outlet/>
            </div>
        </div>
    );
}

export default MainLayout;