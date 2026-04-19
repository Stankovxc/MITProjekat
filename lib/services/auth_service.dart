import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // Importuj tvoj novi model

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> registerUser(UserModel userModel, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );

      User? firebaseUser = result.user;

      if (firebaseUser != null) {
        await _db
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userModel.toFirestore());
      }
      return firebaseUser;
    } catch (e) {
      print("Greška pri registraciji: $e");
      return null;
    }
  }

  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Greška pri prijavi: ${e.code}");
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
