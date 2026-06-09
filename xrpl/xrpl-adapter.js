#!/usr/bin/env node
/**
 * xrpl-adapter.js
 * Reference implementation: turns an Apostle attestation (from TroptionsReserveRegistry / DocumentHashRegistry)
 * into XRPL-compatible reference data for loan/vault memos or URIs.
 *
 * Usage (after an attestation on Apostle):
 *   node xrpl-adapter.js "NST-T-2025-12-30-700M" "0x<docHash>" "0x<apostleAttestTx>" "700000000.00" "Scotia Bank Canada custody"
 *
 * Output includes hex MemoData ready for XRPL transactions and a full reference object.
 *
 * This demonstrates the XRPL integration guidance in executable form.
 * Adapt to your exact XRPL lending protocol objects (vaults, loans, broker flows).
 */

const args = process.argv.slice(2);
if (args.length < 5) {
  console.error('Usage: node xrpl-adapter.js <pledgeId> <docHash> <attestTx> <amount> <custodyNote>');
  console.error('Example: node xrpl-adapter.js "NST-T-2025-12-30-700M" "0xabc123..." "0xdef456..." "700000000.00" "Scotia Bank Canada custody"');
  process.exit(1);
}

const [pledgeId, docHash, attestTx, amount, custodyNote] = args;

const reference = {
  pledgeId,
  docHash,
  attestTx,
  amount,
  asset: "USD",
  custody: custodyNote,
  securedParty: "Troptions",
  evidence: "https://<your-deployed-pages-site> or https://raw.githubusercontent.com/FTHTrading/troptions-ucc/main/legal/UCC1-COLLATERAL-DRAFT.md",
  source: "troptions-ucc repo + Apostle (chain 7332) attestation for 700M NST/Troptions pledge"
};

// For XRPL MemoData (common pattern)
const memoDataHex = Buffer.from(JSON.stringify(reference)).toString('hex').toUpperCase();

console.log('=== XRPL REFERENCE (ready for MemoData or URI) ===');
console.log('MemoData (hex for MemoData field):');
console.log(memoDataHex);
console.log('');
console.log('Full reference object:');
console.log(JSON.stringify(reference, null, 2));
console.log('');
console.log('Example XRPL tx fragment (Memos array):');
console.log(JSON.stringify([
  {
    Memo: {
      MemoType: Buffer.from('PledgeReference').toString('hex').toUpperCase(),
      MemoData: memoDataHex
    }
  }
], null, 2));
console.log('');
console.log('For URI field (e.g. in tokens or custom lending objects):');
console.log(`troptions-ucc://pledge/${pledgeId}?docHash=${docHash}&attestTx=${attestTx}&amount=${amount}`);
console.log('');
console.log('Next: submit via xrpl.js or your XRPL client, referencing the Apostle attestation for the 700M collateral.');
console.log('See xrpl/XRPL_INTEGRATION.md for full context and review disclaimers.');
