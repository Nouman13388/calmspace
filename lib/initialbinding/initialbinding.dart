  import 'package:get/get.dart';

  import '../controllers/auth_controller.dart';

  class InitialBinding extends Bindings {
    @override
    void dependencies() {
      // Put the AuthController in the dependency injection system
      Get.put<AuthController>(AuthController(), permanent: true);
      Get.lazyPut(()=>AuthController(),fenix: true);
    }
  }
