import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../utils/AppColor.dart';

class ImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  const ImageViewer({super.key, required this.imageUrls});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  int _selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFE5E8E8),
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFF),
          shadowColor: Colors.transparent,
          title: const Text(
            ' Imagenes de los Comentarios',
            style: TextStyle(color: AppColor.myTextColor),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Visibility(
          visible: widget.imageUrls.isNotEmpty,
          replacement: const Center(
            child: Text('No existen imágenes en los comentarios'),
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ImageFullScreen(
                      imageUrls: widget.imageUrls,
                    );
                  }));
                },
                child: Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  color: _selectedIndex == index ? Colors.grey[300] : null,
                  colorBlendMode:
                      _selectedIndex == index ? BlendMode.saturation : null,
                ),
              );
            },
          ),
        ));
  }
}

class ImageFullScreen extends StatelessWidget {
  final List<String> imageUrls;

  ImageFullScreen({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Center(
            child: Image.network(
              imageUrls[index],
              fit: BoxFit.contain,
            ),
          );
        },

        // initialPage: initialPage,
      ),
    ));
  }
}
