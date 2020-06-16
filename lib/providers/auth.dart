import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guesture/models/g_user.dart';

class Auth with ChangeNotifier {
 

  Future<GUser> _gUserFromFBUser(FirebaseUser user) async {
    if(user == null) return null;
    final admin = await Firestore.instance.collection('users').document(user.uid).get().then((value) => value.data['parent_uid'] == null ? true : false);
        final uid = await Firestore.instance.collection('users').document(user.uid).get().then((value) => value.data['parent_uid'] == null ? value.documentID: value.data['parent_uid']);

    if(!admin)
    return GUser(
      uid: uid,
      email: user.email,
      isAdmin: admin,
    );
    return GUser(
      uid: uid,
      email: user.email,
      isAdmin: admin,
    );
  }

  Stream<Future<GUser>> get authenticatedState {
    return FirebaseAuth.instance.onAuthStateChanged.map((fbuser) => _gUserFromFBUser(fbuser));
  }

  Future<int> signUp(String email, String password) async {
    try {
      final response = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if(response == null) return 0;
      
      await Firestore.instance.collection('users').document(response.user.uid).setData({
        'parent_uid': null,
        'email': response.user.email,
      });
      return 1;
    } catch (err) {
      return 0;
    }
  }

  Future<int> signUpStandardUser(
      String email, String password, String parentUid) async {
    try {

      final count = await Firestore.instance.collection('users').where('parent_uid',isEqualTo: parentUid).getDocuments().then((value) => value.documents.length);
      if(count > 1) return -1;
      final result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await Firestore.instance.collection('users').document(result.user.uid).setData({
        'parent_uid': parentUid,
        'email': email,
      });
      return 1;
    } catch (err) {
      return 0;
    }
  }

  Future<int> login(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      
      return 1;
    } catch (err) {
      if (err.toString().contains('ERROR_USER_NOT_FOUND')) return -1;
      return 0;
      
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
