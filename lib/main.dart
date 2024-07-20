import 'dart:collection';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:internet_radio_browser/api/query.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';

import 'CustomAudioHandler.dart';
import 'StationListWidget.dart';
import 'api/structs/country.dart';
import 'api/structs/language.dart';
import 'api/structs/station.dart';

void main() {
  runApp(
      ChangeNotifierProvider(create: (context) => PlayerModel(), child: App()));
}

class PlayerModel extends ChangeNotifier {
  List<Station> _stations = [];
  int _selStationI = -1;
  late Future<AudioHandler> _audioHandlerFuture;
  late AudioHandler _audioHandler;

  PlayerModel() {
    /*
    getStationsBy(Filter.countrycodeexact, "jp",
            hideBroken: true, order: Order.votes, reverse: true, limit: 100)
        .then(
      (value) {
        print("Found ${value.length} stations");
        stations = value;
        notifyListeners();
      },
    );
     */

    /*
    searchStations(SearchStationsParams(
            countryCode: "jp",
            hideBroken: true,
            order: Order.votes,
            reverse: true,
            limit: 100))
        .then((value) {
      print("Found ${value.length} stations");
      stations = value;
      notifyListeners();
    });
     */

    _audioHandlerFuture = AudioService.init(
        builder: () => CustomAudioHandler(),
        config: const AudioServiceConfig(
            androidNotificationChannelName: "Audio playback"));

    _audioHandlerFuture.then((value) {
      print("AudioService initialized");
      _audioHandler = value;
      _audioHandler.playbackState.listen((event) {
        print("Audio handler playback state changed");
        notifyListeners();
      });

      notifyListeners();
    });
  }

  Future<AudioHandler> get audioHandlerFuture => _audioHandlerFuture;

  UnmodifiableListView<Station> get stations => UnmodifiableListView(_stations);
  bool get isPlaying => _audioHandler.playbackState.value.playing;

  int get selStationI => _selStationI;
  bool get isStationSelected =>
      !(selStationI == -1 || selStationI >= stations.length);
  Station? get selStation => isStationSelected ? stations[selStationI] : null;
  AudioHandler get audioHandler => _audioHandler;

  bool get isLoading =>
      _audioHandler.playbackState.value.processingState ==
          AudioProcessingState.buffering ||
      _audioHandler.playbackState.value.processingState ==
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

void showServerInfo(BuildContext context) {
  var serverInfo = getServerStats();
  showDialog(
      context: context,
      builder: (context) => Dialog(
          child: FutureBuilder(
              future: serverInfo,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DataTable(
                      columns: const [
                        DataColumn(label: Text("Key")),
                        DataColumn(label: Text("Value"))
                      ],
                      rows: snapshot.data!
                          .toJson()
                          .entries
                          .map((e) => DataRow(cells: [
                                DataCell(Text(e.key)),
                                DataCell(Text(e.value.toString()))
                              ]))
                          .toList(growable: false));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          "Failed to get server info: ${(snapshot.error as ClientException).message}",
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center));
                }
                return const Center(child: CircularProgressIndicator());
              })));
}

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  var searchArgs = SearchStationsParams();

  @override
  Widget build(BuildContext context) {
    final countriesFuture = getCountries();
    final languagesFuture = getLanguages();

    return Dialog(
        shape: Border.all(),
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(10),
          child: FutureBuilder(
              future: Future.wait([countriesFuture, languagesFuture]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final countryEntries = <DropdownMenuItem<dynamic>>[
                        const DropdownMenuItem(value: null, child: Text("ANY"))
                      ] +
                      (snapshot.data![0] as List<Country>)
                          .map((e) => DropdownMenuItem(
                              value: e.name,
                              child: Text(e.name,
                                  overflow: TextOverflow.ellipsis)))
                          .toList(growable: false);
                  final languageEntries = <DropdownMenuItem<dynamic>>[
                        const DropdownMenuItem(value: null, child: Text("ANY"))
                      ] +
                      (snapshot.data![1] as List<Language>)
                          .map((e) => DropdownMenuItem(
                              value: e.name,
                              child: Text(e.name,
                                  overflow: TextOverflow.ellipsis)))
                          .toList(growable: false);

                  return Flex(
                    direction: Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Search",
                          style: Theme.of(context).textTheme.titleLarge),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Name: "),
                            Expanded(
                                child: TextField(
                                    onChanged: (value) =>
                                        searchArgs.name = value))
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text("Country: "),
                            Expanded(
                                child: DropdownButton(
                                    value: searchArgs.country,
                                    items: countryEntries,
                                    isExpanded: true,
                                    onChanged: (value) => setState(() {
                                          searchArgs.country = value;
                                        })))
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text("Language: "),
                            Expanded(
                                child: DropdownButton(
                                    value: searchArgs.language,
                                    items: languageEntries,
                                    isExpanded: true,
                                    onChanged: (value) => setState(() {
                                          searchArgs.language = value;
                                        })))
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Tag: "),
                            Expanded(
                                child: TextField(
                                    onChanged: (value) =>
                                        searchArgs.tag = value))
                          ]),
                      Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      // TODO: Show progress indicator
                                      var results =
                                          await searchStations(searchArgs);
                                      assert(context.mounted);
                                      if (context.mounted) {
                                        Provider.of<PlayerModel>(context,
                                                listen: false)
                                            .stations = results;
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text("OK")),
                                OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel"))
                              ])),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          "Failed to prepare search dialog: ${snapshot.error}"));
                }

                return const Center(child: CircularProgressIndicator());
              }),
        )));
  }
}

void showSearchOptionsDialog(BuildContext context) {
  showDialog(context: context, builder: (context) => const SearchDialog());
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
        body: FutureBuilder(
          future: Provider.of<PlayerModel>(context).audioHandlerFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Stack(
                children: [
                  Scaffold(
                      appBar: AppBar(
                          actions: [
                            IconButton(
                                onPressed: () => showServerInfo(context),
                                icon: const Icon(Icons.dns),
                                tooltip: "Show Server Information")
                          ],
                          leading: IconButton(
                              onPressed: () => showSearchOptionsDialog(context),
                              icon: const Icon(Icons.search),
                              tooltip: "Show Search Options")),
                      body: SafeArea(
                          child: Padding(
                              padding:
                                  EdgeInsets.only(bottom: minSheetHeightPx),
                              child: const SizedBox.expand(
                                  child: StationListWidget())))),
                  Positioned.fill(
                    child: SizedBox.expand(
                      child: DraggableScrollableSheet(
                        minChildSize: minSheetHeightRatio,
                        maxChildSize: 1.0,
                        initialChildSize: minSheetHeightRatio,
                        snapSizes: const [minSheetHeightRatio, 1.0],
                        snap: true,
                        controller: sheetCont,
                        builder: (context, scrollController) =>
                            SingleChildScrollView(
                          controller: scrollController,
                          child: Container(
                            color: Colors.grey.shade900,
                            child: SizedBox(
                              height: MediaQuery.sizeOf(context).height,
                              child: SheetChild(scrollController: sheetCont),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return Center(
                  child: Text("Failed to initialize: ${snapshot.error}"));
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class SheetChild extends StatefulWidget {
  const SheetChild({super.key, required this.scrollController});

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
              await widget.model.audioHandler.pause();
            } else {
              await widget.model.audioHandler.play();
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
