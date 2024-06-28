import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _username = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
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
                      height: 200,
                    ),
                    SizedBox(height: 24),
                    _buildTextField(
                      label: 'Username',
                      hint: 'Enter your username',
                      icon: Icons.person,
                      onSaved: (value) => _username = value!,
                    ),
                    SizedBox(height: 16),
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
                    SizedBox(height: 16),
                    _buildTextField(
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      icon: Icons.lock_outline,
                      onSaved: (value) => _confirmPassword = value!,
                      isPassword: true,
                      isConfirmPassword: true,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Sign Up',
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
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                              color: Colors.red.shade300,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
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
    bool isConfirmPassword = false,
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
        suffixIcon: isPassword || isConfirmPassword
            ? IconButton(
          icon: Icon(
            (isPassword ? _isPasswordVisible : _isConfirmPasswordVisible)
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.red.shade300,
          ),
          onPressed: () {
            setState(() {
              if (isPassword) {
                _isPasswordVisible = !_isPasswordVisible;
              } else {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              }
            });
          },
        )
            : null,
        filled: true,
        fillColor: Colors.black54,
      ),
      style: TextStyle(color: Colors.white),
      obscureText: (isPassword && !_isPasswordVisible) ||
          (isConfirmPassword && !_isConfirmPasswordVisible),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (isConfirmPassword && value != _password) {
          return 'Passwords do not match';
        }
        return null;
      },
      onSaved: onSaved,
      onChanged: (value) {
        if (isPassword) {
          _password = value;
        }
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: _email,
          password: _password,
          data: {'username': _username}, // Add this line
        );

        if (response.user != null) {
          // Create user profile
          await Supabase.instance.client.from('profiles').insert({
            'user_id': response.user!.id,
            'username': _username,
          });

          // Update user's display name
          await Supabase.instance.client.auth.updateUser(
            UserAttributes(
              data: {'username': _username},
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign Up Successful! Please check your email to confirm your account.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          _showErrorSnackBar('Sign Up failed. Please try again.');
        }
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