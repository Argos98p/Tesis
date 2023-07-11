import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn(
    serverClientId: "100416626035-15m8dfdvjhe1iv114l3tdcrpdj299g4r.apps.googleusercontent.com"

  );
  static Future<GoogleSignInAccount?> login()=>_googleSignIn.signIn();

  static Future<GoogleSignInAccount?> logout()=>_googleSignIn.signOut();
  static Future<GoogleSignInAccount?> checkLogin()=> _googleSignIn.signInSilently();
  static Future<GoogleSignInAccount?> disconnect()=>_googleSignIn.disconnect();
  static GoogleSignInAccount? currentUser()=>_googleSignIn.currentUser;
}