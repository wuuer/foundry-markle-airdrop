# Generate account data for building Merkel Tree

```bash
forge script script/GenerateInput.s.sol
```

# Generate Merkel Tree data

```bash
forge script script/MakeMerkleTree.s.sol
```

**change the root in helperConfig.s.sol**

**change the proofs of user in MerkleAirdropTest.t.sol**

# EIP-191 and EIP-712

https://www.cyfrin.io/blog/understanding-ethereum-signature-standards-eip-191-eip-712

1. EIP-191
   https://eips.ethereum.org/EIPS/eip-191
2. EIP-712  
   https://eips.ethereum.org/EIPS/eip-712

# ECDSA

# Transaction types

    1. 113

# EIP712 MessageHash

```bash
cast call <contract-address> "getMessageHash(address,uint256)" <account-address> 25000000000000000000 --rpc-url http://localhost:8545
```

# ECDSA sign

```bash
cast wallet sign --no-hash <MessageHash> --private-key <private-key>
```
