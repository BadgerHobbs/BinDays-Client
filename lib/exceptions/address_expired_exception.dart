/// Thrown when the API returns 410 Gone, indicating that the cached address UID
/// is no longer valid for the current collector version. The user must re-select
/// their address to obtain a UID in the new format.
class AddressExpiredException implements Exception {
  const AddressExpiredException();

  @override
  String toString() =>
      'The cached address UID is no longer valid for this collector. Please re-select your address.';
}
