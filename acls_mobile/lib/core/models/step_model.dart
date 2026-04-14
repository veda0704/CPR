/// Represents one choice button in a simulation step
class ChoiceModel {
  final String label;
  final String next;
  final String color;
  final bool isExit;

  const ChoiceModel({
    required this.label,
    required this.next,
    required this.color,
    this.isExit = false,
  });

  factory ChoiceModel.fromJson(Map<String, dynamic> json) {
    return ChoiceModel(
      label: json['label'] as String? ?? '',
      next: json['next'] as String? ?? 'dashboard',
      color: json['color'] as String? ?? 'primary',
      isExit: json['isExit'] as bool? ?? false,
    );
  }
}

/// Represents one simulation step returned by the backend
class StepModel {
  final String id;
  final String title;
  final String question;
  final String? video;
  final String? interactiveComponent;
  final Map<String, dynamic>? interactiveProps;
  final String? audioUrl;
  final List<ChoiceModel> choices;
  final int? timeLimit;
  final String? timeOutNext;

  const StepModel({
    required this.id,
    required this.title,
    required this.question,
    this.audioUrl,
    this.video,
    this.interactiveComponent,
    this.interactiveProps,
    required this.choices,
    this.timeLimit,
    this.timeOutNext,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    final choicesJson = json['choices'] as List<dynamic>? ?? [];
    return StepModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      question: json['question'] as String? ?? '',
      audioUrl: json['audio_url'] as String?,
      video: json['video'] as String?,
      interactiveComponent: json['interactive_component'] as String?,
      interactiveProps: json['interactive_props'] as Map<String, dynamic>?,
      choices: choicesJson
          .map((c) => ChoiceModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      timeLimit: json['time_limit'] as int?,
      timeOutNext: json['timeout_next'] as String?,
    );
  }
}
