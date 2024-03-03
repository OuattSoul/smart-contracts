// SPDX-License-Identifier: MIT

pragma solidity  ^0.8.20;


contract FunctionSignature {

    /*uint256 public num;

    function getNum() public view returns (uint256) {
        return num;
    }

    function setNum(uint256 _newNum) public {
        num = _newNum;
    }*/

    // "function setNum(uint256 _newNum)" ==> 0xdf141266

    // "function getNum()" ==> 0xf944f5ba

    function getSignature1(string calldata _funtionSignature) external pure returns (bytes4) {
        
        return bytes4(keccak256(bytes(_funtionSignature)));
    }
}