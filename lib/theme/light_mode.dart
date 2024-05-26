import 'package:flutter/material.dart';

 ThemeData lightMode = ThemeData(
   colorScheme: ColorScheme.light(
     background: Colors.grey.shade300,
     primary: Colors.grey.shade500,
     secondary: Colors.grey.shade200,
     tertiary: Colors.white,
     inversePrimary: Colors.grey.shade900,
   ),
   textTheme: TextTheme(
     bodyText1: TextStyle(
       color: Color(0xFF0D3D7C),
     ),
   )
 );