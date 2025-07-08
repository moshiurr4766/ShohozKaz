

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/core/controllers/home_controller.dart';
import 'package:shohozkaz/features/screen/pages/design/widgets/home_container.dart';

class TPromoSlide extends StatelessWidget {
  const TPromoSlide({super.key,required this.banners});

  final List<String> banners;
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Column(
      children: [
        CarouselSlider(
          items: banners.map((url) => TroundedImage(imageUrl: url)).toList(),
          options: CarouselOptions(
            height: 170.0,
            viewportFraction: 1,
            onPageChanged: (index, _) => controller.updatePageIndicator(index),

            autoPlay: true,
            enlargeCenterPage: true,
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < banners.length; i++)
                  TCirculerContainer(
                    width: 8,
                    height: 4,
                    margin: EdgeInsets.only(right: 4),
                  
                    backgroundColor: controller.carousalCurrentIndex.value == i
                        ? AppColors.primary
                        : Colors.grey,

                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



class TroundedImage extends StatelessWidget {
  const TroundedImage({
    super.key,
    required this.imageUrl,
    this.border,
    this.padding,
    this.onPressed,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.applyImageRadius = true,
    this.isNetworkImage = false,
    this.backgroundColor = Colors.transparent,
    this.borderRadius = 12,
  });

  final double? width, height;
  final String imageUrl;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color backgroundColor;
  final BoxFit fit;
  final EdgeInsetsDirectional? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: border,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius:
            applyImageRadius ? BorderRadius.circular(borderRadius) : BorderRadius.zero,
        child: Image(
          width: width,
          height: height,
          fit: fit,
          image: isNetworkImage
              ? NetworkImage(imageUrl)
              : AssetImage(imageUrl) as ImageProvider,
        ),
      ),
    );
  }
}
