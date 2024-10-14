import 'package:lanka_health_care/components/my_button.dart';
import 'package:lanka_health_care/components/my_textfield.dart';
import 'package:lanka_health_care/helper/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

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
      displayMessageToUser(AppStrings.pwnotmatch, context);
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
        if (userType == AppStrings.doctor) {
          //navigate to doctor dashboard
          Navigator.pushNamed(context, '/doctorDashboard');
        } else if (userType == AppStrings.healthcaremanager) {
          //navigate to healthcare manager dashboard
          Navigator.pushNamed(context, '/healthcareManagerDashboard');
        } else if (userType == AppStrings.healthcareprovider) {
          //navigate to healthcare provider dashboard
          Navigator.pushNamed(context, '/healthcareProviderDashboard');
        } else {
          //display error if user type is not selected
          displayMessageToUser(AppStrings.notvalidusertype , context);
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
                  AppStrings.signup,
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
                      hint: const Text(AppStrings.usertypeselection),
                      items: const [
                        DropdownMenuItem(
                            value: AppStrings.doctor, child: Text(AppStrings.doctorLabel)),
                        DropdownMenuItem(
                            value: AppStrings.healthcaremanager,
                            child: Text(AppStrings.healthCareManagerLabel)),
                        DropdownMenuItem(
                            value: AppStrings.healthcareprovider,
                            child: Text(AppStrings.healthCareProviderLabel)),
                      ],
                      onChanged: (value) {
                        setState(() {
                          userTypeController.text = value.toString();
                        });
                      }),
                ),

                const SizedBox(height: 10),

                //specialization textfield
                if (userTypeController.text == AppStrings.doctor||
                    userTypeController.text == AppStrings.healthcareprovider)
                  MyTextField(
                    hintText: AppStrings.specialization,
                    obscureText: false,
                    controller: specializationController,
                    width: 500,
                  ),

                const SizedBox(height: 10),

                //username textfield
                MyTextField(
                  hintText: AppStrings.loginFirstName,
                  obscureText: false,
                  controller: firstnameController,
                  width: 500,
                ),

                const SizedBox(height: 10),

                //lastname textfield
                MyTextField(
                  hintText: AppStrings.loginLastName,
                  obscureText: false,
                  controller: lastnameController,
                  width: 500,
                ),

                const SizedBox(height: 10),

                //email textfield
                MyTextField(
                  hintText: AppStrings.loginEmail,
                  obscureText: false,
                  controller: emailController,
                  width: 500,
                ),

                const SizedBox(height: 10),

                //password textfield
                MyTextField(
                  hintText: AppStrings.loginPassword,
                  obscureText: true,
                  controller: passwordController,
                  width: 500,
                ),

                const SizedBox(height: 10),

                //confirmpassword textfield
                MyTextField(
                  hintText: AppStrings.loginConfirmPassword,
                  obscureText: true,
                  controller: confirmPasswordController,
                  width: 500,
                ),

                const SizedBox(height: 30),

                //sign up button
                MyButton(
                  text: AppStrings.signup,
                  onTap: registerUser,
                  width: 500,
                ),

                const SizedBox(height: 10),

                //Already have an account? Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(AppStrings.loginhaveacc,
                        style: TextStyle(
                          color: Colors.black,
                        )),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        AppStrings.signin,
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
