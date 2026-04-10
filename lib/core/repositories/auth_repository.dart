import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 1. 이미 가지고 계신 firebase_providers.dart 파일 경로를 임포트합니다.
import '../../data/firebase/firebase_providers.dart'; 
import '../models/user_model.dart'; 

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  // 2. 여기서 만들어두신 프로바이더를 쏙쏙 뽑아서 Repository에 넣어줍니다!
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
}

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  // 익명 로그인
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  // Firestore에 유저 정보 저장 (첫 로그인일 때만)
  Future<void> saveUserToFirestore(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      final newUser = UserModel(
        uid: user.uid,
        groupIds: [], 
      );
      
      await docRef.set(newUser.toJson()); 
    }
  }
}