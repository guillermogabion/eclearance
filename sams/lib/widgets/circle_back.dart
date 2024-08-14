import 'package:flutter/material.dart';

class CircleBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CircleBackButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(
            2.0), // Optional: padding between border and icon
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color.fromARGB(255, 239, 235, 235), // Border color
            width: 0.2, // Border width
          ),
        ),
        child: CircleAvatar(
          radius: 20.0, // Circle radius
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 36.0, // IconButton width
            height: 36.0, // IconButton height
            child: IconButton(
              iconSize: 15.0, // Icon size
              icon: Transform.translate(
                offset: const Offset(1, 0), // Adjust offset if needed
                child: const Icon(Icons.arrow_back_ios_new),
              ),
              onPressed: onPressed ??
                  () {
                    Navigator.of(context).pop();
                  },
            ),
          ),
        ),
      ),
    );
  }
}
