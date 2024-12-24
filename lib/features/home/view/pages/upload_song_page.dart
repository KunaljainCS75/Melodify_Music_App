import 'dart:io';

import 'package:client/core/constants/size_constant.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/view/widgets/audio_waves.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadSongPage extends ConsumerStatefulWidget {
  const UploadSongPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends ConsumerState<UploadSongPage> {
  final artistNameController = TextEditingController();
  final songNameController = TextEditingController();
  Color selectedColor = Pallete.cardColor;
  File? selectedImage;
  File? selectedAudio;
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    songNameController.dispose();
    artistNameController.dispose();
  }

  void selectAudio() async {
    final pickedAudio = await pickAudio();
    if (pickedAudio != null) {
      setState(() {
        selectedAudio = pickedAudio;
      });
    }
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading  = ref.watch(homeViewmodelProvider.select((val) => val?.isLoading == true));
    return Scaffold(
        appBar: AppBar(
          title: const Text("Upload Song"),
          actions: [
            IconButton(onPressed: () async {
              if (formKey.currentState!.validate() && selectedAudio != null && selectedImage != null){
                await ref.read(homeViewmodelProvider.notifier).uploadSong(
                  selectedAudio: selectedAudio!, 
                  selectedThumbnail: selectedImage!, 
                  songName: songNameController.text, 
                  artistName: artistNameController.text, 
                  seletedColor: selectedColor,
                );
                selectedImage = null;
                selectedAudio = null;
              } else {
                showSnackBar(context, "You need to fill all required details!");
              }
            }, icon: const Icon(Icons.check))
          ],
        ),
        body: isLoading 
        ? const CustomLoader() 
        : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.defaultSpace),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  // Thumbnail Box
                  GestureDetector(
                    onTap: selectImage,
                    child: selectedImage != null
                        ? SizedBox(
                            width: double.infinity,
                            height: Sizes.defaultSpace * 8,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(selectedImage!,
                                    fit: BoxFit.cover)))
                        : DottedBorder(
                            color: Pallete.borderColor,
                            radius: const Radius.circular(10),
                            borderType: BorderType.RRect,
                            strokeCap: StrokeCap.round,
                            dashPattern: const [10, 4],
                            child: const SizedBox(
                              height: Sizes.defaultSpace * 8,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_open, size: Sizes.iconLg),
                                  SizedBox(height: Sizes.spaceBtwItems),
                                  Text("Select the thumbnail",
                                      style: TextStyle(fontSize: Sizes.textSm))
                                ],
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: Sizes.spaceBtwSections),
              
                  // Song Details
              
                  selectedAudio != null ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                          const Text("Pick another song")
                        ],
                      ),
                      AudioWaves(path: selectedAudio!.path),
                    ],
                  )
                  : CustomField(
                      hintText: "Pick Song", readOnly: true, onTap: selectAudio),
                  const SizedBox(height: Sizes.spaceBtwItems),
              
                  CustomField(
                      hintText: "Artist", controller: artistNameController),
                  const SizedBox(height: Sizes.spaceBtwItems),
              
                  CustomField(
                      hintText: "Song Name", controller: songNameController),
                  // const SizedBox(height: Sizes.spaceBtwSections),
              
                  // Color Picker
                  ColorPicker(
                      pickersEnabled: const {
                        ColorPickerType.both: true,
                        ColorPickerType.primary : false,
                        ColorPickerType.accent : false,
                      },
                      heading: const Text("Select color theme for your song", style: TextStyle(fontWeight: FontWeight.w700, fontSize: Sizes.textSm)),
                      color: selectedColor,
                      hasBorder: true,
                      borderColor: Colors.black,
                      showColorName: true,
                      showColorCode: true,
                      showMaterialName: true,
                      showRecentColors: true,
                      // showEditIconButton: true,
                      colorNameTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                      onColorChanged: (Color color) {
                        setState(() {
                          selectedColor = color;
                        });
                  })
                ],
              ),
            ),
          ),
        ));
  }
}
