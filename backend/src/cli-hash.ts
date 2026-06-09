#!/usr/bin/env tsx
/**
 * troptions-ucc backend cli-hash
 * Quick local hashing of a file for legal / collateral packets.
 *
 * Usage:
 *   npm run hash -- --file "C:\path\to\NST T pledge agreement 2025-12-30_150719.pdf"
 *   npm run hash -- --text "hello world"
 */

import { createHash } from 'crypto';
import { readFileSync } from 'fs';
import { argv, exit } from 'process';

function sha256(buf: Buffer): string {
  return '0x' + createHash('sha256').update(buf).digest('hex');
}

function keccak256(buf: Buffer): string {
  return '0x' + createHash('sha3-256').update(buf).digest('hex');
}

const args = argv.slice(2);
let buf: Buffer | null = null;
let label = '';

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--file' && args[i + 1]) {
    const p = args[i + 1];
    buf = readFileSync(p);
    label = p;
    i++;
  } else if (args[i] === '--text' && args[i + 1]) {
    buf = Buffer.from(args[i + 1], 'utf8');
    label = '(inline text)';
    i++;
  }
}

if (!buf) {
  console.error('Usage: npm run hash -- --file <path> | --text <string>');
  exit(1);
}

console.log(`File: ${label}`);
console.log(`Size: ${buf.length} bytes`);
console.log(`sha256:   ${sha256(buf)}`);
console.log(`keccak256 (stand-in): ${keccak256(buf)}`);
console.log('');
console.log('Register the sha256 (or keccak) via the on-chain registries after legal review.');
