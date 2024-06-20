import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jelone/models/post_model.dart';
import 'package:jelone/utils/post_comp.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

final _scrollController = ScrollController();
  final _queryLimit = 20; // Number of posts to fetch at a time

  // Track the last document retrieved for pagination
  DocumentSnapshot? _lastDocument;

  // List to store fetched posts
  List<PostModel> _posts = [];

  @override
  void initState() {
    _fetchInitialPosts();
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchInitialPosts() async {
    final query = FirebaseFirestore.instance
        .collection('posts')
        .where('isPublic', isEqualTo: true)
        .orderBy('likesCount', descending: true)
        .limitToLast(_queryLimit);

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _posts = snapshot.docs.map((doc) => PostModel.fromJson(doc.data())).toList();
        _lastDocument = snapshot.docs.last;
      });
    }
  }

  void _fetchMorePosts() async {
    if (_lastDocument == null) return; // No more posts to load

    // Firestore query to get next set of posts
    final nextQuery = FirebaseFirestore.instance
        .collection('posts')
        .where('isPublic', isEqualTo: true)
        .orderBy('likesCount', descending: true) // Replace with your sorting criteria
        .limitToLast(_queryLimit)
        .startAfterDocument(_lastDocument!);

    final snapshot = await nextQuery.get();

    setState(() {
      _posts.addAll(snapshot.docs.map((doc) => PostModel.fromJson(doc.data())).toList());
      _lastDocument = snapshot.docs.last;
    });
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final triggerFetch = maxScroll * 0.8; // Load more data when 80% scrolled

    if (currentScroll >= triggerFetch) {
      _fetchMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _posts.length,
        controller: _scrollController,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return PostComponent(post);
        },
      ),
    );
  }
}