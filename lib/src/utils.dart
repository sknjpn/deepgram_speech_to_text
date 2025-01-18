import 'dart:convert';
import 'dart:typed_data';

/// Builds a URL with query parameters.
///
/// Merge the base query parameters with the query parameters (base are overridden by the method's)
Uri buildUrl(String baseUrl, Map<String, dynamic>? baseQueryParams,
    Map<String, dynamic>? queryParams) {
  final uri = Uri.parse(baseUrl);

  // マージしたパラメータを取得
  final mergedParams = mergeMaps(baseQueryParams, queryParams);

  // クエリ文字列を手動で構築
  final queryParts = <String>[];
  mergedParams.forEach((key, value) {
    if (value is List) {
      // リストの場合、各要素を同じキーで追加
      for (var item in value) {
        queryParts.add('$key=${Uri.encodeComponent(item.toString())}');
      }
    } else {
      // リスト以外は通常通り追加
      queryParts.add('$key=${Uri.encodeComponent(value.toString())}');
    }
  });

  // クエリ文字列を作成
  final queryString = queryParts.join('&');

  // 新しいURIを作成（クエリ文字列を手動で追加）
  return uri.replace(query: queryString);
}

/// Merges two maps, returning a new map. If both maps have the same key, the value from map2 is used.
Map<String, dynamic> mergeMaps(
    Map<String, dynamic>? map1, Map<String, dynamic>? map2) {
  return {...?map1, ...?map2};
}

String toUt8(String text) {
  if (text.isEmpty) {
    return text;
  }

  try {
    return utf8.decode(text.runes.toList());
  } catch (e) {
    return text;
  }
}

class Headers {
  static const authorization = "authorization";
  static const contentType = "content-type";
  static const accept = "accept";
}

/// Get a 1 sec duration sample audio data encoded in base64.
Uint8List getSampleAudioData() {
  // 1 sec of audio encoded in base64 (french mp3)
  String base64Audio =
      "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MGZ7ylxSjqZPmaHMXGKxF5ASY4XizDNmVzM6qEFsujXJNd/81EBleR75K//9WcMdx3OGmUiA3e5CYlMW4xgiIhrfyoUDr1LW1lkAkrdklGNq5ypvnvE2r58OziWqMIgOs7n8h5+cxSLpmo8bTJqackYeIijKrMZgcn//WxWR1///90VMopRl2LFrhwDQwYxT4tOKJO5TmUC5WomoABlkAkrdklGNq5ypvnvE2r58OziWqMIgOs7n8h5+cxSLpmo8bTJqackYeIijKrMZgcn//WxWR1///90VMopRl2LFrhwDQwYy+LTikO5TpQLlaiaqCDJusjcjmu/geFcYI2npTntIb1m3E59JH8RzeiRQwiql2ZmiUbbTaZWxEMd10FgpX//yraxWZG//86gxzlFMMS7fO3aLGp//+pIApAgjgAKhTGJpARacU8mcDSAi04oNKYuipFBxQKUxdFSKDvqaHws6QCLxAUNX4FYCEBLG0m07LvA8K4gCNp6U57SG9ZtxOfSR/Ec3okUMIqpdmZolG202mVsRDHddBYKV//8q2sVmRv//dQY5yimEku3zt2i2b/4qXA5CoAE1HAy5PCQASd0ljkdtvxuMFIk8HDIcaCY7dRoSuyeGG07iDkHIzqg6Fa5nb7PvQyuROlBAf//U1X39v/7qewIchRRWE007MoRxFP+koeOudNvhbGC8ekAJO6SxyO2343GCkSeDhkONBMduo0JXZPDDadxByDkZ1QdCtczt9n3oZXInSggP//qar7+3/91PYEOQoorCaadmUI4in/SUPHXOm3z+MF49NQAAXWSQmWE6NL/L0Ut/p6/JXtUosgfej3JUZgzKqpe9naJM1VMOctXarhFxjKO191Gs/+0n///736owoVHCFy3tIhkoLAJ0Y1ngqvIi1E2HXQKtwAACjAISUEuwwlNhzi9I2rJW+I5RDuLEfvR7kqMwZlVUveztEmaq//qSAEIEPQCCm0FeaAwQbFMoK401IjiKVTNrTCRFEUembWmEiKKj2r8i4xlHa+6jWf/aT///979UYUKjhC5b2kQyUFhjoxrPBVbpEWomw66BVqAAdggJQSXnrZY/VIToZArlCL4QNaO4aUAY14VUCu5TluEyae6Ncql3W6pmFNI2jHYWVpn6ZHt////mrkwSFMczd5CFOwhZA7A4db/wKbMtXtULOwQEpJLz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";
  Uint8List decodedAudio = base64Decode(base64Audio);

  return decodedAudio;
}
