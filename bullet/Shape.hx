package bullet;

@:enum abstract Axis(Int) {
	var X = 0;
	var Y = 1;
	var Z = 2;
}

class Shape {

	var inst : Bullet.CollisionShape;
	var getPrim : Void -> h3d.prim.Primitive;
	var primitive : h3d.prim.Primitive;
	public var inertia : Point;

	function new(v,getPrim) {
		inst = v;
		this.getPrim = getPrim;
		var inertia = new Bullet.Vector3();
		inst.calculateLocalInertia(1.,inertia);
		this.inertia = inertia;
		inertia.delete();
	}

	inline function getInstance() {
		return inst;
	}

	public function getPrimitive() {
		if( primitive == null && getPrim != null ) primitive = getPrim();
		return primitive;
	}

	public static function createBox( sizeX : Float, sizeY : Float, sizeZ : Float ) : Shape {
		var vec3 = new Bullet.Vector3(sizeX * 0.5, sizeY * 0.5, sizeZ * 0.5);
		var sh = new Shape(new Bullet.BoxShape(vec3), function() {
			var cube = new h3d.prim.Cube(sizeX, sizeY, sizeZ, true);
			cube.unindex();
			cube.addUVs();
			cube.addNormals();
			cube.addTangents();
			return cube;
		});
		vec3.delete();
		return sh;
	}

	public static function createSphere( radius : Float ) : Shape {
		return new Shape(new Bullet.SphereShape(radius), function() {
			var sp = new h3d.prim.Sphere(radius, Math.ceil(8 * Math.max(radius,1)), Math.ceil(6 * Math.max(radius,1)));
			sp.addNormals();
			sp.addUVs();
			sp.addTangents();
			return sp;
		});
	}

	public static function createCapsule( axis : Axis, radius : Float, length : Float ) : Shape {
		return new Shape(switch( axis ) {
		case X:
			new Bullet.CapsuleShapeX(radius, length);
		case Y:
			new Bullet.CapsuleShape(radius, length);
		case Z:
			new Bullet.CapsuleShapeZ(radius, length);
		}, function() {
			var cy = new h3d.prim.Cylinder( hxd.Math.imax(Math.ceil(radius*Math.PI*2 * 10), 6), radius, length, true);
			cy.addUVs();
			//cy.addTangents();
			switch( axis ) {
			case Z:
			case X:
				var m = new h3d.Matrix();
				m.initRotation(0,Math.PI/2,0);
				cy.transform(m);
			case Y:
				var m = new h3d.Matrix();
				m.initRotation(Math.PI/2,0,0);
				cy.transform(m);
			}
			return cy;
		});
	}

	public function setLocalScaling(x, y, z) {
		var vec3 = new Bullet.Vector3(x, y, z);
		inst.setLocalScaling(vec3);
		vec3.delete();
	}

	public static function createCylinder( axis : Axis, ray : Float, height : Float ) : Shape {
		var vec3;
		var sh = new Shape(switch( axis ) {
		case X:
			vec3 = new Bullet.Vector3(height * 0.5, ray, ray);
			new Bullet.CylinderShapeX(vec3);
		case Y:
			vec3 = new Bullet.Vector3(ray, height * 0.5, ray);
			new Bullet.CylinderShape(vec3);
		case Z:
			vec3 = new Bullet.Vector3(ray, ray, height * 0.5);
			new Bullet.CylinderShapeZ(vec3);
		}, function() {
			var cy = new h3d.prim.Cylinder( hxd.Math.imax(Math.ceil(ray*Math.PI*2 * 10), 6), ray, height, true);
			cy.addUVs();
			//cy.addTangents();
			switch( axis ) {
			case Z:
			case X:
				var m = new h3d.Matrix();
				m.initRotation(0,Math.PI/2,0);
				cy.transform(m);
			case Y:
				var m = new h3d.Matrix();
				m.initRotation(Math.PI/2,0,0);
				cy.transform(m);
			}
			return cy;
		});
		vec3.delete();
		return sh;
	}

	public static function createCone( axis : Axis, radius : Float, length : Float ) : Shape {
		throw "TODO";
	}

	public static function createCompound( shapes : Array<{ shape : Shape, mass : Float, position : h3d.col.Point, rotation : h3d.Quat }> ) {
		var comp = new Bullet.CompoundShape(true);
		for( s in shapes ) {
			var tr = new Bullet.Transform(new Bullet.Quaternion(s.rotation.x, s.rotation.y, s.rotation.z, s.rotation.w), new Bullet.Vector3(s.position.x, s.position.y, s.position.z));
			comp.addChildShape(tr,s.shape.getInstance());
		}
		return { shape : new Shape(comp,null), rotation : new h3d.Quat(), position : new h3d.col.Point() };
	}

}
