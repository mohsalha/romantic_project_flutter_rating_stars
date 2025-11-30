library flutter_rating_stars;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/generated/assets.dart';

class RatingStars extends StatefulWidget {
  final double maxValue;
  final double value;
  final int starCount;
  final double starSize;
  final Color valueLabelColor;
  final TextStyle valueLabelTextStyle;
  final double valueLabelRadius;
  final double starSpacing;
  final bool maxValueVisibility;
  final bool valueLabelVisibility;
  final EdgeInsets valueLabelPadding;
  final EdgeInsets valueLabelMargin;
  final Color starOffColor;
  final Color starColor;
  final Function(double value)? onValueChanged;
  final Widget Function(int index, Color? color)? starBuilder;
  final Duration animationDuration;
  final Axis axis;
  final double angle;

  const RatingStars({
    Key? key,
    this.value = 0,
    this.starCount = 5,
    this.starSize = 20,
    this.valueLabelColor = const Color(0xff9b9b9b),
    this.valueLabelTextStyle = const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        fontSize: 12.0),
    this.valueLabelRadius = 10,
    this.maxValue = 5,
    this.starSpacing = 2,
    this.maxValueVisibility = true,
    this.valueLabelVisibility = true,
    this.animationDuration = Duration.zero,
    this.valueLabelPadding =
        const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
    this.valueLabelMargin = const EdgeInsets.only(right: 8),
    this.starOffColor = const Color(0xffe7e8ea),
    this.starColor = Colors.yellow,
    this.onValueChanged,
    this.starBuilder,
    this.axis = Axis.horizontal,
    this.angle = 0.0,
  }) : super(key: key);

  @override
  _RatingStarsState createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars>
    with TickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: _calculateDuration());
    _animationController!.forward(from: 0);
    super.initState();
  }

  Duration _calculateDuration() {
    var millis = (widget.animationDuration.inMilliseconds *
            widget.value /
            widget.maxValue)
        .round();
    return Duration(milliseconds: millis);
  }

  @override
  void didUpdateWidget(covariant RatingStars oldWidget) {
    if (widget.value != oldWidget.value) {
      _animationController!.duration = _calculateDuration();
      _animationController!.forward(from: 0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainLayout(
      builder: (context) => <Widget>[
        if (widget.valueLabelVisibility)
          Container(
            padding: _buildInsets(widget.valueLabelPadding),
            margin: _buildInsets(widget.valueLabelMargin),
            child: _buildLabel,
            decoration: BoxDecoration(
                color: widget.valueLabelColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(widget.valueLabelRadius)),
          ),
        // إضافة SizedBox لضمان المحاذاة
        SizedBox(
          height: widget.starSize,
          child: Stack(
            children: [
              _buildListStars(
                  builder: (context, index) =>
                      _starWidget(index, true, widget.starOffColor)),
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _animationController!,
                  builder: (context, child) {
                    return _buildClipRect(
                      builder: (context) => _buildListStars(
                        builder: (context, index) => Transform.scale(
                          scale: Tween<double>(begin: 0.0, end: 1.0)
                              .chain(CurveTween(
                                  curve: Interval(0.15 * index, 1.0,
                                      curve: Curves.elasticOut)))
                              .evaluate(_animationController!),
                          child: _starWidget(index, false, widget.starColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool get isHorizontal => widget.axis == Axis.horizontal;

  Widget _buildClipRect({required WidgetBuilder builder}) {
    final factor = math.max(0.0,
        math.min(widget.maxValue.toDouble(), widget.value / widget.maxValue));
    return ClipRect(
      child: Container(
        child: Align(
          widthFactor: isHorizontal ? factor : 1.0,
          heightFactor: !isHorizontal ? factor : 1.0,
          alignment: isHorizontal ? Alignment.centerLeft : Alignment.topCenter,
          child: builder(context),
        ),
      ),
    );
  }

  Widget _starWidget(int index, bool action, [Color? color]) {
    var _star = Center(
      child: Transform.rotate(
        angle: widget.angle * math.pi / 180.0,
        child: widget.starBuilder != null
            ? SizedBox(
                child: widget.starBuilder!(index, color),
                width: widget.starSize,
                height: widget.starSize,
              )
            : Image.asset(
                Assets.assetsStarOff,
                width: widget.starSize,
                height: widget.starSize,
                package: 'flutter_rating_stars',
                color: color,
              ),
      ),
    );

    if (!action) return _star;

    return SizedBox(
      width: widget.starSize,
      height: widget.starSize,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.starSize / 2))),
          minimumSize: WidgetStateProperty.all<Size>(
              Size(widget.starSize, widget.starSize)),
          padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
          elevation: WidgetStateProperty.all<double>(0.0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
          overlayColor:
              WidgetStateProperty.all<Color>(widget.starColor.withOpacity(0.2)),
          animationDuration: Duration(milliseconds: 100),
        ),
        onPressed: widget.onValueChanged == null
            ? null
            : () {
                var v = index + 1.0;
                v = v * widget.maxValue / widget.starCount;
                widget.onValueChanged!(v);
              },
        child: _star,
      ),
    );
  }

  Widget _buildMainLayout({required ListWidgetBuilder builder}) {
    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: builder(context),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: builder(context),
      );
    }
  }

  Widget _buildListStars({required IndexedWidgetBuilder builder}) =>
      _buildMainLayout(
        builder: (context) => List.generate(
          widget.starCount,
          (index) {
            return Container(
              margin: index == widget.starCount - 1
                  ? null
                  : EdgeInsetsDirectional.only(end: widget.starSpacing),
              alignment: Alignment.center,
              height: widget.starSize,
              child: builder.call(context, index),
            );
          },
        ),
      );

  Widget get _buildLabel => RotatedBox(
        quarterTurns: isHorizontal ? 0 : 1,
        child: Text(
          "${widget.value.toStringAsPrecision(2)}${widget.maxValueVisibility ? '/${widget.maxValue.toStringAsPrecision(2)}' : ''}",
          style: widget.valueLabelTextStyle,
        ),
      );

  EdgeInsets _buildInsets(EdgeInsets insets) => isHorizontal
      ? insets
      : insets.copyWith(
          left: widget.valueLabelPadding.vertical,
          right: widget.valueLabelPadding.vertical,
          top: widget.valueLabelPadding.horizontal,
          bottom: widget.valueLabelPadding.horizontal,
        );
}

typedef ListWidgetBuilder = List<Widget> Function(BuildContext context);
