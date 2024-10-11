import 'package:lanka_health_care/components/my_button.dart';
import 'package:lanka_health_care/components/my_textfield.dart';
import 'package:lanka_health_care/helper/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanka_health_care/services/database.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final DatabaseService databaseService = DatabaseService();
  //text controllers
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController userTypeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  //register method
  Future<void> registerUser() async {
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

    //make sure passwords match
    if (passwordController.text != confirmPasswordController.text) {
      //pop loading circle
      Navigator.pop(context);

      //show error messsage to the user
      displayMessageToUser('Password does not match', context);
    }

    //if passwords do match
    else {
      //try creating the user
      try {
        if (!mounted) return;
        //create the user
        UserCredential? userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        //store the user data in the database
        await DatabaseService().createUser(
          userCredential.user!.uid,
          userTypeController.text,
          emailController.text,
          firstnameController.text,
          lastnameController.text,
          specializationController.text,
        );

        //pop loading circle
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
      } on FirebaseAuthException catch (e) {
        //pop loading circle
        Navigator.pop(context);

        //display the error message to the user
        displayMessageToUser(e.code, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                Image.asset(
                  'lib/resources/images/logo.png',
                  width: 200,
                ),

                const SizedBox(height: 30),

                //sign up text
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 50),

                //user type textfield
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
                        DropdownMenuItem(
                            value: 'doctor', child: Text('Doctor')),
                        DropdownMenuItem(
                            value: 'healthcaremanager',
                            child: Text('Healthcare Manager')),
                        DropdownMenuItem(
                            value: 'healthcareprovider',
                            child: Text('Healthcare Provider')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          userTypeController.text = value.toString();
                        });
                      }),
                ),

                const SizedBox(height: 10),

                //specialization textfield
                if (userTypeController.text == 'doctor' ||
                    userTypeController.text == 'healthcareprovider')
                  MyTextField(
                    hintText: 'Specialization',
                    obscureText: false,
                    controller: specializationController,
                    width: 500,
                  ),

                const SizedBox(height: 10),

                //username textfield
                MyTextField(
                  hintText: 'First Name',
                  obscureText: false,
                  controller: firstnameController,
                  width: 500,
                ),

                const SizedBox(height: 10),

                //lastname textfield
                MyTextField(
                  hintText: 'Last Name',
                  obscureText: false,
                  controller: lastnameController,
                  width: 500,
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

                //confirmpassword textfield
                MyTextField(
                  hintText: 'Confirm Password',
                  obscureText: true,
                  controller: confirmPasswordController,
                  width: 500,
                ),

                const SizedBox(height: 30),

                //sign up button
                MyButton(
                  text: 'Sign Up',
                  onTap: registerUser,
                  width: 500,
                ),

                const SizedBox(height: 10),

                //Already have an account? Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ',
                        style: TextStyle(
                          color: Colors.black,
                        )),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
