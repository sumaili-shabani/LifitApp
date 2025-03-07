class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profilePicture;
  final String? homeAddress;
  final String? workAddress;
  final double rating;
  final int totalRides;
  final List<String> favoriteLocations;
  final Map<String, String>
      preferences; // Préférences utilisateur (langue, thème, etc.)

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
    this.homeAddress,
    this.workAddress,
    this.rating = 0.0,
    this.totalRides = 0,
    this.favoriteLocations = const [],
    this.preferences = const {},
  });

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    String? homeAddress,
    String? workAddress,
    double? rating,
    int? totalRides,
    List<String>? favoriteLocations,
    Map<String, String>? preferences,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      homeAddress: homeAddress ?? this.homeAddress,
      workAddress: workAddress ?? this.workAddress,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      favoriteLocations: favoriteLocations ?? this.favoriteLocations,
      preferences: preferences ?? this.preferences,
    );
  }
}
