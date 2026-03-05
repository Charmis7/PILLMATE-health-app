import 'package:flutter/material.dart';
import '../widget/reusable_widgets.dart';
import 'new_pswd_screen.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        children: [
          const SizedBox(height: 80),
          Image.asset('assets/images/img_10.png', height: 200),
          const SizedBox(height: 30),
          const Text("Enter OTP!", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Enter code sent to your email.", textAlign: TextAlign.center),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [ _otpBox(context), _otpBox(context), _otpBox(context), _otpBox(context) ],
          ),
          const SizedBox(height: 40),
          PrimaryButton(text: "Verify", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePasswordScreen()))),
        ],
      ),
    );
  }

  Widget _otpBox(BuildContext context) {
    return SizedBox(width: 60, child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
            counterText: "", filled: true, fillColor: Colors.white, border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
        )
        )
     )
    );
  }
}