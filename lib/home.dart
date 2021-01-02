import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// firebase authenticator
final FirebaseAuth _auth = FirebaseAuth.instance;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Builder(builder: (BuildContext context) {
                return RaisedButton(
                    child: Text('sign out'),
                    onPressed: () async {
                      final FirebaseUser user = await _auth.currentUser();
                      if (user == null) {
                        Scaffold.of(context).showSnackBar(const SnackBar(
                          content: Text('No one has signed in.'),
                        ));
                        return;
                      }
                      await _auth.signOut();
                      final String email = user.email;
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(email + ' has succesfully signed out.'),
                      ));
                    }
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}

