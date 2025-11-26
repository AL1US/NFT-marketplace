// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ERC/Xcoin.sol";
import "./ERC/NFT.sol";

contract Main is Xcoin, XcoinNFT {

    /*
    * Мульти функции совмещающие работу двух стандартов токенов
    */

    function buyNFT(uint256 _id, uint256 _amount) public payable {

        uint256 priceNFT = storeNFT[_id].price * _amount;
        uint256 amountNFT = storeNFT[_id].amount;
        address ownerNFT = storeNFT[_id].owner;
        bytes memory data = "";

        require(storeNFT[_id].owner != msg.sender, "The owner of the nft cannot buy it from himself");
        require(balanceOf(msg.sender) >= priceNFT, "You dot't have ehougn Xcoin");
        require(amountNFT >= _amount, "Your chosen amount increases the number of tokens in the store.");
        require(amountNFT != 0, "This nft does not exist");

        // перевод токенов овнеру nft
        transfer(ownerNFT, priceNFT);

        // перевод самих nft
        safeTransferFrom(address(this), msg.sender, _id, _amount, data);

        // вычитание _amount из amount
        storeNFT[_id].amount -= _amount;

        // if amount in store == 0 -> del this nft 
        if (storeNFT[_id].amount == 0) {
            delete storeNFT[_id];
        }
    }


    // Тут мы вручную вносим адрес, чтомы при деплое родительских контрактов, их овнером был не сам контракт,
    // а адрес того кто деплоит
    constructor(address initialOwner) Xcoin(initialOwner) XcoinNFT(initialOwner) {

    }
} 
