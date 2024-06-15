import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  // Search query controller
  final TextEditingController _searchController = TextEditingController();

  // current seach mode for firestore
  SearchModes _searchMode = SearchModes.users;

  @override
  Widget build(BuildContext context) {
    final topSize = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            SizedBox(height: topSize),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search for a product",
                  // back button in prefix
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                  ),
                  //Set the suffix to a search mode selector dropdown
                  suffixIcon: DropdownButton<SearchModes>(
                    
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                    value: _searchMode,
                    onChanged: (SearchModes? value) {
                      if (value != null) setState(() => _searchMode = value);
                    },
                    items: const[
                      DropdownMenuItem(
                        value: SearchModes.users,
                        child: Text(
                          "Users",
                        ),
                      ),
                      DropdownMenuItem(
                        value: SearchModes.posts,
                        child: Text(
                          "Posts",
                        ),
                      ),
                      DropdownMenuItem(
                        value: SearchModes.chats,
                        child: Text(
                          "Chats",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

          ],
        ),
    ),
    );
  }
}

enum SearchModes {
  users,
  posts,
  chats
}