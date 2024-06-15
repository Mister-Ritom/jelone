import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jelone/childpages/chat_page.dart';
import 'package:jelone/childpages/home_page.dart';
import 'package:jelone/pages/post_page.dart';
import 'package:jelone/childpages/profile_page.dart';
import 'package:jelone/childpages/trending_page.dart';
import 'package:jelone/pages/search_page.dart';
import 'package:jelone/pages/settings_page.dart';
import 'package:jelone/pages/sign_up_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //Page view controller
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final pages = [
    const HomePage(),
    const ChatPage(),
    const TrendingPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    // Subscribe to auth state change
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SignUpPage()));
      }
    });
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Jelone",
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 22,
              ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            "assets/Jelone.png",
          ),
        ),
        actions: [
          //Notiiication Icon
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.bell,
              size: 18,
            ),
            onPressed: () {
              // Perform notification action
            },
          ),
          // Search Icon
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.magnifyingGlass,
              size: 18,
            ),
            onPressed: () {
              //Navigate to material page search
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SearchPage()));
            },
          ),

          // if the page is profile page then show the three dot menu else show nothing
          if (_currentPage == 3)
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    child: Text("Edit Profile"),
                  ),
                  PopupMenuItem(
                    child: const Text("Settings"),
                    onTap: () {
                      //Navigate to settings page
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SettingsPage()));
                    },
                  ),
                  PopupMenuItem(
                    child: const Text("Logout"),
                    onTap: () {
                      //Logout the user
                      FirebaseAuth.instance.signOut();
                    },
                  ),
                ];
              },
            ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: pages,
      ),
      floatingActionButton: Transform(
        transform: Matrix4.translationValues(
            16, 0.0, 0.0), //Random value IDK how it worked
        child: Container(
          //shape to make it circular
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          height: 48.0,
          width: 48.0,
          child: FloatingActionButton(
            tooltip: 'Add Post',
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PostPage()));
            },
            child: const Icon(FontAwesomeIcons.plus, size: 22.0),
            // elevation: 5.0,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.hardEdge,
          child: BottomAppBar(
            height: 64,
            shape: const CircularNotchedRectangle(),
            notchMargin: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.house,
                    size: 20,
                  ),
                  onPressed: () {
                    _pageController.jumpToPage(0);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.comment,
                    size: 20,
                  ),
                  onPressed: () {
                    _pageController.jumpToPage(1);
                  },
                ),
                const SizedBox(
                    width:
                        36), // The dummy space for the floating action button
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.fire,
                    size: 20,
                  ),
                  onPressed: () {
                    _pageController.jumpToPage(2);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.user,
                    size: 20,
                  ),
                  onPressed: () {
                    _pageController.jumpToPage(3);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
