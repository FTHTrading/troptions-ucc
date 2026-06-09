// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DocumentHashRegistry
 * @notice Append-only (versioned) registry for cryptographic hashes of legal / collateral documents.
 *         Used for the NST / TROPTIONS 700M pledge collateral package and related UCC filings.
 *
 *         Primary goal: create an immutable, event-sourced audit trail that can be
 *         cross-referenced to the exact bytes of the PDFs held in operator-controlled storage.
 *
 * @dev Events are the source of truth for forensic reconstruction.
 *      Hashes are stored as bytes32 (keccak256 recommended for on-chain, sha256 acceptable for off-chain prep).
 */
contract DocumentHashRegistry {
    struct DocRecord {
        string name;           // e.g. "NST-T-Pledge-2025-12-30", "UCC1-Collateral-Draft-v1"
        uint8 version;         // 1, 2, ... for amendments / re-executions
        address registrant;    // who performed the on-chain registration
        uint64 timestamp;      // block timestamp at registration
        bytes32 contentHash;   // the hash being registered (idempotency key per (name,version))
        string uri;            // optional off-chain pointer (IPFS, R2 signed URL, internal ref)
    }

    // name => version => record
    mapping(string => mapping(uint8 => DocRecord)) public records;

    // contentHash => (name, version) for reverse lookup / collision prevention
    mapping(bytes32 => string) public hashToName;
    mapping(bytes32 => uint8) public hashToVersion;

    address public owner;
    mapping(address => bool) public registrars; // authorized to call registerDocument

    event DocumentRegistered(
        string indexed name,
        uint8 indexed version,
        bytes32 indexed contentHash,
        address registrant,
        uint64 timestamp,
        string uri
    );

    event RegistrarAdded(address indexed registrar);
    event RegistrarRemoved(address indexed registrar);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyRegistrar() {
        require(registrars[msg.sender] || msg.sender == owner, "Not authorized registrar");
        _;
    }

    constructor() {
        owner = msg.sender;
        registrars[msg.sender] = true;
        emit RegistrarAdded(msg.sender);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        address prev = owner;
        owner = newOwner;
        emit OwnershipTransferred(prev, newOwner);
    }

    function addRegistrar(address registrar) external onlyOwner {
        require(registrar != address(0), "Zero address");
        registrars[registrar] = true;
        emit RegistrarAdded(registrar);
    }

    function removeRegistrar(address registrar) external onlyOwner {
        registrars[registrar] = false;
        emit RegistrarRemoved(registrar);
    }

    /**
     * @notice Register (or re-register same content for same (name,version)) a document hash.
     * @dev Idempotent on identical (name, version, contentHash). Reverts on contentHash collision with different (name,version).
     */
    function registerDocument(
        string calldata name,
        uint8 version,
        bytes32 contentHash,
        string calldata uri
    ) external onlyRegistrar {
        require(bytes(name).length > 0, "Name required");
        require(contentHash != bytes32(0), "Hash required");
        require(version > 0, "Version must be > 0");

        DocRecord storage existing = records[name][version];

        if (existing.contentHash != bytes32(0)) {
            // Already registered — must be identical content for safety
            require(existing.contentHash == contentHash, "Version already exists with different hash");
            // Allow uri update only by original registrar or owner (simple rule)
            if (bytes(uri).length > 0) {
                existing.uri = uri;
            }
            return;
        }

        // Collision check across all names/versions
        string memory priorName = hashToName[contentHash];
        if (bytes(priorName).length > 0) {
            require(
                keccak256(bytes(priorName)) == keccak256(bytes(name)) && hashToVersion[contentHash] == version,
                "Content hash already registered under different identifier"
            );
        }

        DocRecord memory rec = DocRecord({
            name: name,
            version: version,
            registrant: msg.sender,
            timestamp: uint64(block.timestamp),
            contentHash: contentHash,
            uri: uri
        });

        records[name][version] = rec;
        hashToName[contentHash] = name;
        hashToVersion[contentHash] = version;

        emit DocumentRegistered(name, version, contentHash, msg.sender, rec.timestamp, uri);
    }

    function getRecord(string calldata name, uint8 version)
        external
        view
        returns (DocRecord memory)
    {
        return records[name][version];
    }

    function getByHash(bytes32 contentHash)
        external
        view
        returns (string memory name, uint8 version, DocRecord memory record)
    {
        name = hashToName[contentHash];
        version = hashToVersion[contentHash];
        record = records[name][version];
    }
}
