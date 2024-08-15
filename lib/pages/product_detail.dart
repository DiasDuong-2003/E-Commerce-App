import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_app/pages/login.dart';
import 'package:shopping_app/services/consts.dart';
import 'package:shopping_app/services/database.dart';
import 'package:shopping_app/services/shared_prefs.dart';
import 'package:shopping_app/widget/support_widget.dart';

class ProductDetail extends StatefulWidget {
  final String image, name, detail, price;
  ProductDetail(
      {required this.image,
      required this.name,
      required this.detail,
      required this.price});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  String? name, mail, image;

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  Future<void> getthesharedpref() async {
    name = await SharedPreferenceHelper().getUserName();
    mail = await SharedPreferenceHelper().getUserEmail();
    image = await SharedPreferenceHelper().getUserImage();
    setState(() {});
  }

  Future<void> ontheload() async {
    await getthesharedpref();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        margin: EdgeInsets.only(left: 20.0),
                        child: Icon(Icons.arrow_back_outlined))),
                Center(
                  child: Image.network(
                    widget.image,
                    height: 300,
                    width: 300,
                  ),
                )
              ]),
              Container(
                padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.name,
                          style: AppWidget.semiboldTextFieldStyle(),
                        ),
                        Text(
                          "\$" + widget.price,
                          style: TextStyle(
                              color: Color(0xFFfd6f3e),
                              fontSize: 23.0,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Details",
                      style: AppWidget.semiboldTextFieldStyle(),
                    ),
                    SizedBox(height: 10.0),
                    Text(widget.detail),
                    SizedBox(height: 90.0),
                    GestureDetector(
                      onTap: () async {
                        // Check if the user is logged in
                        bool isLoggedIn = await _checkLoginStatus();
                        if (isLoggedIn) {
                          // Proceed with the payment
                          makePayment(widget.price);
                        } else {
                          // Navigate to the login screen
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LogIn())); // Adjust the route as needed
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                            color: Color(0xFFfd6f3e),
                            borderRadius: BorderRadius.circular(10)),
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Text(
                            "Buy Now",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    String? username = await SharedPreferenceHelper().getUserName();
    String? email = await SharedPreferenceHelper().getUserEmail();

    // If either username or email is null, user is not logged in
    return username != null && email != null;
  }

  Future<void> makePayment(String amount) async {
    print("Purchase");
    try {
      String? paymentIntentClientSecret =
          await _createPaymentIntent(amount, "usd");
      if (paymentIntentClientSecret == null) return;
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Duong Duc",
        ),
      );
      await _processPayment();
    } catch (e) {
      print(e);
    }
  }

  Future<String?> _createPaymentIntent(String amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency,
      };
      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": 'application/x-www-form-urlencoded'
          },
        ),
      );
      if (response.data != null) {
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      Map<String, dynamic> orderInfoMap = {
        "Product": widget.name,
        "Price": widget.price,
        "Name": name,
        "Email": mail,
        "Image": image,
        "ProductImage": widget.image,
        "Status": "On the way"
      };
      await DatabaseMethods().orderDetails(orderInfoMap);
    } catch (e) {
      print(e);
    }
  }

  String _calculateAmount(String amount) {
    final calculateamount = int.parse(amount) * 100;
    return calculateamount.toString();
  }
}
