import 'package:flutter/material.dart';
import 'package:story_app/data/model/list_story_response.dart';
import 'package:story_app/utils/extensions.dart';

class CardStory extends StatelessWidget {
  final ListStory stories;
  final GestureTapCallback? onTap;

  const CardStory({super.key, required this.stories, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 0,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/user.png',
                        width: 24,
                      ),
                      const SizedBox(width: 8.0),
                      Text(stories.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(
                    stories.createdAt.relativeTimeSpan(context),
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Image.network(
                    stories.photoUrl,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      stories.description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
