import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

const placeholderImage =
    'https://upload.wikimedia.org/wikipedia/commons/c/cd/Portrait_Placeholder_Square.png';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  OverlayEntry? _floatingWindow;
  late User user;
  late TextEditingController controller;
  final phoneController = TextEditingController();

  String? photoURL;

  bool isLoading = false;

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser!;
    print("User is present or not:: $user");
    controller = TextEditingController(text: user.displayName);

    FirebaseAuth.instance.userChanges().listen((event) {
      if (event != null && mounted) {
        // getAccessTokenFromUser();
        setState(() {
          user = event;
        });
      }
    });

    log(user.toString());

    super.initState();
  }

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  // void getAccessTokenFromUser() async {
  //   final  idToken = await user.getIdToken();

  //   if(idToken != null ) print("td token--------> ${idToken.token} ");

  // }

  void _showFloatingWindow(BuildContext context) {
    if (_floatingWindow != null) {
      _closeFloatingWindow();
    }

    _floatingWindow = OverlayEntry(
      builder:
          (context) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeFloatingWindow, // Tap outside closes the overlay
            child: Stack(
              children: [
                Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {},
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 10),
                          ],
                        ),
                        width: 150,
                        height: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.email ?? 'User',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                _signOut();
                              },
                              child: Text('Sign Out'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );

    // Insert the overlay entry to the overlay stack
    Overlay.of(context)?.insert(_floatingWindow!);
  }

  // Function to remove the floating window
  void _closeFloatingWindow() {
    _floatingWindow?.remove();
    _floatingWindow = null;
  }

  // Simulated sign-out function
  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('User signed out')));
    _closeFloatingWindow(); // Close the floating window after sign out
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photos"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () {
                _showFloatingWindow(context);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  placeholderImage,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: const Center(child: Text("Hello")),
    );
  }
}
