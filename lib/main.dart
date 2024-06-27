import 'dart:collection';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:internet_radio_browser/StationListWidget.dart';
import 'package:internet_radio_browser/api/enums.dart';
import 'package:internet_radio_browser/api/query.dart';
import 'package:provider/provider.dart';

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
                  builder: (context, scrollController) => SingleChildScrollView(
                    controller: scrollController,
                    child: Container(
                      color: Colors.grey.shade900,
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            height: minSheetHeightPx,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Consumer<PlayerModel>(
                                  builder: (context, model, child) => Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox.square(
                                          dimension: minSheetHeightPx * 0.95,
                                          child: CircularProgressIndicator(
                                              value: model.isLoading ? null : 0,
                                              color: Colors.amber)),
                                      IconButton(
                                        onPressed: () async {
                                          if (!model.isStationSelected) {
                                            return;
                                          }
                                          if (model.isPlaying) {
                                            await model.audioHandler?.pause();
                                          } else {
                                            await model.audioHandler?.play();
                                          }
                                          print("Toggle");
                                        },
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                            model.isPlaying
                                                ? Icons.pause_circle
                                                : Icons.play_circle,
                                            size: minSheetHeightPx * 0.95),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
