import 'dart:typed_data';

class BCHUtils {
  //由官方文档提供的码表
  //https://github.com/bitcoincashorg/bitcoincash.org/blob/master/spec/cashaddr.md
  String CHARSET = "qpzry9x8gf2tvdw0s3jn54khce6mua7l";

  int PUBKEY_TYPE = 0; //P2KH
  int SCRIPT_TYPE = 1; //P2SH

  encodeFull(String prefix, int kind, Uint8List addrHash) {
    //编码一个完整的CashAddr, 其包含前缀(bitcoincash|bchtest|bchreg)和分隔符(:).
    //bitcoincash for Bitcoin Cash main net, bchtest for bitcoin cash testnet, bchreg for bitcoin cash regtest.
    return prefix + ":" + encode(prefix, kind, addrHash);
  }

  encode(String prefix, int kind, Uint8List addrHash) {
    //编码一个不带前缀和分隔符的CashAddr
    assert(prefix is String, 'prefix must be a string');
    assert(addrHash is Uint8List, 'addr_hash must be binary bytes');
    assert(kind == SCRIPT_TYPE || kind == PUBKEY_TYPE,
        'unrecognised address type {$kind}');

    Uint8List payload = packAddrData(kind, addrHash);
    Uint8List checksum = createChecksum(prefix, payload);
    String retval = "";
    for (int d in payload + checksum) {
      retval += CHARSET[d];
    }
    return retval;
  }

  Uint8List packAddrData(int kind, Uint8List addrHash) {
    //给地址数据添加版本字节(Version byte)并打包
    int versionByte = kind << 3;

    int offset = 1;
    int encodedSize = 0;
    if (addrHash.length >= 40) {
      offset = 2;
      encodedSize |= 0x04;
    }
    encodedSize |= ((addrHash.length - 20 * offset) / (4 * offset)).floor();

    // invalid size?
    bool sizeInvalide = !((addrHash.length - 20 * offset) % (4 * offset) != 0 ||
        !(0 <= encodedSize && encodedSize <= 7));
    assert(sizeInvalide, 'invalid address hash size {$addrHash}');

    versionByte |= encodedSize;

    List<int> data = [versionByte];
    data.addAll(addrHash);
    return convertbits(Uint8List.fromList(data), 8, 5, pad: true);
  }

  Uint8List convertbits(Uint8List data, int frombits, int tobits,
      {pad = true}) {
    //2的次幂转换
    int acc = 0;
    int bits = 0;
    List<int> ret = List.empty(growable: true);
    int maxv = (1 << tobits) - 1;
    int maxAcc = (1 << (frombits + tobits - 1)) - 1;
    for (int value in data) {
      acc = ((acc << frombits) | value) & maxAcc;
      bits += frombits;
      while (bits >= tobits) {
        bits -= tobits;
        ret.add((acc >> bits) & maxv);
      }
    }

    if (pad && bits > 0) {
      ret.add((acc << (tobits - bits)) & maxv);
    }

    return Uint8List.fromList(ret);
  }

  Uint8List createChecksum(String prefix, Uint8List data) {
    //计算给定前缀和数据的校验和。
    Uint8List values =
        Uint8List.fromList(prefix_expand(prefix) + data + Uint8List(8));
    int polymod = calcPolymod(values);
    //返回被分成 8 个 5 位数字的Polymod
    List<int> retval = List.empty(growable: true);
    for (int i = 0; i < 8; i++) {
      int r = (polymod >> 5 * (7 - i)) & 31;
      retval.add(r);
    }
    return Uint8List.fromList(retval);
  }

  Uint8List prefix_expand(String prefix) {
    //将前缀展开为用于校验和计算的值
    List<int> retval = List.empty(growable: true);
    for (int x in prefix.codeUnits) {
      retval.add(x & 0x1f);
    }
    // 添加一个0作为分隔符
    retval.add(0);
    return Uint8List.fromList(retval);
  }

  int calcPolymod(values) {
    //计算CashAddr校验和的内部函数,官方文档提供
    //https://github.com/bitcoincashorg/bitcoincash.org/blob/master/spec/cashaddr.md
    int c = 1;
    for (int d in values) {
      int c0 = c >> 35;
      c = ((c & 0x07ffffffff) << 5) ^ d;
      if ((c0 & 0x01) > 0) {
        c ^= 0x98f2bc8e61;
      }
      if ((c0 & 0x02) > 0) {
        c ^= 0x79b76d99e2;
      }
      if ((c0 & 0x04) > 0) {
        c ^= 0xf33e5fb3c4;
      }
      if ((c0 & 0x08) > 0) {
        c ^= 0xae2eabe2a8;
      }
      if ((c0 & 0x10) > 0) {
        c ^= 0x1e4f43e470;
      }
    }
    int retval = c ^ 1;
    return retval;
  }
}
