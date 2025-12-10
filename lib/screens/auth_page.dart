  import 'package:flutter/material.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:prostart/screens/forget_password_screen.dart';
  import '../services/auth_service.dart';
  import 'admin_home_page.dart';
  import 'main_screen.dart';
  import 'signup_screen.dart';
  import '../utils/utils.dart';


  class AuthPage extends StatefulWidget {
    const AuthPage({super.key});

    @override
    _AuthPageState createState() => _AuthPageState();
  }

  class _AuthPageState extends State<AuthPage> {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    bool isLogin = true;

    Future<void> _signInWithEmail() async {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        _showMessage("Please fill in both fields");
        return;
      }

      Utils.showLoadingDialog(context);

      await Future.delayed(const Duration(milliseconds: 1500));

      try {
        UserCredential userCredential;

        if (isLogin) {
          userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
        } else {
          userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        }

        Utils.hideLoadingDialog(context);

        if (email == "helmi@topadmin.com") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomePage()),
          );
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } catch (e) {
        Utils.hideLoadingDialog(context);
        print("Error during sign-in: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    void _showMessage(String message) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Notification"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff0694df), Color(0xff06234a)],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100.0, left: 50, right: 50),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Welcome to ProStart !",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                ),
                              ),
                              const SizedBox(height: 150),
                              TextField(
                                style: const TextStyle(color: Colors.white),
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    borderSide: BorderSide(width: 2.0, color: Colors.white),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    borderSide: BorderSide(width: 2.0, color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    borderSide: BorderSide(width: 2.0, color: Colors.white),
                                  ),
                                  prefixIcon: Icon(Icons.mail, color: Color(0xffffffff)),
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: Color(0xffffffff), fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                style: const TextStyle(color: Colors.white),
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    borderSide: BorderSide(width: 2.0, color: Colors.white),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    borderSide: BorderSide(width: 2.0, color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    borderSide: BorderSide(width: 2.0, color: Colors.white),
                                  ),
                                  prefixIcon: Icon(Icons.lock, color: Color(0xffffffff)),
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: Color(0xffffffff), fontWeight: FontWeight.bold,),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()),
                                    );
                                  },
                                  child: const Text(
                                    'Forget your password ?',
                                    style: TextStyle(
                                      color: Color(0xffffffff),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 550.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                              color: Colors.white,
                            ),
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 25.0, left: 25.0, bottom: 600.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: _signInWithEmail,
                                    child: Container(
                                      height: 60,
                                      width: 310,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: const LinearGradient(
                                          colors: [Color(0xff0694df), Color(0xff06234a)],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const SignUpScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 60,
                                      width: 310,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: const LinearGradient(
                                          colors: [Color(0xff0694df), Color(0xff06234a)],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Create an account',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "or login with",
                                    style: TextStyle(
                                      color: Color(0xff06234a),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  InkWell(
                                    onTap: () async {
                                      Utils.showLoadingDialog(
                                        context,
                                        animationAsset: 'assets/animations/google_loading.json',
                                      );
                                      User? user = await AuthService().signInWithGoogle();
                                      await Future.delayed(const Duration(seconds: 2));
                                      Utils.hideLoadingDialog(context);

                                      if (user != null) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const HomePage(),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Google Sign-In failed. Please try again.")),
                                        );
                                      }
                                    },
                                    child: Image.asset(
                                      'assets/images/google_icon.png',
                                      width: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
      );
    }
  }