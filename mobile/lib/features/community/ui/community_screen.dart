import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../redux/app_state.dart';
import '../redux/community_actions.dart';
import '../redux/community_state.dart';
import '../data/models.dart';
import '../../../core/localization/localization_manager.dart';
import '../../../core/ui/widgets/university_widgets.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _filter = 'All posts';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CommunityState>(
      onInit: (store) => store.dispatch(FetchPostsAction()),
      converter: (store) => store.state.communityState,
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildFilter(),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildPostsList(state.posts),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreatePostSheet(context),
            child: const Icon(Icons.add_comment),
          ),
        );
      },
    );
  }

  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Create New Post', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Post',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school, color: Colors.blue, size: 30),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hello, Ahmed Mohamed', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text('community_nav'.tr(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Recent Posts', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _filter,
            underline: const SizedBox(),
            items: ['Oldest', 'All posts', 'Newest'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _filter = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(List<dynamic> posts) {
    if (posts.isEmpty) return const Center(child: Text('No posts yet'));

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final postData = posts[index];
          final post = postData is Post ? postData : Post.fromJson(postData);
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: CommunityPostCard(post: post),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CommunityPostCard extends StatefulWidget {
  final Post post;
  const CommunityPostCard({super.key, required this.post});

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  bool _showComments = false;
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return UniversityCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: Colors.blue.shade100, child: const Icon(Icons.person)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.post.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.post.createdAt.toString().split(' ')[0], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.post.text),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildReactionIcon('👍', widget.post.likes),
                _buildReactionIcon('❤️', 0),
                _buildReactionIcon('💡', 0),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _showComments = !_showComments),
                  child: Text('${widget.post.commentsCount} comments'),
                ),
              ],
            ),
            if (_showComments) ...[
              const Divider(),
              _buildCommentsList(),
              const SizedBox(height: 12),
              _buildAddCommentInput(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReactionIcon(String emoji, int count) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Text(emoji),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text('$count', style: const TextStyle(fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return Column(
      children: widget.post.comments.map((comment) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 12, child: Icon(Icons.person, size: 12)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(comment.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(comment.dateTime.toString().split(' ')[0], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                    Text(comment.text, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddCommentInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _commentController,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              counterText: "",
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            if (_commentController.text.length >= 2) {
              StoreProvider.of<AppState>(context).dispatch(AddCommentAction(widget.post.id, _commentController.text));
              _commentController.clear();
            }
          },
          icon: const Icon(Icons.send, color: AppTheme.primaryNavy),
        ),
      ],
    );
  }
}
