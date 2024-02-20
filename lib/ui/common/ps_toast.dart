import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import '../../config/ps_colors.dart';

class PsToast {
  void showToast(String message, 
                  {Color? backgroundColor, 
                  Color? textColor, 
                  ToastGravity gravity = ToastGravity.BOTTOM, 
                  Toast length = Toast.LENGTH_LONG }) {
    
    backgroundColor ??= PsColors.mainColor;
    textColor ??= PsColors.redColor;


    Fluttertoast.showToast(
        msg: message,
        toastLength: length,
        gravity: gravity,
        timeInSecForIosWeb: 1,
        backgroundColor: backgroundColor,
        textColor: textColor);

  }
}
