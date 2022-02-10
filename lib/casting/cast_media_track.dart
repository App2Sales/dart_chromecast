class CastMediaTrack {
  /// This is an unique ID, used to reference the track
  final int trackId;

  /// Track type. Can be TEXT, VIDEO OR AUDIO
  final String type;

  /// Track content type
  final String trackContentType;

  /// A Name for humans
  final String? name;

  /// Track language
  final String? language;

  final bool? forced;

  CastMediaTrack({
    required this.trackId,
    required this.type,
    required this.trackContentType,
    this.name,
    this.language,
    this.forced,
  });

  static CastMediaTrack fromMap(Map<String, dynamic> map) {
    return CastMediaTrack(
      trackId: map['trackId'],
      type: map['type'],
      trackContentType: map['trackContentType'],
      name: map['name'],
      language: map['language'],
      forced: map['forced'],
    );
  }

  Map<String, dynamic> toChromeCastMap() {
    return {
      'trackId': trackId,
      'type': type,
      'trackContentType': trackContentType,
      'name': name,
      'language': language,
      'forced': forced,
    };
  }

  static List<Map<String, dynamic>> listToChromeCastMap(
      List<CastMediaTrack> listTrackMedia) {
    return listTrackMedia
        .map((trackMediaItem) => trackMediaItem.toChromeCastMap())
        .toList();
  }
}
