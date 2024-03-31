import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  late GoogleMapController mapController;
  late final Set<Marker> markers = {};

  geo.Placemark? placemark;

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
    final Set<Marker> markers = {};
    return Consumer<DetailStoryProvider>(builder: (context, state, _) {
      ResultState<DetailStoryResponse> result = state.state;
      switch (result.status) {
        case Status.loading:
          return const Center(child: CircularProgressIndicator());
        case Status.hasData:
          var detailStory = result.data?.story;

          var latLng = detailStory?.lat != null && detailStory?.lon != null
              ? LatLng(detailStory!.lat!, detailStory.lon!)
              : null;
          if (latLng != null && markers.isEmpty) {
            markers.add(
              Marker(
                  markerId: MarkerId(detailStory!.id),
                  position: latLng,
                  onTap: () {
                    mapController.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(
                          detailStory.lat!,
                          detailStory.lon!,
                        ),
                        18,
                      ),
                    );
                  }),
            );
          }
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
                      const SizedBox(
                        height: 36.0,
                      ),
                      if (latLng != null)
                        SizedBox(
                          height: 500,
                          child: Stack(
                            children: [
                              GoogleMap(
                                markers: markers,
                                initialCameraPosition: CameraPosition(
                                  zoom: 18,
                                  target: latLng,
                                ),
                                zoomControlsEnabled: true,
                                onMapCreated: (controller) async {
                                  final info =
                                      await geo.placemarkFromCoordinates(
                                          detailStory.lat!, detailStory.lon!);

                                  final place = info[0];
                                  final street = place.street!;
                                  final address =
                                      '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

                                  setState(() {
                                    placemark = place;
                                  });

                                  final marker = Marker(
                                    markerId: const MarkerId("source"),
                                    position: latLng,
                                    infoWindow: InfoWindow(
                                      title: street,
                                      snippet: address,
                                    ),
                                  );

                                  setState(() {
                                    markers.clear();
                                    markers.add(marker);
                                  });

                                  setState(() {
                                    mapController = controller;
                                  });
                                },
                                onTap: (LatLng latLng) async {
                                  final info =
                                      await geo.placemarkFromCoordinates(
                                          latLng.latitude, latLng.longitude);

                                  final place = info[0];
                                  final street = place.street!;
                                  final address =
                                      '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

                                  final marker = Marker(
                                    markerId: const MarkerId("source"),
                                    position: latLng,
                                    infoWindow: InfoWindow(
                                      title: street,
                                      snippet: address,
                                    ),
                                  );

                                  setState(() {
                                    placemark = place;
                                    markers.clear();
                                    markers.add(marker);
                                  });

                                  mapController.animateCamera(
                                    CameraUpdate.newLatLng(latLng),
                                  );
                                },
                              ),
                              if (placemark == null)
                                const SizedBox()
                              else
                                Positioned(
                                  top: 16,
                                  right: 24,
                                  left: 24,
                                  child: PlacemarkWidget(
                                    placemark: placemark!,
                                  ),
                                )
                            ],
                          ),
                        )
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

class PlacemarkWidget extends StatelessWidget {
  const PlacemarkWidget({
    super.key,
    required this.placemark,
  });

  final geo.Placemark placemark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 700),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: 20,
            offset: Offset.zero,
            color: Colors.grey.withOpacity(0.5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  placemark.street!,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).primaryColor),
                ),
                Text(
                  '${placemark.subLocality}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
