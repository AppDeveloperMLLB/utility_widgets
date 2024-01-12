import 'package:flutter/material.dart';
import 'package:utility_widgets/flexible_page_view/size_reporting_widget.dart';

class FlexiblePageView extends StatefulWidget {
  final List<Widget> children;
  final double initHeight;
  final Function(double)? onHeightChanged;

  const FlexiblePageView({
    Key? key,
    required this.children,
    this.initHeight = 100,
    this.onHeightChanged,
  }) : super(key: key);

  @override
  State<FlexiblePageView> createState() => _FlexiblePageViewState();
}

class _FlexiblePageViewState extends State<FlexiblePageView> {
  final GlobalKey viewKey = GlobalKey();
  late PageController _pageController;

  /// PageViewの高さ
  late double height;

  /// 各ページの高さのリスト
  ///
  /// ページを切り替えた時に高さを変更するように、各ぺーじの高さを保持しておく
  List<double> pageHeightList = [];

  @override
  void initState() {
    _pageController = PageController();
    height = widget.initHeight;
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      height: height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.children.length,
        onPageChanged: (value) {
          if (pageHeightList.length <= value) {
            return;
          }

          // 保存しているページの高さがあれば設定する
          setState(() {
            height = pageHeightList[value];
          });
        },
        itemBuilder: (context, index) {
          return OverflowBox(
            maxHeight: double.infinity,
            child: SizeReportingWidget(
              child: widget.children[index],
              onSizeChange: (size) {
                // 変更通知された高さと初期値の高さが同じ場合、
                // pageHeightListに高さを追加できないケースがあるので、
                // height == widget.initHeight場合は、追加する
                if (height == widget.initHeight || size.height != height) {
                  setState(
                    () {
                      height = size.height;
                      if (pageHeightList.length <= index) {
                        pageHeightList.add(size.height);
                      } else {
                        pageHeightList[index] = size.height;
                      }
                    },
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
