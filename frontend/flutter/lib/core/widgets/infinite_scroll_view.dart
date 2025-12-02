import 'package:flutter/material.dart';

/// TekTech InfiniteScrollView
///
/// Generic widget for infinite scroll functionality
/// - Automatically loads more when reaching bottom
/// - Configurable threshold
/// - Pull-to-refresh support
/// - Loading indicator at bottom
class InfiniteScrollView extends StatefulWidget {
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget? Function(BuildContext context, int index)? separatorBuilder;
  final int itemCount;
  final VoidCallback? onLoadMore;
  final Future<void> Function()? onRefresh;
  final bool hasMore;
  final bool isLoadingMore;
  final EdgeInsetsGeometry? padding;
  final double loadMoreThreshold;
  final Widget? loadingIndicator;
  final ScrollPhysics? physics;

  const InfiniteScrollView({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.separatorBuilder,
    this.onLoadMore,
    this.onRefresh,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.padding,
    this.loadMoreThreshold = 200.0,
    this.loadingIndicator,
    this.physics,
  });

  @override
  State<InfiniteScrollView> createState() => _InfiniteScrollViewState();
}

class _InfiniteScrollViewState extends State<InfiniteScrollView> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !widget.hasMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = widget.loadMoreThreshold;

    if (maxScroll - currentScroll <= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !widget.hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    widget.onLoadMore?.call();

    // Wait a bit to allow state to update
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final listView = ListView.separated(
      controller: _scrollController,
      padding: widget.padding,
      physics: widget.physics,
      itemCount: widget.itemCount + (widget.hasMore ? 1 : 0),
      separatorBuilder: (context, index) {
        if (widget.separatorBuilder != null && index < widget.itemCount) {
          return widget.separatorBuilder!(context, index) ??
              const SizedBox.shrink();
        }
        return const SizedBox.shrink();
      },
      itemBuilder: (context, index) {
        // Show loading indicator at bottom
        if (index == widget.itemCount) {
          return _buildLoadingIndicator();
        }

        return widget.itemBuilder(context, index);
      },
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(onRefresh: widget.onRefresh!, child: listView);
    }

    return listView;
  }

  Widget _buildLoadingIndicator() {
    if (widget.loadingIndicator != null) {
      return widget.loadingIndicator!;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
