// End-to-end API tests against a throwaway in-memory MongoDB replica set.
//
//   cd apps/backend && npm install && npm test
//
// - Needs no .env: uses test-only secrets below, never real ones.
// - Cloudinary is replaced with a local stub, so nothing is uploaded.
// - Nothing touches the real (Render / Atlas) database.
const path = require('path');
const assert = require('assert');
const { MongoMemoryReplSet } = require('mongodb-memory-server-core');

const BACKEND = path.join(__dirname, '..');
const PORT = 5099;
const BASE = `http://127.0.0.1:${PORT}/api`;

let uploadCount = 0;
const cloudinaryPath = require.resolve(path.join(BACKEND, 'config/cloudinary.js'));
require.cache[cloudinaryPath] = {
  id: cloudinaryPath,
  filename: cloudinaryPath,
  loaded: true,
  exports: {
    uploader: {
      upload_stream(opts, cb) {
        return {
          end() {
            uploadCount += 1;
            cb(null, {
              secure_url: `https://example.test/${opts.folder}/${uploadCount}`,
              public_id: `${opts.folder}/${uploadCount}`,
            });
          },
        };
      },
      destroy: async () => ({}),
    },
  },
};

async function call(method, url, { token, body, form } = {}) {
  const headers = {};
  if (token) headers.Authorization = `Bearer ${token}`;
  let payload;
  if (form) payload = form;
  else if (body !== undefined) {
    headers['Content-Type'] = 'application/json';
    payload = JSON.stringify(body);
  }
  const res = await fetch(BASE + url, { method, headers, body: payload });
  let json = null;
  try { json = await res.json(); } catch (_) {}
  return { status: res.status, json };
}

function pngBlob() {
  return new Blob([Buffer.from('89504e470d0a1a0a', 'hex')], { type: 'image/png' });
}

const steps = [];
function step(name, fn) { steps.push([name, fn]); }

module.exports = { call, step, steps, assert, pngBlob, BASE };

(async () => {
  const repl = await MongoMemoryReplSet.create({ replSet: { count: 1, storageEngine: 'wiredTiger' } });
  process.env.MONGO_URI = repl.getUri('surplus-test');
  process.env.JWT_SECRET = 'test-only-secret';
  process.env.ADMIN_SETUP_SECRET = 'test-setup-secret';
  process.env.PORT = String(PORT);

  require(path.join(BACKEND, 'server.js'));
  await new Promise((r) => setTimeout(r, 1500));

  const files = process.argv.slice(2);
  for (const file of files.length ? files : [path.join(__dirname, 'flow.e2e.js')]) {
    require(path.resolve(file));
  }

  let failed = 0;
  for (const [name, fn] of steps) {
    try {
      await fn();
      console.log('PASS', name);
    } catch (e) {
      failed += 1;
      console.log('FAIL', name, '\n   ', e.message);
    }
  }
  console.log(failed ? `${failed} FAILED` : `ALL ${steps.length} PASSED`);
  await repl.stop();
  process.exit(failed ? 1 : 0);
})();
