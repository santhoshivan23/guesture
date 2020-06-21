import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:guesture/models/event.dart';
import 'package:guesture/models/g_user.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class AddEventScreen extends StatefulWidget {
  static const routeName = './add-event';

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _eventNameFocusNode = FocusNode();
  final _dtFocusNode = FocusNode();
  final _locationFocusNode = FocusNode();
  final _ticketPriceFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  DateTime _pickedDate;
  TimeOfDay _pickedTime;
  var _processingEvent = Event(
    eventName: '',
    location: '',
    startDate: null,
    startTime: null,
    ticketPrice: 0,
  );

  @override
  void dispose() {
    _eventNameFocusNode.dispose();
    _dtFocusNode.dispose();
    _locationFocusNode.dispose();
    _ticketPriceFocusNode.dispose();

    super.dispose();
  }
  Future<String> _createInviteLink(String eventID, String role) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://guesture.page.link',
        link: Uri.parse('https://guesture.page.link/workspace?wID=$eventID&role=$role'),
        androidParameters: AndroidParameters(
          packageName: 'com.santhoshivan.guesture',
          minimumVersion: 0,
        ));
    final Uri inviteUrl = await parameters.buildShortLink().then((value) => value.shortUrl);
    
    return inviteUrl.toString();
  }

  Future<void> _fabClicked() async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    _processingEvent.eventID = randomAlphaNumeric(5);
    _processingEvent.inviteLinkA = await _createInviteLink(_processingEvent.eventID,'admin');
    _processingEvent.inviteLinkO = await _createInviteLink(_processingEvent.eventID,'org');
    Navigator.of(context).pop();
    await GuestureDB.addEvent(_processingEvent);
  }

  @override
  Widget build(BuildContext context) {
    final gUser = ModalRoute.of(context).settings.arguments as GUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Add a new event')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.done),
        onPressed: _fabClicked,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
                  child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  focusNode: _eventNameFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_dtFocusNode);
                  },
                  decoration: InputDecoration(
                    labelText: 'Name of the event',
                    labelStyle: GoogleFonts.notoSans(),
                  ),
                  onSaved: (val) {
                    _processingEvent = Event(
                      eventName: val,
                      uid: gUser.uid,
                      location: _processingEvent.location,
                      startDate: _processingEvent.startDate,
                      startTime: _processingEvent.startTime,
                      ticketPrice: _processingEvent.ticketPrice,
                    );
                  },
                  validator: (enteredEvent) {
                    if (enteredEvent.isEmpty)
                      return 'Event Name cannot be empty!';
                    if (enteredEvent.length < 5)
                      return "Event Name is too short! (Min 5 chars)";
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: DateTimeField(
                  format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                  onShowPicker: (context, currentValue) async {
                    final date = await showDatePicker(
                        context: context,
                        initialDate: currentValue ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030));
                    if (date != null) {
                      _pickedDate = date;
                      final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()));
                      _pickedTime = time;
                      return DateTimeField.combine(date, time);
                    } else
                      return currentValue;
                  },
                  onSaved: (val) {
                    _processingEvent = Event(
                      uid: _processingEvent.uid,
                      eventName: _processingEvent.eventName,
                      location: _processingEvent.location,
                      startDate: val,
                      startTime: TimeOfDay.fromDateTime(val),
                      ticketPrice: _processingEvent.ticketPrice,
                    );
                  },
                  focusNode: _dtFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_locationFocusNode);
                  },
                  decoration: InputDecoration(
                    labelText: 'Starting date and time',
                    labelStyle: GoogleFonts.notoSans(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  focusNode: _locationFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_ticketPriceFocusNode);
                  },
                  decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: GoogleFonts.notoSans(),
                  ),
                  validator: (enteredLocation) {
                    if (enteredLocation.isEmpty)
                      return 'Location cannot be empty!';
                    if (enteredLocation.length < 5)
                      return "Location is too short! (Min 5 chars)";
                    return null;
                  },
                  onSaved: (val) {
                    _processingEvent = Event(
                      uid: _processingEvent.uid,
                      eventName: _processingEvent.eventName,
                      location: val,
                      startDate: _processingEvent.startDate,
                      startTime: _processingEvent.startTime,
                      ticketPrice: _processingEvent.ticketPrice,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  focusNode: _ticketPriceFocusNode,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Ticket Price',
                    labelStyle: GoogleFonts.notoSans(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (enteredTP) {
                    if (enteredTP.isEmpty) return 'Ticket Price cannot be empty!';
                    return null;
                  },
                  onSaved: (val) {
                    _processingEvent = Event(
                      uid: _processingEvent.uid,
                      eventName: _processingEvent.eventName,
                      location: _processingEvent.location,
                      startDate: _processingEvent.startDate,
                      startTime: _processingEvent.startTime,
                      ticketPrice: double.parse(val),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
