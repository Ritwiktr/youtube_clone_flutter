import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: NetworkImage('https://source.unsplash.com/random/1080x1920?dark'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/youtube_logo.png',
                      height: 300,
                    ),
                    SizedBox(height: 24),
                    _buildTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email,
                      onSaved: (value) => _email = value!,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock,
                      onSaved: (value) => _password = value!,
                      isPassword: true,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Sign In',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      onPressed: _isLoading ? null : _submitForm,
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      onPressed: () {
                        // Handle forgot password
                      },
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              color: Colors.red.shade300,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => SignupScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required Function(String?) onSaved,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white54),
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.red.shade300),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.red.shade300,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        )
            : null,
        filled: true,
        fillColor: Colors.black54,
      ),
      style: TextStyle(color: Colors.white),
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      onSaved: onSaved,
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: _email,
          password: _password,
        );

        if (response.user != null) {
          // Fetch user profile
          final profile = await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('user_id', response.user!.id)
              .single();

          if (profile == null) {
            // If profile doesn't exist, create one
            await Supabase.instance.client.from('profiles').insert({
              'user_id': response.user!.id,
              'username': _email.split('@')[0], // Default username
            });
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          _showErrorSnackBar('Login failed. Please try again.');
        }
      } on AuthException catch (error) {
        _showErrorSnackBar('Authentication error: ${error.message}');
      } on PostgrestException catch (error) {
        _showErrorSnackBar('Database error: ${error.message}');
      } catch (error) {
        _showErrorSnackBar('An unexpected error occurred: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}