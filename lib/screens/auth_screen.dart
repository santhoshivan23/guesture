import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guesture/providers/auth.dart';
import 'package:guesture/widgets/cwg_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AuthScreen extends StatelessWidget {

  static const routeName = '/auth';
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
  void initState() {
    checkConnectivityAddListener();

    super.initState();
  }

  @override
  void dispose() {
    _emailFN.dispose();
    _pwdFN.dispose();
    _confirmpwdFN.dispose();
    _cpwdController.dispose();
    _fnController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  void showNetworkSnackBar(bool isConnected) {
    if (isConnected)
      Scaffold.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
          content: Text(
            'Connection Established!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    else
      Scaffold.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          content: Text(
            'Ouch! We are unabe to reach our server! Please check your network connection!',
            textAlign: TextAlign.center,
          ),
        ),
      );
  }

  void showAuthSnackBar(bool success, String message) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? Colors.green : Colors.red,
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> handleResetPassword() async {
    final status = await checkConnectivity();
    if (status == ConnectivityResult.none) {
      showNetworkSnackBar(false);
      return;
    }
    if (_emailController.text.isEmpty) {
      showAuthSnackBar(false, "Enter a valid email");
      return;
    }
    final result = await Auth().sendPasswordResetEmail(_emailController.text);
    print(result);
    if (result == 1)
      showAuthSnackBar(true,
          'A password reset mail has been sent to ${_emailController.text}. Follow the instructions to reset your passord');
    else if (result == 0)
      showAuthSnackBar(false,
          '${_emailController.text} is not registered with us. Kindly signup!');
    else
      showAuthSnackBar(false, "Enter a valid email");
  }

  checkConnectivityAddListener() async {
    Auth().connectionStatus.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none)
        showNetworkSnackBar(true);
      else
        showNetworkSnackBar(false);
    });
  }

  checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return result;
  }

  var _authMode = AuthMode.Login;
  String email;
  String password;
  String displayName;
  bool passwordVisible = false;
  final _pwdController = TextEditingController();
  final _cpwdController = TextEditingController();
  final _fnController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailFN = FocusNode();
  final _pwdFN = FocusNode();
  final _confirmpwdFN = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _loading = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _emailController,
                    focusNode: _emailFN,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofocus: false,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Icon(MdiIcons.email,
                          color: Colors.white.withOpacity(0.6)),
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
                      if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(email)) return 'Enter a valid email';
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
                    obscureText: !passwordVisible,
                    controller: _pwdController,
                    textInputAction: _authMode == AuthMode.SignUp
                        ? TextInputAction.next
                        : TextInputAction.done,
                    decoration: InputDecoration(
                      prefixIcon: Icon(MdiIcons.accountLock,
                          color: Colors.white.withOpacity(0.6)),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                        icon: passwordVisible
                            ? Icon(Icons.visibility_off,
                                color: Colors.white.withOpacity(0.5))
                            : Icon(Icons.visibility,
                                color: Colors.white.withOpacity(0.5)),
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.3),
                      hintText: 'Password',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                    validator: (pwd) {
                      if (pwd.length < 5) return 'Password is too short';
                      if (_pwdController.text != _cpwdController.text &&
                          _authMode == AuthMode.SignUp)
                        return 'Passwords do not match';
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      if (_authMode == AuthMode.SignUp)
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
                        prefixIcon: Icon(
                          MdiIcons.accountLock,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.3),
                        hintText: 'Confirm Password',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                  ),
                if (_authMode == AuthMode.SignUp)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.name,
                      autofocus: false,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_emailFN);
                      },
                      controller: _fnController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person_pin,
                          color: Colors.white,
                        ),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.3),
                        hintText: 'Full Name',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.6)),
                      ),
                      validator: (name) {
                        if (name.isEmpty) return "Enter a valid name";
                        if (name.length < 5) return "Name is too short";
                        return null;
                      },
                      onSaved: (name) {
                        displayName = name;
                      },
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7)),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Forgot your credentials?  ',
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: handleResetPassword,
                      child: Text(
                        'Get help signing in.',
                        style: TextStyle(
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
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
                ),
                CWGButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _authenticate() async {
    final result = await checkConnectivity();
    if (result == ConnectivityResult.none) {
      showNetworkSnackBar(false);
      return;
    }
    if (!_formKey.currentState.validate()) return;
    setState(() {
      _loading = true;
    });
    _formKey.currentState.save();
    if (_authMode == AuthMode.SignUp) {
      final result = await Auth().signUp(email, password, displayName);
      if (result != 1) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Signup Failed'),
                  content: Text('The email id entered is already in use!'),
                  actions: [
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _loading = false;
                        });
                      },
                    )
                  ],
                ));
      }
      Navigator.of(context).pop();
      return;
    } else {
      final result = await Auth().login(email, password);

      if (result == -1)
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Authentication Failed'),
                  content: Text(
                      'The email id entered is not registered with us. Kindly sign-up!'),
                  actions: [
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _loading = false;
                        });
                      },
                    )
                  ],
                ));
      else if (result == 0) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Authentication Failed'),
                  content: Text('Invalid login credentials!'),
                  actions: [
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _loading = false;
                        });
                      },
                    )
                  ],
                ));
      }
      Navigator.of(context).pop();
      return;
    }
  }
}
