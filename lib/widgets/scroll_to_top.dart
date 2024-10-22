import 'package:flutter/material.dart';

class ScrollToTop extends StatefulWidget {
  const ScrollToTop({
    super.key,
  });

  @override
  State<ScrollToTop> createState() => _ScrollToTopState();
}

class _ScrollToTopState extends State<ScrollToTop> {
  ScrollController? scrollController;
  bool showScrollToTopButton = false;

  void _scrollListener() {
    if (scrollController == null) return;

    final shouldShow = scrollController!.offset > 100;
    if (shouldShow != showScrollToTopButton) {
      setState(() {
        showScrollToTopButton = shouldShow;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scrollController?.removeListener(_scrollListener);
    scrollController = PrimaryScrollController.of(context);
    scrollController?.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController?.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!showScrollToTopButton) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: () => scrollController?.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ),
      child: const Icon(Icons.arrow_upward),
    );
  }
}
