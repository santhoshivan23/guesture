import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guesture/screens/auth_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _totalPages = 5;
  final _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _totalPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool active) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: 8.0,
      width: active ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: active ? Colors.deepPurple : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _toPrivacyPolicy() async {
    const url =
        'https://github.com/santhoshivan23/guesture_privacy_policy/blob/master/privacy_policy.txt';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SingleChildScrollView(
                  child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 0.4, 0.7, 0.9],
                colors: [
                
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.white,
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: height * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        child: FlatButton(
                          onPressed: _toPrivacyPolicy,
                          child: Text(
                            'Privacy',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(255, 79, 90, 1),
                                fontSize: 18),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(AuthScreen.routeName);
                          },
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                                color: Color.fromRGBO(255, 79, 90, 1),
                                fontWeight: FontWeight.w500,
                                fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(height * 0.02),
                    child: Center(
                        child: Text('Guesture',
                            style: GoogleFonts.pacifico(
                                color: Colors.deepPurple, fontSize: 40))),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: PageView(
                      physics: BouncingScrollPhysics(),
                      controller: _pageController,
                      children: [
                        buildSlide(
                            title: "Organize events, concerts and workshops!",
                            caption:
                                'Manage your workspace wih ease by providing access controls to Event administrators & organizers.',
                            path: 'assets/illustrations/i1.jpg'),
                        buildSlide(
                            title: "Finance management like never before!",
                            caption:
                                'Get brief analysis of your transactions and control who can see it.',
                            path: 'assets/illustrations/i2.png'),
                        buildSlide(
                            title: "Event Scheduling",
                            caption:
                                'Manage all your events in one place. Schedule your calendar in advance and proceed with ease.',
                            path: 'assets/illustrations/i3.png'),
                        buildSlide(
                            title: "Check-In Guests",
                            caption:
                                'Generate QR based tickets and share them right away to your guests. On the event day, check-in the guests either by scanning the tickets or manually entering their unique ID.',
                            path: 'assets/illustrations/i6.png'),
                        buildSlide(
                            title: "Collaborate & Conquer",
                            caption:
                                'Invite your colleagues to join your workspace by sharing the invite link or send a request right away.',
                            path: 'assets/illustrations/i7.png'),
                      ],
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicator(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: _currentPage == _totalPages - 1
          ? Container(
              height: 55,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(AuthScreen.routeName);
                },
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Get Started!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Padding buildSlide({String path, String title, String caption}) {
        final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.all(height * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.3,
            child: Center(
              child: Image.asset(
                path,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: height * 0.035),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Text(
              title, textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 20,
                  color: Color.fromRGBO(255, 79, 90, 1),
                  fontWeight: FontWeight.w600),
            )),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                caption,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  color: Colors.indigo,
                  fontSize: 14,
                  fontWeight: FontWeight.w500
                ),
              )),
        ],
      ),
    );
  }
}
