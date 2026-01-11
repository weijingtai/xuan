import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { after, before, test } from "node:test";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import { doc, getDoc, setDoc, updateDoc } from "firebase/firestore";

let testEnv;

before(async () => {
  const rules = readFileSync(new URL("../firestore.rules", import.meta.url), "utf8");
  testEnv = await initializeTestEnvironment({
    projectId: "demo-xuan",
    firestore: { rules },
  });
});

after(async () => {
  await testEnv?.cleanup();
});

test("layout_templates: owner can write, other uid denied", async () => {
  const aliceDb = testEnv.authenticatedContext("alice").firestore();
  const bobDb = testEnv.authenticatedContext("bob").firestore();

  const templateDoc = doc(aliceDb, "users", "alice", "modules", "common", "layout_templates", "t1");
  await assertSucceeds(
    setDoc(templateDoc, {
      schemaVersion: 1,
      entityId: "t1",
      collectionId: "c1",
      name: "n1",
      description: null,
      template: { a: 1 },
      version: 1,
      clientUpdatedAt: new Date(),
      serverUpdatedAt: new Date(),
      deletedAt: null,
      lastOperationId: "op1",
      lastDeviceId: "device1",
    }),
  );

  await assertFails(getDoc(doc(bobDb, "users", "alice", "modules", "common", "layout_templates", "t1")));
  await assertFails(
    setDoc(doc(bobDb, "users", "alice", "modules", "common", "layout_templates", "t2"), {
      schemaVersion: 1,
      entityId: "t2",
      collectionId: "c1",
      name: "n2",
      description: null,
      template: { a: 2 },
      version: 1,
      clientUpdatedAt: new Date(),
      serverUpdatedAt: new Date(),
      deletedAt: null,
      lastOperationId: "op2",
      lastDeviceId: "device2",
    }),
  );
});

test("oplog: immutable fields cannot change; status cannot rollback", async () => {
  const aliceDb = testEnv.authenticatedContext("alice").firestore();
  const opDoc = doc(aliceDb, "users/alice/oplog/op1");

  await assertSucceeds(
    setDoc(opDoc, {
      operationId: "op1",
      entityType: "layout_template",
      entityId: "t1",
      opType: "upsert",
      clientTimeUtc: new Date(),
      device: {
        deviceId: "device1",
        platform: "ios",
        formFactor: "phone",
        model: null,
        osVersion: null,
        appVersion: null,
      },
      result: {
        status: "pending",
        attempt: 0,
        errorCode: null,
        errorMessage: null,
        syncedAt: null,
      },
    }),
  );

  await assertSucceeds(
    updateDoc(opDoc, {
      "result.status": "failed",
      "result.attempt": 1,
      "result.errorCode": "network",
      "result.errorMessage": "timeout",
    }),
  );

  await assertFails(updateDoc(opDoc, { entityId: "t2" }));

  await assertSucceeds(
    updateDoc(opDoc, {
      "result.status": "success",
      "result.attempt": 2,
      "result.syncedAt": new Date(),
      "result.errorCode": null,
      "result.errorMessage": null,
    }),
  );

  await assertFails(
    updateDoc(opDoc, {
      "result.status": "pending",
      "result.attempt": 3,
    }),
  );

  const snap = await getDoc(opDoc);
  assert.equal(snap.exists(), true);
});

test("oplog: can transition to dead and cannot leave dead", async () => {
  const aliceDb = testEnv.authenticatedContext("alice").firestore();
  const opDoc = doc(aliceDb, "users/alice/oplog/opDead1");

  await assertSucceeds(
    setDoc(opDoc, {
      operationId: "opDead1",
      entityType: "layout_template",
      entityId: "t1",
      opType: "upsert",
      clientTimeUtc: new Date(),
      device: {
        deviceId: "device1",
        platform: "ios",
        formFactor: "phone",
        model: null,
        osVersion: null,
        appVersion: null,
      },
      result: {
        status: "pending",
        attempt: 0,
        errorCode: null,
        errorMessage: null,
        syncedAt: null,
      },
    }),
  );

  await assertSucceeds(
    updateDoc(opDoc, {
      "result.status": "failed",
      "result.attempt": 1,
      "result.errorCode": "network",
      "result.errorMessage": "timeout",
      "result.syncedAt": new Date(),
    }),
  );

  await assertSucceeds(
    updateDoc(opDoc, {
      "result.status": "dead",
      "result.attempt": 2,
      "result.errorCode": "network",
      "result.errorMessage": "timeout",
      "result.syncedAt": new Date(),
    }),
  );

  await assertFails(
    updateDoc(opDoc, {
      "result.status": "success",
      "result.attempt": 3,
      "result.syncedAt": new Date(),
      "result.errorCode": null,
      "result.errorMessage": null,
    }),
  );

  await assertFails(
    updateDoc(opDoc, {
      "result.status": "pending",
      "result.attempt": 3,
    }),
  );

  await assertSucceeds(
    updateDoc(opDoc, {
      "result.status": "dead",
      "result.attempt": 3,
      "result.errorCode": "network",
      "result.errorMessage": "timeout",
      "result.syncedAt": new Date(),
    }),
  );
});
