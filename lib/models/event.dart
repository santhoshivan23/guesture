import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guesture/models/transaction.dart';

import './guest.dart';

class Event {
  String uid;
  String eventID;
  final String eventName;
  final DateTime startDate;
  final TimeOfDay startTime;
  String inviteLink;
  List<Guest> guests;
  List<GTransaction> transactions;
  final double ticketPrice;
  final String location;
  double checkInFraction;
  

  Event({
    this.uid,
    this.eventID,
    @required this.eventName,
    @required this.startDate,
    @required this.startTime,
    this.inviteLink,
    this.guests,
    this.transactions,
    @required this.ticketPrice,
    @required this.location,
    this.checkInFraction,
  });

}