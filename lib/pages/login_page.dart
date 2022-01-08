import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:smart_warehouse_mobile/constants/strings.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Warehouse",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey.shade800),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  headerSection(),
                  textSection(),
                  buttonSection(),
                ],
              ),
      ),
    );
  }

  signIn(String username, password) async {
    Map data = {
      'username': username,
      'password': password,
    };

    dynamic jsonData;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response =
        await http.post(Uri.parse(Strings.urlGetToken), body: data);
    if (response.statusCode == 200) {
      jsonData = json.decode(response.body);
      setState(() {
        _isLoading = false;
        sharedPreferences.setString("token", jsonData['token']);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => HomePage()),
            (Route<dynamic> route) => false);
      });
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
      _isLoading = false;
      _showDialog(context);
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      margin: const EdgeInsets.only(top: 30.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isLoading = true;
          });
          signIn(usernameController.text, passwordController.text);
        },
        style: ElevatedButton.styleFrom(
          primary: const Color(0xFF198754),
        ),
        child: const Text(
          "Zaloguj się",
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Container textSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      margin: const EdgeInsets.only(top: 30.0),
      child: Column(
        children: <Widget>[
          txtUsername("Nazwa użytkownika", Icons.person),
          const SizedBox(height: 30.0),
          txtPassword("Hasło", Icons.password),
        ],
      ),
    );
  }

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  TextFormField txtUsername(String title, IconData icon) {
    return TextFormField(
      controller: usernameController,
      style: const TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        hintText: title,
        hintStyle: const TextStyle(color: Colors.white70),
        icon: Icon(icon, color: Colors.white70),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white70)),
      ),
    );
  }

  TextFormField txtPassword(String title, IconData icon) {
    return TextFormField(
      controller: passwordController,
      style: const TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        hintText: title,
        hintStyle: const TextStyle(color: Colors.white70),
        icon: Icon(icon, color: Colors.white70),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white70)),
      ),
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
    );
  }

  Container headerSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: const Text(
        'Zaloguj się, aby korzystać z aplikacji',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Błąd logowania"),
          content: const Text("Nieprawidłowa nazwa użytkownika lub hasło."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
