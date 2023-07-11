const Colors = ["#95cfd5", "#70367c","#fd7e50","#809bce","#eac4d5","#fd8a8a","#86c8bc","#66657d","#98a8f8","#7e9d9c","#587073"]
Array.prototype.random = function () {
    return this[Math.floor((Math.random()*Colors.length))];
}

export default  Colors;