import 'package:flutter/material.dart';

class ShakeableCard extends StatefulWidget {
  @override
  _ShakeableCardState createState() => _ShakeableCardState();
}

class _ShakeableCardState extends State<ShakeableCard> {
  bool _isShaking = false;

  void _handleTap() {
    if (!_isShaking) {
      setState(() {
        _isShaking = true;
      });

      // Reset shake after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isShaking = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.40 - 80,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform:
              _isShaking ? Matrix4.rotationZ(0.05) : Matrix4.rotationZ(0),
          child: SizedBox(
            height: 150,
            child: Card(
              color: const Color(0xFF4B49AC),
              elevation: _isShaking ? 15 : 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title of the Card',
                      style: Theme.of(context).textTheme.headline6?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Some content goes here. You can add more widgets inside the card as needed.',
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
