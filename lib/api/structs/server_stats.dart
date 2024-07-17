import 'package:json_annotation/json_annotation.dart';

part 'server_stats.g.dart';

@JsonSerializable()
class ServerStats {
  @JsonKey(name: "supported_version")
  int supportedVersion;
  @JsonKey(name: "software_version")
  String softwareVersion;
  @JsonKey(name: "status")
  String status;
  @JsonKey(name: "stations")
  int stations;
  @JsonKey(name: "stations_broken")
  int stationsBroken;
  @JsonKey(name: "tags")
  int tags;
  @JsonKey(name: "clicks_last_hour")
  int clicksLastHour;
  @JsonKey(name: "clicks_last_day")
  int clicksLastDay;
  @JsonKey(name: "languages")
  int languages;
  @JsonKey(name: "countries")
  int countries;

  ServerStats({
    required this.supportedVersion,
    required this.softwareVersion,
    required this.status,
    required this.stations,
    required this.stationsBroken,
    required this.tags,
    required this.clicksLastHour,
    required this.clicksLastDay,
    required this.languages,
    required this.countries,
  });

  factory ServerStats.fromJson(Map<String, dynamic> json) =>
      _$ServerStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ServerStatsToJson(this);
}
