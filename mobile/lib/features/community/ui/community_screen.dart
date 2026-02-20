import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../redux/app_state.dart';
import '../redux/community_actions.dart';
import '../redux/community_state.dart';
import 'create_post_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CommunityState>(
      onInit: (store) => store.dispatch(FetchPostsAction()),
      converter: (store) => store.state.communityState,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Community')),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.posts.length,
                  itemBuilder: (context, index) {
                    return PostCard(post: state.posts[index]);
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen())),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final isLiked = post['is_liked'] as bool? ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostDetailsScreen(post: post)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post['user'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(post['created_at'].toString().split('T')[0], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(post['content']),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                         size: 18, color: isLiked ? Colors.blue : null),
                    onPressed: () {
                      StoreProvider.of<AppState>(context).dispatch(ToggleLikeAction(post['id']));
                    },
                  ),
                  Text('${post['likes']}'),
                  const SizedBox(width: 16),
                  const Icon(Icons.comment_outlined, size: 18),
                  const SizedBox(width: 4),
                  Text('${post['comments_count']}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> post;
  const PostDetailsScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  PostCard(post: post),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Comments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  _buildCommentsList(),
                ],
              ),
            ),
          ),
          _buildCommentInput(context),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, i) {
        return ListTile(
          leading: const CircleAvatar(radius: 14),
          title: Text(i == 0 ? 'Ali' : 'Sara'),
          subtitle: Text(i == 0 ? 'Great post!' : 'Very helpful.'),
        );
      },
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    final controller = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Add a comment...', border: InputBorder.none),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                StoreProvider.of<AppState>(context).dispatch(AddCommentAction(post['id'], controller.text));
                controller.clear();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comment added!')));
              }
            },
          ),
        ],
      ),
    );
  }
}
