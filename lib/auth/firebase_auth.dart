import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authentication{
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore store = FirebaseFirestore.instance;

  User? currentUser() {
  return auth.currentUser;
  }


  // Sign in
  Future<UserCredential> signInEandP(String email, String password) async {
    try {
      var authenticatedUser = await auth.signInWithEmailAndPassword(email: email, password: password);
      if (authenticatedUser.user!.emailVerified) {
        return authenticatedUser;
      } else {
        throw Exception("Email is not verified.");
      }
    } on FirebaseAuthException catch(e){
      throw Exception(e.code);
    }
  }

  // Sign out
  Future<void> signOut() async {
    return await auth.signOut();
  }

  // Sign up
  Future<UserCredential> signUpEandP(String email, String password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user!.sendEmailVerification(); // Send verification email
      store.collection("User").doc(userCredential.user!.uid).set(
          {
            "uid": userCredential.user!.uid,
            "email": email,
          }
      );
      return userCredential;
    } on FirebaseAuthException catch(e){
      throw Exception(e.code);
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    User? user = auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }
}
