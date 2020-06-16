import 'package:bubbled_navigation_bar/bubbled_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:guesture/screens/checkin_subscreen.dart';
import 'package:guesture/screens/dashboard_subscreen.dart';
import 'package:guesture/screens/finance_subscreen.dart';
import 'package:guesture/screens/reservations_subscreen.dart';

class EventOverviewScreen extends StatefulWidget {
  static const routeName = '/event-overview';

  @override
  _EventOverviewScreenState createState() => _EventOverviewScreenState();
}

class _EventOverviewScreenState extends State<EventOverviewScreen> {
  int _selectedPageIndex = 0;

  PageController _pageController;
  MenuPositionController _menuPositionController;
  bool _userPageDragging = false;

  @override
  void initState() {
    _pageController = PageController(
      initialPage: 0,
      keepPage: false,
      viewportFraction: 1,
    );

    _menuPositionController = MenuPositionController(initPosition: 0);

    _pageController.addListener(_handlePageChange);
    super.initState();
  }

  void _handlePageChange() {
    _menuPositionController.absolutePosition = _pageController.page;
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void checkUserDragging(ScrollNotification scrollNotification) {
    if (scrollNotification is UserScrollNotification &&
        scrollNotification.direction != ScrollDirection.idle)
      _userPageDragging = true;
    else if (scrollNotification is ScrollEndNotification)
      _userPageDragging = false;
    if (_userPageDragging)
      _menuPositionController.findNearestTarget(_pageController.page);
  }

  @override
  Widget build(BuildContext context) {
    final eventData = ModalRoute.of(context).settings.arguments as Map<String,dynamic>;
    final eventID = eventData['eventID'];
    final eventName = eventData['eventName']; 
    final bool isAdmin = eventData['isAdmin'];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:  Text(eventName),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.deepPurple.withOpacity(0.5)]),
          ),
        ),
       
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          checkUserDragging(scrollNotification);
        },
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) {},
          children: <Widget>[
            DashboardSubScreen(eventID: eventID,),
            ReservationsSubScreen(eventID: eventID,isAdmin: isAdmin,),
            CheckinSubscreen(eventID: eventID),
            FinanceSubscreen(eventID: eventID,isAdmin: isAdmin,),
          ],
        ),
      ),
      
      bottomNavigationBar: BubbledNavigationBar(
        controller: _menuPositionController,
        onTap: (index) {
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 250),
              curve: Curves.easeInOutQuad);
        },
        initialIndex: 0,
        animationDuration: Duration(milliseconds: 250),
        defaultBubbleColor: Colors.indigo,
        items: <BubbledNavigationBarItem>[
          BubbledNavigationBarItem(
            icon: Icon(
              Icons.dashboard,
              color: Colors.redAccent,
            ),
            activeIcon: Icon(
              Icons.dashboard,
              color: Colors.white,
            ),
            title: Text(
              'Overview',
              style: TextStyle(color: Colors.white),
            ),
          ),
          BubbledNavigationBarItem(
            icon: Icon(
              Icons.people,
              color: Colors.blue,
            ),
            activeIcon: Icon(
              Icons.people,
              color: Colors.white,
            ),
            title: Text(
              'Reservations',
              style: TextStyle(color: Colors.white),
            ),
          ),
          BubbledNavigationBarItem(
            icon: Icon(
              Icons.send,
              color: Colors.pink,
            ),
            activeIcon: Icon(
              Icons.send,
              color: Colors.white,
            ),
            title: Text(
              'Check-In',
              style: TextStyle(color: Colors.white),
            ),
          ),
          BubbledNavigationBarItem(
            icon: Icon(
              Icons.monetization_on,
              color: Colors.purple,
            ),
            activeIcon: Icon(
              Icons.monetization_on,
              color: Colors.white,
            ),
            title: Text(
              'Finance',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
