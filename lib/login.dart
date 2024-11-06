import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/supervisor_main.dart';
import 'package:pencatatan_kinerja_ob/employee_pages.dart/employee_main.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/office_helper_pages/office_helper_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage>{
  final _formKey = GlobalKey<FormState>();

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  Future checkLogin() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/check_login.php');
    var request = await http.post(url, body: { 
      "username": username.text,
      "password": password.text,
    });
    return request.body;
  }

  bool isChecking = false;

  late SharedPreferences pref;
  bool obscureText = true;

  Future setLogIn(String role, String id) async {
    pref = await SharedPreferences.getInstance();
    await pref.setBool('status', true);
    await pref.setString('role', role);
    await pref.setString('id', id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            children: [
              Hero(
                tag: 'splash_art',
                child: Image.asset('assets/logo.png')
              ),
              const Text(
                'Office Helper\nTeam Management',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  isDense: false,
                  contentPadding: const EdgeInsets.only(right: 16.0, left: 16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  label: const Text('Employee ID'),
                ),
                controller: username,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty){
                    return 'Please input your Employee ID!';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                obscureText: obscureText,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(right: 16.0, left: 16.0),
                  suffixIcon: IconButton(
                    tooltip: (obscureText)
                    ? 'Show'
                    : 'Hide',
                    splashRadius: 22,
                    onPressed: (){
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    icon: (obscureText)
                    ? const Icon(Icons.visibility_rounded)
                    : const Icon(Icons.visibility_off_rounded),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  label: const Text('Password'),
                ),
                controller: password,
                validator: (value) {
                  if (value == null || value.isEmpty){
                    return 'Please input your password!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20,),
              Center(
                child: ElevatedButton(
                  onPressed: (!isChecking)
                  ? (){
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isChecking = true;
                      });
                      checkLogin().then((value){
                        Map result = jsonDecode(value) as Map;
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(result['title']),
                              content: Text(result['message']),
                              actions: [
                                TextButton(
                                  onPressed: (){
                                    if (result['result'] == 1){
                                      setLogIn(result['role'], username.text);
                                      Navigator.pop(context);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => 
                                          (result['role'] == '1') ? const AdminMain() : 
                                          (result['role'] == '2') ? const OfficeBoyMain() : const EmployeeMain(),
                                        ),
                                      );
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        isChecking = false;
                                      });
                                    }
                                  },
                                  child: const Text('Ok')
                                ),
                              ],
                            );
                          },
                        );
                      });
                    }
                  }
                  : null,
                  child: (!isChecking)
                  ? const Text('Login')
                  : const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator()
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}