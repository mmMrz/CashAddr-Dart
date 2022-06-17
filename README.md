# CashAddr-Dart

For general bch new address format of CashAddr  
Bitcoin Cash general purpose address translation for Flutter/Dart  
通过Dart实现的比特币地址到BCH CashAddr格式地址的转换实现.可用于Flutter移动钱包开发.  

用法
````dart
String cashaddr = BCHUtils().encodeFull("bchtest", 0, "公钥Hash(SHA256(RIPEMD160(Pubkey)))");
````
  
QQ群：653317062 （失踪的新华社）
    
# References
* [Specification](https://github.com/Bitcoin-UAHF/spec/blob/master/cashaddr.md)
