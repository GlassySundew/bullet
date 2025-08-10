package bullet;

import hxd.impl.UInt16;

class CollisionFilterGroups {
	public static final DefaultFilter : UInt16 = 1;
	public static final StaticFilter : UInt16 = 2;
	public static final KinematicFilter : UInt16 = 4;
	public static final DebrisFilter : UInt16 = 8;
	public static final SensorTrigger : UInt16 = 16;
	public static final CharacterFilter : UInt16 = 32;
	public static final AllFilter : UInt16 = -1;
}

class World {

	var config : Bullet.DefaultCollisionConfiguration;
	var dispatch : Bullet.Dispatcher;
	var broad : Bullet.BroadphaseInterface;
	var pcache : Bullet.OverlappingPairCache;
	var solver : Bullet.ConstraintSolver;
	var inst : Bullet.DiscreteDynamicsWorld;
	var bodies : Array<Body> = [];
	var constraints : Array<Constraint> = [];
	public var parent : h3d.scene.Object;

	public function new( ?parent ) {
		this.parent = parent;
		config = new Bullet.DefaultCollisionConfiguration();
		dispatch = new Bullet.CollisionDispatcher(config);
		broad = new Bullet.DbvtBroadphase();
		pcache = broad.getOverlappingPairCache();
		solver = new Bullet.SequentialImpulseConstraintSolver();
		inst = new Bullet.DiscreteDynamicsWorld(dispatch, broad, solver, config);
	}

	var fromPoint = new Bullet.Vector3();
	var toPoint = new Bullet.Vector3();
	// Returns a body if the ray hits something. the to param will be set to where it was hit
	public function rayTest(from : h3d.col.Point, to : h3d.col.Point, group : UInt16 = -1, mask : UInt16 = -1, ?hitNormal : h3d.col.Point) : Body {
		fromPoint.setValue(from.x, from.y, from.z);
		toPoint.setValue(to.x, to.y, to.z);
		var res = new Bullet.ClosestRayResultCallback(fromPoint, toPoint);
		res.m_collisionFilterMask = mask;
		res.m_collisionFilterGroup = group;
		inst.rayTest(fromPoint, toPoint, res);
		to.set(res.m_hitPointWorld.x(), res.m_hitPointWorld.y(), res.m_hitPointWorld.z());
		var hit = res.hasHit();
		var bod : Bullet.RigidBody = cast res.m_collisionObject;

		if (hit) {
			var hitId = res.m_collisionObject.getUserIndex();
			if (hitNormal != null) {
				hitNormal.x = res.m_hitNormalWorld.x();
				hitNormal.y = res.m_hitNormalWorld.y();
				hitNormal.z = res.m_hitNormalWorld.z();
			}

			res.delete();
			return getRigidBodyById(hitId);
		} 

		res.delete();

		return null;
	}
	
	public function setDebugDrawer(debugDraw : Bullet.IDebugDraw) {
		inst.setDebugDrawer(debugDraw);
	}

	public function getDebugDrawer() : Bullet.IDebugDraw {
		return inst.getDebugDrawer();
	}

	public function setGravity( x : Float, y : Float, z : Float ) {
		inst.setGravity(new Bullet.Vector3(x, y, z));
	}

	public function stepSimulation( time : Float, iterations : Int ) {
		inst.stepSimulation(time, iterations);
	}

	public function getManifoldCount() {
		return dispatch.getNumManifolds();
	}

	public function sync() {}

	function clearBodyMovement( b : Body ) {
		pcache.cleanProxyFromPairs(@:privateAccess b.inst.getBroadphaseHandle(),dispatch);
	}

	function addRigidBody( b : Body, group : UInt16 = -1, mask : UInt16 = -1 ) {
		if( b.world != null ) throw "Body already in world";
		bodies[b.id] = b;
		@:privateAccess b.world = this;
		inst.addRigidBody(@:privateAccess b.inst, group, mask);
		if( b.object != null && parent != null && b.object.parent == null ) parent.addChild(b.object);
	}

	public function getRigidBodyById(id : Body.BodyId) : Body {
		return bodies[id];
	}

	function removeRigidBody( b : Body ) {
		if( bodies[b.id] == null ) return;
		@:privateAccess b.world = null;
		inst.removeRigidBody(@:privateAccess b.inst);
		if( b.object != null && b.object.parent == parent ) b.object.remove();
	}

	function addConstraint( c : Constraint ) {
		if( c.world != null ) throw "Constraint already in world";
		constraints.push(c);
		@:privateAccess c.world = this;
		inst.addConstraint(@:privateAccess c.cst, c.disableCollisionsBetweenLinkedBodies);
	}

	function removeConstraint( c : Constraint ) {
		if( !constraints.remove(c) ) return;
		@:privateAccess c.world = null;
		inst.removeConstraint(@:privateAccess c.cst);
	}

}
