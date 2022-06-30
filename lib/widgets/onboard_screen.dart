import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sendbird_fcm/constants.dart';
import 'package:flutter_sendbird_fcm/utility/size_config.dart';

class OnBaordScreen extends StatefulWidget {
  @override
  _OnBaordScreenState createState() => _OnBaordScreenState();
}

final _controller = PageController(
  initialPage: 0,
);

int _currentPage = 0;

List<Widget> _pages = [
  Column(
    children: [
      Expanded(
          child: Container(
              width: SizeConfig.screenWidth! * 0.8,
              child: Image.asset('assets/unnamed.png'))),
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text.rich(
          TextSpan(
              text: 'Made with ',
              style: kPageViewTextStyle.copyWith(color: Colors.black),
              children: <InlineSpan>[
                TextSpan(
                  text: 'Flutter',
                  style: kPageViewTextStyle.copyWith(color: primaryColor),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () => Container(),
                )
              ]),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  ),
  Column(
    children: [
      Expanded(
          child: Container(
              width: SizeConfig.screenWidth,
              child: Image.asset('assets/firebase.png'))),
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text.rich(
          TextSpan(
              text: 'Backend : ',
              style: kPageViewTextStyle.copyWith(color: Colors.black),
              children: <InlineSpan>[
                TextSpan(
                  text: 'Firebase',
                  style: kPageViewTextStyle.copyWith(color: primaryColor),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () => Container(),
                )
              ]),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  ),
  Column(
    children: [
      Expanded(
          child: Container(
              width: SizeConfig.screenWidth,
              child: Image.asset('assets/sendbird.png'))),
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text.rich(
          TextSpan(
              text: 'Chat API : ',
              style: kPageViewTextStyle.copyWith(color: Colors.black),
              children: <InlineSpan>[
                TextSpan(
                  text: 'SendBird',
                  style: kPageViewTextStyle.copyWith(color: primaryColor),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () => Container(),
                )
              ]),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  ),
];

class _OnBaordScreenState extends State<OnBaordScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _controller,
            children: _pages,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
        ),
        SizedBox(
          height: 10,
        ),
        DotsIndicator(
          dotsCount: _pages.length,
          position: _currentPage.toDouble(),
          decorator: DotsDecorator(
              size: const Size.square(9.0),
              activeSize: const Size(22.0, 9.0),
              activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              activeColor: primaryColor),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
