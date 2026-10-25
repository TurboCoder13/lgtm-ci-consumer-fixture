"use strict";
const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const crypto = require("node:crypto");
const { spawnSync } = require("node:child_process");
const { setTimeout: delay } = require("node:timers/promises");
const { createDecoder, completeness, freeze } = require("./capture.cjs");

const query =
  "2026-10-25 21:00:00.123456 IP (proto UDP (17), length 60)\n" +
  "    127.0.0.1.40000 > 127.0.0.53.53: 1234+ A? api.github.com. (32)\n";
const answer =
  "2026-10-25 21:00:00.124567 IP (proto UDP (17), length 76)\n" +
  "    127.0.0.53.53 > 127.0.0.1.40000: 1234 q: A? api.github.com. 1/0/0 api.github.com. A 140.82.116.5 (48)\n";
const initialized =
  "agent-status=Initialized\nendpoint called ip address:port 140.82.116.5:443, domain: api.github.com., pid: 1234, process: curl\n";

function valid() {
  return {
    state: { stage: "frozen", healthyAtFreeze: true },
    wire: query + answer,
    agent: initialized,
  };
}

test("preserve UTC timestamps, directions, query ID and answer through chunk boundaries", () => {
  let result = "";
  const decoder = createDecoder((record) => (result += record));
  const data = query + answer;
  for (let offset = 0; offset < data.length; offset += 7)
    decoder.feed(data.slice(offset, offset + 7));
  decoder.flush();
  assert.equal(result, data);
});

test("omit unrelated DNS records without orphaning headers", () => {
  let result = "";
  const decoder = createDecoder((record) => (result += record));
  decoder.feed(query.replace("api.github.com", "unrelated.invalid") + answer);
  decoder.flush();
  assert.equal(result, answer);
});

test("complete evidence is distinguishable from mere network success", () => {
  assert.deepEqual(completeness(valid()), []);
});

for (const stage of ["missing", "starting", "failed", "ended"])
  test(`reject ${stage} capture even with plausible packet text`, () => {
    const evidence = valid();
    evidence.state.stage = stage;
    assert.notEqual(completeness(evidence).length, 0);
  });

test("reject a freeze after capture ended early", () => {
  const evidence = valid();
  evidence.state.healthyAtFreeze = false;
  assert.notEqual(completeness(evidence).length, 0);
});

test("reject empty or error-only capture", () => {
  for (const wire of ["", "tcpdump: Permission denied\n"])
    assert.notEqual(completeness({ ...valid(), wire }).length, 0);
});

test("reject queries without answers, including cached/unobserved response paths", () => {
  assert.notEqual(completeness({ ...valid(), wire: query }).length, 0);
});

test("reject answers without an observed query", () => {
  const wire = answer.replace("q: A? api.github.com. ", "");
  assert.notEqual(completeness({ ...valid(), wire }).length, 0);
});

test("reject absent agent or application observations", () => {
  for (const agent of ["", "Initialized\n", "endpoint called ip address:port"])
    assert.notEqual(completeness({ ...valid(), agent }).length, 0);
});

test("real collector freezes immutable text while a mocked capture emits late packets", async (context) => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "ci1203-capture-"));
  context.after(() => fs.rmSync(directory, { recursive: true, force: true }));
  const bin = path.join(directory, "bin");
  fs.mkdirSync(bin);
  fs.writeFileSync(
    path.join(bin, "sudo"),
    `#!${process.execPath}\n` +
      `process.on('SIGINT', () => {});\n` +
      `process.stderr.write('tcpdump: listening on any\\n');\n` +
      `process.stdout.write(${JSON.stringify(query + answer)});\n` +
      `setTimeout(() => process.stdout.write(${JSON.stringify(query + answer)}), 700);\n` +
      `setTimeout(() => process.exit(0), 1000);\n`,
    { mode: 0o755 },
  );
  const started = spawnSync(
    process.execPath,
    [path.join(__dirname, "capture.cjs"), "start", directory],
    {
      env: {
        ...process.env,
        PATH: `${bin}${path.delimiter}${process.env.PATH}`,
      },
      encoding: "utf8",
      timeout: 7000,
    },
  );
  assert.equal(started.status, 0, started.stderr);
  await delay(100);
  await freeze(directory);
  const target = path.join(directory, "dns-wire.txt");
  const before = fs.readFileSync(target);
  const digest = crypto.createHash("sha256").update(before).digest("hex");
  fs.writeFileSync(
    path.join(directory, "SHA256SUMS"),
    `${digest}  dns-wire.txt\n`,
  );
  const manifest = fs.readFileSync(path.join(directory, "SHA256SUMS"));
  await delay(1100);
  assert.equal(fs.readFileSync(target, "utf8"), query + answer);
  assert.deepEqual(fs.readFileSync(target), before);
  assert.deepEqual(
    fs.readFileSync(path.join(directory, "SHA256SUMS")),
    manifest,
  );
  const state = JSON.parse(
    fs.readFileSync(path.join(directory, "capture-status.txt"), "utf8"),
  );
  assert.equal(state.healthyAtFreeze, true);
});

for (const scenario of ["unavailable", "startup-error", "early-exit"])
  test(`real startup rejects ${scenario} capture`, (context) => {
    const directory = fs.mkdtempSync(path.join(os.tmpdir(), "ci1203-start-"));
    context.after(() => fs.rmSync(directory, { recursive: true, force: true }));
    const bin = path.join(directory, "bin");
    fs.mkdirSync(bin);
    if (scenario !== "unavailable")
      fs.writeFileSync(
        path.join(bin, "sudo"),
        `#!${process.execPath}\n` +
          (scenario === "early-exit"
            ? "process.stderr.write('tcpdump: listening on any\\n');process.exit(1);\n"
            : "process.stderr.write('tcpdump: Permission denied\\n');process.exit(1);\n"),
        { mode: 0o755 },
      );
    const started = spawnSync(
      process.execPath,
      [path.join(__dirname, "capture.cjs"), "start", directory],
      {
        env: { ...process.env, PATH: bin },
        encoding: "utf8",
        timeout: 7000,
      },
    );
    assert.equal(started.status, 1);
    assert.match(started.stderr, /startup failed/);
  });

test("a DNS reply question section is not evidence of an observed query", () => {
  assert.notEqual(completeness({ ...valid(), wire: answer }).length, 0);
});
