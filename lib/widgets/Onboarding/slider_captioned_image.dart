import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class SliderCaptionedImage extends StatelessWidget {
  final int index;
  final String caption;
  final String imageUrl;

  const SliderCaptionedImage({
    Key? key,
    required this.index,
    required this.caption,
    required this.imageUrl,
    required int captionFontSize,
    required Color captionColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
   return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 50), // Add space above the logo
            const Positioned(
              child: Image(
                image: AssetImage('assets/logo2.png'), // Provide the path to your logo image
                height: 80,
              ),
            ),
            Positioned(
              child: Image(
                image: AssetImage(imageUrl), // Provide the path to your main image
                height: 330,
                width: 400,
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          child: Text(
            caption,
            style: GoogleFonts.raleway(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
            maxLines: 3,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

  }

}
