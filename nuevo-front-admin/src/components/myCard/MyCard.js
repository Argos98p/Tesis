import "./MyCard.css"
const MyCard = ({color, element,onCardClick}) => {

    return (
        <div className={"mycard"} style={{backgroundColor:color}} onClick={onCardClick}>
            <p>{element? element.nombre :""}</p>
        </div>
    );
}

export default  MyCard;