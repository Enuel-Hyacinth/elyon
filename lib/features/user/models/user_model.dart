import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  final String id;

  final String displayName;

  final String email;

  final String photoUrl;

  final int credits;

  final String subscription;

  final int totalProjects;

  final int totalRenders;

  final int completedProjects;

  final int failedProjects;

  final double storageUsed;

  final String role;

  final bool notificationsEnabled;

  final String theme;

  final String language;

  final bool onboardingCompleted;

  final DateTime createdAt;

  final DateTime lastLogin;

  const UserModel({

    required this.id,

    required this.displayName,

    required this.email,

    required this.photoUrl,

    required this.credits,

    required this.subscription,

    required this.totalProjects,

    required this.totalRenders,

    required this.completedProjects,

    required this.failedProjects,

    required this.storageUsed,

    required this.role,

    required this.notificationsEnabled,

    required this.theme,

    required this.language,

    required this.onboardingCompleted,

    required this.createdAt,

    required this.lastLogin,

  });
  //--------------------------------------------------
  // TO MAP
  //--------------------------------------------------

  Map<String, dynamic> toMap() {

    return {

      "id": id,

      "displayName": displayName,

      "email": email,

      "photoUrl": photoUrl,

      "credits": credits,

      "subscription": subscription,

      "totalProjects": totalProjects,

      "totalRenders": totalRenders,

      "completedProjects": completedProjects,

      "failedProjects": failedProjects,

      "storageUsed": storageUsed,

      "role": role,

      "notificationsEnabled":
          notificationsEnabled,

      "theme": theme,

      "language": language,

      "onboardingCompleted":
          onboardingCompleted,

      "createdAt":
          Timestamp.fromDate(createdAt),

      "lastLogin":
          Timestamp.fromDate(lastLogin),

    };

  }

  //--------------------------------------------------
  // FROM MAP
  //--------------------------------------------------

  factory UserModel.fromMap(
    Map<String, dynamic> map,
  ) {

    return UserModel(

      id: map["uid"] ?? map["id"] ?? "",

      displayName:
          map["displayName"] ?? "",

      email:
          map["email"] ?? "",

      photoUrl:
          map["photoUrl"] ?? "",

      credits:
          map["credits"] ?? 0,

      subscription:
          map["subscription"] ?? "Free",

      totalProjects:
          map["totalProjects"] ?? 0,

      totalRenders:
          map["totalRenders"] ?? 0,

      completedProjects:
          map["completedProjects"] ?? 0,

      failedProjects:
          map["failedProjects"] ?? 0,

      storageUsed:
          (map["storageUsed"] ?? 0)
              .toDouble(),

      role:
          map["role"] ?? "user",

      notificationsEnabled:
          map["notificationsEnabled"] ?? true,

      theme:
          map["theme"] ?? "system",

      language:
          map["language"] ?? "English",

      onboardingCompleted:
          map["onboardingCompleted"] ?? false,

      createdAt:

       map["createdAt"] is Timestamp

         ? (map["createdAt"] as Timestamp).toDate()

         : DateTime.now(),

      lastLogin:

      map["lastLogin"] is Timestamp

         ? (map["lastLogin"] as Timestamp).toDate()

         : DateTime.now(),

    );

  }
  //--------------------------------------------------
  // COPY WITH
  //--------------------------------------------------

  UserModel copyWith({

    String? id,

    String? displayName,

    String? email,

    String? photoUrl,

    int? credits,

    String? subscription,

    int? totalProjects,

    int? totalRenders,

    int? completedProjects,

    int? failedProjects,

    double? storageUsed,

    String? role,

    bool? notificationsEnabled,

    String? theme,

    String? language,

    bool? onboardingCompleted,

    DateTime? createdAt,

    DateTime? lastLogin,

  }) {

    return UserModel(

      id: id ?? this.id,

      displayName:
          displayName ?? this.displayName,

      email:
          email ?? this.email,

      photoUrl:
          photoUrl ?? this.photoUrl,

      credits:
          credits ?? this.credits,

      subscription:
          subscription ?? this.subscription,

      totalProjects:
          totalProjects ?? this.totalProjects,

      totalRenders:
          totalRenders ?? this.totalRenders,

      completedProjects:
          completedProjects ??
              this.completedProjects,

      failedProjects:
          failedProjects ??
              this.failedProjects,

      storageUsed:
          storageUsed ?? this.storageUsed,

      role:
          role ?? this.role,

      notificationsEnabled:
          notificationsEnabled ??
              this.notificationsEnabled,

      theme:
          theme ?? this.theme,

      language:
          language ?? this.language,

      onboardingCompleted:
          onboardingCompleted ??
              this.onboardingCompleted,

      createdAt:
          createdAt ?? this.createdAt,

      lastLogin:
          lastLogin ?? this.lastLogin,

    );

  }
  //--------------------------------------------------
  // PREMIUM USER
  //--------------------------------------------------

  bool get isPremium =>

      subscription == "Pro" ||

      subscription == "Enterprise";

  //--------------------------------------------------
  // ADMIN
  //--------------------------------------------------

  bool get isAdmin =>

      role == "admin";

  //--------------------------------------------------
  // HAS CREDITS
  //--------------------------------------------------

  bool get hasCredits =>

      credits > 0;

  //--------------------------------------------------
  // CAN RENDER
  //--------------------------------------------------

  bool get canRender =>

      hasCredits &&
      onboardingCompleted;

  //--------------------------------------------------
  // IS NEW USER
  //--------------------------------------------------

  bool get isNewUser =>

      totalProjects == 0;

  //--------------------------------------------------
  // AVAILABLE STORAGE
  //--------------------------------------------------

  double get remainingStorage =>

      100 - storageUsed;

  //--------------------------------------------------
  // STORAGE %
  //--------------------------------------------------

  double get storagePercentage {

    if (storageUsed <= 0) {

      return 0;

    }

    return storageUsed / 100;

  }

  //--------------------------------------------------
  // SUCCESS RATE
  //--------------------------------------------------

  double get successRate {

    if (totalRenders == 0) {

      return 0;

    }

    return completedProjects /
        totalRenders;

  }

  //--------------------------------------------------
  // FAILURE RATE
  //--------------------------------------------------

  double get failureRate {

    if (totalRenders == 0) {

      return 0;

    }

    return failedProjects /
        totalRenders;

  }

  //--------------------------------------------------
  // MEMBER SINCE
  //--------------------------------------------------

  Duration get membershipDuration =>

      DateTime.now().difference(
        createdAt,
      );
  //--------------------------------------------------
  // EQUALITY
  //--------------------------------------------------

  @override
  bool operator ==(Object other) {

    if (identical(this, other)) {

      return true;

    }

    return other is UserModel &&

        other.id == id &&

        other.email == email;

  }

  //--------------------------------------------------
  // HASHCODE
  //--------------------------------------------------

  @override
  int get hashCode =>

      Object.hash(
        id,
        email,
      );

  //--------------------------------------------------
  // TOSTRING
  //--------------------------------------------------

  @override
  String toString() {

    return '''

UserModel(

  id: $id,

  displayName: $displayName,

  email: $email,

  credits: $credits,

  subscription: $subscription,

  totalProjects: $totalProjects,

  totalRenders: $totalRenders,

  completedProjects: $completedProjects,

  failedProjects: $failedProjects,

)

''';

  }

}