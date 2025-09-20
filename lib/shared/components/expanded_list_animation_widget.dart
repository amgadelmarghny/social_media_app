import 'package:flutter/material.dart';

/// A widget that animates the expansion and collapse of its child.
/// Used for sections that can be toggled open/closed with a smooth animation.
class ExpandedSection extends StatefulWidget {
  /// The widget to show/hide with animation.
  final Widget child;

  /// Controls the maximum height of the expanded section.
  /// Used to calculate the maxHeight constraint.
  final int height;

  /// Whether the section should be expanded or collapsed.
  final bool expand;

  const ExpandedSection({
    super.key,
    this.expand = false,
    required this.child,
    required this.height,
  });

  @override
  State<ExpandedSection> createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations(); // Set up the animation controller and animation.
    _runExpandCheck();   // Start animation based on initial expand value.
  }

  /// Sets up the animation controller and the curved animation.
  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  /// Runs the expand/collapse animation depending on the [expand] value.
  void _runExpandCheck() {
    if (widget.expand) {
      expandController.forward(); // Animate to expanded.
    } else {
      expandController.reverse(); // Animate to collapsed.
    }
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck(); // Respond to changes in the expand property.
  }

  @override
  void dispose() {
    expandController.dispose(); // Clean up the animation controller.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The SizeTransition animates the vertical size of the child.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SizeTransition(
        axisAlignment: 1.0,
        sizeFactor: animation,
        child: Container(
          padding: const EdgeInsets.only(bottom: 5),
          constraints: BoxConstraints(
            // minWidth is always infinity to take full width.
            minWidth: double.infinity,
            // maxHeight is determined by the height parameter.
            // If height > 5, use 195. If height == 1, use 55. Otherwise, height * 50.0.
            maxHeight: widget.height > 5
                ? 195
                : widget.height == 1
                    ? 55
                    : widget.height * 50.0,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
