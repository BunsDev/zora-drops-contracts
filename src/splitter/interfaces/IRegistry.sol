// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


interface IRegistry {
    function mint(uint256 id, address user) external;

    function burn(uint256 id) external;
}
