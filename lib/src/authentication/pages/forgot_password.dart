import 'package:callup247/main.dart';
import 'package:callup247/src/authentication/pages/user_login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../../responsive_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  // 01 - use case check network

  Future<bool> _checkInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 02 - use case change user's password

  Future<void> _changePassword() async {
    final newpassword = _passwordController.text.trim();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await supabase.auth.updateUser(UserAttributes(password: newpassword));
      if (mounted) {
        messenger.showSnackBar(SnackBar(
          content: Text(
            'Password Changed Successfully :)',
            style:
                responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ));
        setState(() {
          loading = false;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => const SignIn()),
        );
      }
    } on PostgrestException catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(
          'Server Error, Please try again in a bit :(',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(
          'Unexpected Error, Please try again in a bit :(',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // init

  @override
  void initState() {
    super.initState();
    _acontroller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Adjust the duration as needed
    )..repeat();
  }

  // dispose

  @override
  void dispose() {
    _acontroller.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  // variables

  late AnimationController _acontroller;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  bool isPasswordConfirmVisible = false;
  bool isPasswordVisible = false;
  var loading = false;

  @override
  // build method
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      RotationTransition(
                        turns:
                            Tween(begin: 0.0, end: 1.0).animate(_acontroller),
                        child: Image.asset(
                          'assets/logo_t.png',
                          height: 75,
                        ),
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),

                      Text(
                        'Reset your Password',
                        style: responsiveTextStyle(context, 20,
                            const Color(0xFF000000), FontWeight.w700),
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
                      // Password

                      TextFormField(
                        controller: _passwordController,
                        cursorColor: const Color(0xFFA6A6A6),
                        style: responsiveTextStyle(context, 16,
                            const Color(0xFFA6A6A6), FontWeight.w500),
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(25, 54, 222,
                                  255), // Background color of the square
                              borderRadius: BorderRadius.circular(
                                  8.0), // Border radius of the square
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: Color(0xFF36DDFF),
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(
                              0xFFFFFFFF), // Background color of the text field
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          hintText: 'Password',
                          hintStyle: responsiveTextStyle(context, 16,
                              const Color(0xFFA6A6A6), FontWeight.w500),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                            child: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFFE2E2E5),
                            ),
                          ),
                        ),
                        obscureText: !isPasswordVisible,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a password';
                          }
                          // Password strength validation criteria
                          const lengthCriteria =
                              8; // Minimum length requirement
                          // final uppercaseCriteria = RegExp(r'[A-Z]');
                          // final lowercaseCriteria = RegExp(r'[a-z]');
                          // final digitCriteria = RegExp(r'[0-9]');
                          // final specialCharCriteria =
                          //     RegExp(r'[!@#$%^&*(),.?":{}|<>]');
                          if (value.length < lengthCriteria) {
                            return 'Password must be at least $lengthCriteria characters long';
                          }
                          // if (!uppercaseCriteria.hasMatch(value) ||
                          //     !lowercaseCriteria.hasMatch(value) ||
                          //     !digitCriteria.hasMatch(value) ||
                          //     !specialCharCriteria.hasMatch(value)) {
                          //   return 'Password must include uppercase, lowercase, digit, and special characters';
                          // }
                          return null;
                        },
                      ),
                      SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.08),

                      // Confirm Password

                      TextFormField(
                        controller: _confirmpasswordController,
                        cursorColor: const Color(0xFFA6A6A6),
                        style: responsiveTextStyle(context, 16,
                            const Color(0xFFA6A6A6), FontWeight.w500),
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(25, 54, 222,
                                  255), // Background color of the square
                              borderRadius: BorderRadius.circular(
                                  8.0), // Border radius of the square
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: Color(0xFF36DDFF),
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(
                              0xFFFFFFFF), // Background color of the text field
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          hintText: 'Confirm your Password',
                          hintStyle: responsiveTextStyle(context, 16,
                              const Color(0xFFA6A6A6), FontWeight.w500),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                isPasswordConfirmVisible =
                                    !isPasswordConfirmVisible;
                              });
                            },
                            child: Icon(
                              isPasswordConfirmVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFFE2E2E5),
                            ),
                          ),
                        ),
                        obscureText: !isPasswordConfirmVisible,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please re-type your password';
                          }
                          // todo: confiirm password validation logic
                          if (value != _passwordController.text) {
                            return 'passwords must match';
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),

                      // action button

                      loading
                          ? const CircularProgressIndicator()
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF36DDFF)),
                                    onPressed: () async {
                                      final messenger =
                                          ScaffoldMessenger.of(context);
                                      // Check network connectivity
                                      bool isConnected =
                                          await _checkInternetConnectivity();
                                      if (!isConnected) {
                                        if (!context.mounted) return;
                                        // Show a snackbar for no network
                                        messenger.showSnackBar(SnackBar(
                                          content: Text(
                                            'No internet connection. Please check your network settings.',
                                            style: responsiveTextStyle(
                                                context,
                                                16,
                                                Colors.black,
                                                FontWeight.bold),
                                          ),
                                          backgroundColor: Colors.red,
                                        ));
                                        return; // Exit the function if there's no network
                                      }
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          loading = true;
                                        });
                                        _changePassword();
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                      child: Text(
                                        'Confirm',
                                        style: responsiveTextStyle(
                                            context,
                                            14,
                                            const Color(0xFF140202),
                                            FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
