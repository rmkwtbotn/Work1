// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:flutter_application_1/config/internal_config.dart';
import 'package:flutter_application_1/model/request/customer_login_post_req.dart';
import 'package:flutter_application_1/model/response/customer_login_post_res.dart';
import 'package:flutter_application_1/pages/register.dart';
import 'package:flutter_application_1/pages/showtrip.dart';
import 'package:http/http.dart' as http;

import 'dart:developer' as dev;

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

// ignore: camel_case_types
class _loginPageState extends State<loginPage> {
  String url = '';
  String text = '';
  TextEditingController phoneNoCtl = TextEditingController();
  TextEditingController passNoCtl = TextEditingController();
  //initState คือ function ที่ทำงานหลังจากหน้านี้
  //initState จะทำงานครั้งเดียว
  //จะไม่ทำงานเมื่อเราเรียก setstate
  //ไม่สามารถทำงานเป็น Async function ได้
  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((value) {
      dev.log(API_ENDPOINT); //ไม่แนะนำให้ใช้
      dev.log(value['apiEndpoint']);
      url = value['apiEndpoint'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onDoubleTap: () {
                      dev.log("Image double tab");
                    },
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ],
              ),
            ),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10.0, right: 20, left: 20),
                  child: Text(
                    "หมายเลขโทรศัพท์",
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, right: 20, left: 20),
              child: TextField(
                controller: phoneNoCtl,
                // onChanged: (value) {
                //   phonenumber = value;
                // },
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                ),
              ),
            ),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10.0, right: 20, left: 20),
                  child: Text(
                    "รหัสผ่าน",
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, right: 20, left: 20),
              child: TextField(
                controller: passNoCtl,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, right: 20, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: Reg,
                    child: const Text('ลงทะเบียนใหม่'),
                  ),
                  FilledButton(
                    onPressed: login,
                    child: const Text('เข้าสู่ระบบ'),
                  ),
                ],
              ),
            ),
            Text(text),
          ],
        ),
      ),
    );
  }

  // void Reg() {
  //   log('This is Register button');
  //   setState(() {
  //     text = 'Hello world!!!!!!!';
  //   });
  // }

  // void login() {
  //   log('This is a Login!!!!!!');
  //   setState(() {
  //     text = ('login time ') + (Time.toString());
  //     Time++;
  //   });
  // }

  void login() {
    if (url.isEmpty) {
      setState(() {
        text = "Login failed: API not ready";
      });
      return;
    }

    var data = CustomerLoginPostRequest(
      phone: phoneNoCtl.text,
      password: passNoCtl.text,
    );

    http
        .post(
          Uri.parse('$url/customers/login'),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: customerLoginPostRequestToJson(data),
        )
        .then((response) {
          if (response.statusCode == 200) {
            try {
              var customers = CustomersLoginPostRes.fromJson(
                jsonDecode(response.body),
              );
              dev.log("Customer email: ${customers.customer.email}");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ShowTripPage(cid: customers.customer.idx),
                ),
              );
            } catch (e) {
              dev.log("Error parsing response: $e");
              setState(() {
                text = "Login failed: Error processing response";
              });
            }
          } else if (response.statusCode == 401) {
            setState(() {
              text = "Login failed: Incorrect username or password";
            });
          } else {
            setState(() {
              text = "Login failed: Server error (${response.statusCode})";
            });
          }
        })
        .catchError((error) {
          dev.log("Network error: $error");
          setState(() {
            text = "Login failed: Network error";
          });
        });
  }

  // ignore: non_constant_identifier_names
  void Reg() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }
}
