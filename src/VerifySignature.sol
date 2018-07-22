pragma solidity ^0.4.24;

contract VerifySignature {

    constructor() public payable {}

    /// destroy the contract and reclaim the leftover funds.
    function kill() public {
        selfdestruct(msg.sender);
    }

    /// signature methods.
    function splitSignature(bytes sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes.
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes sig) public returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return accumulate(message, v, r, s);
        // return ecrecover(prefixed(message), v, r, s);
    }

    /// builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


