import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:story_app/data/model/list_story_response.dart';
import 'package:story_app/provider/auth_provider.dart';
import 'package:story_app/provider/list_story_provider.dart';
import 'package:story_app/utils/result_state.dart';
import 'package:story_app/widgets/card_story.dart';
import 'package:story_app/widgets/error_message.dart';

class StoriesListScreen extends StatefulWidget {
  const StoriesListScreen({super.key});

  @override
  State<StoriesListScreen> createState() => _StoriesListScreenState();
}

class _StoriesListScreenState extends State<StoriesListScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<ListStoryProvider>();
    provider.pageItems = 1;
    Future.microtask(
      () async {
        await provider.fetchAllStories();
      },
    );

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        if (provider.pageItems != null) {
          provider.fetchAllStories();
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

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
              controller: scrollController,
              shrinkWrap: true,
              itemCount: result.data!.listStory.length +
                  (state.pageItems != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == result.data!.listStory.length &&
                    state.pageItems != null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                var story = result.data!.listStory[index];
                return CardStory(
                  stories: story,
                  onTap: () => context.push('/stories/detail/${story.id}'),
                );
              },
            );
          default:
            return const Center(
              child: ErrorMessage(),
            );
        }
      }),
    );
  }
}
