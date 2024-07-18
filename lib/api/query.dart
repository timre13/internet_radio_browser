import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:http/retry.dart';
import 'package:internet_radio_browser/api/structs/country.dart';

import 'enums.dart';
import 'structs/server_stats.dart';
import 'structs/station.dart';

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

Future<List<Station>> searchStations({
  String? name,
  bool? nameExact,
  String? country,
  bool? countryExact,
  String? countryCode,
  String? language,
  bool? languageExact,
  String? tag,
  bool? tagExact,
  List<String>? tagList,
  String? codec,
  int? bitrateMin,
  int? bitrateMax,
  bool? isHttps,
  Order? order,
  bool? reverse,
  int limit = _searchLimit,
  bool hideBroken = true,
}) async {
  var params = {
    "name": name,
    "nameExact": nameExact,
    "country": country,
    "countryExact": countryExact,
    "countrycode": countryCode,
    "language": language,
    "languageExact": languageExact,
    "tag": tag,
    "tagExact": tagExact,
    "tagList": tagList?.join(","),
    "codec": codec,
    "bitrateMin": bitrateMin,
    "bitrateMax": bitrateMax,
    "is_https": isHttps,
    "order": order.toString(),
    "reverse": reverse,
    "limit": limit,
    "hidebroken": hideBroken,
  };
  params.removeWhere((key, value) => value == null);

  final url = Uri.http(
    apiBaseUrl,
    "/json/stations/search",
    params.map((key, value) => MapEntry(key, value.toString())),
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
