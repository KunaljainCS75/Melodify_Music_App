import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/view/pages/signup_page.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:client/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
    formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    // final isLoading = ref.watch(authViewmodelProvider)?.isLoading == true;
    // the above statement is listening all kind of changes in authViewModel
    // But we only want to listen to loading value changes: so below statement
    final isLoading = ref.watch(authViewmodelProvider.select((val) => val?.isLoading == true));
    ref.listen(authViewmodelProvider, (_, next) {
      next?.when(data: (data) {
        // Navigate to HOME PAGE
        Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => const HomePage()), (_) => false);
      }, error: (error, st) {
        showSnackBar(context, error.toString());
      }, loading: () {
        // Handling loading cannot allow any return any Loader widget
        // This is because ref.listen is "void" method
      });
    });

    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const CustomLoader()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sign In",
                          style: TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      CustomField(
                          hintText: "Email", controller: emailController),
                      const SizedBox(height: 15),
                      CustomField(
                          hintText: "Password",
                          controller: passwordController,
                          isObscure: true),
                      const SizedBox(height: 20),
                      AuthGradientButton(
                          buttontext: "Sign In",
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              ref
                                  .read(authViewmodelProvider.notifier)
                                  .loginUser(
                                      email: emailController.text,
                                      password: passwordController.text);
                            }
                          }),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignupPage()));
                        },
                        child: RichText(
                          text: TextSpan(
                              text: "Don't have an account? ",
                              style: Theme.of(context).textTheme.titleMedium,
                              children: const [
                                TextSpan(
                                    text: 'Sign Up',
                                    style: TextStyle(
                                        color: Pallete.gradient2,
                                        fontWeight: FontWeight.bold))
                              ]),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
