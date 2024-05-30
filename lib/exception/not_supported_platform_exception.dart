
class NotSupportedPlatformException extends Error implements UnsupportedError {
  @override
  final String? message;
  NotSupportedPlatformException([this.message]);
  @override
  String toString() {
    var message = this.message;
    return (message != null)
        ? "NotSupportedPlatformException: $message"
        : "NotSupportedPlatformException";
  }
}