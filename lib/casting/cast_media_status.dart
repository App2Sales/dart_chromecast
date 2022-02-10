import 'dart:convert';
import 'package:dart_chromecast/casting/cast_media_track.dart';
import 'package:logging/logging.dart';

class CastMediaStatus {
  final Logger log = new Logger('CastMediaStatus');

  dynamic _sessionId;

  final String? _nativeStatus;
  final bool _isPlaying;
  final bool _isPaused;
  final bool _isMuted;
  final bool _isIdle;
  final bool _isFinished;
  final bool _isCancelled;
  final bool _hasError;
  final bool _isLoading;
  final bool _isBuffering;
  final double? _volume;
  final double? _position;
  final Map? _media;
  final List? _activeTrackIds;

  CastMediaStatus.fromChromeCastMediaStatus(Map mediaStatus)
      : _sessionId = mediaStatus['mediaSessionId'],
        _nativeStatus = mediaStatus['playerState'],
        _isIdle = 'IDLE' == mediaStatus['playerState'],
        _isPlaying = 'PLAYING' == mediaStatus['playerState'],
        _isPaused = 'PAUSED' == mediaStatus['playerState'],
        _isMuted = null != mediaStatus['volume'] &&
            true == mediaStatus['volume']['muted'],
        _isLoading = 'LOADING' == mediaStatus['playerState'],
        _isBuffering = 'BUFFERING' == mediaStatus['playerState'],
        _isFinished = 'IDLE' == mediaStatus['playerState'] &&
            'FINISHED' == mediaStatus['idleReason'],
        _isCancelled = 'IDLE' == mediaStatus['playerState'] &&
            'CANCELLED' == mediaStatus['idleReason'],
        _hasError = 'IDLE' == mediaStatus['playerState'] &&
            'ERROR' == mediaStatus['idleReason'],
        _volume = null != mediaStatus['volume']
            ? mediaStatus['volume']['level'].toDouble()
            : null,
        _position = mediaStatus['currentTime'].toDouble(),
        _media = mediaStatus['media'],
        _activeTrackIds = mediaStatus['activeTrackIds'];

  dynamic get sessionId => _sessionId;

  String? get nativeStatus => _nativeStatus;

  bool get isIdle => _isIdle;

  bool get isPlaying => _isPlaying;

  bool get isFinished => _isFinished;

  bool get isCancelled => _isCancelled;

  bool get isPaused => _isPaused;

  bool get isMuted => _isMuted;

  bool get isLoading => _isLoading;

  bool get isBuffering => _isBuffering;

  bool get hasError => _hasError;

  double? get volume => _volume;

  double? get position => _position;

  Map? get media => _media;

  List get activeTrackIds => _activeTrackIds ?? [];

  List<CastMediaTrack> get castMediaTracks {
    List<CastMediaTrack> _castMediaTracks = [];
    try {
      List<dynamic>? _tracksMap = _media?['tracks'];

      if (_tracksMap != null && _tracksMap.isNotEmpty) {
        for (Map<String, dynamic> _trackMap in _tracksMap) {
          CastMediaTrack _castMediaTrack = CastMediaTrack.fromMap(_trackMap);
          _castMediaTracks.add(_castMediaTrack);
        }
      }
    } on Exception catch (e) {}

    return _castMediaTracks;
  }

  List<CastMediaTrack> get subtitles {
    return castMediaTracks.where((track) => track.type == 'TEXT').toList();
  }

  List<CastMediaTrack> get audios {
    return castMediaTracks.where((track) => track.type == 'AUDIO').toList();
  }

  @override
  String toString() {
    return jsonEncode({
      'sessionId': _sessionId,
      'nativeStatus': _nativeStatus,
      'isFinished': _isFinished,
      'isIdle': _isIdle,
      'isPlaying': _isPlaying,
      'isPaused': _isPaused,
      'isMuted': _isMuted,
      'isLoading': _isLoading,
      'isBuffering': _isBuffering,
      'isCancelled': _isCancelled,
      'hasError': _hasError,
      'volume': _volume,
      'position': _position,
      'media': _media,
      'activeTrackIds': _activeTrackIds,
    });
  }
}
