import React, {Component, useState} from 'react';
import './login.css';
import { ACCESS_TOKEN } from '../../routes/index';
import {getCurrentUser, login} from '../../auth/Auth';
import {Link, Navigate, useNavigate} from 'react-router-dom'

import SocialLogin from '../../components/social/Social';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import {toast, ToastContainer} from "react-toastify";
import sleep from "../../utils/Sleep";

class Login extends Component {
 

    render() {
        if(this.props.authenticated) {
            return <Navigate
                to={{
                pathname: "/",
                state: { from: this.props.location }
            }}/>;            
        }
         return(
            <Container fluid className='login-container'>
                <Row className='vertical-center'>
                    <Col xxs={{ span: 12, offset: 0 }} xs={{ span: 8, offset: 2 }} md={{ span: 4, offset: 4 }} className="login-content">
                        <div className=''>
                            <h3>Ingresa para administrar lugares</h3>
                        </div>
                        <LoginForm onLogout={this.props.onLogout} />
                        {/*<div className="or-separator">*/}
                        {/*    <span className="or-text">OR</span>*/}
                        {/*</div>*/}
                        {/*<SocialLogin />*/}
                        {/*<span className="signup-link">New user? <Link to="/signup">Sign up!</Link></span>*/}
                    </Col>
                </Row>
            </Container>
        );

    }
}
const LoginForm = ({onLogout}) => {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const navigate = useNavigate();


    const handleInputChange = (event) => {
        const target = event.target;
        const inputName = target.name;        
        const inputValue = target.value;

        this.setState({
            [inputName] : inputValue
        });        
    }

    const handleSubmit = (event) => {
        event.preventDefault();
        const notifySuccess = () => toast.success('Acceso correcto', {
            position: "top-right",
            autoClose: 2000,
            hideProgressBar: false,
            closeOnClick: true,
            pauseOnHover: true,
            draggable: true,
            progress: undefined,
            theme: "light",
        });

        const notifyError = (error)=>toast.error(error, {
            position: "top-right",
            autoClose: 2000,
            hideProgressBar: false,
            closeOnClick: true,
            pauseOnHover: true,
            draggable: true,
            progress: undefined,
            theme: "light",
        });

        login({"email":email,"password":password})
        .then(async response => {
               // notifySuccess();
                localStorage.setItem(ACCESS_TOKEN, response.accessToken);
                await sleep(1000);
                getCurrentUser().then(
                    async response =>{
                        console.log(response)
                        if(response.statusCode===500){
                            console.log("credenciales invalidads")
                        }else{
                            if(response.role === "admin"){
                                navigate("/admin/home");
                                window.location.reload();
                            }else{
                                onLogout()
                                notifyError("El usuario no es administrador")
                            }
                        }

                    }
                ).catch((error=>{
                    notifyError(error.message)
                    console.log(error);
                }));

                // navigate("/admin/home", {authenticated:true})
                // window.location.reload();

            //this.props.history.push("/");
        }).catch(error => {
            notifyError(error.message)

            alert("credenciales invalidas")
        });
    }

        return (
            <form onSubmit={handleSubmit} className='form-login'>
                <div className="form-item">
                    <input type="email" name="email" 
                        className="form-control" placeholder="Email"
                           value={email} onChange={(e) => setEmail(e.target.value)} required/>
                </div>
                <div className="form-item">
                    <input type="password" name="password" 
                        className="form-control" placeholder="Password"
                           value={password} onChange={(e) => setPassword(e.target.value)} required/>
                </div>
                <div className="form-item ">
                    <button type="submit" className="btn  btn-block login-button">INGRESAR</button>
                </div>
            </form>                    
        );
}

export default Login