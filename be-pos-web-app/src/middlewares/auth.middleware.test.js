import { test } from "node:test";
import assert from "node:assert/strict";

// token.service.js throws at import time when no JWT secret is configured.
process.env.JWT_ACCESS_SECRET = "test-secret";
process.env.JWT_REFRESH_SECRET = "test-secret";

const { authorize } = await import("./auth.middleware.js");

// Runs the middleware once and reports whether it called next() or responded.
const run = (allowedRoles, user) => {
  const res = {
    statusCode: null,
    body: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(payload) {
      this.body = payload;
      return this;
    },
  };
  let nextCalled = false;
  authorize(allowedRoles)({ user }, res, () => {
    nextCalled = true;
  });
  return { nextCalled, res };
};

test("owner passes routes that do not list owner", () => {
  for (const allowed of [["admin"], ["kasir"], ["admin", "kasir"], []]) {
    const { nextCalled } = run(allowed, { role: "owner" });
    assert.equal(nextCalled, true, `owner blocked on ${JSON.stringify(allowed)}`);
  }
});

test("admin and kasir are still limited to the roles a route lists", () => {
  assert.equal(run(["kasir"], { role: "admin" }).nextCalled, false);
  assert.equal(run(["admin"], { role: "kasir" }).nextCalled, false);
  assert.equal(run(["owner"], { role: "admin" }).nextCalled, false);
  assert.equal(run(["owner"], { role: "kasir" }).nextCalled, false);

  assert.equal(run(["admin", "kasir"], { role: "admin" }).nextCalled, true);
  assert.equal(run(["kasir"], { role: "kasir" }).nextCalled, true);
});

test("a rejected request gets 403 with the Indonesian message", () => {
  const { nextCalled, res } = run(["kasir"], { role: "admin" });
  assert.equal(nextCalled, false);
  assert.equal(res.statusCode, 403);
  assert.deepEqual(res.body, { message: "Akses ditolak" });
});

test("missing user or unknown role is rejected", () => {
  assert.equal(run(["kasir"], undefined).nextCalled, false);
  assert.equal(run(["kasir"], {}).nextCalled, false);
  assert.equal(run(["kasir"], { role: "guest" }).nextCalled, false);
  assert.equal(run([], undefined).nextCalled, false);
});
