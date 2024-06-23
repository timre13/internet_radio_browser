import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'station.g.dart';

@JsonSerializable()
class Station {
  @JsonKey(name: "changeuuid")
  final String changeuuid;
  @JsonKey(name: "stationuuid")
  final String stationuuid;
  @JsonKey(name: "serveruuid")
  final String? serveruuid;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "url")
  final String url;
  @JsonKey(name: "url_resolved")
  final String urlResolved;
  @JsonKey(name: "homepage")
  final String homepage;
  @JsonKey(name: "favicon")
  final String favicon;
  @JsonKey(name: "tags", fromJson: _strValsFromJson, toJson: _strValsToJson)
  final List<String> tags;
  @JsonKey(name: "country")
  final String country;
  @JsonKey(name: "countrycode")
  final String countrycode;
  @JsonKey(name: "iso_3166_2")
  final dynamic iso31662;
  @JsonKey(name: "state")
  final String state;
  @JsonKey(name: "language", fromJson: _strValsFromJson, toJson: _strValsToJson)
  final List<String> language;
  @JsonKey(
      name: "languagecodes", fromJson: _strValsFromJson, toJson: _strValsToJson)
  final List<String> languagecodes;
  @JsonKey(name: "votes")
  final int votes;
  @JsonKey(name: "lastchangetime_iso8601")
  final DateTime lastchangetimeIso8601;
  @JsonKey(name: "codec")
  final Codec codec;
  @JsonKey(name: "bitrate")
  final int bitrate;
  @JsonKey(name: "hls")
  final int hls;
  @JsonKey(name: "lastcheckok")
  final int lastcheckok;
  @JsonKey(name: "lastchecktime_iso8601")
  final DateTime lastchecktimeIso8601;
  @JsonKey(name: "lastcheckoktime")
  final DateTime lastcheckoktimeIso8601;
  @JsonKey(name: "lastlocalchecktime_iso8601")
  final DateTime? lastlocalchecktimeIso8601;
  @JsonKey(name: "clicktimestamp_iso8601")
  final DateTime? clicktimestampIso8601;
  @JsonKey(name: "clickcount")
  final int clickcount;
  @JsonKey(name: "clicktrend")
  final int clicktrend;
  @JsonKey(name: "ssl_error")
  final int sslError;
  @JsonKey(name: "geo_lat")
  final double? geoLat;
  @JsonKey(name: "geo_long")
  final double? geoLong;
  @JsonKey(name: "has_extended_info")
  final bool? hasExtendedInfo;

  Station({
    required this.changeuuid,
    required this.stationuuid,
    required this.serveruuid,
    required this.name,
    required this.url,
    required this.urlResolved,
    required this.homepage,
    required this.favicon,
    required this.tags,
    required this.country,
    required this.countrycode,
    required this.iso31662,
    required this.state,
    required this.language,
    required this.languagecodes,
    required this.votes,
    required this.lastchangetimeIso8601,
    required this.codec,
    required this.bitrate,
    required this.hls,
    required this.lastcheckok,
    required this.lastchecktimeIso8601,
    required this.lastcheckoktimeIso8601,
    required this.lastlocalchecktimeIso8601,
    required this.clicktimestampIso8601,
    required this.clickcount,
    required this.clicktrend,
    required this.sslError,
    required this.geoLat,
    required this.geoLong,
    required this.hasExtendedInfo,
  });

  factory Station.fromJson(Map<String, dynamic> json) =>
      _$StationFromJson(json);

  Map<String, dynamic> toJson() => _$StationToJson(this);

  @override
  String toString() => jsonEncode(toJson());

  static List<String> _strValsFromJson(String input) =>
      input.split(",").toList(growable: false);
  static String _strValsToJson(List<String> input) => input.join(",");
}

enum Codec {
  @JsonValue("AAC")
  aac,
  @JsonValue("AAC+")
  aacplus,
  @JsonValue("AAC+,H.264")
  aacplusH264,
  @JsonValue("AAC,H.264")
  aacH264,
  @JsonValue("FLAC")
  flac,
  @JsonValue("FLV")
  flv,
  @JsonValue("MP3")
  mp3,
  @JsonValue("MP3,H.264")
  mp3H264,
  @JsonValue("OGG")
  ogg,
  @JsonValue("UNKNOWN")
  unknown,
  @JsonValue("UNKNOWN,H.264")
  unknownH264,
  @JsonValue("")
  unspecified,
}

final codecValues = EnumValues({
  "AAC": Codec.aac,
  "AAC+": Codec.aacplus,
  "AAC+,H.264": Codec.aacplusH264,
  "AAC,H.264": Codec.aacH264,
  "FLAC": Codec.flac,
  "FLV": Codec.flv,
  "MP3": Codec.mp3,
  "MP3,H.264": Codec.mp3H264,
  "OGG": Codec.ogg,
  "UNKNOWN": Codec.unknown,
  "UNKNOWN,H.264": Codec.unknownH264,
  "": Codec.unspecified,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
