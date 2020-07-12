import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:guesture/models/event.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:guesture/services/admob.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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

  InterstitialAd _interstitialAd;
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    
    // testDevices: <String>[
    //   'FDEA28183E85C0246AFC385DD539453C',
    //   '08F97A3F50B1A9056804BEBB2AB80902',
    //   '4A6014F8ED0B533145242BE3600EC087'


    // ],
    keywords: [
      'event',
      'management',
      'hotels',
      'bookings',
      'tour',
      'flights',
      'shopping',
      'trains',
      'government',
      'cars',
      'travel'
    ],
  );
  final ams = AdMobService();
  var loading = false;
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
        link: Uri.parse(
            'https://guesture.page.link/workspace?wID=$eventID&role=$role'),
        androidParameters: AndroidParameters(
          packageName: 'com.santhoshivan.guesture',
          minimumVersion: 0,
        ));
    final Uri inviteUrl =
        await parameters.buildShortLink().then((value) => value.shortUrl);

    return inviteUrl.toString();
  }

  Future<void> _fabClicked(bool isModify, String oldID) async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    await _interstitialAd.show(
          anchorType: AnchorType.bottom,
          anchorOffset: 0.0,
          horizontalCenterOffset: 0.0);
    if (!isModify) {
      _processingEvent.eventID = randomAlphaNumeric(5);
      
      Navigator.of(context).pop();
      _processingEvent.inviteLinkA =
          await _createInviteLink(_processingEvent.eventID, 'admin');
      _processingEvent.inviteLinkO =
          await _createInviteLink(_processingEvent.eventID, 'org');

      await GuestureDB.addEvent(_processingEvent);
    } else {
      _processingEvent.eventID = oldID;
      Navigator.of(context).pop();
      await GuestureDB.modifyEvent(_processingEvent);
    }
  }

  @override
  void initState() {
    _interstitialAd = getInterstitalAd();
    _interstitialAd..load();
    super.initState();
  }

  InterstitialAd getInterstitalAd() {
    return InterstitialAd(
        adUnitId: ams.getInterstitialAdId(),
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print(event);
        });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final gUser = args['gUser'];
    final isModify = args['isModify'];

    final eventData = args['eventData'] as Event;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(!isModify ? 'Add a new event' : '${eventData.eventName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () => isModify
                ? _fabClicked(isModify, eventData.eventID)
                : _fabClicked(isModify, null),
          ),
        ],
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
                  initialValue: isModify ? eventData.eventName : null,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      MdiIcons.pen,
                      color: Colors.pink,
                    ),
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
                    if(enteredEvent.length >21)
                      return "Event Name is too long! (Max 20 chars) ";
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: DateTimeField(
                  validator: (DateTime dt) {
                    if(dt == null)
                    return "This is a required field";
                    return null;
                  },
                  resetIcon: Icon(MdiIcons.update),
                  initialValue: isModify ? eventData.startDate : null,
                  format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                  onShowPicker: (context, currentValue) async {
                    final date = await showDatePicker(
                      
                        context: context,
                        initialDate: currentValue ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030));
                    if (date != null) {
                     
                      final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()));
                    
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
                    prefixIcon: Icon(
                      MdiIcons.calendar,
                      color: Colors.pink,
                    ),
                    labelText: 'Starting date and time',
                    labelStyle: GoogleFonts.notoSans(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  initialValue: isModify ? eventData.location : null,
                  focusNode: _locationFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_ticketPriceFocusNode);
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      MdiIcons.googleMaps,
                      color: Colors.pink,
                    ),
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
                  initialValue:
                      isModify ? eventData.ticketPrice.toString() : null,
                  focusNode: _ticketPriceFocusNode,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      MdiIcons.cash,
                      color: Colors.pink,
                    ),
                    labelText: 'Ticket Price',
                    labelStyle: GoogleFonts.notoSans(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (enteredTP) {
                    if (enteredTP.isEmpty)
                      return 'Ticket Price cannot be empty!';
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
