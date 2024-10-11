import 'package:lanka_health_care/components/my_button.dart';
import 'package:lanka_health_care/components/my_textfield.dart';
import 'package:lanka_health_care/helper/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanka_health_care/services/database.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controllers
  final TextEditingController userTypeController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  //login method
  void login() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 250, 230, 35)),
        ),
      ),
    );

    //try sign in
    try {
      //get user type
      Map<String, dynamic> user = await DatabaseService()
          .getUser(emailController.text, userTypeController.text);

      if (!mounted) return;

      if (user.isEmpty) {
        //pop the loading circle
        Navigator.pop(context);
        //display error message
        displayMessageToUser('User not found', context);
      } else {
        //sign in the user
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        if (!mounted) return;

        //pop the loading circle
        Navigator.pop(context);

        //verify user type
        String userType = userTypeController.text;
        if (userType == 'doctor') {
          //navigate to doctor dashboard
          Navigator.pushNamed(context, '/doctorDashboard');
        } else if (userType == 'healthcaremanager') {
          //navigate to healthcare manager dashboard
          Navigator.pushNamed(context, '/healthcareManagerDashboard');
        } else if (userType == 'healthcareprovider') {
          //navigate to healthcare provider dashboard
          Navigator.pushNamed(context, '/healthcareProviderDashboard');
        } else {
          //display error if user type is not selected
          displayMessageToUser('Please select a valid user type', context);
        }
      }
    } catch (e) {
      if (mounted) {
        //pop the loading circle in case of error
        Navigator.pop(context);
        //display error message
        displayMessageToUser(e.toString(), context);
      }
    }
  }

  //Forgot password method
  void forgotPassword() async {
    String email = emailController.text.trim();

    if (email.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        //Display success message
        displayMessageToUser('Registration success', context);
      } on FirebaseAuthException catch (e) {
        //Display error message
        displayMessageToUser(e.code, context);
      }
    } else {
      //Display error if email is empty
      displayMessageToUser('Error email empty', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/resources/images/logo.png',
                width: 200,
              ),
              const SizedBox(height: 30),
              //sign in text
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: 500,
                child: DropdownButtonFormField(
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    hint: const Text('Select User Type'),
                    items: const [
                      DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                      DropdownMenuItem(
                          value: 'healthcaremanager',
                          child: Text('Healthcare Manager')),
                      DropdownMenuItem(
                          value: 'healthcareprovider',
                          child: Text('Healthcare Provider')),
                    ],
                    onChanged: (value) {
                      userTypeController.text = value.toString();
                    }),
              ),

              const SizedBox(height: 10),

              //email textfield
              MyTextField(
                hintText: 'Email',
                obscureText: false,
                controller: emailController,
                width: 500,
              ),

              const SizedBox(height: 10),

              //password textfield
              MyTextField(
                hintText: 'Password',
                obscureText: true,
                controller: passwordController,
                width: 500,
              ),

              const SizedBox(height: 10),

              //forgot password
              GestureDetector(
                onTap: forgotPassword,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),

              const SizedBox(height: 30),

              //sign in button
              MyButton(
                text: 'Sign In',
                onTap: login,
                width: 500,
              ),

              const SizedBox(height: 10),

              //Don't have an account? Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account? ',
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
