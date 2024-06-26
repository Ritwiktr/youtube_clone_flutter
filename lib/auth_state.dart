import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

class AuthStatee extends StatefulWidget {
  const AuthStatee({Key? key}) : super(key: key);

  @override
  _AuthStateeState createState() => _AuthStateeState();
}

class _AuthStateeState extends State<AuthStatee> {
  User? _user;

  @override
  void initState() {
    _user = Supabase.instance.client.auth.currentUser;
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {
        _user = data.session?.user;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _user == null ? LoginScreen() : HomeScreen();
  }
}