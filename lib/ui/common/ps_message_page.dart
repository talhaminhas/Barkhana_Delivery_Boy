



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({
    Key? key,
    required this.message,
  }) : super(key: key);

  final String message;

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MessagePage> {
  @override
  void initState() {
    super.initState();

    // Delay for 2 seconds and then pop the page
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PsColors.mainColor,
      body: Center(
        child: Text(
          widget.message,
          style: TextStyle(fontSize: 24, color: PsColors.white),
        ),
      ),
    );
  }
}