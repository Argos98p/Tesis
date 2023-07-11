import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter } from 'react-router-dom';
import App from './App';
import "./scss/volt.scss";
import {ProSidebarProvider} from "react-pro-sidebar";



ReactDOM.render(
    <ProSidebarProvider>

    {/*<React.StrictMode>*/}
      <BrowserRouter>

      <App/>

    </BrowserRouter>
  {/*</React.StrictMode>*/}
        </ProSidebarProvider>

        ,
  document.getElementById('root')
);

