class ImageDTO {
  final String name;
  String path;
  final DateTime uploadAt;

  ImageDTO({
    required this.name,
    this.path = '',
    required this.uploadAt,
  });

  factory ImageDTO.fromJson(Map<String, dynamic> json) {
    return ImageDTO(
      name: json['name'],
      path: json['path'],
      uploadAt: DateTime.parse(json['uploadAt'].toDate().toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'path': path,
        'uploadAt': uploadAt,
      };
}
