import 'package:flutter/material.dart';

import '../../widgets/my_divider.dart';
import '../../widgets/title_login_widget.dart';

class NewAccountPage extends StatefulWidget {
  const NewAccountPage({Key? key}) : super(key: key);

  @override
  State<NewAccountPage> createState() => _NewAccountPageState();
}

class _NewAccountPageState extends State<NewAccountPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      color: Color(0xFFFFFFFF),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: height * 0.05, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                logoContainer(width * 0.5),
                const SizedBox(
                  height: 20,
                ),
                textLogin("Crear nueva cuenta"),
                const SizedBox(
                  height: 20,
                ),
                myTextField(Icons.person, "Nombre"),
                const SizedBox(
                  height: 10,
                ),
                myTextField(Icons.dashboard, "Nickname"),
                const SizedBox(
                  height: 10,
                ),
                myTextField(Icons.mail, "Correo"),
                const SizedBox(
                  height: 10,
                ),
                myTextField(Icons.lock, "Contraseña"),
                const SizedBox(
                  height: 30,
                ),
                btnRegistrar(),
                const SizedBox(
                  height: 20,
                ),


                myDivider("o continue con"),
                const SizedBox(
                  height: 20,
                ),
                socialButtons()
                //remember(),
                //loginEmail(),
                // noHaveAccount()
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

Widget remember() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Checkbox(
        checkColor: Colors.white,
        //fillColor: MaterialStateProperty.resolveWith(getColor),
        value: false,
        onChanged: (bool? value) {},
      ),
      const Text("Recordar"),
    ],
  );
}

Widget socialButtons(){
  return SizedBox(
    height: 70,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container( padding: EdgeInsets.all(10), decoration:  BoxDecoration(
          borderRadius:  BorderRadius.circular(16.0),
          color: Color(0xFFF5F5F5),
        ), height: 75,width: 75,child:Image.asset('assets/icons/fb.png',height: 60,) ,),
        SizedBox(width: 40,),
        Container( padding: EdgeInsets.all(10), decoration:  BoxDecoration(
          borderRadius:  BorderRadius.circular(16.0),
          color: Color(0xFFF5F5F5),
        ), height: 75,width: 75,child:Image.asset('assets/icons/google.png',height: 60,) ,),

      ],
    ),
  );
}

Widget btnRegistrar(){
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(

      onPressed: (){},
      style: ElevatedButton.styleFrom(
        backgroundColor:  Color(0xFF246BFD),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text('Registrar'),
    ),
  );
}

Widget myTextField(myIcon, mytext) {
  return TextField(
      decoration: InputDecoration(
    prefixIcon: Icon(myIcon),
    fillColor: Color(0xFFFFFBFB),
    hintText: mytext,
    filled: true,
    border:
        OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  ));
}

Widget logoContainer(width) {
  return Image.asset(
    'assets/images/logo.png',
    height: width,
  );
}
