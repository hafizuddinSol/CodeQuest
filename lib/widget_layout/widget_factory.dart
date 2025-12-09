import 'package:flutter/material.dart';
import '../widgets/notification_widget.dart';
import '../widgets/progress_widget.dart';
import '../widgets/RecentActivityWidget.dart';

class WidgetFactory {
  static Widget buildWidget({
    required String id,
    required void Function() onRemove, // <- explicit VoidCallback type
    String? timeFilter,
    String? topicFilter,
  }) {
    switch (id) {
      case "notifications":
        return NotificationWidget(
          key: UniqueKey(),
          onRemove: onRemove,
          timeFilter: timeFilter ?? "all",
          topicFilter: topicFilter ?? "all",
        );

      case "progress":
        return ProgressWidget(
          key: UniqueKey(),
          onRemove: onRemove,
        );

      case "recent":
        return RecentActivityWidget(
          key: UniqueKey(),
          onRemove: onRemove,
        );

      default:
        return const SizedBox();
    }
  }
}

