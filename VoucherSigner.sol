// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract VoucherSigner is Ownable {

    address voucherSigner;

    function setVoucher(address newSigner) public onlyOwner {
        require(newSigner != voucherSigner, 'Already active');
        require(newSigner != address(0), 'address 0 cant be signer');
        voucherSigner = newSigner;
    }

    function getVoucher() public view returns(address) {
        return voucherSigner;
    }

    constructor ( address signer) {
        setVoucher(signer);
    }


}