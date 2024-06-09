import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'user_repo.dart';
import 'models/models.dart';
class FirebaseUserRepo implements UserRepository {
	final FirebaseAuth _firebaseAuth;
	final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

	final usersCollection = FirebaseFirestore.instance.collection('users');

	FirebaseUserRepo({
		FirebaseAuth? firebaseAuth,
	}) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

	@override
  Stream<User?> get user {
		return _firebaseAuth.authStateChanges().map((firebaseUser) {
			return firebaseUser;
		});
	}

	@override
	Future<void> signIn(String email, String password) async {
		try {
			await _firebaseAuth.signInWithEmailAndPassword(
					email: email,
					password: password
			);
			// Retrieve FCM token
			String? fcmToken = await _firebaseMessaging.getToken();

			// Save FCM token to Firestore document associated with the user
				await saveFCMTokenToFirestore(_firebaseAuth.currentUser!.uid, fcmToken!);
					} catch (e) {
			log(e.toString());
			rethrow;
		}
	}

	// Save FCM Token to Firestore
	Future<void> saveFCMTokenToFirestore(String userId, String fcmToken) async {
		try {
			await FirebaseFirestore.instance.collection('users').doc(userId).update({
				'fcmToken': fcmToken,
			});
		} catch (e) {
			print("Error saving FCM token to Firestore: $e");
			rethrow;
		}
	}
	@override
	Future<MyUser> signUp(MyUser myUser, String password) async {
		try {
			UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
				email: myUser.email,
				password: password,
			);

			// Update myUser with the userId generated by Firebase
			myUser = myUser.copyWith(
				userId: userCredential.user!.uid,
			);

			// Save user data to Firestore
			await setUserData(myUser);

			// Retrieve FCM token
			String? fcmToken = await _firebaseMessaging.getToken();

			// Save FCM token to Firestore document associated with the user
				await saveFCMTokenToFirestore(myUser.userId, fcmToken!);

			return myUser;
		} catch (e) {
			log(e.toString());
			rethrow;
		}
	}

	  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await usersCollection
				.doc(myUser.userId)
				.set(myUser.toEntity().toDocument());

			// Retrieve FCM token
			String? fcmToken = await _firebaseMessaging.getToken();

			// Save FCM token to Firestore document associated with the user
			await saveFCMTokenToFirestore(_firebaseAuth.currentUser!.uid, fcmToken!);
		} catch (e) {
      log(e.toString());
			rethrow;
    }
  }


	@override
	Future<void> logOut() async {
		await _firebaseAuth.signOut();
	}

}

