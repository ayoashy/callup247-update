import 'dart:convert';
import 'package:callup247/main.dart';
import 'package:callup247/src/authentication/pages/user_verification.dart';
import 'package:callup247/src/responsive_text_styles.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class ServiceProviderSignUpScreen extends StatefulWidget {
  const ServiceProviderSignUpScreen({super.key});

  @override
  State<ServiceProviderSignUpScreen> createState() =>
      _ServiceProviderSignUpScreenState();
}

class _ServiceProviderSignUpScreenState
    extends State<ServiceProviderSignUpScreen> {
  // 01 - use case pick image

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // 02 - use case upload image

  Future<void> _uploadImage() async {
    final filename = _fullnameController.text.trim();
    try {
      // print('upload image start');
      await supabase.storage.from('avatars').upload(
            filename,
            _image!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      if (mounted) {
        // print('img uploaded');
      }
    } on PostgrestException catch (error) {
      // print('postgres error: ${error.message}');
    } catch (error) {
      // print(error);
    }
  }

  // 03 - use case create user

  Future<void> _createUser(BuildContext context) async {
    final emailaddress = _emailaddressController.text.trim();
    final password = _passwordController.text.trim();
    try {
      // print('create user start');
      setState(() {
        loading = true;
      });
      await supabase.auth.signUp(password: password, email: emailaddress);
      if (mounted) {
        // print('create user success');
      }
    } on PostgrestException catch (error) {
      print(error.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Server Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      setState(() {
        loading = false;
      });
    } catch (error) {
      print(error);
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Unexpected Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        // print('finished');
      }
    }
  }

  // 0? - use case signin user

  Future<void> _signInUser() async {
    final emailaddress = _emailaddressController.text.trim();

    try {
      await supabase.auth.signInWithOtp(
        email: emailaddress,
        emailRedirectTo:
            kIsWeb ? null : 'io.supabase.flutter://signin-callback/',
      );
      if (mounted) {
        // print('success');
      }
    } on PostgrestException catch (error) {
      // print(error.message);
    } catch (error) {
      // print(error);
    } finally {
      if (mounted) {}
    }
  }

  // 04 - use case update profiles table

  Future<void> _updateProfile(BuildContext context) async {
    final fullname = _fullnameController.text.trim();
    final country = countryValue as String;
    final state = stateValue as String;
    final city = cityValue;
    final displaypicture = supabase.storage
        .from('avatars')
        .getPublicUrl(_fullnameController.text.trim());
    final user = supabase.auth.currentUser;
    final details = {
      'id': user!.id,
      'updated_at': DateTime.now().toIso8601String(),
      'full_name': fullname,
      'country': country,
      'state': state,
      'city': city,
      'avatar_url': displaypicture,
      'service_provider': 'TRUE'
    };
    // print('update profile start');
    try {
      await supabase.from('profiles').upsert(details);
      if (mounted) {
        // print('update profile successful');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Welcome to callup247!!',
            style:
                responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ));
      }
    } on PostgrestException catch (error) {
      // print(error.message + 'update profile');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Server Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      setState(() {
        loading = false;
      });
    } catch (error) {
      // print(error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Unexpected Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      setState(() {
        loading = false;
      });
    } finally {
      if (mounted) {
        // print('update profile finished');
        setState(() {
          loading = false;
        });
      }
    }
  }

  // 05 - use case save user information locally

  Future<void> _saveProfileLocally() async {
    final fullname = _fullnameController.text.trim();
    final emailaddress = _emailaddressController.text.trim();
    final country = countryValue as String;
    final state = stateValue as String;
    final city = cityValue;
    final displaypicture = supabase.storage
        .from('avatars')
        .getPublicUrl(_fullnameController.text.trim());

    // Create a map to represent the user's profile data
    final userProfile = {
      'fullname': fullname,
      'email': emailaddress,
      'country': country,
      'state': state,
      'city': city,
      'displaypicture': displaypicture,
      'service_provider': 'TRUE'
    };

    // Encode the map to JSON and save it as a single string
    final jsonString = json.encode(userProfile);

    // Obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

    // Set the JSON string in SharedPreferences
    await prefs.setString('userprofile', jsonString);
  }

  // 05 - use case check network

  Future<bool> _checkInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 06 - variables

  bool isPasswordVisible = false;
  bool isPasswordConfirmVisible = false;
  String? countryValue = "";
  String? stateValue = "";
  String? cityValue = "";
  File? _image;
  final _fullnameController = TextEditingController();
  final _emailaddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  var loading = false;
  final _formKey = GlobalKey<FormState>();
  bool isPasswordReset = false;

// 07 - dispose

  @override
  void dispose() {
    _emailaddressController.dispose();
    _fullnameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 08 - build method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF13CAF1),
        title: Text(
          'Sign Up',
          style:
              responsiveTextStyle(context, 20, Colors.black, FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color(0xFF039fdc),
                Color(0xFF13CAF1),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // full name

                  TextFormField(
                    controller: _fullnameController,
                    cursorColor: Colors.white,
                    textCapitalization: TextCapitalization.words,
                    style: responsiveTextStyle(context, 16, Colors.white, null),
                    decoration: InputDecoration(
                        labelText: 'First & Last Name',
                        labelStyle: responsiveTextStyle(
                            context, 14, Colors.black87, null),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black87))),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your first and last name';
                      } else if (value.split(' ').length < 2) {
                        return 'Please enter both your first and last name';
                      }
                      return null;
                    },
                  ),

                  // email address

                  TextFormField(
                    controller: _emailaddressController,
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.emailAddress,
                    style: responsiveTextStyle(context, 16, Colors.white, null),
                    decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: responsiveTextStyle(
                            context, 14, Colors.black87, null),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black87))),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email address';
                      }
                      // Email address regex pattern for basic validation
                      const emailPattern =
                          r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
                      final regExp = RegExp(emailPattern);
                      if (!regExp.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      // You can add email validation logic here.
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                  // Country Picker

                  CSCPicker(
                    flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                    dropdownDecoration: BoxDecoration(
                        color: const Color(0xFF13CAF1),
                        borderRadius: BorderRadius.circular(6)),
                    disabledDropdownDecoration: BoxDecoration(
                        color: const Color(0xFF039fdc),
                        borderRadius: BorderRadius.circular(6)),
                    selectedItemStyle:
                        responsiveTextStyle(context, 14, Colors.black, null),
                    onCountryChanged: (value) {
                      // Handle the selected country value here.
                      setState(() {
                        // Store the selected country value in a variable.
                        countryValue = value;
                      });
                    },
                    onStateChanged: (value) {
                      // Handle the selected state value here.
                      setState(() {
                        // Store the selected state value in a variable.
                        stateValue = value;
                      });
                    },
                    onCityChanged: (value) {
                      // Handle the selected city value here.
                      setState(() {
                        // Store the selected city value in a variable.
                        cityValue = value;
                      });
                    },
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '-- this information is used to help find service providers close to you :)',
                        style: responsiveTextStyle(
                            context, 8, Colors.blueGrey, null),
                      ),
                    ],
                  ),

                  // Password

                  TextFormField(
                    controller: _passwordController,
                    cursorColor: Colors.white,
                    style: responsiveTextStyle(context, 16, Colors.white, null),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle:
                          responsiveTextStyle(context, 14, Colors.black, null),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87)),
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
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    obscureText: !isPasswordVisible,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a password';
                      }
                      // Password strength validation criteria
                      const lengthCriteria = 8; // Minimum length requirement
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

                  // Confirm Password

                  TextFormField(
                    controller: _confirmpasswordController,
                    cursorColor: Colors.white,
                    style: responsiveTextStyle(context, 16, Colors.white, null),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle:
                          responsiveTextStyle(context, 14, Colors.black, null),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87)),
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
                          color: Colors.black54,
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                  // display picture

                  GestureDetector(
                    onTap: () {
                      _pickImage();
                    },
                    child: Column(
                      children: <Widget>[
                        if (_image != null)
                          Image.file(
                            _image!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          )
                        else
                          const Icon(
                            Icons.camera_alt,
                            size: 100,
                            color: Colors.black54,
                          ),
                        Text(
                          'Add a display pictue :)',
                          style: responsiveTextStyle(
                              context, 14, Colors.black, null),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                  // todo: add terms and conditions document, agreement

                  // sign up button

                  loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF039fdc)),
                          onPressed: () async {
                            // print('test for network');
                            // Check network connectivity
                            bool isConnected =
                                await _checkInternetConnectivity();
                            if (!isConnected) {
                              // Show a snackbar for no network
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  'No internet connection. Please check your network settings.',
                                  style: responsiveTextStyle(context, 16,
                                      Colors.black, FontWeight.bold),
                                ),
                                backgroundColor: Colors.red,
                              ));
                              return; // Exit the function if there's no network
                            }

                            if (_image == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  'Please add a display picture :)',
                                  style: responsiveTextStyle(context, 16,
                                      Colors.black, FontWeight.bold),
                                ),
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }
                            // Add your sign-up logic here.
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });

                              try {
                                // Run _createUser and wait for it to finish
                                await _createUser(context);

                                // Only run _uploadImage if _createUser has finished successfully
                                if (_image != null) {
                                  await _uploadImage();
                                }

                                // Update profile locally and remotely
                                await _saveProfileLocally();
                                await _updateProfile(context);
                                await _signInUser();

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                    'Welcome to callup247!!',
                                    style: responsiveTextStyle(context, 16,
                                        Colors.black, FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.green,
                                ));

                                // Delay and navigate
                                await Future.delayed(
                                    const Duration(seconds: 2));
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        VerificationScreen(
                                      isPasswordReset: isPasswordReset,
                                    ),
                                  ),
                                );
                              } catch (error) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                    'An error occurred. Please try again later.',
                                    style: responsiveTextStyle(context, 16,
                                        Colors.black, FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.red,
                                ));
                              } finally {
                                setState(() {
                                  loading = false;
                                });
                              }
                            }
                          },
                          child: Text(
                            'Sign Up',
                            style: responsiveTextStyle(
                                context, 14, Colors.black, FontWeight.bold),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
