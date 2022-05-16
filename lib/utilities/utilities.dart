import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _image = await _imagePicker.pickImage(source: source);

  if (_image != null) {
    return await _image.readAsBytes();
  } else {
    print('No image selected');
  }
}

showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.grey[700],
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    ),
  );
}
