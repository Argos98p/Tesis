import { BrowserRouter as Router, Routes as Switch, Route, Outlet, useNavigate, Navigate } from "react-router-dom";
import MainLayout from "./components/mainLayout/MainLayout";
import Login from "./pages/login/Login";
import Signup from './pages/signup/Signup';
import OnePlace from './pages/onePlace/OnePlace';
import { Component, useEffect, useState } from "react";
import LoadingIndicator from './components/others/LoadingIndicator';
import { getCurrentUser } from './auth/Auth';
import { ACCESS_TOKEN } from './routes/index';
import AppHeader from './components/appHeader/AppHeader';
import Home from "./pages/home/Home";
import Protected from "./routes/Protected";
import Organizacion from "./pages/organizacion/Organizacion";


import OAuth2RedirectHandler from "./auth/OAuthRedirectHandler";
import RegionPage from "./pages/region/Region";

import 'bootstrap/dist/css/bootstrap.min.css';

import "./App.css";
import { ToastContainer } from "react-toastify";
import {Dashboard} from "@mui/icons-material";
import MyDashboard from "./pages/dashboard/MyDashboard";

const App = () => {
    const [authenticated, setAuthenticated] = useState(false);
    const [currentUser, setCurrentUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();

    const loadCurrentlyLoggedInUser = () => {
        getCurrentUser()
            .then(response => {
                setAuthenticated(true);
                setLoading(false);
                setCurrentUser(response);

            }).catch(error => {
                setLoading(false)
            });
    }

    const handleLogout = () => {
        localStorage.removeItem(ACCESS_TOKEN);
        setAuthenticated(false);
        setCurrentUser(null);
    }


    useEffect(() => {
        loadCurrentlyLoggedInUser();
    }, [authenticated]);


    const PrivateRoute = () => {
        return authenticated ? <Navigate to="/admin" /> : <Navigate to="/login" />;
    }

    return (
        <>
            <ToastContainer />
            {
                 loading ? <LoadingIndicator /> :

                    <div className="container-fluid m-0 p-0">
                        <AppHeader authenticated={authenticated} onLogout={handleLogout} />
                        <div className={"contenedor"}>
                            <Switch>
                                <Route exact path="/" element={<PrivateRoute />} />
                                <Route exact path="/login" element={<Login onLogout={handleLogout} authenticated={authenticated} />} />
                                <Route exact path="/signup" element={<Signup authenticated={authenticated} />} />

                                <Route path={"/admin"} element={<Protected authenticated={authenticated}>
                                        <MainLayout authenticated={authenticated} currentUser={currentUser} />
                                    </Protected>}>

                                    <Route path={"dashboard"} element={<Protected authenticated={authenticated}>
                                        <MyDashboard authenticated={authenticated} currentUser={currentUser} />
                                    </Protected>}/>

                                    <Route path="home" element={<Protected authenticated={authenticated}>
                                        <Home authenticated={authenticated} currentUser={currentUser} />
                                    </Protected>} />

                                    <Route path="organizacion/:id" element={<Protected authenticated={authenticated}>
                                            <Organizacion authenticated={authenticated} currentUser={currentUser} />
                                        </Protected>} />

                                    <Route path="region/:id/*" element={<Protected authenticated={authenticated}>
                                        <RegionPage authenticated={authenticated} currentUser={currentUser} />
                                    </Protected>} />

                                    <Route path="recurso/:id/*" element={<Protected authenticated={authenticated}>
                                        <OnePlace authenticated={authenticated} currentUser={currentUser} />
                                    </Protected>} />






                                </Route>

                                <Route exact path="/oauth2/redirect" element={<OAuth2RedirectHandler />} />
                            </Switch>
                        </div>

                    </div>

            }</>);

}


export default App;
