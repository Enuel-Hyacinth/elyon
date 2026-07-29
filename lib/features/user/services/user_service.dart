import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserService {

  //--------------------------------------------------
  // FIREBASE
  //--------------------------------------------------

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  //--------------------------------------------------
  // TYPED USERS COLLECTION
  //--------------------------------------------------

  CollectionReference<UserModel>
      get _users =>
          _firestore
              .collection("users")
              .withConverter<UserModel>(

                fromFirestore: (snapshot, _) =>
                    UserModel.fromMap(
                      snapshot.data()!,
                    ),

                toFirestore: (user, _) =>
                    user.toMap(),

              );

  //--------------------------------------------------
  // CURRENT USER
  //--------------------------------------------------

  User? get currentUser =>
      _auth.currentUser;

  //--------------------------------------------------
  // CURRENT USER ID
  //--------------------------------------------------

  String get currentUserId {

    final user = currentUser;

    if (user == null) {

      throw Exception(
        "No authenticated user.",
      );

    }

    return user.uid;

  }

  //--------------------------------------------------
  // SERVER TIMESTAMP
  //--------------------------------------------------

  FieldValue get serverTimestamp =>
      FieldValue.serverTimestamp();

  //--------------------------------------------------
  // GET CURRENT USER PROFILE
  //--------------------------------------------------

  Future<UserModel?> getCurrentUserProfile() async {

    final user = currentUser;

    if (user == null) {

      return null;

    }

    final snapshot =
        await _users.doc(user.uid).get();

    if (!snapshot.exists) {

      return null;

    }

    return snapshot.data();

  }

  //--------------------------------------------------
  // CREATE USER PROFILE
  //--------------------------------------------------

  Future<UserModel> createUserProfile({

    required String displayName,
    required String email,

  }) async {

    final user = currentUser;

    if (user == null) {

      throw Exception(
        "No authenticated user.",
      );

    }

    final document =
        _users.doc(user.uid);

    final profile = UserModel(

      id: user.uid,

      displayName: displayName,

      email: email,

      photoUrl: user.photoURL ?? "",

      credits: 100,

      subscription: "Free",

      totalProjects: 0,

      totalRenders: 0,

      completedProjects: 0,

      failedProjects: 0,

      storageUsed: 0,

      role: "user",

      notificationsEnabled: true,

      theme: "system",

      language: "English",

      onboardingCompleted: false,

      createdAt: DateTime.now(),

      lastLogin: DateTime.now(),

    );

    try {

      await document.set(profile);

      await document.update({

        "createdAt": serverTimestamp,

        "lastLogin": serverTimestamp,

     });

      return profile;

    } on FirebaseException catch (e) {

      throw Exception(
        "Unable to create profile: ${e.message}",
      );

    }

  }

  //--------------------------------------------------
  // PROFILE EXISTS
  //--------------------------------------------------

  Future<bool> profileExists() async {

    final snapshot =
        await _users
            .doc(currentUserId)
            .get();

    return snapshot.exists;

  }

  //--------------------------------------------------
  // GET PROFILE
  //--------------------------------------------------

  Future<UserModel?> getProfile() async {

    try {

      final snapshot =
          await _users
              .doc(currentUserId)
              .get();

      if (!snapshot.exists) {

        return null;

      }

      return snapshot.data();

    } on FirebaseException catch (e) {

      throw Exception(
        "Unable to load profile: ${e.message}",
      );

    }

  }

  //--------------------------------------------------
  // STREAM PROFILE
  //--------------------------------------------------

  Stream<UserModel?> streamProfile() {

    return _users
        .doc(currentUserId)
        .snapshots()
        .map((snapshot) {

      if (!snapshot.exists) {

        return null;

      }

      return snapshot.data();

    });

  }

  
  //--------------------------------------------------
  // UPDATE PROFILE
  //--------------------------------------------------

  Future<UserModel> updateProfile({

    required UserModel user,

    String? displayName,

    String? photoUrl,

    String? theme,

    String? language,

    bool? notificationsEnabled,

    bool? onboardingCompleted,

  }) async {

    final updated = user.copyWith(

      displayName: displayName,

      photoUrl: photoUrl,

      theme: theme,

      language: language,

      notificationsEnabled: notificationsEnabled,

      onboardingCompleted: onboardingCompleted,

      lastLogin: DateTime.now(),

    );

    try {

      await _users
          .doc(updated.id)
          .update({

        ...updated.toMap(),

        "lastLogin": serverTimestamp,

      });

      if (displayName != null &&
          displayName.isNotEmpty) {

        await currentUser?.updateDisplayName(
          displayName,
        );

      }

      if (photoUrl != null &&
          photoUrl.isNotEmpty) {

        await currentUser?.updatePhotoURL(
          photoUrl,
        );

      }

      await currentUser?.reload();

      return updated;

    } on FirebaseException catch (e) {

      throw Exception(

        "Unable to update profile: ${e.message}",

      );

    }

  }

  //--------------------------------------------------
  // UPDATE PHOTO URL
  //--------------------------------------------------

  Future<void> updatePhotoUrl(

    String photoUrl,

  ) async {

    await _users
        .doc(currentUserId)
        .update({

      "photoUrl": photoUrl,

    });

    await currentUser?.updatePhotoURL(
      photoUrl,
    );

    await currentUser?.reload();

  }

  //--------------------------------------------------
  // UPDATE DISPLAY NAME
  //--------------------------------------------------

  Future<void> updateDisplayName(

    String displayName,

  ) async {

    await _users
        .doc(currentUserId)
        .update({

      "displayName": displayName,

    });

    await currentUser?.updateDisplayName(
      displayName,
    );

    await currentUser?.reload();

  }

    //--------------------------------------------------
  // UPDATE LAST LOGIN
  //--------------------------------------------------

  Future<void> updateLastLogin() async {

    try {

      await _users
          .doc(currentUserId)
          .update({

        "lastLogin": serverTimestamp,

      });

    } on FirebaseException catch (e) {

      throw Exception(

        "Unable to update login: ${e.message}",

      );

    }

  }

  //--------------------------------------------------
  // ADD CREDITS
  //--------------------------------------------------

  Future<void> addCredits({

    required int amount,

  }) async {

    if (amount <= 0) {

      throw Exception(
        "Credit amount must be greater than zero.",
      );

    }

    await _firestore.runTransaction(

      (transaction) async {

        final reference =
            _users.doc(currentUserId);

        final snapshot =
            await transaction.get(reference);

        if (!snapshot.exists) {

          throw Exception(
            "User profile not found.",
          );

        }

        final user = snapshot.data()!;

        transaction.update(

          reference,

          {

            "credits":
                user.credits + amount,

            "lastLogin":
                serverTimestamp,

          },

        );

      },

    );

  }

  //--------------------------------------------------
  // DEDUCT CREDITS
  //--------------------------------------------------

  Future<void> deductCredits({

    required int amount,

  }) async {

    if (amount <= 0) {

      throw Exception(
        "Credit amount must be greater than zero.",
      );

    }

    await _firestore.runTransaction(

      (transaction) async {

        final reference =
            _users.doc(currentUserId);

        final snapshot =
            await transaction.get(reference);

        if (!snapshot.exists) {

          throw Exception(
            "User profile not found.",
          );

        }

        final user = snapshot.data()!;

        if (user.credits < amount) {

          throw Exception(
            "Insufficient credits.",
          );

        }

        transaction.update(

          reference,

          {

            "credits":
                user.credits - amount,

            "lastLogin":
                serverTimestamp,

          },

        );

      },

    );

  }

  //--------------------------------------------------
  // HAS ENOUGH CREDITS
  //--------------------------------------------------

  Future<bool> hasEnoughCredits(

    int requiredCredits,

  ) async {

    final user =
        await getProfile();

    if (user == null) {

      return false;

    }

    return user.credits >=
        requiredCredits;

  }

  //--------------------------------------------------
  // GET CURRENT CREDITS
  //--------------------------------------------------

  Future<int> currentCredits() async {

    final user =
        await getProfile();

    return user?.credits ?? 0;

  }

   //--------------------------------------------------
  // UPDATE SUBSCRIPTION
  //--------------------------------------------------

  Future<void> updateSubscription({

    required String subscription,

  }) async {

    try {

      await _users
          .doc(currentUserId)
          .update({

        "subscription": subscription,

        "lastLogin": serverTimestamp,

      });

    } on FirebaseException catch (e) {

      throw Exception(

        "Unable to update subscription: ${e.message}",

      );

    }

  }

  //--------------------------------------------------
  // UPDATE USER STATISTICS
  //--------------------------------------------------

  Future<void> updateStatistics({

    int projects = 0,

    int renders = 0,

    int completed = 0,

    int failed = 0,

  }) async {

    try {

      await _users
          .doc(currentUserId)
          .update({

        "totalProjects":
            FieldValue.increment(projects),

        "totalRenders":
            FieldValue.increment(renders),

        "completedProjects":
            FieldValue.increment(completed),

        "failedProjects":
            FieldValue.increment(failed),

        "lastLogin":
            serverTimestamp,

      });

    } on FirebaseException catch (e) {

      throw Exception(

        "Unable to update statistics: ${e.message}",

      );

    }

  }

  //--------------------------------------------------
  // DELETE USER PROFILE
  //--------------------------------------------------

  Future<void> deleteProfile() async {

    try {

      await _users
          .doc(currentUserId)
          .delete();

    } on FirebaseException catch (e) {

      throw Exception(

        "Unable to delete profile: ${e.message}",

      );

    }

  }

  //--------------------------------------------------
  // SIGN OUT
  //--------------------------------------------------

  Future<void> signOut() async {

    await _auth.signOut();

  }

  //--------------------------------------------------
  // RUN TRANSACTION
  //--------------------------------------------------

  Future<T> runTransaction<T>(

    Future<T> Function(
      Transaction transaction,
    ) action,

  ) async {

    return _firestore.runTransaction<T>(

      (transaction) async {

        return action(transaction);

      },

    );

  }

  //--------------------------------------------------
  // HEALTH CHECK
  //--------------------------------------------------

  Future<bool> ping() async {

    try {

      await _firestore
          .collection("_health")
          .limit(1)
          .get();

      return true;

    } catch (_) {

      return false;

    }

  }

}