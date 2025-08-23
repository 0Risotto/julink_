// lib/presentation/profile/pages/own_profile_posts.dart
import 'package:flutter/material.dart';
import 'package:julink/data/models/common/page_response.dart';
import 'package:julink/data/models/posts/post.dart';
import 'package:julink/data/repository/posts/post_repository.dart';
import 'package:julink/data/sources/posts/post_service.dart';
import 'package:julink/presentation/home/pages/feed/page/feed_page.dart'; // for PostsContent

class OwnProfilePosts extends StatefulWidget {
  final int authorId; // supply the current user's id

  const OwnProfilePosts({super.key, required this.authorId});

  @override
  State<OwnProfilePosts> createState() => _OwnProfilePostsState();
}

class _OwnProfilePostsState extends State<OwnProfilePosts> {
  late final PostRepository _repo;
  final List<Post> _posts = [];

  bool _loading = true;
  bool _loadingMore = false;
  int _page = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _repo = PostRepository(postService: PostService());
    _load(refresh: true);
  }

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _loading = true;
        _page = 0;
        _hasMore = true;
        _posts.clear();
      });
    }
    try {
      final raw = await _repo.getOwnPosts(
        authorId: widget.authorId,
        page: _page,
        size: 10,
      );

      final page = PagedResponse<Post>.fromJson(
        Map<String, dynamic>.from(raw as Map),
        (m) => Post.fromJson(m),
      );

      setState(() {
        _posts.addAll(page.content);
        _hasMore = !page.last; // relies on your backend page flags
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load your posts: $e')),
        );
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    _page += 1;
    try {
      final raw = await _repo.getOwnPosts(
        authorId: widget.authorId,
        page: _page,
        size: 10,
      );

      final page = PagedResponse<Post>.fromJson(
        Map<String, dynamic>.from(raw as Map),
        (m) => Post.fromJson(m),
      );

      setState(() {
        _posts.addAll(page.content);
        _hasMore = !page.last;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load more: $e')));
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text("You haven’t posted anything yet."),
        ),
      );
    }

    // Pull to refresh + infinite scroll
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          _loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => _load(refresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Reuse your existing card UI with delete + comments etc.
              PostsContent(posts: _posts, repo: _repo),

              if (_loadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
