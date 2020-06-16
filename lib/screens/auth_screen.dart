import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guesture/providers/auth.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Guesture',
                  style:
                      GoogleFonts.pacifico(color: Colors.white, fontSize: 26),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AuthCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum AuthMode { Login, SignUp }

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  var _authMode = AuthMode.Login;
  String email;
  String password;
  final _pwdController = TextEditingController();
  final _cpwdController = TextEditingController();
  final _emailFN = FocusNode();
  final _pwdFN = FocusNode();
  final _confirmpwdFN = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _loading = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          child: 
          Container(
            
            width: double.infinity,
            
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Form(
                key: _formKey,
                child:  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          focusNode: _emailFN,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofocus: false,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            fillColor: Colors.grey.withOpacity(0.3),
                            filled: true,
                            hintText: 'Email ID',
                            hintStyle:
                                TextStyle(color: Colors.white.withOpacity(0.5)),
                          ),
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_pwdFN);
                          },
                          validator: (email) {
                            if (!email.contains('.com') || !email.contains('@'))
                              return 'Enter a valid email';
                            return null;
                          },
                          onSaved: (val) {
                            email = val;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          focusNode: _pwdFN,
                          style: TextStyle(color: Colors.white),
                          autofocus: false,
                          obscureText: true,
                          controller: _pwdController,
                          textInputAction: _authMode == AuthMode.SignUp ? TextInputAction.next : TextInputAction.done,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.3),
                            hintText: 'Password',
                            hintStyle:
                                TextStyle(color: Colors.white.withOpacity(0.5)),
                          ),
                          validator: (pwd) {
                            if (pwd.length < 5) return 'Password is too short!';
                            if (_pwdController.text != _cpwdController.text &&
                                _authMode == AuthMode.SignUp)
                              return 'Passwords do not match!';
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            if(_authMode == AuthMode.SignUp)
                            FocusScope.of(context).requestFocus(_confirmpwdFN);
                          },
                          onSaved: (val) {
                            password = val;
                          },
                        ),
                      ),
                      if (_authMode == AuthMode.SignUp)
                     
                                            Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              focusNode: _confirmpwdFN,
                              textInputAction: TextInputAction.done,
                              style: TextStyle(color: Colors.white),
                              autofocus: false,
                              obscureText: true,
                              controller: _cpwdController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.3),
                                hintText: 'Confirm Password',
                                hintStyle:
                                    TextStyle(color: Colors.white.withOpacity(0.5)),
                              ),
                            
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15.0),
                        child: _loading
                            ? CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              )
                            : RaisedButton(
                                onPressed: _authenticate,
                                color: Colors.indigo,
                                child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      _authMode == AuthMode.SignUp
                                          ? 'Sign Up'
                                          : 'Login',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Divider(
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'OR',
                                style:
                                    TextStyle(color: Colors.white.withOpacity(0.6)),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _authMode == AuthMode.SignUp
                                ? 'Already have an account?'
                                : 'Don\'t have an account?',
                            style: TextStyle(color: Colors.grey),
                          ),
                          FlatButton(
                            onPressed: () {
                              if (_authMode == AuthMode.SignUp)
                                setState(() {
                                  _authMode = AuthMode.Login;
                                });
                              else
                                setState(() {
                                  _authMode = AuthMode.SignUp;
                                });
                            },
                            child: Text(
                              _authMode == AuthMode.SignUp ? 'Login' : 'Sign Up',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              
            ),
          ),
        
    );
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState.validate()) return;
    setState(() {
      _loading = true;
    });
    _formKey.currentState.save();
    if (_authMode == AuthMode.SignUp) {
      final result = await Auth()
          .signUp(email, password);
      if(result !=1)
     {
        showDialog(context: context, builder: (ctx) => AlertDialog(
          title: Text('Signup Failed'),
          content : Text('The email id entered is already in use!'),
          actions: [
            FlatButton(child: Text('OK'), onPressed: () {
              Navigator.pop(ctx);
            setState(() {
              _loading = false;
            });
            },)
          ],
        ));
      }
      return;
    } else {
      final result = await Auth()
          .login(email, password);
      
     if (result == -1)
        showDialog(context: context, builder: (ctx) => AlertDialog(
          title: Text('Authentication Failed'),
          content : Text('The email id entered is not registered with us. Kindly sign-up!'),
          actions: [
            FlatButton(child: Text('OK'), onPressed: () {
              Navigator.pop(ctx);
            setState(() {
              _loading = false;
            });
            },)
          ],
        ));
      else if(result == 0) {
        showDialog(context: context, builder: (ctx) => AlertDialog(
          title: Text('Authentication Failed'),
          content : Text('Invalid login credentials!'),
          actions: [
            FlatButton(child: Text('OK'), onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _loading = false;
              });
            },)
          ],
        ));
      }

      return;
    }
  }
}
