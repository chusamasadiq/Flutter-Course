import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttercourse/models/cart.dart' as model;
import '../utils/utils.dart';

class AuthMethods {
  // Firebase Auth Instance
  final _auth = FirebaseAuth.instance;

  // Firebase Firestore Instance
  final _firestore = FirebaseFirestore.instance;

  // Sign Up User Function
  Future<String> signUpUser({
    required String email,
    required String password,
    required String phoneNo,
    required String username,
  }) async {
    String response;
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.toString(),
        password: password.toString(),
      );

      // SharedPreferences Instance
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      //  Storing email in Shared Preferences
      sharedPreferences.setString('email', email.toString());

      // Store Data into Cloud Firestore
      _firestore.collection('users').doc(_auth.currentUser?.uid).set({
        'username': username.toString(),
        'email': email.toString(),
        'phoneNo': phoneNo.toString(),
      });

      response = 'success';
    } on FirebaseAuthException catch (ex) {
      return response = (ex.message.toString());
    }
    return response;
  }

  // SignIn User Function
  Future<String> signInUser({
    required String email,
    required String password,
  }) async {
    String response;
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.toString(),
        password: password.toString(),
      );

      // SharedPreferences Instance
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      //  Storing email in Shared Preferences
      sharedPreferences.setString('email', email.toString());

      response = 'success';
    } on FirebaseAuthException catch (ex) {
      return response = (ex.message.toString());
    }
    return response;
  }

  // Forgot Password Function
  Future<String> forgotPassword({
    required String email,
  }) async {
    String response;
    try {
      await _auth.sendPasswordResetEmail(
        email: email.toString(),
      );
      response = 'success';
    } on FirebaseAuthException catch (ex) {
      return response = (ex.message.toString());
    }
    return response;
  }

  Future<String> orderNow({required String foodID, required String foodName, required int foodPrice, required int quantity, required String foodImage, required int deliveryCharges, required int foodTotalPrice,
  }) async {
    String response;

    // Add Data in Firestore using Cart Model
    try {
      model.Cart cart = model.Cart(
        foodID: foodID,
        foodName: foodName,
        foodPrice: foodPrice,
        quantity: quantity,
        foodImage: foodImage,
        deliveryCharges: deliveryCharges,
        foodTotalPrice: foodTotalPrice,
      );
      User currentUser = _auth.currentUser!;
      await _firestore.collection('users').doc(currentUser.uid).collection('orders').doc().set(cart.toJson());
      response = 'success';
    } on FirebaseAuthException catch (ex) {
      response = ex.message.toString();
    }
    return response;
  }

  // Send Order Details
  void sendOrderDetails({required String foodName, required int foodPrice, required int quantity, required int deliveryCharges, required int foodTotalPrice,
  }) async {
    String username = 'usamasadiqdev@gmail.com';
    String password = 'bpzjbfrttivgrbwu';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'FastDelivery')
      ..recipients.add(_auth.currentUser?.email)
      ..subject = 'Order Details'
      ..text = 'Food Name: $foodName\n'
          'Food Price: $foodPrice\n'
          'Quantity: $quantity\n'
          'Delivery Charges: $deliveryCharges\n'
          'Food Total Price: $foodTotalPrice';

    try {
      await send(message, smtpServer);
      Utils.toastMessage('Order details sent to your email');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // Logout Function
  void logout() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.remove('email');
    _auth.signOut();
  }
}
