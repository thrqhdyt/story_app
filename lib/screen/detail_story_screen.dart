import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_app/data/model/detail_story_response.dart';
import 'package:story_app/provider/detail_story_provider.dart';
import 'package:story_app/utils/extensions.dart';
import 'package:story_app/utils/result_state.dart';
import 'package:story_app/widgets/error_message.dart';

class DetailStoryScreen extends StatefulWidget {
  final String storyId;

  const DetailStoryScreen({super.key, required this.storyId});

  @override
  State<DetailStoryScreen> createState() => _DetailStoryScreenState();
}

class _DetailStoryScreenState extends State<DetailStoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      DetailStoryProvider detailProvider =
          Provider.of<DetailStoryProvider>(context, listen: false);
      detailProvider.fetchDetailStory(widget.storyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailStoryProvider>(builder: (context, state, _) {
      ResultState<DetailStoryResponse> result = state.state;
      switch (result.status) {
        case Status.loading:
          return const Center(child: CircularProgressIndicator());
        case Status.hasData:
          var detailStory = result.data?.story;
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, isScrolled) {
                return [
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    expandedHeight: 250,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Hero(
                        tag: detailStory.photoUrl,
                        child: Image.network(
                          detailStory.photoUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/user.png',
                                  width: 20,
                                ),
                                const SizedBox(width: 6.0),
                                Text(detailStory!.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Text(
                              detailStory.createdAt.relativeTimeSpan(context),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(detailStory.description,
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        default:
          return const Center(
            child: ErrorMessage(),
          );
      }
    });
  }
}
