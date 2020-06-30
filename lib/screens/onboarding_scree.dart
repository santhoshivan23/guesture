import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guesture/screens/auth_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.1, 0.4, 0.7, 0.9],
              colors: [
                // Color.fromRGBO(75, 0, 130, 1),
                // Color.fromRGBO(75, 0, 150, 1),
                // Color.fromRGBO(75, 0, 170, 1),
                // Color.fromRGBO(100, 0, 190, 1),
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
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
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                      child: Text('Guesture',
                          style: GoogleFonts.pacifico(
                              color: Colors.deepPurple, fontSize: 40))),
                ),
                Container(
                  height: 600,
                  child: PageView(
                    physics: BouncingScrollPhysics(),
                    controller: _pageController,
                    children: [
                      buildSlide(
                          title: "This is the title",
                          caption:
                              'This is the place for description. It should describe the title in brief. This is the place for description. It should describe the title in brief',
                          path: 'assets/illustrations/i1.jpg'),
                      buildSlide(
                          title: "This is the title",
                          caption:
                              'This is the place for description. It should describe the title in brief. This is the place for description. It should describe the title in brief',
                          path: 'assets/illustrations/i2.png'),
                      buildSlide(
                          title: "This is the title",
                          caption:
                              'This is the place for description. It should describe the title in brief. This is the place for description. It should describe the title in brief',
                          path: 'assets/illustrations/i3.png'),
                      buildSlide(
                          title: "This is the title",
                          caption:
                              'This is the place for description. It should describe the title in brief. This is the place for description. It should describe the title in brief',
                          path: 'assets/illustrations/i6.png'),
                      buildSlide(
                          title: "This is the title",
                          caption:
                              'This is the place for description. It should describe the title in brief. This is the place for description. It should describe the title in brief',
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
      bottomSheet: _currentPage == _totalPages - 1
          ? Container(
              height: 55,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(30),
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
    return Padding(
      padding: const EdgeInsets.all(30.0),
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
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Text(
              title,
              style: TextStyle(
                  color: Color.fromRGBO(255, 79, 90, 1),
                  fontWeight: FontWeight.w600),
            )),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                caption,
                style: TextStyle(
                  color: Colors.indigo,
                ),
              )),
        ],
      ),
    );
  }
}
