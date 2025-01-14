import './media_resource.dart';

class VideoResource extends MediaResource {
  final String name;
  VideoResource({ required super.id, required super.aspectRatio, required this.name });
}