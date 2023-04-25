import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tareqe/models/theme.dart';

class DisplayImage extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;
  final bool showEditIcons;

  // Constructor
   DisplayImage({
    Key? key,
    required this.imagePath,
    required this.onPressed,
     this.showEditIcons=true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = appTheme.imageRignColor;

    return Center(
        child: Stack(children: [
          buildImage(color),
          Visibility(
            visible: showEditIcons,
              child: Positioned(
            child: buildEditIcon(color),
            right: 4,
            top: 10,
          )
          ),
        ]));
  }

  // Builds Profile Image
  Widget buildImage(Color color) {
    final image = imagePath.contains('https://')
        ? NetworkImage(imagePath)
        : imagePath.startsWith("assets/images")
        ?AssetImage(imagePath)
        :FileImage(File(imagePath))
    ;

    return CircleAvatar(
      radius: 75,
      backgroundColor: color,
      child: CircleAvatar(
        backgroundImage: image as ImageProvider,
        radius: 70,
      ),
    );
  }

  // Builds Edit Icon on Profile Picture
  Widget buildEditIcon(Color color) => buildCircle(
      all: 8,
      child: Icon(
        Icons.edit,
        color: color,
        size: 20,
      ));

  // Builds/Makes Circle for Edit Icon on Profile Picture
  Widget buildCircle({
    required Widget child,
    required double all,
  }) =>
      ClipOval(
          child: Container(
            padding: EdgeInsets.all(all),
            color: Colors.white,
            child: child,
          ));
}