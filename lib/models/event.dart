import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class Event {
  String uid;
  String eventID;
  final String eventName;
  final DateTime startDate;
  final TimeOfDay startTime;
  String inviteLinkA;
  String inviteLinkO;
  
  final double ticketPrice;
  final String location;
  double checkInFraction;
  final bool access;
  final String role;

  Event({
    this.uid,
    this.eventID,
    @required this.eventName,
    @required this.startDate,
    @required this.startTime,
    this.inviteLinkA,
    this.inviteLinkO,
    
    @required this.ticketPrice,
    @required this.location,
    this.checkInFraction,
    this.access,
    this.role
  });

}