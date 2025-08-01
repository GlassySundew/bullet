// hl_debug_drawer.h
#pragma once
#include <btBulletDynamicsCommon.h>
#include <vector>
#include <cstring> // std::memcpy

// Flat POD so we can reinterpret_cast to float[9] blocks
struct HlDebugLine {
    float x1, y1, z1;
    float x2, y2, z2;
    float r, g, b; // 0..1
};

class HlDebugDrawer : public btIDebugDraw {
    int m_mode = DBG_DrawWireframe | DBG_DrawAabb | DBG_DrawContactPoints;
    std::vector<HlDebugLine> m_lines;

public:
    HlDebugDrawer() = default;

    // ---- btIDebugDraw overrides ----
    void setDebugMode(int m) override { m_mode = m; }
    int  getDebugMode() const override { return m_mode; }

    void drawLine(const btVector3& from,
        const btVector3& to,
        const btVector3& color) override {
        m_lines.push_back({
          (float)from.x(), (float)from.y(), (float)from.z(),
          (float)to.x(),   (float)to.y(),   (float)to.z(),
          (float)color.x(), (float)color.y(), (float)color.z()
            });
    }

    void drawContactPoint(const btVector3& p,
        const btVector3& n,
        btScalar /*distance*/,
        int /*life*/,
        const btVector3& color) override {
        const btVector3 tip = p + n * btScalar(0.1);
        m_lines.push_back({
          (float)p.x(), (float)p.y(), (float)p.z(),
          (float)tip.x(), (float)tip.y(), (float)tip.z(),
          (float)color.x(), (float)color.y(), (float)color.z()
            });
    }

    void reportErrorWarning(const char* /*s*/) override {}
    void draw3dText(const btVector3& /*pos*/, const char* /*text*/) override {}

    // ---- Helpers that MATCH your IDL ----

    // IDL: [Const] long getLineCount();
    long getLineCount() const {
        return (long)m_lines.size();
    }

    // IDL: [Const] VoidPtr getLinesPtr();
    // Return as const void* because IDL marked it [Const]
    void* getLinesPtr() const {
        return const_cast<void*>(static_cast<const void*>(m_lines.data()));
    }

    // IDL: long copyLines(VoidPtr outFloatBuffer, long maxFloats);
    // Take void* (not float*) so the wrapper can pass a Bytes/VoidPtr directly.
    long copyLines(void* outFloatBuffer, long maxFloats) const {
        const long totalFloats = (long)m_lines.size() * 9;
        const long nFloats = (maxFloats < totalFloats) ? maxFloats : totalFloats;
        const float* src = reinterpret_cast<const float*>(m_lines.data());
        // std::memcpy(dest<void*>, src<const void*>, bytes)
        std::memcpy(outFloatBuffer, src, (size_t)nFloats * sizeof(float));
        // Return number of LINES written, not floats, to match earlier examples
        return nFloats / 9;
    }

    // Optional: clear() if you expose it in IDL
    void clear() { m_lines.clear(); }
};
