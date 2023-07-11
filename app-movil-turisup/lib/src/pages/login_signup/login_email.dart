import 'package:flutter/material.dart';

import '../../widgets/my_divider.dart';
import '../../widgets/title_login_widget.dart';


class LoginEmail extends StatefulWidget {
  const LoginEmail({Key? key}) : super(key: key);

  @override
  State<LoginEmail> createState() => _LoginEmailState();
}

class _LoginEmailState extends State<LoginEmail> {

  @override
  Widget build(BuildContext context) {

    TextEditingController textCorreoController = TextEditingController();
    TextEditingController textPassController = TextEditingController();

    textCorreoController.text = "admin@gmail.com";
    textPassController.text = "123456789";

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
          color: Color(0xFFFFFFFF),
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: height * 0.03, horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    logoContainer(width * 0.5),
                    const SizedBox(
                      height: 20,
                    ),
                    textLogin("Iniciar sesion"),
                    const SizedBox(
                      height: 20,
                    ),
                    myTextField(Icons.mail, "Correo",textCorreoController,false),
                    const SizedBox(
                      height: 10,
                    ),
                    myTextField(Icons.lock, "Contraseña",textPassController,true),
                    const SizedBox(
                      height: 10,
                    ),
                    remember(),
                    const SizedBox(
                      height: 10,
                    ),
                    btnRegistrar(context),
                    const SizedBox(
                      height: 10,
                    ),

                    //socialButton('assets/icons/fb.png',"Continuar con Facebook"),
                    //socialButton('assets/icons/google.png',"Continuar con Google"),
                    myDivider("o continue con"),
                    const SizedBox(
                      height: 10,
                    ),
                    socialButtons(context)
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


Widget remember(){
  return Row( mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Checkbox(
    checkColor: Colors.white,
    //fillColor: MaterialStateProperty.resolveWith(getColor),
    value: false, onChanged: (bool? value) {  },

  ),
    Text("Recordar"),

  ],);
}

Widget btnRegistrar(context){
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(

      onPressed: () {
        Navigator.pushReplacementNamed(context,
          '/home',);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:  Color(0xFF246BFD),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text('Iniciar sesion'),
    ),
  );
}
Widget logoContainer(width) {
  return Image.asset(
    'assets/images/logo.png',
    height: width,
  );
}



Widget myTextField(myIcon, mytext,controller,hide) {
  return TextField(
      obscureText: hide,
      enableSuggestions: false,
      autocorrect: false,
    controller: controller,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, ),
          borderRadius: BorderRadius.all(Radius.circular(12))
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black12,),
            borderRadius: BorderRadius.all(Radius.circular(12))
        ),

        prefixIcon: Icon(myIcon),
        fillColor: const Color(0xFFFAFAFA),
        hintText: mytext,
        filled: true,

      ));
}

Widget socialButtons(context){
  return SizedBox(
    height: 70,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: (){
              Navigator.pushReplacementNamed(context,
                '/home',);
          },
          child: Container( padding: EdgeInsets.all(10), decoration:  BoxDecoration(
            borderRadius:  BorderRadius.circular(16.0),
            color: Color(0xFFF5F5F5),
          ), height: 75,width: 75,child:Image.asset('assets/icons/fb.png',height: 60,) ,),
        ),
        SizedBox(width: 40,),
        InkWell(
          onTap: (){
            Navigator.pushReplacementNamed(context,
              '/home',);
          },
          child: Container( padding: EdgeInsets.all(10), decoration:  BoxDecoration(
            borderRadius:  BorderRadius.circular(16.0),
            color: Color(0xFFF5F5F5),
          ), height: 75,width: 75,child:Image.asset('assets/icons/google.png',height: 60,) ,),
        ),

      ],
    ),
  );
}
