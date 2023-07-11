import React, {Component, useState} from 'react';
import './signup.css';
import {Link, Navigate, useNavigate} from 'react-router-dom'
import {signup} from '../../auth/Auth';
import SocialLogin from '../../components/social/Social';
import Container from "react-bootstrap/Container";
import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import sleep from "../../utils/Sleep";
class Signup extends Component {

    render() {

        if(this.props.authenticated) {
            return <Navigate
                to={{
                pathname: "/",
                state: { from: this.props.location }
            }}/>;            
        }

        return (
            <Container fluid className='login-container'>
                <Row className='vertical-center'>
                    <Col xxs={{ span: 12, offset: 0 }} xs={{ span: 8, offset: 2 }} md={{ span: 4, offset: 4 }} className="login-content">
                        <div className='titulo'>
                            <h2>Registrate</h2>
                            <p>Ingresa una contraseña y un correo</p>
                        </div>
                        <SocialLogin />
                        <div className="or-separator">
                            <span className="or-text">OR</span>
                        </div>
                        <SignupForm {...this.props} />
                        <span className="login-link">Already have an account? <Link to="/login">Login!</Link></span>

                    </Col>
                </Row>
            </Container>

        );
    }
}

const SignupForm = () =>{

    const [name, setName] = useState("");
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const navigate = useNavigate();

    const handleSubmit = (event) => {
        const notifySuccess = () => toast.success('Usuario creado, porfavor ingrese', {
            position: "top-right",
            autoClose: 2000,
            hideProgressBar: false,
            closeOnClick: true,
            pauseOnHover: true,
            draggable: true,
            progress: undefined,
            theme: "light",
        });

        const notifyError = ()=>toast.error('Ocurrio un problema en la creacion del usuario', {
            position: "top-right",
            autoClose: 2000,
            hideProgressBar: false,
            closeOnClick: true,
            pauseOnHover: true,
            draggable: true,
            progress: undefined,
            theme: "light",
        });

        event.preventDefault();   


        signup({"name":name,"email":email,"password":password})
        .then(async response => {
            notifySuccess();
            await sleep(4000);
            navigate("/login");

        }).catch(error => {
            notifyError();
        });
    }


        return (
            <form onSubmit={handleSubmit}>
                <div className="form-item">
                    <input type="text" name="name" 
                        className="form-control" placeholder="Name"
                        value={name} onChange={(e) => setName(e.target.value)} required/>
                </div>
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
                    <button type="submit" className="btn btn-block btn-primary btn-login" >Sign Up</button>
                </div>
            </form>                    

        );

}

export default Signup