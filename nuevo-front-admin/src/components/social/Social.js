import fbLogo from "../../assets/img/logos/fb-logo.png";
import { useNavigate } from "react-router-dom";
import React from 'react';
import googleLogo from '../../assets/img/logos/google-logo.png';
import { GOOGLE_AUTH_URL, FACEBOOK_AUTH_URL } from '../../routes/index';
import './social.css';
import Container from 'react-bootstrap/Container';


const SocialLogin =()=> {

  const navigate = useNavigate();


    return (
      <Container className='social-container'>
        <div className='social-button-fb' onClick={()=>window.location.href = (FACEBOOK_AUTH_URL)}>
          <a  href={FACEBOOK_AUTH_URL} ><img src={fbLogo} alt="Facebook" /></a>
        </div>
        <div className='social-button-google' onClick={()=>window.location.href = (GOOGLE_AUTH_URL)}>
          <a  href={GOOGLE_AUTH_URL} className='social-button'> <img src={googleLogo} alt="Google" /></a>
        </div>
        
      </Container>
    );

  
}

export default SocialLogin;