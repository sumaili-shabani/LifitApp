class ApiKeys {
  static const String googleMapsKey = 'AIzaSyC6-UOrf9k9HrsGHwQt8EW6EsYqi58GFHo';

  // Vérifier que la clé API est activée pour les services suivants :
  // - Maps SDK for Android
  // - Maps SDK for iOS
  // - Directions API
  // - Places API
  static bool isConfigured() {
    return googleMapsKey.isNotEmpty && googleMapsKey != 'YOUR_API_KEY';
  }
}
