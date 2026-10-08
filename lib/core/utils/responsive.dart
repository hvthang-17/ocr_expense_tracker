import 'package:flutter/material.dart';

/*
 * Tiện ích hỗ trợ responsive UI cho các kích thước màn hình Android (Phone & Tablet).
 * Cung cấp breakpoints và widget giới hạn chiều rộng tối đa (ResponsiveCenter).
 *
 */
class Responsive {
  Responsive._();

  static const double mobileMaxBreakpoint = 600;
  static const double maxContentWidth = 800;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMaxBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileMaxBreakpoint;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.width;
}

/*
 * Widget bọc nội dung màn hình để giới hạn chiều rộng tối đa (tối đa 800px)
 * và căn giữa nội dung khi chạy trên màn hình máy tính bảng hoặc xoay ngang (landscape).
 *
 */
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
