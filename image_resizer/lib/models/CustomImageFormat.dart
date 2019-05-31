abstract class CustomImageFormat {
  static const int IF_ORIG = 0;
  static const int IF_16_TO_9 = 1;
  static const int IF_4_TO_3 = 2;

  //TODO Map.unmodifiable
  static const Map<int, String> formats = {
    IF_ORIG: 'Original',
    IF_16_TO_9: '16/9',
    IF_4_TO_3: '4/3'
  };
  static const Map<int, double> formatsValues = {
    IF_ORIG: 1,
    IF_16_TO_9: 16 / 9,
    IF_4_TO_3: 4 / 3
  };
}
