import 'package:dart_chromecast/casting/cast.dart';
import 'package:dart_chromecast/casting/cast_media_track.dart';
import 'package:flutter/material.dart';
import 'package:nsd/nsd.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const CastExample());
}

class CastExample extends StatefulWidget {
  const CastExample({Key? key}) : super(key: key);

  @override
  _CastExampleState createState() => _CastExampleState();
}

class _CastExampleState extends State<CastExample> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cast example',
      home: CastExampleHome(),
    );
  }
}

class CastExampleHome extends StatefulWidget {
  const CastExampleHome({Key? key}) : super(key: key);

  @override
  State<CastExampleHome> createState() => _CastExampleHomeState();
}

class _CastExampleHomeState extends State<CastExampleHome> {
  CastSender? _castSender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInfo(),
            _buildDiscoveryButton(),
            _buildDisconnectButton(),
            _buildLoadVideoButton(),
            _buildControlsButtons(),
            _buildChangeSubtitles(),
            _buildStatusButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Text(
      (_castSender?.device.name != null)
          ? 'Connected to ${_castSender!.device.name}'
          : 'Not connected',
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDiscoveryButton() {
    return ElevatedButton(
      onPressed: () async {
        final Discovery discovery = await startDiscovery('_googlecast._tcp');

        await showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: '',
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return DevicesDialog(
              discovery: discovery,
              onDeviceSelected: (castSender) {
                setState(() {
                  _castSender = castSender;
                });
              },
            );
          },
        );
        await stopDiscovery(discovery);
      },
      child: const Text('Discover devices'),
    );
  }

  Widget _buildDisconnectButton() {
    return ElevatedButton(
      onPressed: () async {
        await _castSender?.disconnect();

        setState(() {
          _castSender = null;
        });
      },
      child: const Text('Disconnect device'),
    );
  }

  Widget _buildLoadVideoButton() {
    return ElevatedButton(
      onPressed: () {
        _castSender?.load(
          CastMedia(
            contentId:
                'https://cdn.scaleplay.com.br/static/1a6e9c2f-4ee9-4670-8af1-abf37b3223fe/44/cd/04/video/44cd0469-6e3a-4780-8232-c2545af91487.m3u8',
            title: 'Sample test 1',
          ),
        );
      },
      child: const Text('Load video'),
    );
  }

  Widget _buildControlsButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              _castSender?.seek(
                  _castSender?.castSession?.castMediaStatus?.position ??
                      0 - 10);
            },
            icon: const Icon(Icons.replay_10),
          ),
          IconButton(
            onPressed: () {
              _castSender?.togglePause();
            },
            icon: Icon(
              (_castSender?.castSession?.castMediaStatus?.isPlaying == true)
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
          ),
          IconButton(
            onPressed: () {
              // _castSender?.seek(
              //     _castSender?.castSession?.castMediaStatus?.position ??
              //         0 + 10);
              _castSender?.seek(21 * 60 + 26);
            },
            icon: const Icon(Icons.forward_10),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeSubtitles() {
    return StreamBuilder<CastMediaStatus?>(
      stream: _castSender?.castMediaStatusController.stream,
      builder: (context, snapshot) {
        List<CastMediaTrack> _subtitles =
            _castSender?.castSession?.castMediaStatus?.subtitles ?? [];
        print('----------------------------');
        return Wrap(
          spacing: 10.0,
          alignment: WrapAlignment.center,
          children: [
                ElevatedButton(
                  onPressed: () => _castSender?.setSubtitleTrack(),
                  child: const Text('Disable Subtitles'),
                ),
              ] +
              _subtitles
                  .map(
                    (subtitle) => ElevatedButton(
                      onPressed: () {
                        _castSender?.setSubtitleTrack(
                            subtitleTrackId: subtitle.trackId);
                      },
                      child: Text('Change subtitle to ${subtitle.name}'),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }

  Widget _buildStatusButton() {
    return ElevatedButton(
      onPressed: () {
        // print(_castSender?.castSession?.castMediaStatus.toString());
        print('=============== all tracks');
        _castSender?.castSession?.castMediaStatus?.castMediaTracks
            .forEach((element) {
          print(element.toChromeCastMap());
        });

        print('=============== subtitles');
        _castSender?.castSession?.castMediaStatus?.subtitles.forEach((element) {
          print(element.toChromeCastMap());
        });
      },
      child: Text('Get infos'),
    );
  }
}

class DevicesDialog extends StatefulWidget {
  final Discovery discovery;
  final void Function(CastSender castSender) onDeviceSelected;

  const DevicesDialog({
    Key? key,
    required this.discovery,
    required this.onDeviceSelected,
  }) : super(key: key);

  @override
  State<DevicesDialog> createState() => _DevicesDialogState();
}

class _DevicesDialogState extends State<DevicesDialog> {
  @override
  void initState() {
    widget.discovery.addListener(_discoveryListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.discovery.removeListener(_discoveryListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Dialog(
        child: Container(
          height: 200.0,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.discovery.services
                .map(
                  (s) => ListTile(
                    title: Text(s.name ?? ''),
                    onTap: () async {
                      final CastSender castSender = CastSender(
                        CastDevice(
                          name: s.name,
                          type: s.type,
                          host: s.host,
                          port: s.port,
                        ),
                      );

                      await castSender.connect();
                      castSender.launch();

                      widget.onDeviceSelected.call(castSender);

                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _discoveryListener() {
    setState(() {});
  }
}
