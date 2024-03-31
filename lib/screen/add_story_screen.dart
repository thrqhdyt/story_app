import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:story_app/common.dart';
import 'package:story_app/provider/new_story_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:story_app/provider/upload_provider.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final textController = TextEditingController();
  late final void Function() textListener;

  // ignore: avoid_init_to_null
  LatLng? _location = null;
  late GoogleMapController mapController;
  late final Set<Marker> markers = {};

  geo.Placemark? placemark;

  @override
  void initState() {
    super.initState();
    onMyLocationButtonPress(context.read<UploadProvider>());
    textListener = () => context.read<UploadProvider>().isEnabled =
        textController.text.trim().isNotEmpty;
    textController.addListener(textListener);
  }

  @override
  void dispose() {
    textController.removeListener(textListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.addStoryBtnNav,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: context.watch<NewStoryProvider>().imagePath == null
                  ? SizedBox(
                      width: 250,
                      height: 200,
                      child: Image.asset(
                        'assets/upload_image.png',
                      ),
                    )
                  : _showImage(),
            ),
            const SizedBox(
              height: 4.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _onCameraView(),
                  child: Text(AppLocalizations.of(context)!.cameraBtn),
                ),
                const SizedBox(
                  width: 16.0,
                ),
                ElevatedButton(
                  onPressed: () => _onGalleryView(),
                  child: Text(AppLocalizations.of(context)!.galleryBtn),
                ),
              ],
            ),
            const SizedBox(
              height: 36.0,
            ),
            SizedBox(
              width: 250,
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(
              height: 24.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    if (context.watch<UploadProvider>().isLocationGranted &&
                        _location != null)
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          zoom: 15,
                          target: _location!,
                        ),
                        markers: markers,
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                        myLocationEnabled: true,
                        onMapCreated: (controller) async {
                          final info = await geo.placemarkFromCoordinates(
                              _location!.latitude, _location!.longitude);
                          final place = info[0];
                          final street = place.street!;
                          final address =
                              '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
                          setState(() {
                            placemark = place;
                          });
                          defineMarker(_location!, street, address);

                          final marker = Marker(
                            markerId: const MarkerId("source"),
                            position: _location!,
                          );
                          setState(() {
                            mapController = controller;
                            markers.add(marker);
                          });
                        },
                        onTap: (LatLng latLng) {
                          context.read<UploadProvider>().curentCorrdinate =
                              latLng;
                          onPressGoogleMap(latLng);
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 24.0,
            ),
            ElevatedButton(
              onPressed: context.watch<UploadProvider>().isEnabled &&
                      context.watch<NewStoryProvider>().imagePath != null
                  ? () async {
                      await _onUpload();
                      context.pushReplacement('/stories');
                    }
                  : null,
              style: ElevatedButton.styleFrom(fixedSize: const Size(250, 50)),
              child: context.watch<UploadProvider>().isUploading
                  ? const CircularProgressIndicator()
                  : Text(AppLocalizations.of(context)!.uploadBtn),
            ),
            const SizedBox(
              height: 16.0,
            ),
          ],
        ),
      ),
    );
  }

  _onUpload() async {
    final ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);
    final newStoryProvider = context.read<NewStoryProvider>();
    final uploadProvider = context.read<UploadProvider>();
    final imagePath = newStoryProvider.imagePath;
    final imageFile = newStoryProvider.imageFile;

    if (imagePath == null || imageFile == null) return;

    final fileName = imageFile.name;

    final newBytes = await uploadProvider.compressImage(imageFile);

    await uploadProvider.upload(
      newBytes,
      fileName,
      textController.text,
    );

    if (uploadProvider.uploadResponse != null) {
      newStoryProvider.setImageFile(null);
      newStoryProvider.setImagePath(null);
    }

    scaffoldMessengerState.showSnackBar(
      SnackBar(content: Text(uploadProvider.message)),
    );
  }

  _onGalleryView() async {
    final provider = context.read<NewStoryProvider>();

    final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    final isLinux = defaultTargetPlatform == TargetPlatform.linux;
    if (isMacOS || isLinux) return;

    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  _onCameraView() async {
    final provider = context.read<NewStoryProvider>();
    final ImagePicker picker = ImagePicker();

    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isiOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isNotMobile = !(isAndroid || isiOS);
    if (isNotMobile) return;

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  Widget _showImage() {
    final imagePath = context.read<NewStoryProvider>().imagePath;
    return kIsWeb
        ? Image.network(
            imagePath.toString(),
            fit: BoxFit.contain,
          )
        : Image.file(
            File(imagePath.toString()),
            fit: BoxFit.contain,
          );
  }

  void onPressGoogleMap(LatLng latLng) async {
    final info =
        await geo.placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    final place = info[0];
    final street = place.street!;
    final address =
        '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {
      placemark = place;
    });

    defineMarker(latLng, street, address);

    mapController.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
  }

  void onMyLocationButtonPress(UploadProvider uploadProvider) async {
    final Location location = Location();
    late bool serviceEnabled;
    late PermissionStatus permissionGranted;
    late LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    uploadProvider.isLocationGranted = serviceEnabled;
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      uploadProvider.isLocationGranted = serviceEnabled;
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    _location = LatLng(locationData.latitude!, locationData.longitude!);
    uploadProvider.curentCorrdinate = _location;

    if (_location != null) {
      final info = await geo.placemarkFromCoordinates(
          _location!.latitude, _location!.longitude);

      final place = info[0];
      final street = place.street;
      final address =
          '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      setState(() {
        placemark = place;
      });

      defineMarker(_location!, street!, address);

      mapController.animateCamera(
        CameraUpdate.newLatLng(_location!),
      );
    }
  }

  void defineMarker(LatLng latLng, String street, String address) {
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
  }
}
