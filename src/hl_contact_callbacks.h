#pragma once
#include <btBulletDynamicsCommon.h>
#include <vector>
#include <algorithm>

struct HlContact {
	float px, py, pz;   // world position on B
	float nx, ny, nz;   // normal on B, pointing from B towards A
	float distance;     // cp.getDistance()
	const btCollisionObject* other; // the other object
};

// Returns true if any contact was found.
//class AnyHitCallback : public btCollisionWorld::ContactResultCallback {
//public:
//    bool anyHit = false;
//
//    // optional: you can set these directly too
//    // m_collisionFilterGroup = ...; 
//    // m_collisionFilterMask  = ...;
//
//    btScalar addSingleResult(btManifoldPoint& cp,
//        const btCollisionObjectWrapper* col0, int, int,
//        const btCollisionObjectWrapper* col1, int, int) override {
//        anyHit = true;
//        return 0.f;
//    }
//};

// Collects all contacts into a POD array for easy copying to Haxe.
class CollectContacts : public btCollisionWorld::ContactResultCallback {
public:
    const btCollisionObject* self = nullptr; // set via setSelf(selfObj)
    short mask = -1;  // optional: set a specific mask you want to include
    short group = -1; // optional: if you care about group; not required

    std::vector<const btCollisionObject*> uniqueOthers;

    void clear() { uniqueOthers.clear(); }
    void setSelf(const btCollisionObject* obj) { self = obj; }
    void setFilter(short groupBits, short maskBits) { group = groupBits; mask = maskBits; }

    // Ensure statics/kinematics aren’t accidentally filtered out
    bool needsCollision(btBroadphaseProxy* proxy) const override {
        if (!proxy) return false;
        // If you want to honor Bullet's default filtering based on this callback’s group/mask:
        if (m_collisionFilterMask) {
            if ((proxy->m_collisionFilterGroup & m_collisionFilterMask) == 0) return false;
        }
        if (m_collisionFilterGroup) {
            if ((m_collisionFilterGroup & proxy->m_collisionFilterMask) == 0) return false;
        }
        // Allow statics and kinematics as long as filters pass
        return true;
    }

    static inline const btCollisionObject* pickOther(
        const btCollisionObject* self,
        const btCollisionObjectWrapper* col0,
        const btCollisionObjectWrapper* col1)
    {
        const btCollisionObject* a = col0->getCollisionObject();
        const btCollisionObject* b = col1->getCollisionObject();
        if (a == self) return b;
        if (b == self) return a;
        // fallback: return the one that isn't static/ghost preference if you like
        return b;
    }

    btScalar addSingleResult(btManifoldPoint& cp,
        const btCollisionObjectWrapper* col0, int, int,
        const btCollisionObjectWrapper* col1, int, int) override
    {
        const btCollisionObject* other = pickOther(self, col0, col1);
        if (std::find(uniqueOthers.begin(), uniqueOthers.end(), other) == uniqueOthers.end())
            uniqueOthers.push_back(other);
        return 0.f;
    }

    int uniqueCount() const { return (int)uniqueOthers.size(); }
    const btCollisionObject* getUniqueOther(int i) const { return uniqueOthers[i]; }
};