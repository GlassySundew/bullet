# Bullet

[Bullet Physics](https://github.com/bulletphysics) wrapper for [Heaps](https://github.com/HeapsIO/heaps)

Supports both HashLink and JS output thanks to [WebIDL](https://github.com/ncannasse/webidl)

## Compilation

* Download the [Bullet Sources](https://github.com/bulletphysics/bullet3/releases/tag/2.89) and extract them into the `src/bullet` directory.
* Make sure you have hashlink installed in two directories above the current one:

```bash
/hashlink <- hashlink git repo
/libs
   /bullet <- the current git repository
      /src
         /bullet <- should contain the extracted Bullet sources
            /src
               /btBulletCollisionAll.cpp
               /... etc.
```

### HL Target

* First run `haxe bullet.hl.hxml`, then check the platform
specific instructions:

#### Windows

* Open and compile `bullet.sln`
* Place `bullet.hdll` where you have your other `.hdll`s

#### MacOS

* Currently compiling only works with `GCC`
* Install CMake: `brew install cmake`
* Install GCC:  `brew install gcc`
* Run the following command, and make sure the paths to `gcc` and `g++` are correct
  * `cmake -DCMAKE_C_COMPILER=/usr/local/bin/gcc-9 -DCMAKE_CXX_COMPILER=/usr/local/bin/g++-9 . -G"Unix Makefiles"`
* Build: `make`
* If compilation was successful, install the `.hdll`
  * `make install`

#### Linux

* This should work the same way as MacOS, except install GCC and CMake using your preferred package manager.

### JS Target

* Windows
  * TODO
* MacOS
  * TODO
* Linux
  * TODO
