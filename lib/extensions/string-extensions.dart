
final whitespaceRex = RegExp(r'^\s+$');

extension StringExtensions on String {
  bool isWhitespace() => whitespaceRex.hasMatch(this);

  bool isFalsy() => this == null || this == "" || this.isWhitespace();
  bool isTruthy() => !this.isFalsy();

  String append(String suffix)  => this + suffix;
  String prepend(String prefix) => prefix + this;

  String truncate({int maxLength = 50, String ellipsis = "..."}) {
    if (this != null && this.length >= maxLength) {
      final keepLength = maxLength - ellipsis.length;
      return this.substring(0, keepLength).append(ellipsis);
    }
    return this;
  }
}