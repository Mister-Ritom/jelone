import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jelone/models/user_model.dart';
import 'package:jelone/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<UserModel> getUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not found");
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception("User not found");
    }
    return UserModel.fromJson(snapshot.data()!);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildProfileWidget(),
                const SizedBox(height: 16),
                buildSettingButton(
                  FontAwesomeIcons.pencil,
                  "Appearance",
                  "Make Jelone yours",
                  () {},
                ),
                const SizedBox(height: 6),
                buildSettingButton(
                  themeProvider.themeMode == ThemeMode.system
                      ? FontAwesomeIcons.circleHalfStroke
                      : themeProvider.themeMode == ThemeMode.dark
                          ? FontAwesomeIcons.moon
                          : FontAwesomeIcons.sun,
                  "Theme",
                  "Change the app's theme",
                  () => showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        height: 200,
                        child: Column(
                          children: [
                            ListTile(
                              //if the theme mode is currently used, make the bacckground grayish
                              tileColor:
                                  themeProvider.themeMode == ThemeMode.light
                                      ? Colors.grey
                                      : null,
                              leading: const Icon(FontAwesomeIcons.sun),
                              title: const Text("Light"),
                              onTap: () {
                                themeProvider.setThemeMode(ThemeMode.light);
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              //if the theme mode is currently used, make the bacckground grayish
                              tileColor:
                                  themeProvider.themeMode == ThemeMode.dark
                                      ? Colors.grey
                                      : null,
                              leading: const Icon(FontAwesomeIcons.moon),
                              title: const Text("Dark"),
                              onTap: () {
                                themeProvider.setThemeMode(ThemeMode.dark);
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              //if the theme mode is currently used, make the bacckground grayish
                              tileColor:
                                  themeProvider.themeMode == ThemeMode.system
                                      ? Colors.grey
                                      : null,
                              leading:
                                  const Icon(FontAwesomeIcons.circleHalfStroke),
                              title: const Text("System Default"),
                              onTap: () {
                                themeProvider.setThemeMode(ThemeMode.system);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                buildSettingButton(
                  FontAwesomeIcons.info,
                  "About us",
                  "About Jelone- The company",
                  () {
                    launchUrl(
                      Uri.parse("https://jelone-web.vercel.app/about"),
                    );
                  },
                  importance: 4,
                ),
                const SizedBox(height: 6),
                buildSettingButton(
                  FontAwesomeIcons.heart,
                  "Support us",
                  "Donate to jelone to support us!",
                  () {
                    launchUrl(
                      Uri.parse("https://jelone-web.vercel.app/donation"),
                    );
                  },
                  importance: 4,
                ),
                const SizedBox(height: 6),
                buildSettingButton(
                  FontAwesomeIcons.bug,
                  "Report a bug",
                  "Found a bug? Let us know!",
                  () {
                    launchUrl(
                      Uri.parse("https://jelone-web.vercel.app/bug-report"),
                    );
                  },
                  importance: 4,
                ),
                const SizedBox(height: 16),
                //Terms of service
                buildSettingButton(
                  FontAwesomeIcons.fileLines,
                  "Terms of Service",
                  "Read our terms of service",
                  () {
                    launchUrl(
                      Uri.parse("https://jelone-web.vercel.app/terms"),
                    );
                  },
                  importance: 2,
                ),
                const SizedBox(height: 6),
                //Privacy policy
                buildSettingButton(
                  FontAwesomeIcons.userShield,
                  "Privacy Policy",
                  "Read our privacy policy",
                  () {
                    launchUrl(
                      Uri.parse("https://jelone-web.vercel.app/privacy"),
                    );
                  },
                  importance: 2,
                ),
              ],
            ),
          ),
        ));
  }

  Widget buildProfileWidget() {
    return FutureBuilder(
        future: getUser(),
        builder: (context, data) {
          if (data.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (data.hasError || data.data == null) {
            //log the error
            log("Something went wrong while fetching user data",
                error: data.error);
            return const SizedBox();
          }

          final user = data.data!;
          return Material(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              elevation: 6,
              child: SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ProfilePicture(
                        img: user.photoUrl,
                        name: user.name,
                        radius: 32,
                        fontsize: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ));
        });
  }

  Widget buildSettingButton(
      IconData icon, String title, String desc, void Function() onClick,
      {int importance = 6}) {
    return GestureDetector(
      onTap: onClick,
      child: Material(
        type: importance < 4 ? MaterialType.transparency : MaterialType.card,
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        elevation: importance.toDouble(),
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            // if the importance is less than 4, make the text  grey
                            color: importance < 4
                                ? Colors.grey
                                : Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      child: Text(
                        desc,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  FontAwesomeIcons.chevronRight,
                  color: importance < 4
                      ? Colors.grey
                      : Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
