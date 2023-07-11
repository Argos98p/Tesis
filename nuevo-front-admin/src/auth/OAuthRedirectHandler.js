import React, { Component } from 'react';
import { ACCESS_TOKEN } from '../routes/index';
import {Navigate, useSearchParams} from 'react-router-dom'

const  OAuth2RedirectHandler = () => {

    const [searchParams, setSearchParams] = useSearchParams();


    const token = searchParams.get('token');
    const error = searchParams.get('error');


    const returnNavigation=(myToken)=>{
        if(myToken){
            localStorage.setItem(ACCESS_TOKEN, token);
            return <Navigate to={{
                pathname: "/admin/home"
            }}/>;
        }else{
            return <Navigate to={{
                pathname: "/login"
            }}/>
        }
    }
    return (<>{returnNavigation(token)}</>);
}

export default OAuth2RedirectHandler;