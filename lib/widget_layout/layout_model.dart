
class DashboardLayout {
  final List<String> widgetOrder;

  DashboardLayout({required this.widgetOrder});

  Map<String, dynamic> toMap() {
    return {
      'widgetOrder': widgetOrder,
    };
  }

  factory DashboardLayout.fromMap(Map<String, dynamic> map) {
    return DashboardLayout(
      widgetOrder: List<String>.from(map['widgetOrder'] ?? []),
    );
  }
}
