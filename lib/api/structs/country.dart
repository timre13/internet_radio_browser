import 'package:json_annotation/json_annotation.dart';

part 'country.g.dart';

@JsonSerializable()
class Country {
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "iso_3166_1")
  final String code;
  @JsonKey(name: "stationcount")
  final int stationcount;

  Country({
    required this.name,
    required this.code,
    required this.stationcount,
  });

  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);

  Map<String, dynamic> toJson() => _$CountryToJson(this);
}
