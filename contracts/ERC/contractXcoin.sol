// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract contractXcoin is ERC20 {

    /*
    * Обычные переменные
    */

    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10 ** 18; // количество всех токенов в системе

    address ownerXcoin;

    /*
    * Структуры
    */

    struct structUser {
        string nameUser;
        string referalCode;
        uint256 discont; // Процент скидки
    }

    /*
    * Мапинги
    */

    mapping(address => structUser) public user;

    // Конструктор нужен для того, чтобы уже при деплое контракта задать
    // какие либо данные и сделать рутинные действия
    constructor() ERC20("Xcoin", "X") {

        ownerXcoin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

        _mint(ownerXcoin, INITIAL_SUPPLY);

        user[ownerXcoin] = structUser("Owner", "XCoinReferal31415", 0);

        // Remix - Переводы токенов на другие адресы для простоты тестирования
        user[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = structUser("Tom", "PROFI4B202024", 0);
        ERC20._transfer(
            ownerXcoin,
            0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
            200_000
        );

        user[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = structUser("Max", "PROFI78732024", 0);
        ERC20._transfer(
            ownerXcoin,
            0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
            300_000
        );

        user[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = structUser("Jack", "PROFI617F2024", 0);
        ERC20._transfer(
            ownerXcoin,
            0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB,
            400_000
        );

        // Hardhat - эти же переводы только для локальной сети hardhat

        // user[0x70997970C51812dc3A010C7d01b50e0d17dc79C8] = structUser("Tom", "PROFI3C442024", 0);
        // ERC20._transfer(ownerXcoin, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 200_000);

        // user[0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC] = structUser("Max", "PROFI90F72024", 0);
        // ERC20._transfer(ownerXcoin, 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC, 300_000);

        // user[0x90F79bf6EB2c4f870365E785982E1f101E93b906] = structUser("Jack", "PROFI15d32024", 0);
        // ERC20._transfer(ownerXcoin, 0x90F79bf6EB2c4f870365E785982E1f101E93b906, 400_000);
    }
}