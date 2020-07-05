import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guesture/models/g_user.dart';
import 'package:guesture/models/guest.dart';
import 'package:guesture/screens/cash_confirm_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

class NewReservationScreen extends StatefulWidget {
  static const routeName = './new-reservation';

  @override
  _NewReservationScreenState createState() => _NewReservationScreenState();
}

class _NewReservationScreenState extends State<NewReservationScreen> {
  final _guestNameFocusNode = FocusNode();
  final _guestMobileNumberFocusNode = FocusNode();
  final _guestOrgFocusNode = FocusNode();
  final _guestEmailIDFocusNode = FocusNode();
  final _guestAllowanceFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _switchStateGender = true;

  bool _switchStatePMode = true;

  var _processingGuest = Guest(
    gAllowance: null,
    gEmailID: null,
    gEventID: null,
    gGender: null,
    gOrg: null,
    gMobileNumber: null,
    gName: null,
  );

  void _switchToggleGender(bool val) {
    setState(() {
      _switchStateGender = val;
    });
  }

  void _switchTogglePMode(bool val) {
    setState(() {
      _switchStatePMode = val;
    });
  }

  void _fabClicked(context, String eventID, String myUid, String eventName,) {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    _processingGuest = Guest(
      gID: randomAlphaNumeric(10),
      gName: _processingGuest.gName,
      gMobileNumber: _processingGuest.gMobileNumber,
      gEmailID: _processingGuest.gEmailID,
      gOrg: _processingGuest.gOrg,
      gAllowance: _processingGuest.gAllowance,
      gGender: _switchStateGender ? 'M' : 'F',
      gEventID: _processingGuest.gEventID,
      reservedBy: myUid,
    );

   
    Navigator.of(context)
        .pushNamed(CashConfirmScreen.routeName, arguments: {
          'guest' :_processingGuest,
          'eventID' : eventID,
          'eventName' :  eventName,
          });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as Map<String,String>;
    final String eventID = args['eventID'];
    final String myUid = args['myUid'];
    final String eventName = args['eventName'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('New Reservation'),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.done,color: Colors.white,), onPressed: () => _fabClicked(context, eventID,myUid,eventName),)
        ],
      ),
      
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                child: TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: _guestNameFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_guestEmailIDFocusNode);
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(MdiIcons.account,color: Colors.pink,),
                    labelText: 'Full Name',
                    labelStyle: GoogleFonts.notoSans(),
                  ),
                  onSaved: (val) {
                    _processingGuest = Guest(
                      gName: val,
                      gMobileNumber: _processingGuest.gMobileNumber,
                      gEmailID: _processingGuest.gEmailID,
                      gOrg: _processingGuest.gOrg,
                      gAllowance: _processingGuest.gAllowance,
                      gGender: _processingGuest.gGender,
                      gEventID: eventID,
                    );
                  },
                  validator: (enteredName) {
                    if (enteredName.isEmpty) return 'Name cannot be empty!';
                    if (enteredName.length < 5)
                      return "Name is too short! (Min 5 chars)";
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                child: TextFormField(
                  focusNode: _guestEmailIDFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_guestOrgFocusNode);
                  },
                  decoration: InputDecoration(
                    labelText: 'Email ID',
                    labelStyle: GoogleFonts.notoSans(),
                    prefixIcon: Icon(MdiIcons.email,color: Colors.pink,),
                  ),
                  onSaved: (val) {
                    _processingGuest = Guest(
                      gName: _processingGuest.gName,
                      gMobileNumber: _processingGuest.gMobileNumber,
                      gEmailID: val,
                      gOrg: _processingGuest.gOrg,
                      gAllowance: _processingGuest.gAllowance,
                      gGender: _processingGuest.gGender,
                      gEventID: _processingGuest.gEventID,
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                child: TextFormField(
                  focusNode: _guestOrgFocusNode,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Organization',
                    labelStyle: GoogleFonts.notoSans(),
                    prefixIcon: Icon(MdiIcons.officeBuilding,color: Colors.pink,),
                  ),
                  onFieldSubmitted: (_) {
                    FocusScope.of(context)
                        .requestFocus(_guestMobileNumberFocusNode);
                  },
                  onSaved: (val) {
                    _processingGuest = Guest(
                      gName: _processingGuest.gName,
                      gMobileNumber: _processingGuest.gMobileNumber,
                      gEmailID: _processingGuest.gEmailID,
                      gOrg: val,
                      gAllowance: _processingGuest.gAllowance,
                      gGender: _processingGuest.gGender,
                      gEventID: _processingGuest.gEventID,
                    );
                  },
                  validator: (enteredOrg) {
                    if (enteredOrg.isEmpty)
                      return 'Organization cannot be empty!';
                    if (enteredOrg.length < 3)
                      return "Organization Name is too short! (Min 3 chars)";
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                child: TextFormField(
                  initialValue: '+91',
                  focusNode: _guestMobileNumberFocusNode,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    labelStyle: GoogleFonts.notoSans(),
                    prefixIcon: Icon(MdiIcons.phone,color: Colors.pink,),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (enteredMN) {
                    if (enteredMN.isEmpty) return 'Mobile no. cannot be empty!';
                    if (!enteredMN.startsWith("+"))
                      return 'Invalid Mobile no! Prefix with valid country code. (e.g +91 for India)';
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context)
                        .requestFocus(_guestAllowanceFocusNode);
                  },
                  onSaved: (val) {
                    _processingGuest = Guest(
                      gName: _processingGuest.gName,
                      gMobileNumber: val,
                      gEmailID: _processingGuest.gEmailID,
                      gOrg: _processingGuest.gOrg,
                      gAllowance: _processingGuest.gAllowance,
                      gGender: _processingGuest.gGender,
                      gEventID: _processingGuest.gEventID,
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                child: TextFormField(
                  initialValue: '1'.toString(),
                  focusNode: _guestAllowanceFocusNode,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Allowance',
                    labelStyle: GoogleFonts.notoSans(),
                    prefixIcon: Icon(Icons.people,color: Colors.pink,),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val.isEmpty) return 'Allowances can\'t be empty';
                    if (int.parse(val) == 0) return 'Allowance can\'t be 0';
                  },
                  onSaved: (val) {
                    _processingGuest = Guest(
                      gName: _processingGuest.gName,
                      gMobileNumber: _processingGuest.gMobileNumber,
                      gEmailID: _processingGuest.gEmailID,
                      gOrg: _processingGuest.gOrg,
                      gAllowance: int.parse(val),
                      gGender: _processingGuest.gGender,
                      gEventID: _processingGuest.gEventID,
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                
                    child :Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Female',
                            style: TextStyle(
                                fontWeight: _switchStateGender
                                    ? FontWeight.w300
                                    : FontWeight.w600),
                          ),
                          Switch(
                              inactiveThumbColor: Colors.pink,
                              value: _switchStateGender,
                              onChanged: (val) {
                                _switchToggleGender(val);
                              }),
                          Text(
                            'Male',
                            style: TextStyle(
                                fontWeight: _switchStateGender
                                    ? FontWeight.w600
                                    : FontWeight.w300),
                          )
                        ],
                      ),
                    ),
                    
                  
              )
            ],
          ),
        ),
      ),
    );
  }
}
