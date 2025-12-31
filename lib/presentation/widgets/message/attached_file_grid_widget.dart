import 'dart:convert';

import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/assets/assets.gen.dart';
import 'package:baiqavisit/presentation/widgets/image/rounded_cached_network_image_widget.dart';
import 'package:baiqavisit/utils/extension/image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_opener/photo_opener.dart';

class AttachedFileGridWidget extends StatefulWidget {
  final List<String>? files;
  final List<String>? urls;
  final double size;

  const AttachedFileGridWidget({Key? key, this.files, this.urls, required this.size})
      : super(key: key);

  @override
  State<AttachedFileGridWidget> createState() => _AttachedFileGridWidgetState();
}

class _AttachedFileGridWidgetState extends State<AttachedFileGridWidget> {
  @override
  Widget build(BuildContext context) {
    var size=widget.size-16;
    final List<Object> images = widget.files != null
        ? widget.files!:widget.urls!;
    return SizedBox(
      width: size,
      height: size,
      child: switch(images.length){
        0 => Container(),
        1 => _buildOneImage(images[0],size),
        2 => _buildTwoImage(images,size),
        3 => _buildThreeImage(images,size),
        4 => _buildFourImage(images,size),
        _ => _buildManyImage(images,size),
      },
    );
  }

  Widget _buildOneImage(Object image,double maxSize){
    return _buildImage(image, maxSize,maxSize);
  }

  Widget _buildTwoImage(List<Object> images,double maxSize){
    return Row(
      children: [
        Expanded(child: _buildImage(images[0], maxSize, maxSize/2)),
        SizedBox(
          width: 2,
        ),
        Expanded(child: _buildImage(images[1], maxSize, maxSize/2)),
      ],
    );
  }

  Widget _buildThreeImage(List<Object> images,double maxSize){
    return Column(
      children: [
        Expanded(
          flex: 1,
            child:  _buildImage(images[0], maxSize/2, maxSize)
        ),
        SizedBox(
          height: 2,
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Expanded(child: _buildImage(images[1], maxSize/2, maxSize/2)),
              SizedBox(
                width: 2,
              ),
              Expanded(child: _buildImage(images[2], maxSize/2, maxSize/2))
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFourImage(List<Object> images,double maxSize){
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildImage(images[0], maxSize/2, maxSize/2)),
              SizedBox(width: 2),
              Expanded(child:_buildImage(images[1], maxSize/2, maxSize/2))
            ],
          ),
        ),
        SizedBox(
          height: 2,
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildImage(images[2], maxSize/2, maxSize/2)),
              SizedBox(width: 2),
              Expanded(child: _buildImage(images[3], maxSize/2, maxSize/2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManyImage(List<Object> images,double maxSize){
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildImage(images[0], maxSize/2, maxSize/2)),
              SizedBox(width: 2),
              Expanded(child: _buildImage(images[1], maxSize/2, maxSize/2))
            ],
          ),
        ),
        SizedBox(
          height: 2,
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildImage(images[2], maxSize/2, maxSize/2)),
              SizedBox(width: 2),
              Expanded(child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(images[3], maxSize/2, maxSize/2),
                  Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: Text(
                      '+${images.length - 4}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(Object image, double height,double width,{int index=0}){
    return (image is String)?ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.memory(
        base64Decode(image),
        fit: BoxFit.cover,
        height: height,
        width: width,
      ),
    ):(image is String?ClipRRect(
        borderRadius: BorderRadius.circular(4),
    child: RoundedCachedNetworkImage(
      image: image,
      height: height,
      width: width,
    )
        ):Container());
  }
}
