// import 'package:flutter/material.dart';

// class ZoomableCard extends StatefulWidget {
//   @override
//   _ZoomableCardState createState() => _ZoomableCardState();
// }

// class _ZoomableCardState extends State<ZoomableCard> {
//   bool _isZoomed = false;

//   void _handleTap() {
//     setState(() {
//       _isZoomed = !_isZoomed;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: MediaQuery.of(context).size.height * 0.40 - 80,
//       left: 16,
//       right: 16,
//       child: GestureDetector(
//         onTap: _handleTap,
//         child: AnimatedContainer(
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           transform: _isZoomed ? Matrix4.identity()..scale(1.1) : Matrix4.identity(),
//           child: SizedBox(
//             height: 150,
//             child: Card(
//               color: const Color(0xFF4B49AC),
//               elevation: _isZoomed ? 15 : 10,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Title of the Card',
//                       style: Theme.of(context).textTheme.headline6?.copyWith(
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       'Some content goes here. You can add more widgets inside the card as needed.',
//                       style: Theme.of(context).textTheme.bodyText1?.copyWith(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
