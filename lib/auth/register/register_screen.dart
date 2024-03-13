import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:to_do/Home/home_screen.dart';
import 'package:to_do/MyTheme.dart';
import 'package:to_do/auth/register/custom_textfield.dart';
import 'package:to_do/dialog_utils.dart';
import 'package:to_do/firebase_Utils.dart';
import 'package:to_do/model/my_user.dart';
import 'package:to_do/providers/app_config_provider.dart';
import 'package:to_do/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = 'RegisterScreen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController(text: 'amr');

  TextEditingController emailController =
      TextEditingController(text: 'amr@gmail.com');

  TextEditingController passwordController =
      TextEditingController(text: '123456');

  TextEditingController confirmPasswordController =
      TextEditingController(text: '123456');
  bool passwordScure = true;
  bool confirmPasswordScure = true;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppConfigProvider>(context);
    return Stack(
      children: [
        Container(
          color: provider.appTheme == ThemeMode.dark
              ? MyTheme.blackDarkColor
              : MyTheme.whiteColor,
          child: Image.asset('assets/images/background.png',
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              AppLocalizations.of(context)!.create_account,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: provider.appTheme == ThemeMode.dark
                        ? MyTheme.blackDarkColor
                        : MyTheme.whiteColor,
                  ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.22,
                        ),
                        CustomTextField(
                          labelText: AppLocalizations.of(context)!.user_name,
                          icon: IconButton(
                              onPressed: () {}, icon: Icon(Icons.person)),
                          secureText: false,
                          controller: nameController,
                          validator: (text) {
                            if (text == null || text.trim().isEmpty) {
                              return AppLocalizations.of(context)!
                                  .please_enter_user_name;
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          labelText: AppLocalizations.of(context)!.email,
                          icon: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.email),
                          ),
                          secureText: false,
                          keyBoardType: TextInputType.emailAddress,
                          controller: emailController,
                          validator: (text) {
                            if (text == null || text.trim().isEmpty) {
                              return AppLocalizations.of(context)!
                                  .please_enter_your_email;
                            }
                            final bool emailValid = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(text);
                            if (!emailValid) {
                              return AppLocalizations.of(context)!
                                  .please_enter_valid_email;
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          labelText: AppLocalizations.of(context)!.password,
                          icon: IconButton(
                              onPressed: () {
                                passwordScure = !passwordScure;
                                setState(() {});
                              },
                              icon: passwordScure
                                  ? Icon(Icons.visibility_off)
                                  : Icon(Icons.visibility_rounded)),
                          secureText: passwordScure,
                          controller: passwordController,
                          validator: (text) {
                            if (text == null || text.trim().isEmpty) {
                              return AppLocalizations.of(context)!
                                  .please_enter_your_password;
                            }
                            if (text.length < 6) {
                              return AppLocalizations.of(context)!
                                  .please_should_be_at_least_6_chars;
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          labelText:
                              AppLocalizations.of(context)!.confirm_password,
                          icon: IconButton(
                            onPressed: () {
                              confirmPasswordScure = !confirmPasswordScure;
                              setState(() {});
                            },
                            icon: confirmPasswordScure
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility_rounded),
                          ),
                          secureText: confirmPasswordScure,
                          controller: confirmPasswordController,
                          validator: (text) {
                            if (text == null || text.trim().isEmpty) {
                              return AppLocalizations.of(context)!
                                  .please_confirm_your_password;
                            }
                            if (text != passwordController.text) {
                              return AppLocalizations.of(context)!
                                  .confirm_password_does_not_match_password;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          backgroundColor: MyTheme.primaryColor),
                      onPressed: () {
                        Register();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.create_account,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: provider.appTheme == ThemeMode.dark
                                  ? MyTheme.blackDarkColor
                                  : MyTheme.whiteColor,
                            ),
                      ),
                    ),
                  )
                ]),
          ),
        )
      ],
    );
  }

  void Register() async {
    var provider = Provider.of<AppConfigProvider>(context, listen: false);
    if (formKey.currentState!.validate() == true) {
      try {
        DialogUtils.showLoading(
          provider: provider,
          context: context,
          message: AppLocalizations.of(context)!.loading,
          isDismissible: false,
        );
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        MyUser myUser = MyUser(
          id: credential.user?.uid ?? '',
          email: emailController.text,
          name: nameController.text,
        );
        await FirebaseUtils.addUserToFireStore(myUser);
        var authProvider = Provider.of<AuthProviderr>(context, listen: false);

        authProvider.updateUser(myUser);
        DialogUtils.hideLoading(context);
        DialogUtils.showMessage(
            provider: provider,
            context: context,
            message: AppLocalizations.of(context)!.register_successfully,
            title: AppLocalizations.of(context)!.success,
            posActionName: AppLocalizations.of(context)!.ok,
            posAction: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, home_Screen.routeName);
            });
        print('Account Created Successfully');
        print(credential.user?.uid ?? '');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          DialogUtils.hideLoading(context);
          DialogUtils.showMessage(
            provider: provider,
            context: context,
            message:
                AppLocalizations.of(context)!.the_password_provided_is_too_weak,
            title: AppLocalizations.of(context)!.error,
            posActionName: AppLocalizations.of(context)!.ok,
          );
        } else if (e.code == 'email-already-in-use') {
          DialogUtils.hideLoading(context);
          DialogUtils.showMessage(
            context: context,
            provider: provider,
            message: AppLocalizations.of(context)!
                .the_account_already_exists_for_that_email,
            title: AppLocalizations.of(context)!.error,
            posActionName: AppLocalizations.of(context)!.ok,
          );
        }
      } catch (e) {
        DialogUtils.hideLoading(context);
        DialogUtils.showMessage(
          context: context,
          provider: provider,
          message: '${e.toString()}',
          title: AppLocalizations.of(context)!.error,
          posActionName: AppLocalizations.of(context)!.ok,
          posAction: () => Navigator.pop(context),
        );

        print(e);
      }
    }
  }
}
