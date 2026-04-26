class TryOnResult {
  final String id;
  final String resultUrl;
  final String? cacheKey;
  final DateTime createdAt;

  const TryOnResult({
    required this.id,
    required this.resultUrl,
    this.cacheKey,
    required this.createdAt,
  });

  factory TryOnResult.fromJson(Map<String, dynamic> json) {
    return TryOnResult(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      resultUrl: json['resultUrl'] as String,
      cacheKey: json['cacheKey'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
