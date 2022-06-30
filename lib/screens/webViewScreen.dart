import 'package:flutter/material.dart';
import 'package:flutter_sendbird_fcm/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String header;
  WebViewScreen({Key? key, required this.url, required this.header})
      : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool isLoading = true;
  late WebViewController controller;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await controller.canGoBack()) {
          controller.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: primaryColor,
          centerTitle: true,
          title: Text(widget.header,
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        body: Stack(
          children: [
            WebView(
              onPageFinished: (finished) {
                if (mounted)
                  setState(() {
                    isLoading = false;
                  });
              },
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (controller) {
                this.controller = controller;
              },
            ),
            Visibility(
              visible: isLoading,
              child: new Center(
                  child: Card(
                elevation: 10,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: CircleAvatar(
                    child: Container(
                      height: 90,
                      width: 90,
                      child: CircularProgressIndicator(
                        color: kSecondaryColor,
                        strokeWidth: 3,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    radius: 35,
                    backgroundImage: AssetImage("assets/appLogo1.png")),
              )),
            )
          ],
        ),
      ),
    );
  }
}
