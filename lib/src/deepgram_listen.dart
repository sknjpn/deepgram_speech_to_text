import 'dart:convert';

import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:deepgram_speech_to_text/src/deepgram_live_transcriber.dart';
import 'package:deepgram_speech_to_text/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:universal_file/universal_file.dart';

/// The Speech to Text API.
class DeepgramListen {
  DeepgramListen(
    this._client,
  ) {
    print('DeepgramListen constructor');
  }

  final String _baseSttUrl = 'https://api.deepgram.com/v1/listen';

  final Deepgram _client;

  /// Transcribe from raw data.
  ///
  /// https://developers.deepgram.com/reference/listen-file
  Future<DeepgramSttResult> bytes(List<int> data, {Map<String, dynamic>? queryParams}) async {
    http.Response res = await http.post(
      buildUrl(_baseSttUrl, _client.baseQueryParams, queryParams),
      headers: {
        Headers.authorization: 'Token ${_client.apiKey}',
      },
      body: data,
    );

    return DeepgramSttResult(res.body);
  }

  /// Transcribe a local audio file.
  ///
  /// https://developers.deepgram.com/reference/listen-file
  Future<DeepgramSttResult> file(File file, {Map<String, dynamic>? queryParams}) async {
    assert(file.existsSync());
    final data = await file.readAsBytes();

    return bytes(data, queryParams: queryParams);
  }

  /// Transcribe a local audio file from path.
  ///
  /// https://developers.deepgram.com/reference/listen-file
  Future<DeepgramSttResult> path(String path, {Map<String, dynamic>? queryParams}) {
    final f = File(path);
    return file(f, queryParams: queryParams);
  }

  /// Transcribe a remote audio file from URL.
  ///
  /// https://developers.deepgram.com/reference/listen-remote
  Future<DeepgramSttResult> url(String url, {Map<String, dynamic>? queryParams}) async {
    http.Response res = await http.post(
      buildUrl(_baseSttUrl, _client.baseQueryParams, queryParams),
      headers: {
        Headers.authorization: 'Token ${_client.apiKey}',
        Headers.contentType: 'application/json',
        Headers.accept: 'application/json',
      },
      body: jsonEncode({'url': url}),
    );

    return DeepgramSttResult(res.body);
  }

  /// Create a live transcriber with a start and close method.
  ///
  /// see [DeepgramLiveTranscriber] which you can also use directly
  ///
  /// https://developers.deepgram.com/reference/listen-live
  DeepgramLiveTranscriber liveTranscriber(Stream<List<int>> audioStream, {Map<String, dynamic>? queryParams}) {
    return DeepgramLiveTranscriber(_client.apiKey, inputAudioStream: audioStream, queryParams: mergeMaps(_client.baseQueryParams, queryParams));
  }

  /// Transcribe a live audio stream.
  ///
  /// https://developers.deepgram.com/reference/listen-live
  Stream<DeepgramSttResult> live(Stream<List<int>> audioStream, {Map<String, dynamic>? queryParams}) {
    DeepgramLiveTranscriber transcriber = liveTranscriber(audioStream, queryParams: queryParams);

    transcriber.start();
    return transcriber.stream;
  }
}
