import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_services.dart';

class AuthController extends GetxController {
  final AuthServices _authServices = AuthServices();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final RxBool isLoading = false.obs;
  final Rx<EndUser?> userData = Rx<EndUser?>(null); // EndUser model instance

  @override
  void onInit() {
    super.onInit();
    print("AuthController initialized");
  }

  // Rename the method to avoid conflict
  void onControllerDeleted() {
    print("AuthController removed");
    super.onDelete(); // This calls the parent class's onDelete method
  }

  @override
  void onClose() {
    // Call your renamed method here instead
    onControllerDeleted();
  }

  Future<void> fetchUserByEmail(String email) async {
    try {
      isLoading.value = true;
      print('---------------------------------------------');

      final fetchedData = await _authServices.getUserByEmail(email);
      print('fetchedData $fetchedData');

      if (fetchedData != null) {
        userData.value = EndUser.fromJson(fetchedData);
        print('User data value ${userData.value?.email} ${userData.value?.name} ${userData.value?.id}');

        // Store user data in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', userData.value!.email!);
        await prefs.setString('user_name', userData.value!.name!);
        await prefs.setInt('user_id', userData.value!.id!);

        Get.snackbar('User Found', 'User data fetched successfully', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('User Not Found', 'No user found with this email.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user data: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final name = prefs.getString('user_name');
    final id = prefs.getInt('user_id');

    if (email != null && name != null && id != null) {
      userData.value = EndUser(email: email, name: name, id: id);
      print('User data loaded: ${userData.value}');
    }
  }

  Future<UserCredential?> signUpWithEmail(String fullName, String email, String password, String confirmPassword, bool isTherapist) async {
    if (password != confirmPassword) {
      throw FirebaseAuthException(code: 'passwords-not-match', message: 'The passwords do not match.');
    }

    try {
      isLoading.value = true;

      // Check if user or therapist exists in the database
      bool userExists = await _authServices.checkUserExists(email);
      if (userExists) {
        throw Exception('A user or therapist with this email already exists.');
      }

      // Create Firebase user
      UserCredential userCredential = await _authServices.signUpWithEmail(fullName, email, password);

      // Store user data in the database and set global user data
      if (isTherapist) {
        String specialization = "Default Specialization";
        String bio = "Default Bio";
        await _authServices.storeTherapistData(email, fullName, specialization, bio);
      } else {
        await _authServices.storeUserData(fullName, email, password);
      }
      userData.value = EndUser(email: email, name: fullName); // Populate EndUser model

      return userCredential;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'An error occurred', snackPosition: SnackPosition.BOTTOM);
      rethrow;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in aborted');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      UserCredential? userCredential = await _authServices.signInWithGoogle();

      final userEmail = googleUser.email;
      final userName = googleUser.displayName;

      bool userExists = await _authServices.checkUserExists(userEmail);
      if (!userExists) {
        await _authServices.storeUserData(userName!, userEmail, 'defaultPassword123');
      }

      // Populate EndUser model
      await fetchUserByEmail(userEmail);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      Get.snackbar('Error', mapFirebaseAuthExceptionMessage(e.toString()), snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout(SharedPreferences prefs) async {
    try {
      isLoading.value = true;
      await _authServices.logout();

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      await prefs.clear();
      userData.value = null; // Clear EndUser data on logout
      Get.snackbar('Logged Out', 'You have successfully logged out.', snackPosition: SnackPosition.BOTTOM);
      Get.offAllNamed('/role-selection');
    } catch (e) {
      Get.snackbar('Error', 'Failed to log out. Please try again later.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }


  Future<UserCredential?> authenticateTherapist(String email, String password, SharedPreferences prefs, bool rememberMe) async {
    try {
      isLoading.value = true;

      UserCredential userCredential = await _authServices.signInWithEmail(email, password);

      bool therapistExists = await _authServices.checkUserExists(email);
      if (!therapistExists) {
        Get.snackbar('Error', 'No therapist account found for this email.', snackPosition: SnackPosition.BOTTOM);
        return null;
      }

      if (rememberMe) {
        prefs.setString('email', email);
        prefs.setString('password', password);
        prefs.setBool('rememberMe', rememberMe);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      Get.snackbar('Error', mapFirebaseAuthExceptionMessage(e.toString()), snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      await _authServices.sendPasswordResetEmail(email);
      Get.snackbar('Success', 'Password reset email sent.', snackPosition: SnackPosition.BOTTOM);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', mapFirebaseAuthExceptionMessage(e.message ?? 'An error occurred.'), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }


  // Map Firebase Auth exception messages to user-friendly messages
  String mapFirebaseAuthExceptionMessage(String errorMessage) {
    if (errorMessage.contains('wrong-password')) {
      return 'The password is incorrect.';
    } else if (errorMessage.contains('user-not-found')) {
      return 'No user found with this email.';
    } else if (errorMessage.contains('invalid-email')) {
      return 'The email address is not valid.';
    } else if (errorMessage.contains('user-disabled')) {
      return 'This user has been disabled.';
    }
    return 'An unknown error occurred.';
  }

  Future<void> authenticateUser(String email, String password, SharedPreferences prefs, bool rememberMe) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      await fetchUserByEmail(email);
      if (rememberMe) {
        await prefs.setString('email', email);
        await prefs.setString('password', password);
      }
    } catch (e) {
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }
  void printUserData() {
    if (userData.value != null) {
      print('User Data:');
      print('Email: ${userData.value?.email}');
      print('Name: ${userData.value?.name}');
      print('ID: ${userData.value?.id}');
    } else {
      print('No user data available.');
    }
  }
}
