import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:super_app/common/components/custom_image.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imageURLs;
  final double aspectRatio;
  final EdgeInsetsGeometry padding;
  final bool isIndicatorsOutside;
  final bool autoPlay;
  final int autoPlayDuration;
  final bool infiniteLoop;
  final Duration duration;
  final Color dotColor;
  final Color activeDotColor;
  final bool indicatorHasBackground;
  final Function(int)? onTap;
  final BorderRadiusGeometry borderRadius;

  const ImageSlider({
    super.key,
    required this.imageURLs,
    this.aspectRatio = 1,
    this.padding = EdgeInsets.zero,
    this.isIndicatorsOutside = true,
    this.autoPlay = false,
    this.autoPlayDuration = 4,
    this.infiniteLoop = true,
    this.duration = const Duration(milliseconds: 500),
    this.dotColor = Colors.grey,
    this.activeDotColor = Colors.blue,
    this.indicatorHasBackground = true,
    this.onTap,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  late PageController _controller;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();

    if (widget.autoPlay) _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(Duration(seconds: widget.autoPlayDuration), (timer) {
      if (_controller.page == widget.imageURLs.length - 1 && !widget.infiniteLoop) {
        _controller.animateToPage(0, duration: widget.duration, curve: Curves.easeInOut);
      } else {
        _controller.nextPage(duration: widget.duration, curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: widget.infiniteLoop ? null : widget.imageURLs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: widget.padding,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.onTap != null) {
                            widget.onTap!(widget.infiniteLoop ? (index % widget.imageURLs.length) : index);
                          }
                        },
                        child: ClipRRect(
                          borderRadius: widget.borderRadius,
                          child: CustomImage(
                              url: widget.imageURLs[widget.infiniteLoop ? (index % widget.imageURLs.length) : index]),
                        ),
                      ),
                    );
                  },
                ),
                if (!widget.isIndicatorsOutside) _getDotsIndicator(),
              ],
            ),
          ),
          if (widget.isIndicatorsOutside) _getDotsIndicator(),
        ],
      ),
    );
  }

  Widget _getDotsIndicator() {
    return Container(
      margin: widget.isIndicatorsOutside ? EdgeInsets.zero : const EdgeInsets.all(5).add(widget.padding),
      padding: widget.isIndicatorsOutside ? EdgeInsets.zero : const EdgeInsets.all(5),
      decoration: widget.isIndicatorsOutside
          ? null
          : widget.indicatorHasBackground
              ? BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
      child: SmoothPageIndicator(
        controller: _controller,
        count: widget.imageURLs.length,
        effect: ScrollingDotsEffect(
          activeDotColor: widget.activeDotColor,
          dotColor: widget.dotColor,
          activeStrokeWidth: 2.5,
          activeDotScale: 1.25,
          maxVisibleDots: 5,
          radius: 10,
          spacing: 5,
          dotHeight: 7,
          dotWidth: 7,
        ),
      ),
    );
  }
}
