/// Centralized asset path manager.
/// Never hardcode raw asset paths in widgets.
abstract final class AssetManager {
  static const String _iconsPath = 'assets/icons';
  static const String _imagesPath = 'assets/images';
  static const String _svgsPath = 'assets/svgs';
  static const String _jsonsPath = 'assets/jsons';

  // Images
  static const String appLogo = '$_imagesPath/app_logo.png';
  static const String splashBackground = '$_imagesPath/splash_bg.png';
  static const String recipePlaceholder = '$_imagesPath/recipe_placeholder.png';
  static const String userAvatar = '$_imagesPath/default_avatar.png';
  static const String emptyStateIllustration = '$_imagesPath/empty_state.png';

  // Icons
  static const String icTimer = '$_iconsPath/ic_timer.png';
  static const String icRecipe = '$_iconsPath/ic_recipe.png';
  static const String icExpense = '$_iconsPath/ic_expense.png';

  // SVGs
  static const String svgCookingPot = '$_svgsPath/cooking_pot.svg';
  static const String svgChefHat = '$_svgsPath/chef_hat.svg';
  static const String svgNoData = '$_svgsPath/no_data.svg';

  // Lottie JSONs
  static const String lottieCooking = '$_jsonsPath/cooking_anim.json';
  static const String lottieLoading = '$_jsonsPath/loading.json';
}
