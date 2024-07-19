import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:http/retry.dart';
import 'package:internet_radio_browser/api/structs/country.dart';
import 'package:json_annotation/json_annotation.dart';

import 'enums.dart';
import 'structs/server_stats.dart';
import 'structs/station.dart';

part 'query.g.dart';

enum Filter {
  uuid,
  name,
  nameexact,
  codec,
  codecexact,
  country,
  countryexact,
  countrycodeexact,
  state,
  stateexact,
  language,
  languageexact,
  tag,
  tagexact,
}

const apiBaseUrl = "all.api.radio-browser.info";
final _client = RetryClient(
    IOClient(HttpClient()..userAgent = "internet_radio_browser/1.0"));

Future<List<Station>> getStationsBy(Filter filter, String filterVal,
    {Order order = Order.name,
    bool reverse = false,
    int offset = 0,
    int limit = 100000,
    bool hideBroken = false}) async {
  assert(filterVal.isNotEmpty);
  assert(offset >= 0);
  assert(limit >= 0);
  assert(filter != Filter.countrycodeexact || filterVal.length == 2);
  if (filter == Filter.countrycodeexact) filterVal = filterVal.toUpperCase();

  var url = Uri.http(
      apiBaseUrl,
      "/json/stations/by${filter.name}/$filterVal",
      {
        "order": order,
        "reverse": reverse,
        "offset": offset,
        "limit": limit,
        "hidebroken": hideBroken
      }.map((key, value) => MapEntry(key, value.toString())));
  if (kDebugMode) {
    print("Sending request to $url");
  }
  var resp = await _client.get(url);

  return (jsonDecode(utf8.decode(resp.bodyBytes)) as List<dynamic>)
      .map((e) => Station.fromJson(e))
      .toList(growable: false);
}

const _searchLimit = 100;

@JsonSerializable()
class SearchStationsParams {
  @JsonKey()
  final String? name;
  @JsonKey()
  final bool? nameExact;
  @JsonKey()
  final String? country;
  @JsonKey()
  final bool? countryExact;
  @JsonKey(name: "countrycode")
  final String? countryCode;
  @JsonKey()
  final String? language;
  @JsonKey()
  final bool? languageExact;
  @JsonKey()
  final String? tag;
  @JsonKey()
  final bool? tagExact;
  @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson)
  final List<String>? tagList;
  @JsonKey()
  final String? codec;
  @JsonKey()
  final int? bitrateMin;
  @JsonKey()
  final int? bitrateMax;
  @JsonKey(name: "is_https")
  final bool? isHttps;
  @JsonKey()
  final Order? order;
  @JsonKey()
  final bool? reverse;
  @JsonKey()
  final int limit;
  @JsonKey(name: "hidebroken")
  final bool hideBroken;

  SearchStationsParams({
    this.name,
    this.nameExact,
    this.country,
    this.countryExact,
    this.countryCode,
    this.language,
    this.languageExact,
    this.tag,
    this.tagExact,
    this.tagList,
    this.codec,
    this.bitrateMin,
    this.bitrateMax,
    this.isHttps,
    this.order,
    this.reverse,
    this.limit = _searchLimit,
    this.hideBroken = true,
  });

  factory SearchStationsParams.fromJson(Map<String, dynamic> json) =>
      _$SearchStationsParamsFromJson(json);

  Map<String, dynamic> toJson() => _$SearchStationsParamsToJson(this);

  static List<String>? _tagsFromJson(String? input) =>
      input == null || input.isEmpty
          ? null
          : input.split(",").toList(growable: false);
  static String? _tagsToJson(List<String>? input) => input?.join(",");
}

Map removeEmptyValsFromJson(Map p) {
  return {...p}..removeWhere((key, value) =>
      value == null ||
      ((value is String ||
              value is Map<dynamic, dynamic> ||
              value is List<dynamic>) &&
          value.isEmpty));
}

Future<List<Station>> searchStations(SearchStationsParams params) async {
  var paramsJson = removeEmptyValsFromJson(params.toJson());

  final url = Uri.http(
    apiBaseUrl,
    "/json/stations/search",
    paramsJson.map((key, value) => MapEntry(key, value.toString())),
  );

  if (kDebugMode) {
    print("Sending request to $url");
  }
  final resp = await _client.get(url);

  return (jsonDecode(utf8.decode(resp.bodyBytes)) as List<dynamic>)
      .map((e) => Station.fromJson(e))
      .toList(growable: false);
}

List<Country>? _countryCache;
Future<List<Country>> getCountries() async {
  if (_countryCache == null) {
    var url = Uri.http(apiBaseUrl, "/json/countries");

    if (kDebugMode) {
      print("Sending request to $url");
    }
    var resp = await _client.get(url);

    _countryCache = (jsonDecode(utf8.decode(resp.bodyBytes)) as List<dynamic>)
        .map((e) => Country.fromJson(e))
        .toList(growable: false);
  }

  return Future.value(_countryCache);
}

Future<ServerStats> getServerStats() async {
  var url = Uri.http(apiBaseUrl, "/json/stats");

  if (kDebugMode) {
    print("Sending request to $url");
  }
  var resp = await _client.get(url);

  return ServerStats.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
}
