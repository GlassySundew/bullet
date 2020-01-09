# Bullet

[Bullet Physics](https://github.com/bulletphysics) wrapper for [Heaps](https://github.com/HeapsIO/heaps)

Supports both HashLink and JS output thanks to [WebIDL](https://github.com/ncannasse/webidl)

## Compilation

* Clone this repository

* Run `git submodule init`

* Make sure you have hashlink installed in two directories above the current one:

```bash
/hashlink <- hashlink git repo
/libs
   /bullet <- the current git repository
```

### HL Target

* First run `haxe bullet_hl.hxml`, then check the platform
specific instructions:

#### Windows

* Run CMake, and make sure the variable `HASHLINK_DIR` is correct.
* Compile the created Visual Studio solution.
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

* Install the webidl haxe package: `haxelib git webidl https://github.com/ncannasse/webidl.git`.

* Install [Emscripten](https://emscripten.org/docs/getting_started/downloads.html)

* Make sure the env variable `EMSDK` is set, pointing to the `emsdk` directory.

* Run `haxe bullet_js.hxml`

This should generate the files `bullet.js` and `bullet.wasm`.

Check out the sample html and haxe file on how to load it.

## Building the Sample

First compile bullet as shown in the compilation section.
Once that is done it should be possible to build the samples.

(You have to add the haxelib locally):

```bash
haxelib dev bullet $(pwd)
```

When building the JS sample, make sure to
copy `bullet.js` and `bullet.wasm` into the sample directory.
