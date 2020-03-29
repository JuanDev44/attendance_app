import 'package:attendanceapp/logged_in/home.dart';
import 'package:attendanceapp/logged_in/teacher/batches.dart';
import 'package:attendanceapp/logged_in/teacher/students.dart';
import 'package:attendanceapp/logged_out/methods/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:attendanceapp/logged_out/authentication.dart';
import 'package:attendanceapp/logged_out/methods/log_in.dart';
import 'package:provider/provider.dart';
import 'package:attendanceapp/classes/account.dart';

void main() => runApp(LoginApp());

class LoginApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
      value: User().account,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Attendance App ',
        home: Authentication(),
        routes: {
          '/login': (context) => Login(),
          '/register': (context) => Register(),
          '/batches' : (context) => Batches(),
          '/enrolledStudents' : (context) => EnrolledStudents(),
          '/home' : (context) => Home(),
          '/authentication': (context) => Authentication(),
        },
      ),
    );
  }
}

