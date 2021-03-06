import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//image library
import 'package:image_picker/image_picker.dart';

//firebase library - database
import 'package:lost_pet/resources/firestore_methods.dart';

import 'package:lost_pet/utilities/colors.dart';
import 'package:lost_pet/utilities/providers.dart';
import 'package:lost_pet/utilities/utilities.dart';
import 'package:provider/provider.dart';

//map libraries
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geocode/geocode.dart';
import 'package:map/map.dart';
import 'package:latlng/latlng.dart';

import '../models/user.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _imageTOUpload;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  List<bool> _uploadTypeToggle = [true, false];

  bool isLocationSaved = false;

  final _mapController =
      MapController(location: LatLng(35.33333030145494, 33.31953335381905));
  Offset? _dragStart;
  double _scaleStart = 1.0;
  double lat = 35.33467469237791, long = 33.315482144275215;
  bool loading = false;

  //backend stuff start
  void postImage(
    String uid,
    String username,
    String profileImage,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });
      String res = await FirestoreMethods().uploadPost(
        _descriptionController.text,
        _imageTOUpload!,
        uid,
        username,
        profileImage,
        _uploadTypeToggle[0] ? "lost" : "found",
        GeoPoint(lat, long),
      );

      if (res == 'Success') {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, "Post uploaded successfully");
        clearImage();
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, res);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, e.toString());
    }
  }

  void clearImage() {
    setState(() {
      _imageTOUpload = null;
    });
  }
  //backend stuff end

  void selectImage(context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select an image'),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Take a picture'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List image = await pickImage(
                  ImageSource.camera,
                );
                setState(() {
                  _imageTOUpload = image;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Choose from gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List image = await pickImage(
                  ImageSource.gallery,
                );
                setState(() {
                  _imageTOUpload = image;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      _mapController.zoom += 0.02;
    } else if (scaleDiff < 0) {
      _mapController.zoom -= 0.02;
    } else {
      final now = details.focalPoint;
      final diff = now - _dragStart!;
      _dragStart = now;
      _mapController.drag(diff.dx, diff.dy);
    }
  }

  void _onScaleEnd(ScaleEndDetails details) async {
    try {
      setState(() {
        loading = true;
        isLocationSaved = false;
      });
      lat = _mapController.center.latitude;
      long = _mapController.center.longitude;
      final coordinates = LatLng(lat, long);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return _imageTOUpload == null
        ? Center(
            child: IconButton(
              onPressed: (() => selectImage(context)),
              icon: const Icon(Icons.add),
              color: primaryColor,
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                onPressed: clearImage,
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Add Post'),
              actions: [
                TextButton(
                  onPressed: () => postImage(
                    user.uid,
                    user.username,
                    user.profileImage,
                  ),
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: barColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                _isLoading
                    ? const LinearProgressIndicator(
                        minHeight: 3.0,
                      )
                    : const SizedBox(
                        height: 3.0,
                      ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        user.profileImage,
                      ),
                    ),
                    const Text(
                      'Upload Type',
                    ),
                    ToggleButtons(
                      borderColor: primaryColor,
                      borderRadius: BorderRadius.circular(50),
                      borderWidth: 1,
                      selectedColor: blueColor,
                      hoverColor: blueColor,
                      fillColor: primaryColor,
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Lost',
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Found',
                          ),
                        ),
                      ],
                      isSelected: _uploadTypeToggle,
                      onPressed: (int newIndex) {
                        setState(() {
                          for (int index = 0;
                              index < _uploadTypeToggle.length;
                              index++) {
                            if (index == newIndex) {
                              _uploadTypeToggle[index] = true;
                            } else {
                              _uploadTypeToggle[index] = false;
                            }
                          }
                        });
                      },
                    ),
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: MemoryImage(
                                  _imageTOUpload!,
                                ),
                                fit: BoxFit.fill,
                                alignment: FractionalOffset.topCenter),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your post description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    maxLength: 150,
                    maxLines: 3,
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onScaleStart: _onScaleStart,
                            onScaleUpdate: _onScaleUpdate,
                            onScaleEnd: _onScaleEnd,
                            child: Map(
                              controller: _mapController,
                              builder: (context, x, y, z) {
                                final url =
                                    'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';
                                return CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MaterialButton(
                                    height: 50,
                                    minWidth: 50,
                                    color: Colors.blue,
                                    child: const Icon(Icons.zoom_in,
                                        color: Colors.white),
                                    onPressed: () =>
                                        _mapController.zoom += 0.2),
                                const SizedBox(height: 3),
                                MaterialButton(
                                    height: 50,
                                    minWidth: 50,
                                    color: Colors.blue,
                                    child: const Icon(Icons.zoom_out,
                                        color: Colors.white),
                                    onPressed: () => _mapController.zoom -= 0.2)
                              ],
                            ),
                          ),
                        ),
                        const Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 38,
                            color: Colors.red,
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: (MediaQuery.of(context).size.width * 0.5) -
                              (MediaQuery.of(context).size.width * 0.475),
                          child: Card(
                            elevation: 12,
                            child: Container(
                              width: 300,
                              height: 75,
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  loading
                                      ? const CircularProgressIndicator()
                                      : Text(
                                          'Lat: ${lat.toStringAsFixed(5)} , \nLong: ${long.toStringAsFixed(5)}')
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: (MediaQuery.of(context).size.width * 0.5) - 75,
                          child: InkWell(
                            onTap: () {
                              print(lat);
                              print(long);
                              setState(() {
                                isLocationSaved = true;
                              });
                              print("Container clicked");
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 150,
                              padding: const EdgeInsets.all(10),
                              color: Colors.blue,
                              child: isLocationSaved
                                  ? const Text(
                                      "Location saved",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  : const Text('Set Location'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
