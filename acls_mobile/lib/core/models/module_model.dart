/// Represents one emergency training module card on the dashboard
class ModuleModel {
  final String id;
  final String title;
  final String description;
  final String startStep;
  final String icon;
  final String color;

  const ModuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startStep,
    required this.icon,
    required this.color,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startStep: json['start_step'] as String? ?? '',
      icon: json['icon'] as String? ?? '🏥',
      color: json['color'] as String? ?? 'primary',
    );
  }
}
