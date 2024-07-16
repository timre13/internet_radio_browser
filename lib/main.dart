import 'dart:collection';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:internet_radio_browser/StationListWidget.dart';
import 'package:internet_radio_browser/api/enums.dart';
import 'package:internet_radio_browser/api/query.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';

import 'CustomAudioHandler.dart';
import 'api/structs/station.dart';

void main() {
  runApp(
      ChangeNotifierProvider(create: (context) => PlayerModel(), child: App()));
}

class PlayerModel extends ChangeNotifier {
  List<Station> _stations = [];
  int _selStationI = -1;
  AudioHandler? _audioHandler;

  PlayerModel() {
    getStationsBy(Filter.countrycodeexact, "jp",
            hideBroken: true, order: Order.votes, reverse: true, limit: 100)
        .then(
      (value) {
        print("Found ${value.length} stations");
        stations = value;
        notifyListeners();
      },
    );

    AudioService.init(
            builder: () => CustomAudioHandler(),
            config: const AudioServiceConfig(
                androidNotificationChannelName: "Audio playback"))
        .then((value) {
      print("AudioService initialized");
      _audioHandler = value;
      _audioHandler!.playbackState.listen((event) {
        print("Audio handler playback state changed");
        notifyListeners();
      });
      notifyListeners();
    });
  }

  UnmodifiableListView<Station> get stations => UnmodifiableListView(_stations);
  bool get isPlaying => audioHandler!.playbackState.value.playing;
  int get selStationI => _selStationI;
  bool get isStationSelected =>
      !(selStationI == -1 || selStationI >= stations.length);
  Station? get selStation => isStationSelected ? stations[selStationI] : null;
  AudioHandler? get audioHandler => _audioHandler;
  bool get isLoading =>
      audioHandler!.playbackState.value.processingState ==
          AudioProcessingState.buffering ||
      audioHandler!.playbackState.value.processingState ==
          AudioProcessingState.loading;

  set stations(List<Station> val) {
    _stations = val;
    notifyListeners();
  }

  set selStationI(int val) {
    _selStationI = val;
    notifyListeners();
  }
}

class App extends StatefulWidget {
  App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late DraggableScrollableController sheetCont;

  @override
  void initState() {
    sheetCont = DraggableScrollableController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double minSheetHeightRatio = 0.1;
    final double minSheetHeightPx =
        MediaQuery.sizeOf(context).height * minSheetHeightRatio;

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Stack(
          children: [
            SafeArea(
                child: Padding(
                    padding: EdgeInsets.only(bottom: minSheetHeightPx),
                    child: Consumer<PlayerModel>(
                        builder: (context, model, child) =>
                            const StationListWidget()))),
            Positioned.fill(
              child: SizedBox.expand(
                child: DraggableScrollableSheet(
                  minChildSize: minSheetHeightRatio,
                  maxChildSize: 1.0,
                  initialChildSize: minSheetHeightRatio,
                  snapSizes: const [minSheetHeightRatio, 1.0],
                  snap: true,
                  controller: sheetCont,
                  builder: (context, scrollController) => SingleChildScrollView(
                    controller: scrollController,
                    child: Container(
                      color: Colors.grey.shade900,
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height,
                        child: SheetChild(
                            minSheetHeightPx: minSheetHeightPx,
                            scrollController: sheetCont),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SheetChild extends StatefulWidget {
  const SheetChild(
      {super.key,
      required this.minSheetHeightPx,
      required this.scrollController});

  final double minSheetHeightPx;
  final DraggableScrollableController scrollController;

  @override
  State<SheetChild> createState() => _SheetChildState();
}

class _SheetChildState extends State<SheetChild> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (true) {
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: widget.scrollController.pixels,
          child: Consumer<PlayerModel>(
            builder: (context, model, child) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                    PlayerButton(
                        size: min(widget.scrollController.pixels * 0.95,
                            MediaQuery.of(context).size.width * 0.6),
                        model: model),
                  ] +
                  (widget.scrollController.size >= 0.6
                      ? <Widget>[
                          TextScroll(model.selStation?.name ?? "---",
                              mode: TextScrollMode.endless,
                              intervalSpaces: 10,
                              style: const TextStyle(fontSize: 30)),
                          Text(model.selStation?.url ?? "",
                              textAlign: TextAlign.center),
                          Text(model.selStation?.homepage ?? "",
                              textAlign: TextAlign.center),
                          Text(model.selStation?.country ?? "",
                              textAlign: TextAlign.center),
                          Text(model.selStation?.language.join(", ") ?? "",
                              textAlign: TextAlign.center),
                          Text(
                              model.selStation != null &&
                                      model.selStation!.bitrate != 0
                                  ? "${model.selStation!.bitrate} kbps"
                                  : "",
                              textAlign: TextAlign.center),
                        ]
                      : []),
            ),
          ),
        ),
      );
    }
  }
}

class PlayerButton extends StatefulWidget {
  const PlayerButton({super.key, required this.size, required this.model});

  final double size;
  final PlayerModel model;

  @override
  State<PlayerButton> createState() => _PlayerButtonState();
}

class _PlayerButtonState extends State<PlayerButton> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.square(
            dimension: widget.size,
            child: CircularProgressIndicator(
                value: widget.model.isLoading ? null : 0, color: Colors.amber)),
        IconButton(
          onPressed: () async {
            if (!widget.model.isStationSelected) {
              return;
            }
            if (widget.model.isPlaying) {
              await widget.model.audioHandler?.pause();
            } else {
              await widget.model.audioHandler?.play();
            }
            print("Toggle");
          },
          padding: EdgeInsets.zero,
          icon: Icon(
              widget.model.isPlaying ? Icons.pause_circle : Icons.play_circle,
              size: widget.size),
        ),
      ],
    );
  }
}
