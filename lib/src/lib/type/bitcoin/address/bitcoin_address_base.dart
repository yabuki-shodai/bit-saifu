import 'dart:typed_data';

abstract class Address {
  Uint8List toScriptPubKey();
}
