// lib/data/models/common/paged_response.dart
class PagedResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final bool last;
  final int numberOfElements;
  final bool empty;

  PagedResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
    required this.numberOfElements,
    required this.empty,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final list = (json['content'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => fromJsonT(Map<String, dynamic>.from(e)))
        .toList();

    return PagedResponse(
      content: list,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      first: json['first'] ?? false,
      last: json['last'] ?? false,
      numberOfElements: json['numberOfElements'] ?? list.length,
      empty: json['empty'] ?? list.isEmpty,
    );
  }
}
