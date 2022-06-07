import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:optimove_flutter_sdk/optimove.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TextEditingController userIdTextController;
  late final TextEditingController emailTextController;

  late final TextEditingController pageTitleTextController;
  late final TextEditingController pageCategoryTextController;

  late final TextEditingController eventNameTextController;

  String optimobileIdentifier = "";
  String optimoveVisitorId = "";
  Map<String, dynamic> eventParams = {};

  @override
  void initState() {
    super.initState();
    getIdentifiers();
    userIdTextController = TextEditingController();
    emailTextController = TextEditingController();

    pageTitleTextController = TextEditingController();
    pageCategoryTextController = TextEditingController();

    eventNameTextController = TextEditingController();
  }

  Future<void> getIdentifiers() async {
    optimobileIdentifier = await Optimove.getCurrentUserIdentifier();
    optimoveVisitorId = await Optimove.getVisitorId();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color.fromARGB(255, 255, 133, 102),
        onPrimary: Colors.white,
        secondary: Colors.pink,
        onSecondary: Colors.pink,
        error: Colors.pink,
        onError: Colors.pink,
        background: Colors.pink,
        onBackground: Colors.pink,
        surface: Colors.pink,
        onSurface: Colors.black,
      )),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Optimove Flutter QA'),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SingleChildScrollView(
            child: Column(
              children: [_userInfoSection(), _getUserIdentitySection(), const SizedBox(height: 8), _getScreenVisitSection(), const SizedBox(height: 8), _getReportEventSection()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _userInfoSection() {
    return Card(
      color: const Color.fromARGB(255, 167, 184, 204),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(alignment: Alignment.centerLeft, child: Text("Current user id: $optimobileIdentifier")),
            const SizedBox(height: 8),
            Container(alignment: Alignment.centerLeft, child: Text("Current visitor id: $optimoveVisitorId")),
          ],
        ),
      ),
    );
  }

  Widget _getUserIdentitySection() {
    return Card(
      color: const Color.fromARGB(255, 167, 184, 204),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
                controller: userIdTextController,
                decoration: const InputDecoration(
                  hintText: 'User id',
                )),
            ElevatedButton(
                style: _getButtonStyle(),
                onPressed: () {
                  Optimove.setUserId(userId: userIdTextController.text);
                  getIdentifiers();
                },
                child: const Text("Set user id")),
            TextField(
                controller: emailTextController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                )),
            ElevatedButton(
                style: _getButtonStyle(),
                onPressed: () {
                  Optimove.setUserEmail(email: emailTextController.text);
                },
                child: const Text("Set email")),
            const SizedBox(height: 8),
            ElevatedButton(
                style: _getButtonStyle(),
                onPressed: () {
                  Optimove.registerUser(userId: userIdTextController.text, email: emailTextController.text);
                  getIdentifiers();
                },
                child: const Text("Register user")),
          ],
        ),
      ),
    );
  }

  Widget _getScreenVisitSection() {
    return Card(
      color: const Color.fromARGB(255, 167, 184, 204),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
                controller: pageTitleTextController,
                decoration: const InputDecoration(
                  hintText: 'Page title',
                )),
            TextField(
                controller: pageCategoryTextController,
                decoration: const InputDecoration(
                  hintText: 'Page category (optional)',
                )),
            ElevatedButton(
                style: _getButtonStyle(),
                onPressed: () {
                  if (pageCategoryTextController.text.isEmpty) {
                    Optimove.reportScreenVisit(screenName: pageTitleTextController.text);
                  } else {
                    Optimove.reportScreenVisit(screenName: pageTitleTextController.text, screenCategory: pageCategoryTextController.text);
                  }
                },
                child: const Text("Report screen visit")),
          ],
        ),
      ),
    );
  }

  Widget _getReportEventSection() {
    return Card(
      color: const Color.fromARGB(255, 167, 184, 204),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
                controller: eventNameTextController,
                decoration: const InputDecoration(
                  hintText: 'Event name',
                )),
            ElevatedButton(
                style: _getButtonStyle(),
                onPressed: () {
                  Optimove.reportEvent(event: eventNameTextController.text);
                },
                child: const Text("Report event")),
          ],
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    return ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))));
  }
}
