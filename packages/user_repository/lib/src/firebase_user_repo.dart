import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_repository/src/models/user.dart';

import 'entities/user_entity.dart';
import 'user_repo.dart';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _fireaseAuth;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  FirebaseUserRepo({
    FirebaseAuth? firebaseAuth,
  }) : _fireaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<MyUser?> get user {
    return _fireaseAuth.authStateChanges().flatMap((firebaseUser) async* {
      if (firebaseUser == null) {
        yield MyUser.empty;
      } else {
        yield await usersCollection.doc(firebaseUser.uid).get().then((value) =>
            MyUser.fromEntity(MyUserEntity.fromDocument(value.data()!)));
      }
    });
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _fireaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      log(e.toString() as num);
      rethrow;
    }
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential user = await _fireaseAuth.createUserWithEmailAndPassword(
          email: myUser.email, password: password);
      myUser.userId = user.user!.uid;
      return myUser;
    } catch (e) {
      log(e.toString() as num);
      rethrow;
    }
  }

  @override
  Future<void> logOut() async {
    await _fireaseAuth.signOut();
  }

  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await usersCollection
          .doc(myUser.userId)
          .set(myUser.toEntity().toDocument());
    } catch (e) {
      log(e.toString() as num);
      rethrow;
    }
  }
}
