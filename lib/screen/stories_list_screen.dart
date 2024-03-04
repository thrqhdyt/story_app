import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:story_app/data/model/list_story_response.dart';
import 'package:story_app/provider/auth_provider.dart';
import 'package:story_app/provider/list_story_provider.dart';
import 'package:story_app/utils/result_state.dart';
import 'package:story_app/widgets/card_story.dart';

class StoriesListScreen extends StatelessWidget {
  const StoriesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        title: Text(
          "StoryApp",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: () {
              final authRead = context.read<AuthProvider>();
              authRead.logout();
              context.pushReplacement('/signin');
            },
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Consumer<ListStoryProvider>(builder: (context, state, _) {
        ResultState<ListStoryResponse> result = state.state;
        switch (result.status) {
          case Status.loading:
            return const Center(child: CircularProgressIndicator());
          case Status.hasData:
            return ListView.builder(
              shrinkWrap: true,
              itemCount: result.data!.listStory.length,
              itemBuilder: (context, index) {
                var stories = result.data!.listStory[index];
                return CardStory(stories: stories);
              },
            );
          default:
            return const Center(
              child: Text("Error"),
            );
        }
      }),
    );
  }
}
