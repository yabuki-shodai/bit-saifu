import 'dart:typed_data';

class KeyPair {
  final Uint8List privateKey;
  final Uint8List publicKey;

  KeyPair({required this.privateKey, required this.publicKey});
}
