import 'dart:math';

import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth.dart';
import '../models/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            child: Image.asset('assets/image1.png', fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 250,
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 6 : 3,
                    child: Container(height: deviceSize.height * 0.5, child: AuthCard()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).logIn(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await Provider.of<Auth>(context, listen: false).signUp(
          _emailController.text,
          _passwordController.text,
        );
      }
      print('hello');
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints: BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "Welcome Back",
                    style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 20),
                  child: Text(
                    "Sign Up to continue",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                    ),
                  ),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: const InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                          }
                        : null,
                  ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child: Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have account ?",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    FlatButton(
                        child: Text(
                          ' ${_authMode == AuthMode.Signup ? 'SIGNUP' : 'Signup'} ',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        onPressed: _switchAuthMode,
                        textColor: Colors.black),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
