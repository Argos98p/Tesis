import { useState, useEffect } from 'react';
const baseUrl=API_BASE_URL_2;
const useFetch = (url = '', options = null) => {
  const [data, setData] = useState(null);
  useEffect(() => {
    fetch(baseUrl+url, options)
      .then(res => res.json())
      .then(data => setData(data));
  }, [url, options]);
  return {data}
}
export default useFetch;