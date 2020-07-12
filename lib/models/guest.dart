import 'package:flutter/foundation.dart';

class Guest {
  final String gID;
  final String gEventID;
  final String gName;
  final String gMobileNumber;
  final String gEmailID;
  final String gGender;
  final String gOrg;
  final String reservedBy;
  final int gAllowance;
  bool isCheckedIn;

   Guest({
   this.gID, 
   @required this.gEventID,
   @required this.gName,
   @required this.gMobileNumber,
   @required this.gEmailID,
   @required this.gGender,
   @required this.gOrg,
   @required this.gAllowance,
   this.reservedBy,
   this.isCheckedIn = false,

  });
}