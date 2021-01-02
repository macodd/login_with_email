import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:login_with_email/home.dart';
import 'package:login_with_email/password-recovery.dart';
import 'package:shared_preferences/shared_preferences.dart';

// firebase authenticator
final FirebaseAuth _auth = FirebaseAuth.instance;

// Login page
class LoginPage extends StatefulWidget {

  // title of the page
  final String title = 'Login Page';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    // Scaffold controls the app's view on the screen
    return Scaffold(
      body: Center(
         child: ListView(
          padding: const EdgeInsets.all(16.0),
          shrinkWrap: true,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlutterLogo(size: 100),
                SizedBox(height: 30),
                EmailPasswordForm(),
                SizedBox(height: 10),
                ForgotPassword(),
              ]
            ),
          ]
        )
      )
    );
  }
}

/*
  Form used for entering user email
 */
class EmailPasswordForm extends StatefulWidget {
  @override
  _EmailPasswordFormState createState() => _EmailPasswordFormState();
}

/*
  Private form state for updating screen variables
 */
class _EmailPasswordFormState extends State<EmailPasswordForm> {

  // key used for validating the user's email and password
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // email text box
  final TextEditingController _emailController = TextEditingController();
  // password text box
  final TextEditingController _passwordController = TextEditingController();

  // variables used for updating states
  bool _success;
  String _userEmail;
  String _errorDesc;

  @override
  void initState() {
    super.initState();
    getEmailFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // text field used for entering the email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (String val) {
                if(val.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            // text field used for entering the password
            TextFormField(
              obscureText: true,  // hides the password
              enableSuggestions: false,  // disable suggestions
              autocorrect: false,  // do not allow auto correct
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (String val) {
                if(val.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: Text(
                _success == null
                  ? ''
                  : (_success ? '' : _errorDesc),
                style: TextStyle(
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // button for validating
            SizedBox(
              width: double.infinity,
              //alignment: Alignment.center,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0)
                ),
                color: Colors.blueGrey,
                onPressed: () async {
                  if(_formKey.currentState.validate()) {
                    // check to see if it was a successful login
                    _signInWithEmailAndPassword().then((isLoggedIn) {
                      // clears password input field
                      _passwordController.clear();
                      if(isLoggedIn) {
                        _saveEmailToStorage();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HomePage()
                          ),
                        );
                      }
                    });
                  }
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  /*
    Get email stored locally
   */
  void getEmailFromStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userEmail = prefs.getString('email');

    if(userEmail != null) {
      setState(() {
        // sets the text of the controller to the user email
        _emailController.text = userEmail;
      });
    }
  }

  /*
    Save email in local storage
   */
  void _saveEmailToStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', _userEmail);
  }

  /*
   Function used to sign in an user
   using firebase authentication system
   */
  Future<bool> _signInWithEmailAndPassword() async {

    // authenticated by Firebase
    FirebaseUser user;
    bool loggedIn = false;

    try {
      // sign in the user using email and password
      user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text
      )).user;

      if (user != null) {
        setState(() {
          _success = true;
          _userEmail = user.email;
        });
        loggedIn = true;
      }
    }
    catch(error) {
      // if password or email don't match
      setState(() {
        _success = false;
        _errorDesc = error.message;
      });
      loggedIn = false;
      _saveEmailToStorage();
    }

    return loggedIn;
  }

  // cleans the components when closed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

/*
  Forgot password button
 */
class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
        child: const Text('Forgot password?'),
        onPressed:  () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => PasswordRecoveryPage()
            ),
          );
        }
    );
  }
}