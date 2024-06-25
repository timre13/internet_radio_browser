import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class StationListWidget extends StatefulWidget {
  const StationListWidget({super.key});

  @override
  State<StationListWidget> createState() => _StationListWidgetState();
}

class _StationListWidgetState extends State<StationListWidget> {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<PlayerModel>(context);

    return SingleChildScrollView(
        child: DataTable(
      showCheckboxColumn: false,
      rows: model.stations
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
                  selected: model.selStationI == i,
                  onSelectChanged: (value) async {
                    model.selStationI = i;
                    model.isPlaying = true;
                    assert(model.selStation != null);
                    print("Playing URL: ${model.selStation?.urlResolved}");
                    print(model.selStation);
                    await model.player
                        .setSourceUrl(model.selStation?.urlResolved ?? "");
                    model.player.resume();
                  },
                  color: WidgetStatePropertyAll(model.selStationI == i
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
