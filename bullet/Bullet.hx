package bullet;

#if !macro
typedef Bullet = haxe.macro.MacroType<[webidl.Module.build({ idlFile : "bullet/bullet.idl", chopPrefix : "bt", autoGC : true, nativeLib : "bullet" })]>;
#else
class Bullet {

    static var config : webidl.Options = {
        idlFile : "bullet/bullet.idl",
        autoGC : true, 
        outputDir: "src",
        nativeLib : "bullet",
    };

    public static function build() {
        config.chopPrefix = "bt";
        return webidl.Module.build(config);
    }

#if eval
	static var INCLUDE = "
#ifdef _WIN32
#pragma warning(disable:4305)
#pragma warning(disable:4244)
#pragma warning(disable:4316)
#endif
#include <btBulletDynamicsCommon.h>
#include <BulletSoftBody/btSoftBody.h>
#include <BulletSoftBody/btSoftBodyRigidBodyCollisionConfiguration.h>
#include <BulletSoftBody/btDefaultSoftBodySolver.h>
#include <BulletSoftBody/btSoftBodyHelpers.h>
#include <BulletSoftBody/btSoftRigidDynamicsWorld.h>
#include <BulletCollision/CollisionShapes/btHeightfieldTerrainShape.h>
#include <BulletCollision/CollisionDispatch/btGhostObject.h>
#include <BulletDynamics/Character/btKinematicCharacterController.h>

";
    public static function buildLibCpp() {
        config.includeCode = INCLUDE;
		webidl.Generate.generateCpp(config);
    }

	public static function getFiles() {
        config.includeCode = INCLUDE;
        var sources = sys.io.File.getContent("sourcelist.txt")
            .split("\n")
            .map(s -> StringTools.trim(s))
            .filter(s -> s.length > 0);
        return sources;
	}
	
	public static function buildLibJS() {
		// ammo.js params
		var debug = false;
		var totalMemory = 256 * 1024 * 1024;
		var defines = debug ? [] : ["NO_EXIT_RUNTIME=1", "NO_FILESYSTEM=1", "AGGRESSIVE_VARIABLE_ELIMINATION=1", "NO_DYNAMIC_EXECUTION=1", "TOTAL_MEMORY=" + totalMemory];
		var params = ["-O"+(debug?0:3), "--llvm-lto", "1", "-I", "lib/bullet3/src"];
		for( d in defines ) {
			params.push("-s");
			params.push(d);
        }
        config.outputDir = "build/emscripten";
		webidl.Generate.generateJs(config, getFiles(), params);
    }
#end
}
#end