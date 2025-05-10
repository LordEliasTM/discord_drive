class FileEntry {
  const FileEntry({
    required this.name,
    required this.chunkIndexMessageId,
    required this.size,
  });

  final String name;
  final int chunkIndexMessageId;
  int get id => chunkIndexMessageId;
  final int size;
}
