import 'package:nyxx/nyxx.dart';

extension MessageListExtension on List<Message> {
  bool containsAllIds(List<int> messageIds) {
    return messageIds.every((msgId) => this.any((message) => message.id.value == msgId));
  }
  void sortByIdAscending() {
    this.sort((a, b) => a.id.compareTo(b.id));
  }
  List<Message> filterByIds(List<int> messageIds) {
    return this.where((message) => messageIds.contains(message.id.value)).toList();
  }
}
