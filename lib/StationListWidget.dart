import 'package:flutter/material.dart';

import 'api/structs/station.dart';

class StationListWidget extends StatefulWidget {
  const StationListWidget({super.key, required this.stations});

  final List<Station> stations;

  @override
  State<StationListWidget> createState() => _StationListWidgetState();
}

class _StationListWidgetState extends State<StationListWidget> {
  int selectedStationI = -1;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: DataTable(
      showCheckboxColumn: false,
      rows: widget.stations
          .asMap()
          .map((i, e) => MapEntry(
              i,
              DataRow(
                  cells: [
                    DataCell(e.favicon.isNotEmpty
                        ? LoadingNetworkImage(url: e.favicon)
                        : const Icon(Icons.radio, size: 40)),
                    DataCell(Text(e.name)),
                    DataCell(Text(e.countrycode)),
                    DataCell(Text(e.votes.toString())),
                    DataCell(Text(e.languagecodes.join("+"))),
                  ],
                  selected: selectedStationI == i,
                  onSelectChanged: (value) {
                    setState(() {
                      selectedStationI = i;
                    });
                  },
                  color: WidgetStatePropertyAll(selectedStationI == i
                      ? Colors.amber.withAlpha(140)
                      : Colors.transparent))))
          .values
          .toList(growable: false),
      columns: const [
        DataColumn(label: Text("Icon")),
        DataColumn(label: Text("Name")),
        DataColumn(label: Text("Country")),
        DataColumn(label: Text("Votes")),
        DataColumn(label: Text("Langs")),
      ],
    ));
  }
}

class LoadingNetworkImage extends StatelessWidget {
  const LoadingNetworkImage({super.key, required this.url});

  static const double size = 40;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(url,
        width: size,
        height: size,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress?.expectedTotalBytes !=
              loadingProgress?.cumulativeBytesLoaded) {
            return const SizedBox.square(
                dimension: size, child: CircularProgressIndicator());
          }
          return child;
        },
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: size));
  }
}
