import 'package:json_annotation/json_annotation.dart';

part 'language.g.dart';

@JsonSerializable()
class Language {
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "iso_639")
  String? code;
  @JsonKey(name: "stationcount")
  int stationcount;

  Language({
    required this.name,
    required this.code,
    required this.stationcount,
  });

  factory Language.fromJson(Map<String, dynamic> json) =>
      _$LanguageFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageToJson(this);
}
