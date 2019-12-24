# Bullet

[Bullet Physics](https://github.com/bulletphysics) wrapper for Heaps

Supports both HashLink and JS output thanks to [WebIDL](https://github.com/ncannasse/webidl)

## Compilation

* Make sure you have hashlink installed in two directories above the current one:

```bash
/hashlink
/libs
   /bullet <- this should contain this repository
```

* Download the [Bullet sources](https://github.com/bulletphysics/bullet3/releases/tag/2.89) and extract them into the `src/bullet` directory.

### HL Target

First run `haxe bullet.hl.hxml`, then check the platform
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

* TODO

### JS Target

* Windows
  * TODO
* MacOS
  * TODO
* Linux
  * TODO
