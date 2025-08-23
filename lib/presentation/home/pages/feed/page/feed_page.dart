import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:julink/common/helper/is_dark_mode.dart';
import 'package:julink/core/configs/theme/app_colors.dart';
import 'package:julink/data/models/common/page_response.dart';
import 'package:julink/data/models/posts/post.dart';
import 'package:julink/data/repository/posts/post_repository.dart';
import 'package:julink/data/sources/posts/post_service.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late final PostRepository _postRepository;
  List<Post> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _postRepository = PostRepository(postService: PostService());
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final raw = await _postRepository.getHomePage(page: 0, size: 10);
      final page = PagedResponse<Post>.fromJson(
        Map<String, dynamic>.from(raw as Map),
        (m) => Post.fromJson(m),
      );
      setState(() {
        _posts = page.content;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('loadPosts error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _handlePostCreated(Post p) {
    setState(() => _posts.insert(0, p)); // show new post at top
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post published')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CreatePostsContainer(
                    repo: _postRepository,
                    onCreated: _handlePostCreated,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  )
                : PostsContent(posts: _posts, repo: _postRepository),
            const SizedBox(height: 20),
            const Text("End of Feed"),
            const SizedBox(height: 10),
            const AdsContainer(),
          ],
        ),
      ),
    );
  }
}

class PostsContent extends StatefulWidget {
  final List<Post> posts;
  final PostRepository repo;

  const PostsContent({super.key, required this.posts, required this.repo});

  @override
  State<PostsContent> createState() => _PostsContentState();
}

class _PostsContentState extends State<PostsContent> {
  // like state (optimistic)
  final Map<int, bool> _liked = {};
  final Map<int, int> _likeCounts = {};
  final Set<int> _likingInFlight = {};

  @override
  void initState() {
    super.initState();
    for (final p in widget.posts) {
      _liked[p.id] = _liked[p.id] ?? false;
      _likeCounts[p.id] = p.likeCount ?? 0;
    }
  }

  @override
  void didUpdateWidget(covariant PostsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final p in widget.posts) {
      _liked.putIfAbsent(p.id, () => false);
      _likeCounts.putIfAbsent(p.id, () => p.likeCount ?? 0);
    }
  }

  Future<void> _toggleLike(Post post) async {
    final id = post.id;
    if (_likingInFlight.contains(id)) return;
    final wasLiked = _liked[id] ?? false;
    final prev = _likeCounts[id] ?? (post.likeCount ?? 0);

    setState(() {
      _likingInFlight.add(id);
      _liked[id] = !wasLiked;
      _likeCounts[id] = wasLiked ? (prev - 1).clamp(0, 1 << 31) : prev + 1;
    });

    try {
      if (!wasLiked) {
        await widget.repo.likePost(id);
      } else {
        await widget.repo.deleteLike(id);
      }
    } catch (e) {
      debugPrint('Like toggle failed for $id: $e');
      if (!mounted) return;
      setState(() {
        _liked[id] = wasLiked;
        _likeCounts[id] = prev;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${wasLiked ? 'unlike' : 'like'} post'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _likingInFlight.remove(id));
    }
  }

  String _relative(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  void _onMenuSelect(Post post, String value) async {
    switch (value) {
      case 'edit':
        debugPrint('Edit post ${post.id}');
        break;
      case 'delete':
        try {
          await widget.repo.deletePost(post.id);
          setState(() => widget.posts.remove(post));
          debugPrint('Deleted post ${post.id}');
        } catch (e) {
          debugPrint('Delete error: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete post')),
          );
        }
        break;
      case 'share':
        debugPrint('Share post ${post.id}');
        break;
    }
  }

  // ---------- IMAGE HELPERS ----------
  // TODO: Map your Post model to an image URL here.
  // Example options you might have:
  //   return post.imageUrl;                 // single URL field
  //   return (post.images?.isNotEmpty ?? false) ? post.images!.first : null;
  //   return post.mediaUrl;
  String? _firstImageUrl(Post post) {
    // CHANGE THIS LINE to match your actual Post model:
    // If you don't have images yet, leave as null.
    // ignore: dead_code
    return null;
    // Example:
    // return post.imageUrl;
    // or:
    // return (post.images?.isNotEmpty ?? false) ? post.images!.first : null;
  }

  Widget _postImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (ctx, err, stack) {
            return Container(
              color: Colors.black12,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined),
            );
          },
        ),
      ),
    );
  }
  // -----------------------------------

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.posts.length,
      itemBuilder: (context, index) {
        final post = widget.posts[index];
        final id = post.id;
        final isLiked = _liked[id] ?? false;
        final likeCount = _likeCounts[id] ?? (post.likeCount ?? 0);
        final isBusy = _likingInFlight.contains(id);
        final maybeImageUrl = _firstImageUrl(post);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Card(
                elevation: context.isDarkMode ? 0 : 1.5,
                shadowColor: Colors.black12,
                color: context.isDarkMode
                    ? AppColors.darkCardBackground
                    : AppColors.lightCardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: context.isDarkMode ? Colors.white10 : Colors.black12,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/100?img=1',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "@${post.authorUsername ?? 'Unknown'}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: context.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _relative(post.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.isDarkMode
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_horiz),
                              splashRadius: 20,
                              onSelected: (value) => _onMenuSelect(post, value),
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete_outline),
                                    title: Text('Delete'),
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'share',
                                  child: ListTile(
                                    leading: Icon(Icons.share_outlined),
                                    title: Text('Share'),
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // IMAGE (above title)
                        if (maybeImageUrl != null &&
                            maybeImageUrl.isNotEmpty) ...[
                          _postImage(maybeImageUrl),
                          const SizedBox(height: 12),
                        ],

                        // Optional title
                        if (post.postTitle != null &&
                            post.postTitle!.isNotEmpty) ...[
                          Text(
                            post.postTitle!,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],

                        // Body
                        Text(
                          post.content,
                          softWrap: true,
                          style: TextStyle(
                            height: 1.4,
                            fontSize: 14,
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),

                        const SizedBox(height: 12),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: context.isDarkMode
                              ? Colors.white10
                              : Colors.black12,
                        ),
                        const SizedBox(height: 4),

                        // Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // LIKE
                            TextButton.icon(
                              onPressed: isBusy
                                  ? null
                                  : () => _toggleLike(post),
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 20,
                              ),
                              label: Text(
                                "$likeCount",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                overlayColor: (context.isDarkMode
                                    ? Colors.white10
                                    : Colors.black12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            // COMMENTS
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.comment_rounded, size: 20),
                              label: Text(
                                "${post.commentsCount ?? 0}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                overlayColor: (context.isDarkMode
                                    ? Colors.white10
                                    : Colors.black12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            // SHARE
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.share_outlined, size: 20),
                              label: Text(
                                "Share",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                overlayColor: (context.isDarkMode
                                    ? Colors.white10
                                    : Colors.black12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CreatePostsContainer extends StatefulWidget {
  const CreatePostsContainer({
    super.key,
    required this.repo,
    required this.onCreated,
  });

  final PostRepository repo;
  final void Function(Post created) onCreated;

  @override
  State<CreatePostsContainer> createState() => _CreatePostsContainerState();
}

class _CreatePostsContainerState extends State<CreatePostsContainer> {
  final _titleCtrl = TextEditingController(); // optional, not sent
  final _contentCtrl = TextEditingController();
  bool _posting = false;

  // Faculties (IDs -> names). Change 6 to 5 if your DB uses 5 for Engineering.
  static const Map<int, String> _faculties = {
    1: 'Faculty of Computer and Information Technology',
    2: 'Faculty of Medicine',
    3: 'Faculty of Science',
    4: 'Faculty of Business',
    6: 'Faculty of Engineering',
  };

  final Set<int> _selectedTags = <int>{};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<bool?> _askAddPhotoDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add a photo?'),
        content: const Text('Do you want to attach a photo to this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Add photo'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage(int postId) async {
    try {
      final picker = ImagePicker();
      final XFile? x = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        imageQuality: 85,
      );
      if (x == null) return; // user cancelled

      await widget.repo.uploadImage(postId, x);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image uploaded')));
    } catch (e) {
      debugPrint('Upload failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
    }
  }

  Future<void> _submit() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Write something first')));
      return;
    }

    setState(() => _posting = true);
    try {
      final created =
          await widget.repo.createPost(content, _selectedTags.toList()) as Post;

      _titleCtrl.clear();
      _contentCtrl.clear();
      _selectedTags.clear();
      setState(() {});

      widget.onCreated(created);

      final wantsImage = await _askAddPhotoDialog();
      if (wantsImage == true) {
        await _pickAndUploadImage(created.id);
      }
    } catch (e) {
      debugPrint('Create post failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to publish post')));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SizedBox(
          width: double.infinity,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Card(
              elevation: isDark ? 0 : 1.5,
              shadowColor: Colors.black12,
              color: isDark
                  ? AppColors.darkCardBackground
                  : AppColors.lightCardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/100?img=2',
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Create a post",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                    const SizedBox(height: 12),

                    // Title (optional)
                    TextField(
                      controller: _titleCtrl,
                      maxLines: 1,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Title (optional)',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                    const SizedBox(height: 8),

                    // Content
                    TextField(
                      controller: _contentCtrl,
                      minLines: 3,
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      enabled: !_posting,
                      style: TextStyle(
                        height: 1.4,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                        fillColor: Colors.transparent,
                      ),
                    ),

                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                    const SizedBox(height: 12),

                    // TAGS (multi-select)
                    Text(
                      'Tags (optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _faculties.entries.map((e) {
                        final selected = _selectedTags.contains(e.key);
                        return FilterChip(
                          selected: selected,
                          label: Text(
                            e.value,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedTags.add(e.key);
                              } else {
                                _selectedTags.remove(e.key);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        if (_selectedTags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Text(
                              'Selected: ${_selectedTags.join(', ')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        const Spacer(),
                        TextButton(
                          onPressed: _posting
                              ? null
                              : () {
                                  _titleCtrl.clear();
                                  _contentCtrl.clear();
                                  _selectedTags.clear();
                                  setState(() {});
                                },
                          child: Text(
                            "Clear",
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _posting ? null : _submit,
                          child: _posting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Post"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PeopleToFollowList extends StatefulWidget {
  const PeopleToFollowList({super.key});

  @override
  State<PeopleToFollowList> createState() => _PeopleToFollowListState();
}

class _PeopleToFollowListState extends State<PeopleToFollowList> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AdsContainer extends StatefulWidget {
  const AdsContainer({super.key});

  @override
  State<AdsContainer> createState() => _AdsContainerState();
}

class _AdsContainerState extends State<AdsContainer> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
