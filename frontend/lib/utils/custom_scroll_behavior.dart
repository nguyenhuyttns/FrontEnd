// Thêm vào file lib/utils/custom_scroll_behavior.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse, // Thêm hỗ trợ cho chuột
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };

  // Ghi đè phương thức buildOverscrollIndicator để tùy chỉnh hiệu ứng overscroll (tùy chọn)
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // Hoặc sử dụng GlowingOverscrollIndicator tùy chỉnh
  }

  // Ghi đè phương thức buildScrollbar để tùy chỉnh thanh cuộn (tùy chọn)
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Trả về ScrollbarTheme để có thanh cuộn nhỏ và đẹp hơn
    return child; // Hoặc trả về Scrollbar tùy chỉnh
  }
}
