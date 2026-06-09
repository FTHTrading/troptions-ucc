// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TroptionsReserveRegistry
 * @notice On-chain attestation of reserve / collateral balances linked to specific
 *         pledge instruments (primarily the NST 700M-class pledge and related UCC collateral).
 *
 *         Amounts are stored as strings to preserve exact decimal representation
 *         (avoids u128 / 18-decimal ambiguity across asset classes and legacy instruments).
 *
 * @dev Designed for forensic reconstruction and proof-of-reserve style queries.
 *      Every attestation emits rich events. Off-chain systems (backend + legal) are
 *      expected to supply a matching document hash from DocumentHashRegistry.
 */
contract TroptionsReserveRegistry {
    struct ReserveAttestation {
        string pledgeId;           // e.g. "NST-T-2025-12-30-700M" or internal identifier
        string collateralId;       // sub-instrument or CUSIP-like id within the pledge
        string asset;              // "USD", "USDC", "TROPTIONS", "REAL_ESTATE_PLEDGE", etc.
        string amount;             // exact amount as string (e.g. "700000000.00")
        bytes32 supportingDocHash; // link to DocumentHashRegistry (pledge agreement, valuation, UCC, etc.)
        address attestor;          // who signed/attested on-chain
        uint64 timestamp;          // attestation time
        string note;               // free text (valuation method, haircut, source, etc.)
    }

    // pledgeId => collateralId => latest attestation
    mapping(string => mapping(string => ReserveAttestation)) public attestations;

    // history length per (pledge, collateral) — simple append-only history
    mapping(string => mapping(string => ReserveAttestation[])) public history;

    address public owner;
    mapping(address => bool) public attestors;

    event ReserveAttested(
        string indexed pledgeId,
        string indexed collateralId,
        string asset,
        string amount,
        bytes32 indexed supportingDocHash,
        address attestor,
        uint64 timestamp
    );

    event AttestorAdded(address indexed attestor);
    event AttestorRemoved(address indexed attestor);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAttestor() {
        require(attestors[msg.sender] || msg.sender == owner, "Not authorized attestor");
        _;
    }

    constructor() {
        owner = msg.sender;
        attestors[msg.sender] = true;
        emit AttestorAdded(msg.sender);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        address prev = owner;
        owner = newOwner;
        emit OwnershipTransferred(prev, newOwner);
    }

    function addAttestor(address attestor) external onlyOwner {
        require(attestor != address(0), "Zero address");
        attestors[attestor] = true;
        emit AttestorAdded(attestor);
    }

    function removeAttestor(address attestor) external onlyOwner {
        attestors[attestor] = false;
        emit AttestorRemoved(attestor);
    }

    /**
     * @notice Record a new reserve / collateral attestation.
     * @dev Always appends to history. Latest view is also available via attestations[pledgeId][collateralId].
     *      supportingDocHash should come from a prior (or same tx) registration in DocumentHashRegistry.
     */
    function attestReserve(
        string calldata pledgeId,
        string calldata collateralId,
        string calldata asset,
        string calldata amount,
        bytes32 supportingDocHash,
        string calldata note
    ) external onlyAttestor {
        require(bytes(pledgeId).length > 0, "pledgeId required");
        require(bytes(collateralId).length > 0, "collateralId required");
        require(bytes(asset).length > 0, "asset required");
        require(bytes(amount).length > 0, "amount required");

        ReserveAttestation memory att = ReserveAttestation({
            pledgeId: pledgeId,
            collateralId: collateralId,
            asset: asset,
            amount: amount,
            supportingDocHash: supportingDocHash,
            attestor: msg.sender,
            timestamp: uint64(block.timestamp),
            note: note
        });

        // update latest
        attestations[pledgeId][collateralId] = att;

        // append history
        history[pledgeId][collateralId].push(att);

        emit ReserveAttested(
            pledgeId,
            collateralId,
            asset,
            amount,
            supportingDocHash,
            msg.sender,
            att.timestamp
        );
    }

    function getLatest(string calldata pledgeId, string calldata collateralId)
        external
        view
        returns (ReserveAttestation memory)
    {
        return attestations[pledgeId][collateralId];
    }

    function getHistoryLength(string calldata pledgeId, string calldata collateralId)
        external
        view
        returns (uint256)
    {
        return history[pledgeId][collateralId].length;
    }

    function getHistoryEntry(
        string calldata pledgeId,
        string calldata collateralId,
        uint256 index
    ) external view returns (ReserveAttestation memory) {
        return history[pledgeId][collateralId][index];
    }
}
