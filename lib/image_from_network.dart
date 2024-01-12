import 'package:flutter/material.dart';

class ImageFromNetwork extends StatefulWidget {
  const ImageFromNetwork({
    required this.url,
    this.height,
    this.width,
    this.placeholderWidth,
    this.placeholderHeight,
    this.boxFit = BoxFit.cover,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final double? placeholderWidth;
  final double? placeholderHeight;
  final BoxFit boxFit;

  @override
  State<ImageFromNetwork> createState() => _ImageFromNetworkState();
}

class _ImageFromNetworkState extends State<ImageFromNetwork> {
  /// ローディング中か
  ///
  /// 画像取得に失敗した時の再読み込み処理が速すぎてローディングが見えないため、
  /// 明示的にローディングするようにloadingの状態を定義
  bool loading = false;

  /// ローディング中の遅延時間
  ///
  /// 再読み込みのローディングを見せるために遅延させる時間
  final Duration _delay = const Duration(
    milliseconds: 500,
  );

  @override
  Widget build(BuildContext context) {
    return loading
        ? _buildLoading()
        : Image.network(
            widget.url,
            fit: widget.boxFit,
            width: widget.width,
            height: widget.height,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame == null) {
                // 読み込み直前の前に明示的にサイズを与えないとサイズがガクッと変わる
                return SizedBox(
                  width: widget.placeholderHeight,
                  height: widget.placeholderHeight,
                  child: child,
                );
              }

              return child;
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress != null) {
                return _buildLoading();
              }

              return child;
            },
            errorBuilder: (context, error, stackTrace) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    loading = true;
                  });

                  // ローディングの表示を見せるために遅延させる
                  Future.delayed(
                    _delay,
                    () {
                      setState(
                        () {
                          loading = false;
                        },
                      );
                    },
                  );
                },
                child: Container(
                  color: Colors.grey,
                  width: widget.placeholderWidth,
                  height: widget.placeholderHeight,
                  child: const Center(
                    child: Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildLoading() {
    return Container(
      width: widget.placeholderWidth,
      height: widget.placeholderHeight,
      color: Colors.grey,
      child: const SizedBox(
        height: 40,
        width: 40,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
