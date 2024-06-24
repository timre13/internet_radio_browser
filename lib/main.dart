import 'package:flutter/material.dart';
import 'package:internet_radio_browser/StationListWidget.dart';
import 'package:internet_radio_browser/api/enums.dart';
import 'package:internet_radio_browser/api/query.dart';

import 'api/structs/station.dart';

void main() {
  /*
  getStationsBy(Filter.countrycodeexact, "hu",
          order: Order.votes, reverse: true)
      .then(
    (value) {
      print("Found ${value.length} stations");
      print(value[0]);
      print(value[1]);
      print(value[2]);
    },
  );
   */
  runApp(App());
}

class App extends StatefulWidget {
  App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  List<Station> stations = [];
  late DraggableScrollableController sheetCont;

  @override
  void initState() {
    getStationsBy(Filter.countrycodeexact, "jp",
            order: Order.votes, reverse: true, limit: 100)
        .then(
      (value) {
        print("Found ${value.length} stations");
        setState(() {
          stations = value;
        });
      },
    );

    sheetCont = DraggableScrollableController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double minSheetHeightRatio = 0.1;

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
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.sizeOf(context).height *
                            minSheetHeightRatio),
                    child: StationListWidget(stations: stations))),
            Positioned.fill(
              child: SizedBox.expand(
                child: DraggableScrollableSheet(
                  minChildSize: minSheetHeightRatio,
                  maxChildSize: 1.0,
                  initialChildSize: minSheetHeightRatio,
                  builder: (context, scrollController) => SingleChildScrollView(
                    controller: scrollController,
                    child: Container(
                      color: Colors.grey.shade900,
                      child: SizedBox(
                          height: MediaQuery.sizeOf(context).height,
                          child: const Column(
                              children: [Placeholder(), Placeholder()])),
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
