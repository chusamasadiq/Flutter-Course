import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttercourse/screen/login_screen.dart';
import 'package:fluttercourse/screen/otpverify_screen.dart';
import 'package:fluttercourse/utils/utils.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({Key? key}) : super(key: key);

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late bool isLoading = false;
  String verID = ' ';
  final TextEditingController _phoneNoController = TextEditingController();
  String countryDial = '+33';

  Future<void> verifyPhone(String phoneNumber) async {
    setState(() {
      isLoading = true;
    });
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        setState(() {
          isLoading = false;
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        Utils.toastMessage(e.message.toString());
        setState(() {
          isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        Utils.toastMessage('OTP has sent to your phone number');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              verId: verID,
              dialCode: countryDial,
              phoneNumber: _phoneNoController.text.toString(),
            ),
          ),
        );
        setState(() {
          verID = verificationId;
          isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (e) {},
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gain Height of the Screen
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(screenHeight * 0.01),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/online-delivery.png',
                scale: 5,
              ),
              Text(
                "Welcome to Delivery app!",
                style: TextStyle(
                  fontSize: screenWidth / 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: screenWidth / 50),
              Text(
                "Create an account today!",
                style: TextStyle(
                  fontSize: screenWidth / 30,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: screenWidth * 0.04),
              IntlPhoneField(
                style: const TextStyle(fontSize: 14),
                controller: _phoneNoController,
                showCountryFlag: true,
                showDropdownIcon: true,
                initialValue: countryDial,
                onCountryChanged: (country) {
                  setState(() {
                    countryDial = "+${country.dialCode}";
                  });
                },
                decoration: const InputDecoration(
                  hintStyle: TextStyle(
                    fontSize: 14,
                  ),
                  hintText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: screenWidth * 0.04),
              SizedBox(
                height: screenWidth * 0.12,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      verifyPhone(countryDial +_phoneNoController.text.toString());
                    }
                  },
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        )
                      : const Text('Send OTP'),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FittedBox(
                    child: Text('Already have an account'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Login'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
