import 'package:get/get.dart';

import '../../../data/network/api_provider.dart';
import '../../../data/network/config.dart';
import '../../../data/repository/api_number_repository_impl.dart';
import '../../../data/repository/number_repository_impl.dart';
import '../../../domain/usecase/calculate_reverse_difference_usecase.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    final apiProvider = ApiProvider(baseUrl: ApiConfig.baseUrl);

    Get.lazyPut<HomeController>(
      () => HomeController(
        localUseCase: CalculateReverseDifferenceUseCase(NumberRepositoryImpl()),
        apiUseCase: CalculateReverseDifferenceUseCase(
          ApiNumberRepositoryImpl(apiProvider),
        ),
        apiProvider: apiProvider,
      ),
    );
  }
}
