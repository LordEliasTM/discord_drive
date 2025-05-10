class FolderEntry {
  const FolderEntry({
    required this.name,
    required this.indexMessageId,
  });

  final String name;
  final int indexMessageId;
  int get id => indexMessageId;
}
