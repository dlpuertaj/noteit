class Folder {
  const Folder({
    required this.id,
    required this.name,
    required this.parentId,
    required this.depth,
    required this.isSystem,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? parentId;
  final int depth;
  final bool isSystem;
  final DateTime createdAt;

  Folder copyWith({
    String? id,
    String? name,
    String? parentId,
    int? depth,
    bool? isSystem,
    DateTime? createdAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      depth: depth ?? this.depth,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
