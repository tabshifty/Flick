class MediaResource {

  final String id;
  final double aspectRatio;
  MediaResource({ required this.id, required this.aspectRatio });

  MediaResource.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        aspectRatio = res["aspectRatio"];

  Map<String, Object?> toMap() {
    return {'id': id, 'aspectRatio': aspectRatio, };
  }
}