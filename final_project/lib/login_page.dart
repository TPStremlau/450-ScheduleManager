import 'package:final_project/sign_in';
import 'package:final_project/text_field.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() {
    // Add authentication logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(
                  Icons.lock,
                  size: 100,
                  color: Colors.teal,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome back to your scheduling assistant!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Forgot password functionality
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                MyButton(onTap: signUserIn)         
              ],
            ),
          ),
        ),
      ),
    );
  }
}