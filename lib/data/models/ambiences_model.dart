class AmbienceModel {
  final String id;
  final String title;
  final String tag;
  final String duration;
  final String description;
  final String imagePath;
  final String audioPath;
  final List<String> sensoryChips;

  const AmbienceModel({
    required this.id,
    required this.title,
    required this.tag,
    required this.duration,
    required this.description,
    required this.imagePath,
    required this.audioPath,
    required this.sensoryChips,
  });

  factory AmbienceModel.fromJson(Map<String, dynamic> json) {
    // duration can be an int (seconds) or already a string like "5 min"
    final rawDuration = json['duration'];
    String durationStr;
    if (rawDuration is int) {
      final minutes = rawDuration ~/ 60;
      final seconds = rawDuration % 60;
      durationStr = seconds == 0 ? '$minutes min' : '$minutes:${seconds.toString().padLeft(2, '0')}';
    } else {
      durationStr = rawDuration.toString();
    }

    return AmbienceModel(
      id: json['id'].toString(),
      title: json['title'],
      tag: json['tag'],
      duration: durationStr,
      description: json['description'],
      imagePath: json['imagePath'],
      audioPath: json['audioPath'],
      sensoryChips: List<String>.from(json['sensoryChips']),
    );
  }
}