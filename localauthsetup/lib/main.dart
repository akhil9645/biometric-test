import 'dart:io';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as local_auth_error;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}

// Initial Authentication Screen
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _localAuthentication = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    checkFaceIDSupport();
    _authenticateUser();
  }

  Future<void> checkFaceIDSupport() async {
    final LocalAuthentication localAuth = LocalAuthentication();
    List<BiometricType> availableBiometrics;

    try {
      availableBiometrics = await localAuth.getAvailableBiometrics();
      print("Available Bio: $availableBiometrics");
    } on PlatformException catch (e) {
      print("Error checking biometrics: $e");
      return;
    }

    if (Platform.isIOS && availableBiometrics.contains(BiometricType.face)) {
      print("Face ID is available on this device.");
    } else {
      print("Face ID is not available on this device.");
    }
  }

  Future<void> _authenticateUser() async {
    bool isAuthorized = false;
    try {
      isAuthorized = await _localAuthentication.authenticate(
        localizedReason: "Please authenticate to proceed",
        options: const AuthenticationOptions(
            biometricOnly: false, useErrorDialogs: true, stickyAuth: false),
      );
    } on PlatformException catch (exception) {
      if (exception.code == local_auth_error.notAvailable ||
          exception.code == local_auth_error.passcodeNotSet ||
          exception.code == local_auth_error.notEnrolled) {
        // Handle cases where biometrics are unavailable.
      }
    }

    if (!mounted) return;

    if (isAuthorized) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                const MyHomePage(title: 'Flutter Demo Home Page')),
      );
    } else {
      // Handle failed authentication if needed.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Authenticating...")
          ],
        ),
      ),
    );
  }
}

// Your main app's home page
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$_counter',
                style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
