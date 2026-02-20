class CleanMessageId {
  static String clean(String messageId) {
    return messageId.replaceAll(':', '').replaceAll('%', '');
  }
}
