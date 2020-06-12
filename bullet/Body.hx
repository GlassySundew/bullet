package bullet;

import h3d.Quat;
import hxd.impl.UInt16;

typedef BodyId = Int;

class Body {
	static inline var ACTIVE_TAG = 1;
	static inline var DISABLE_DEACTIVATION = 4;
	static inline var DISABLE_SIMULATION = 5;
	static var _NEXT_ID = 1;

	var state : Bullet.MotionState;
	var inst : Bullet.RigidBody;
	var _pos = new Point();
	var _vel = new Point();
	var _avel = new Point();
	var _q = new h3d.Quat();
	var _tmp = new Array<Float>();

	public var id (default, null) : BodyId;
	public var world(default,null) : World;

	public var shape(default,null) : Shape;
	public var mass(default,null) : Float;
	public var position(get,never) : Point;
	public var velocity(get,set) : Point;
	public var angularVelocity(get,set) : Point;
	public var rotation(get,never) : h3d.Quat;
	public var object(default,set) : h3d.scene.Object;
	public var alwaysActive(default,set) = false;
	public var friction(get, set) : Float;
	public var restitution(get, set) : Float;

	public function new( shape : Shape, mass : Float, ?world : World, group : UInt16 = -1, mask : UInt16 = -1) {
		id = _NEXT_ID++;

		var inertia = new Bullet.Vector3(shape.inertia.x * mass, shape.inertia.y * mass, shape.inertia.x * mass);
		state = new Bullet.DefaultMotionState();
		var inf = new Bullet.RigidBodyConstructionInfo(mass, state, @:privateAccess shape.getInstance(), inertia);
		inst = new Bullet.RigidBody(inf);
		inst.setUserIndex(id);
		inertia.delete();
		inf.delete();
		this.shape = shape;
		this.mass = mass;
		_tmp[6] = 0.;
		if( world != null ) addTo(world, group, mask);
	}

	function set_alwaysActive(b) {
		inst.setActivationState(b ? DISABLE_DEACTIVATION : ACTIVE_TAG);
		return alwaysActive = b;
	}

	function get_restitution() : Float {
		return inst.getRestitution();
	}
	function set_restitution( restitution : Float ) : Float {
		inst.setRestitution(restitution);
		return restitution;
	}

	function set_object(o) {
		if( object != null ) object.remove();
		object = o;
		if( object != null && object.parent == null && world != null && world.parent != null ) world.parent.addChild(object);
		object.ignoreParentTransform = true;
		return o;
	}

	public function setUserIndex(index : Int) {
		return inst.setUserIndex(index);
	}

	public function setUserIndex2(index : Int) {
		return inst.setUserIndex2(index);
	}

	public function getUserIndex() : Int {
		return inst.getUserIndex();
	}

	public function getUserIndex2() : Int {
		return inst.getUserIndex2();
	}

	public function addTo( world : World, group : UInt16 = -1, mask : UInt16 = -1) {
		if( this.world != null ) remove();
		@:privateAccess world.addRigidBody(this, group, mask);
	}

	public function remove() {
		if( world == null ) return;
		@:privateAccess world.removeRigidBody(this);
	}

	function set_friction( f : Float) : Float {
		inst.setFriction(f);
		return f;
	}
	
	function get_friction() : Float {
		return inst.getFriction();
	}

	public function setRollingFriction( f ) {
		inst.setRollingFriction(f);
	}

	public function applyImpulse( impulse : Point, relativePos : Point) {
		var imp = new Bullet.Vector3(impulse.x, impulse.y, impulse.z);
		var impRelPos = new Bullet.Vector3(relativePos.x, relativePos.y, relativePos.z);
		inst.applyImpulse(imp, impRelPos);
		inst.activate();
		imp.delete();
		impRelPos.delete();
	}

	public function addAxis( length = 1. ) {
		if( object == null ) throw "Missing object";
		var g = new h3d.scene.Graphics(object);
		g.lineStyle(1,0xFF0000);
		g.lineTo(length,0,0);
		g.lineStyle(1,0x00FF00);
		g.moveTo(0,0,0);
		g.lineTo(0,length,0);
		g.lineStyle(1,0x0000FF);
		g.moveTo(0,0,0);
		g.lineTo(0,0,length);
		g.material.setDefaultProps("ui");
	}

	public function setTransform( p : Point, ?q : h3d.Quat ) {
		var t = inst.getCenterOfMassTransform();
		var v = new Bullet.Vector3(p.x, p.y, p.z);
		t.setOrigin(v);
		v.delete();
		if( q != null ) {
			var qv = new Bullet.Quaternion(q.x, q.y, q.z, q.w);
			t.setRotation(qv);
			qv.delete();
		}
		inst.setCenterOfMassTransform(t);
		inst.activate();
	}

	public function resetVelocity() {
		inst.setAngularVelocity(zero);
		inst.setLinearVelocity(zero);
		_vel.set(0,0,0);
		_avel.set(0,0,0);
		if( world != null ) @:privateAccess world.clearBodyMovement(this);
	}

	public function initObject() {
		if( object != null ) return object.toMesh();
		var o = new h3d.scene.Mesh(shape.getPrimitive());
		object = o;
		return o;
	}

	public function delete() {
		inst.delete();
		state.delete();
	}

	public function loadPosFromObject() {
		var ignoreTransform = object.ignoreParentTransform;
		object.ignoreParentTransform = false;
		var abs = object.getAbsPos();
		var pos = abs.getPosition();
		setTransform(new Point(pos.x, pos.y, pos.z), object.getAbsRotationQuat());
		object.ignoreParentTransform = ignoreTransform;
	}

	public function setPosition(x : Float, y : Float, z : Float) {
		setTransform(new Point(x, y, z));
	}

	function get_position() {
		var t = inst.getCenterOfMassTransform();
		var p = t.getOrigin();
		_pos.assign(p);
		p.delete();
		return _pos;
	}

	function get_rotation() {
		var t = inst.getCenterOfMassTransform();
		var q = t.getRotation();
		var qw : Bullet.QuadWord = q;
		_q.set(qw.x(), qw.y(), qw.z(), qw.w());
		q.delete();
		return _q;
	}

	function get_velocity() {
		var v = inst.getLinearVelocity();
		_vel.assign(v);
		return _vel;
	}

	function set_velocity(v) {
		if( v != _vel ) _vel.load(v);
		var p = new Bullet.Vector3(v.x, v.y, v.z);
		inst.setLinearVelocity(p);
		p.delete();
		return v;
	}

	function get_angularVelocity() {
		var v = inst.getAngularVelocity();
		_avel.assign(v);
		return _avel;
	}

	function set_angularVelocity(v) {
		if( v != _avel ) _avel.load(v);
		var p = new Bullet.Vector3(v.x, v.y, v.z);
		inst.setAngularVelocity(p);
		p.delete();
		return v;
	}

	public function setAngularFactor(x, y, z) {
		var p = new Bullet.Vector3(x, y, z);
		inst.setAngularFactor(p);
		p.delete();
	}

	public function setGravity(x, y, z) {
		var p = new Bullet.Vector3(x, y, z);
		inst.setGravity(p);
		p.delete();
	}

	public function setVelocity(x, y, z) {
		var p = new Bullet.Vector3(x, y, z);
		inst.setLinearVelocity(p);
		p.delete();
	}

	@:allow(bullet) static var zero(get, null) : Bullet.Vector3;
	static var _zero : Bullet.Vector3;
	static function get_zero() : Bullet.Vector3 {
		if (_zero == null) {
			_zero = new Bullet.Vector3(0,0,0);
		}
		return _zero;
	}

	/**
		Updated the linked object position and rotation based on physical simulation
	**/
	public function sync() {
		if( object == null ) return;
		var pos = position;
		object.x = pos.x;
		object.y = pos.y;
		object.z = pos.z;
		var q = rotation;
		object.getRotationQuat().load(q); // don't share reference
	}

}
