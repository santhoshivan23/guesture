import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:guesture/models/g_user.dart';
import 'package:guesture/providers/guesture_db.dart';

class Auth with ChangeNotifier {
  GUser _gUserFromFBUser(FirebaseUser user) {
    if (user == null) return null;

    return GUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    );
  }

  Stream<GUser> get authenticatedState {
    return FirebaseAuth.instance.onAuthStateChanged
        .map((fbuser) => _gUserFromFBUser(fbuser));
  }

  Stream<ConnectivityResult> get connectionStatus {
    return Connectivity().onConnectivityChanged;
  }

  Future<int> signUp(String email, String password, String displayName) async {
    try {
      final response = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (response == null) return 0;

      final gUser = _gUserFromFBUser(response.user);
      await createUser(gUser);
      await GuestureDB.createToken(response.user.uid);
      return 1;
    } catch (err) {
      return 0;
    }
  }

  Future<int> sendPasswordResetEmail(String email) async {
    final result = await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .then((_) {
      return 1;
    }).catchError((err) {
      // if (err.toString().contains('ERROR_INAVLID_EMAIL')) return -1;
      if(err.toString().contains("ERROR_INVALID_EMAIL"))
      return -1;
      return 0;
    });
    return result;
  }

  Future<void> createUser(GUser gUser) async {
    await Firestore.instance.collection('users').document(gUser.uid).setData({
      'displayName': gUser.displayName,
      'email': gUser.email,
      'photoUrl': gUser.photoUrl,
    });
  }

  Future<int> login(String email, String password) async {
    try {
      final result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      await GuestureDB.createToken(result.user.uid);
      return 1;
    } catch (err) {
      if (err.toString().contains('ERROR_USER_NOT_FOUND')) return -1;
      return 0;
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    final googleAccount = await _googleSignIn.signIn();
    final googleAuth = await googleAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    final result =
        await FirebaseAuth.instance.signInWithCredential(authCredential);

    final FirebaseUser user = result.user;
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    assert(user.uid == currentUser.uid);

    if (result.additionalUserInfo.isNewUser) {
      final gUser = _gUserFromFBUser(user);
      await createUser(gUser);
    }
    await GuestureDB.createToken(user.uid);
  }

  Future<void> logout(String uid) async {
    FirebaseMessaging _fcm = FirebaseMessaging();
    String token = await _fcm.getToken();

    await GuestureDB.deleteToken(uid, token);
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}
