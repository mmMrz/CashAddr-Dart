# CashAddr-Dart

For general bch new address format of CashAddr  
Bitcoin Cash general purpose address translation for Flutter/Dart  
通过Dart实现的比特币地址到BCH CashAddr格式地址的转换实现.可用于Flutter移动钱包开发.    
  
Wallet开发用到了BCH，需要使用BCH的CashAddr格式的地址  
pub.dev中的Package只有两个两年前更新的库,依赖的老版本的库对新开发的项目不友好.  
根据官方规则编写了一个Dart工具类，没有依赖包，参考了其它语言的实现  
  
# 开始使用  
  
使用方法：  
```
//生成不带前缀和分隔符的地址
String cashaddr = BCHUtils().encode("bchtest", 0, "公钥Hash(SHA256(RIPEMD160(Pubkey)))");
//生成带前缀(bitcoincash|bchtest|bchreg)和分隔符(:)的地址
String cashaddr = BCHUtils().encodeFull("bchtest", 0, "公钥Hash(SHA256(RIPEMD160(Pubkey)))");
```
  
其中，第一个参数前缀选项：  
```bitcoincash``` 用于Bitcoin Cash主网络  
```bchtest``` 用于Bitcoin Cash测试网络  
```bchreg``` 用于Bitcoin Cash注册测试  
  
第二个参数用于版本字节中的类型    
```0``` ：P2KH，```1``` ：P2SH   
  
第三个参数是公钥Hash，也就是生成BTC地址时的值，生成其的伪代码为  
```
SHA256(RIPEMD160(Pubkey))
```
  
具体可参考另一篇Blog  
[生成BTC的Address，以及解码出公钥哈希(Pubkey Hash)](https://www.jianshu.com/p/1980c06a234e)  
  
有用的话给个Star Thanks♪(･ω･)ﾉ  
QQ群：653317062 （失踪的新华社）  
      
# References
* [Specification](https://github.com/Bitcoin-UAHF/spec/blob/master/cashaddr.md)
