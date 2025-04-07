import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

typedef OAuthSignIn = void Function();

class ScaffoldSnackbar {
  ScaffoldSnackbar(this._context);

  factory ScaffoldSnackbar.of(BuildContext context) {
    return ScaffoldSnackbar(context);
  }

  final BuildContext _context;

  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}

enum AuthMode { login }

extension on AuthMode {
  String get label => this == AuthMode.login ? 'Sign in' : 'Register';
}

/// Entrypoint example for various sign-in flows with Firebase.
class AuthGate extends StatefulWidget {
  // ignore: public_member_api_docs
  const AuthGate({super.key});
  static String? appleAuthorizationCode;
  @override
  State<StatefulWidget> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

  AuthMode mode = AuthMode.login;

  bool isLoading = false;

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  late Map<Buttons, OAuthSignIn> authButtons;

  @override
  void initState() {
    super.initState();

    authButtons = {
      Buttons.Microsoft:
          () => _handleMultiFactorException(_signInWithMicrosoft),
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SafeArea(
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: error.isNotEmpty,
                            child: MaterialBanner(
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                              content: SelectableText(error),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      error = '';
                                    });
                                  },
                                  child: const Text(
                                    'dismiss',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                              contentTextStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(10),
                            ),
                          ),

                          ...authButtons.keys.map(
                            (button) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child:
                                    isLoading
                                        ? Container(
                                          color: Colors.grey[200],
                                          height: 50,
                                          width: double.infinity,
                                        )
                                        : SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: SignInButton(
                                            button,
                                            onPressed: authButtons[button]!,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleMultiFactorException(
    Future<void> Function() authFunction,
  ) async {
    setIsLoading();
    try {
      await authFunction();
    } on FirebaseAuthMultiFactorException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } catch (e) {
      setState(() {
        error = '$e';
      });
    }
    setIsLoading();
  }

  Future<void> _signInWithMicrosoft() async {
    final microsoftProvider = MicrosoftAuthProvider();

    microsoftProvider.addScope("Files.Read");
    microsoftProvider.addScope("Files.Read.All");
    microsoftProvider.addScope("offline_access");
    microsoftProvider.addScope("User.Read");
    microsoftProvider.addScope("User.Read.All");

    var userCredential =
        await FirebaseAuth.instance.signInWithProvider(microsoftProvider);
    print(userCredential.credential?.accessToken);
  }
}
