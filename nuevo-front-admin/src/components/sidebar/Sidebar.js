import "./sidebar.css";

import { NavLink } from "react-router-dom";
import { IconBase } from "react-icons";
import { FaHome } from "react-icons/fa";

export default function Sidebar() {
    return (
        <div className="sidebar">
            <div className="sidebarWrapper">
                <div className="sidebarMenu">
                    <h3 className="sidebarTitle">Lugares</h3>
                    <ul className="sidebarList">
                        <NavLink to="/admin/home" className="link">
                            <li className="sidebarListItem ">
                                <FaHome className="sidebarIcon"></FaHome>
                                
                                Home
                            </li>
                        </NavLink>
                        <NavLink to="/admin/home" className="link">
                            <li className="sidebarListItem ">
                                <FaHome className="sidebarIcon"></FaHome>                                
                                Home
                            </li>
                        </NavLink>
                        <NavLink to="/admin/revisar" className="link">
                            <li className="sidebarListItem">
                                <IconBase className="sidebarIcon" />
                                Por Revisar
                            </li>
                        </NavLink>

                        <NavLink to="/admin/aceptados" className="link">
                            <li className="sidebarListItem">
                                <IconBase className="sidebarIcon" />
                                Aceptados
                            </li>
                        </NavLink>
                        <NavLink to="/admin/rechazados" className="link">
                            <li className="sidebarListItem">
                                <IconBase className="sidebarIcon" />
                                Rechazados
                            </li>
                        </NavLink>
                    </ul>
                </div>

                {

                    /**
                     * 
                     * <div className="sidebarMenu">
                    <h3 className="sidebarTitle">Organizaciones</h3>
                    <ul className="sidebarList">
                        <NavLink to="/users" className="link">
                            <li className="sidebarListItem">
                                <IconBase className="sidebarIcon" />
                                Organizaciones
                            </li>
                        </NavLink>
                        <NavLink to="/products" className="link">
                            <li className="sidebarListItem">
                                <IconBase className="sidebarIcon" />
                                Sectores
                            </li>
                        </NavLink>
                        <li className="sidebarListItem">
                            <IconBase className="sidebarIcon" />
                            Transactions
                        </li>
                        <li className="sidebarListItem">
                            <IconBase className="sidebarIcon" />
                            Reports
                        </li>
                    </ul>
                </div>
                <div className="sidebarMenu">
                    <h3 className="sidebarTitle">Regiones</h3>
                    <ul className="sidebarList">
                        <li className="sidebarListItem">
                            <IconBase className="sidebarIcon" />
                            Mail
                        </li>
                        <li className="sidebarListItem">
                            <IconBase className="sidebarIcon" />
                            Feedback
                        </li>
                        <li className="sidebarListItem">
                            <IconBase className="sidebarIcon" />
                            Messages
                        </li>
                    </ul>
                </div>
                <div className="sidebarMenu">
                    <h3 className="sidebarTitle">Staff</h3>
                    <ul className="sidebarList">

                        <li className="sidebarListItem">
                            <IconBase className="sidebarIcon" />
                            Analytics
                        </li>
                        <li className="sidebarListItem">
                            <IconBase className="sidebarIcon" />
                            Reports
                        </li>
                    </ul>
                </div>
                     * 
                     */
                }
                
            </div>
        </div>
    );
}
