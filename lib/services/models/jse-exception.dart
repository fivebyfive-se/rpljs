
class JseException implements Exception {
  JseException({this.message = 'JseException'});
  final String message;
}

class JseStoppedException extends JseException {
  JseStoppedException({
    String message = 'JseStoppedException'
  }) : super(message: message);
}