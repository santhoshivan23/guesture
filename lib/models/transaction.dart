import 'package:flutter/material.dart';

enum PaymentMode { Cash, UPI }

class GTransaction {
  @required
  final String payerName;

  final DateTime timeOfPayment;
  @required
  final double amount;

  GTransaction({this.payerName, this.timeOfPayment, this.amount});
}
