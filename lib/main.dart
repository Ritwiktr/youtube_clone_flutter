import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:you_tube/screens/home_screen.dart';
import 'auth_state.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zrkpidgckamhwgthlwlb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpya3BpZGdja2FtaHdndGhsd2xiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTkzOTE1NjUsImV4cCI6MjAzNDk2NzU2NX0.TMPZI0Xq5JFvfr0RUKayMtoTv6WbYAUfuU3Zu8iUkMM',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Clone',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthStatee(), // Use AuthState as a widget, not a function
      routes: {
        '/profile': (context) => ProfileScreen(),
        '/home' : (context) => HomeScreen(),
      },
    );
  }
}