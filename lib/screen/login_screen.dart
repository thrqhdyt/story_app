import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:story_app/common.dart';
import 'package:story_app/provider/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Consumer<AuthProvider>(builder: (context, state, _) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/my_logo.png',
                      width: 100.0,
                      height: 100.0,
                    ),
                    const Center(
                      child: Text(
                        "Story App",
                        style: TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.subTitleLogin,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.pleaseEntEmail;
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: "Email",
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "Password",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseEntPassword;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    context.watch<AuthProvider>().isLoadingLogin
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll<Color>(
                                  Colors.deepOrange),
                              foregroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final scaffoldMessenger =
                                    ScaffoldMessenger.of(context);
                                await state.login(emailController.text,
                                    passwordController.text);
                                if (state.isLogin == true) {
                                  // ignore: use_build_context_synchronously
                                  context.pushReplacement('/stories');
                                } else {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(context)!
                                            .snackbarInvalidAuth,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child:
                                Text(AppLocalizations.of(context)!.buttonLogin),
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.textDontAccount),
                        TextButton(
                          onPressed: () => context.push('/signup'),
                          child: Text(
                              AppLocalizations.of(context)!.buttonRegister),
                        )
                      ],
                    )
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
