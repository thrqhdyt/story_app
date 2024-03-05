import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textListener = () => context.read<UploadProvider>().isEnabled =
        textController.text.trim().isNotEmpty;
    textController.addListener(textListener);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    textController.removeListener(textListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Story",
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
                  child: const Text("Camera"),
                ),
                const SizedBox(
                  width: 16.0,
                ),
                ElevatedButton(
                  onPressed: () => _onGalleryView(),
                  child: const Text("Gallery"),
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
                  : const Text("Upload"),
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
    final bytes = await imageFile.readAsBytes();

    final newBytes = await uploadProvider.compressImage(bytes);

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
}
