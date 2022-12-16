import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
//import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SpotifyLyricsData());
  }
}

class SpotifyLyricsData extends StatefulWidget {
  @override
  SpotifyLyricsState createState() => SpotifyLyricsState();
}

class SpotifyLyricsState extends State<SpotifyLyricsData> {
  final String SPOTIFY_URL = 'https://open.spotify.com/';
  final String SPOTIFY_GET_CURRENT_TRACK_URL =
      'https://api.spotify.com/v1/me/player/currently-playing';
  String track_id = '11dFghVXANMlKmJXsNCbNl';
  String track_id_tmp = '';
  String track_name = '';
  int current_time = 0;

  final String SPOTIFY_GET_CURRENT_LYRIC_URL =
      'https://spclient.wg.spotify.com/color-lyrics/v2/track/';
  final String sp_dc =
      'AQCp0Kbw3NiztVeo0tAa3DS4gzD9v22PhXr-3nDKusbTQIrL9CyJ7-BEkA9Nw_bMRMa055J_Inw2hkBLp92ij-yTIzmQh4U2qfqKp7EkBduLMlYiRuCvAKNv-Nk2063H9qI0eY-jTDrm2pCO6ntvRSMhyfA-Ebg';
  final String sp_key = 'c3a1d84c-439b-4d79-8f79-d752c3772498';
  String token =
      'BQDgylpx9YeB-0MdwYPVxPAD0exMH5BDw5ZFxUq1QwYffZVFXt-wSxk37OlJwyzyWTwhYH3oOQcE8-m_7mX1Az4_SnVP8BXDybrTucVoiMb_wt3klK11eM0N2Kajapg-ZNUoFuKzc30eaAKMVwCn9iCNvsQOhRQDOaq-cdbdudQSpRL_Z6Qd9c-mIry6G7nS6-e201LltKnTx5TA2l2lWA1_4bSksSC1KTetURb_TghgSZb5fELQih9nliFB-VhotCqBnkPBPxEDMfbc_8jOW69dz_LieeHnqWlldyHGWZlxsQYVPaCRgwESvVMoULp_tl2D';
  int token_exp_time = 0;
  String config_json = '';
  String past_lyrics = '';
  String future_lyrics = '';
  String current_lyrics = '';
  List lyrics = [];
  String test = '';

  Future<void> get_token() async {
    /*
    var resonse =
        await http.get(Uri.parse(Uri.encodeFull(SPOTIFY_URL)), headers: {
      "User-Agent":
          "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.0.0 Safari/537.36",
      "App-platform": "WebPlayer",
      "content-type": "text/html; charset=utf-8",
      "cookie": "sp_dc=$sp_dc"
    });

    bool exists = await File('config.json').exists();
    if (exists) {
      config_json = File('config.json').readAsStringSync();
      token_exp_time =
          jsonDecode(config_json)['accessTokenExpirationTimestampMs'];
    }
    */

    var response = await http.get(
        Uri.parse(Uri.encodeFull(
            "https://open.spotify.com/get_access_token?reason=transport&productType=web_player")),
        headers: {
          "user-agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36",
          "cookie": "sp_dc=$sp_dc; sp_key=$sp_key"
        });

    var resp_json = jsonDecode(response.body);
    token = resp_json['accessToken'];
    token_exp_time = resp_json['accessTokenExpirationTimestampMs'];
  }

  Future<void> get_track() async {
    var response = await http.get(
        Uri.parse(Uri.encodeFull(SPOTIFY_GET_CURRENT_TRACK_URL)),
        headers: {"Authorization": "Bearer $token"});

    if (response.statusCode == 200) {
      setState(() {
        var resp_json = jsonDecode(response.body);
        if (resp_json['item'] != null) {
          track_id = resp_json['item']['id'];
          track_name = resp_json['item']['name'];
          current_time = resp_json['progress_ms'];
        }
      });
    } else {
      track_id = 'no data';
      track_name = 'no data';
      current_time = 0;
    }
  }

  void setCurrentLyric(List lyrics) {
    for (int ii = 0; ii < lyrics.length - 1; ii++) {
      if (current_time > int.parse(lyrics[ii]['startTimeMs']) &&
          current_time < int.parse(lyrics[ii + 1]['startTimeMs'])) {
        if (ii > 0) {
          past_lyrics = lyrics[ii - 1]['words'];
        }
        if (ii < lyrics.length - 1) {
          future_lyrics = lyrics[ii + 1]['words'];
        }
        current_lyrics = lyrics[ii]['words'];
      }
    }

    return lyrics[lyrics.length - 1]['words'];
  }

  Future<void> get_lyrics() async {
    var response = await http.get(
        Uri.parse(Uri.encodeFull(
            '$SPOTIFY_GET_CURRENT_LYRIC_URL$track_id?format=json&market=from_token')),
        headers: {
          "User-Agent":
              "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.0.0 Safari/537.36",
          "App-platform": "WebPlayer",
          "Authorization": "Bearer $token"
        });

    if (response.statusCode == 200) {
      setState(() {
        var resp_json = jsonDecode(response.body);
        setCurrentLyric(resp_json['lyrics']['lines']);
      });
    } else {
      current_lyrics = 'no lyrics available';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Current Spotify Information"),
            backgroundColor: Colors.pink),
        body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Track_id: $track_id", textScaleFactor: 2),
                Text("Track_name: $track_name", textScaleFactor: 2),
                Text("Current_Time: $current_time", textScaleFactor: 2),
                Text("Past_Lyrics:      $past_lyrics", textScaleFactor: 2),
                Text("Current_Lyrics: $current_lyrics", textScaleFactor: 2),
                //Text("Future_Lyrics:   $future_lyrics", textScaleFactor: 2)
              ]),
        ));
  }

  @override
  void initState() {
    super.initState();
    this.get_token();

    Timer.periodic(Duration(milliseconds: 500), (Timer t) {
      setState(() {
        this.get_track();
        this.get_lyrics();

        int currTime = DateTime.now().millisecondsSinceEpoch;
        if (token_exp_time < currTime) {
          this.get_token();
        }
      });
    });
  }
}
