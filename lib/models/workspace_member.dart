import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guesture/models/g_user.dart';

class WorkspaceMember  {
  final String uid;
  final String role;
  final int ticketsSold;

  WorkspaceMember({this.uid,this.role,this.ticketsSold});

}