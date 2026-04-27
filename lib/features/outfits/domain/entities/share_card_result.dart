import 'package:freezed_annotation/freezed_annotation.dart';

part 'share_card_result.freezed.dart';
part 'share_card_result.g.dart';

@freezed
class ShareCardResult with _$ShareCardResult {
  const factory ShareCardResult({
    required String url,
    required String expiresAt,
    required String outfitId,
  }) = _ShareCardResult;

  factory ShareCardResult.fromJson(Map<String, dynamic> json) =>
      _$ShareCardResultFromJson(json);
}
