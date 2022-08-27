// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "erc721a/contracts/ERC721A.sol";
import "./VoucherSigner.sol";


contract TestMint is Ownable, ERC721A, ReentrancyGuard, VoucherSigner {

    // Sale Controls
    bool public presaleActive = false;
    bool public saleActive = false;

    // Collection details
    uint256 public maxBatchSize = 3;
    uint256 public collectionSize = 200;

    // Mint Price
    uint256 public mintPrice = 1 ether;

    struct Coupon {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    constructor(address signer) ERC721A("TestMint", "TEST") VoucherSigner(signer) {}

    //Verify Presale Coupon
    function verifyPresale(bytes32 digest, Coupon memory coupon) internal view returns(bool) {
        address signer = ecrecover(digest, coupon.v, coupon.r, coupon.s);
        require(signer != address(0), "ECDSA: invalid signature");
        return signer == getVoucher();
    }

    function publicMint(uint256 _count) external payable nonReentrant {
        uint256 supply = totalSupply();
        require( saleActive, "Public Sale Not Active" );
        require( msg.value == mintPrice * _count, "Incorrect Amount Of ETH Sent" );
        require( _count <= maxBatchSize, "Batch size too large" );
        require( collectionSize >= supply + _count, "Not enough supply" );
        _safeMint(msg.sender, _count);
    }

    function presaleMint(uint256 _count, Coupon memory coupon) external payable nonReentrant {
        bytes32 digest = keccak256(abi.encode(2, msg.sender));
        uint256 supply = totalSupply();
        require( presaleActive, "Public Sale Not Active" );
        require(verifyPresale(digest, coupon), 'Invalid Coupon');
        require( msg.value == mintPrice * _count, "Incorrect Amount Of ETH Sent" );
        require( collectionSize >= supply + _count, "Not enough supply" );
        _safeMint(msg.sender, _count);
    }

    // Set Mint Price
    function setMintPrice(uint256 mintPrice) external onlyOwner {
        mintPrice = mintPrice;
    }

    // Sale Controls
    function setPresaleActive(bool val) public onlyOwner {
        presaleActive = val;
    }

    function setSaleActive(bool val) public onlyOwner {
        saleActive = val;
    }

    // tokenURI data
    string private _baseTokenURI;

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    // withdraw

    function withdrawMoney() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}