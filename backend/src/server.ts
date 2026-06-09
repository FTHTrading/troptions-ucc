/**
 * troptions-ucc / backend
 * Signature packet router + reproducible document hasher for NST/TROPTIONS collateral.
 *
 * Endpoints:
 *   GET  /health
 *   POST /hash                 (JSON { content: string } or multipart file)
 *   POST /signature-packet     (prepare a bundle for legal signers / on-chain registration)
 *
 * Hashes are produced with SHA-256 (standard for off-chain legal) + optional keccak256
 * for direct use with the on-chain registries.
 */

import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import multer from 'multer';
import { createHash, createHash as nodeCreateHash } from 'crypto';
import { z } from 'zod';
import { Buffer } from 'buffer';

const app = express();
const port = process.env.PORT ? Number(process.env.PORT) : 4110;

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(morgan('tiny'));

// In-memory packet store (replace with DB / R2 + signed URL in production)
const packets = new Map<string, any>();

// --- Schemas ---
const HashRequestSchema = z.object({
  content: z.string().optional(), // base64 or utf8 text
  encoding: z.enum(['utf8', 'base64']).default('utf8'),
});

const SignaturePacketSchema = z.object({
  docHash: z.string().regex(/^0x[0-9a-fA-F]{64}$|^[0-9a-fA-F]{64}$/),
  name: z.string().min(1),
  version: z.number().int().positive(),
  signers: z.array(z.object({
    name: z.string(),
    role: z.string().optional(),
    signature: z.string().optional(), // hex or base64
    signedAt: z.string().optional(),
  })).min(1),
  metadata: z.record(z.any()).optional(),
  sourceRef: z.string().optional(), // e.g. OneDrive path or internal id
});

// --- Helpers ---
function sha256(data: Buffer): string {
  return '0x' + createHash('sha256').update(data).digest('hex');
}

function keccak256(data: Buffer): string {
  // Node 21.6+ has webcrypto, but for broad compatibility we use a simple
  // note: for production on-chain keccak, prefer ethers/keccak or viem.
  // Here we provide a placeholder that is consistent within this service.
  // In real use, call the same hash function the contracts expect (keccak256).
  // For now we return a sha3-256 as stand-in and document the difference.
  // TODO: integrate @noble/hashes or viem for exact keccak256.
  return '0x' + createHash('sha3-256').update(data).digest('hex');
}

function toBuffer(input: string, encoding: 'utf8' | 'base64'): Buffer {
  if (encoding === 'base64') {
    return Buffer.from(input, 'base64');
  }
  return Buffer.from(input, 'utf8');
}

// --- Routes ---
app.get('/health', (_req, res) => {
  res.json({
    ok: true,
    service: 'troptions-ucc-backend',
    version: '0.1.0',
    timestamp: new Date().toISOString(),
  });
});

/**
 * Hash a document (text or uploaded file).
 * Returns both sha256 (recommended for legal packets) and a keccak256 stand-in.
 */
app.post('/hash', multer({ storage: multer.memoryStorage() }).single('file'), (req, res) => {
  try {
    let buf: Buffer;

    if (req.file) {
      buf = req.file.buffer;
    } else {
      const parsed = HashRequestSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({ error: 'Invalid body', issues: parsed.error.issues });
      }
      if (!parsed.data.content) {
        return res.status(400).json({ error: 'Provide either file upload or JSON content' });
      }
      buf = toBuffer(parsed.data.content, parsed.data.encoding);
    }

    const sha = sha256(buf);
    const k256 = keccak256(buf);

    res.json({
      sha256: sha,
      keccak256: k256,
      size: buf.length,
      note: 'Use sha256 for off-chain legal packets. keccak256 here is a stand-in; align with on-chain expectation before mainnet use.',
    });
  } catch (err: any) {
    console.error(err);
    res.status(500).json({ error: 'Hash computation failed', message: err.message });
  }
});

/**
 * Accept a signature packet (hashes + signer metadata).
 * Stores it locally for now and returns a packetRef that can be used to retrieve it
 * or to drive on-chain registration.
 */
app.post('/signature-packet', (req, res) => {
  const parsed = SignaturePacketSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: 'Invalid packet', issues: parsed.error.issues });
  }

  const packet = {
    ...parsed.data,
    receivedAt: new Date().toISOString(),
    packetRef: 'pkt_' + Date.now().toString(36) + '_' + Math.random().toString(36).slice(2, 8),
  };

  packets.set(packet.packetRef, packet);

  // In production: persist to durable store, email signers, generate PDF cover sheet, etc.
  res.status(201).json({
    ok: true,
    packetRef: packet.packetRef,
    docHash: packet.docHash,
    message: 'Packet accepted. Use packetRef to retrieve or to prepare on-chain registration payload.',
  });
});

app.get('/signature-packet/:ref', (req, res) => {
  const p = packets.get(req.params.ref);
  if (!p) return res.status(404).json({ error: 'Not found' });
  res.json(p);
});

app.get('/signature-packets', (_req, res) => {
  res.json(Array.from(packets.values()));
});

// --- Error handler ---
app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal error' });
});

app.listen(port, () => {
  console.log(`[troptions-ucc-backend] listening on http://127.0.0.1:${port}`);
});
