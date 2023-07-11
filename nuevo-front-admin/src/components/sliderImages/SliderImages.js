import React, { useRef, useState } from "react";
// Import Swiper React components
import { Swiper, SwiperSlide } from "swiper/react";
import { Navigation, Pagination, Scrollbar } from 'swiper';
import 'swiper/css/navigation';
import 'swiper/css/pagination';
import 'swiper/css/scrollbar';

import 'swiper/css';
// import required modules

export default function SliderImages({imageList}) {

      const imgs = imageList && imageList.map(img => (
        <SwiperSlide key={img}><img src={img} /></SwiperSlide>        
  ));
  return (
    <>
    {
        <Swiper  modules={[Navigation, Pagination, Scrollbar]} pagination navigation scrollbar className="mySwiper">
        {imgs}
      </Swiper> 
    }
      
    </>
  );
}
