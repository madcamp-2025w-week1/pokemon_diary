import 'dart:math';

class GachaLogic {
  int draftRandomPokemon() {
    final random = Random();
    return random.nextInt(151) + 1;
  }
}