OpenSSL for iOS
=================
Build openssl for iOS development  
This script will generate static library for armv7 arm64 and x86_64.  
New Xcode7 bitcode feature supported.

Script only, please download openssl from here: http://www.openssl.org/source/  
Tested Xcode 10 and macOS 10.13
Tested openssl 1.1.1a


Usage
=================
Copy the following lines to your Terminal.app
```
curl -O http://www.openssl.org/source/openssl-1.1.1a.tar.gz
tar xf openssl-1.1.1a.tar.gz
cd openssl-1.1.1a
curl https://raw.githubusercontent.com/Roblox/build-openssl-ios/master/build_openssl_dist.sh |bash
```
Find the result folder iOS-universal inside build_iOS-universal.
