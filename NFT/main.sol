// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ERC/Xcoin.sol";
import "./ERC/NFT.sol";

contract Main is Xcoin, XcoinNFT {

    constructor(address initialOwner) Xcoin(initialOwner) XcoinNFT(initialOwner) {
       
        
    }
} 