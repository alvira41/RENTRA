/// Error dengan pesan yang sudah siap ditampilkan ke user.
class AppException implements Exception {
  final String message;
  AppException(this.message);
  @override
  String toString() => message;
}