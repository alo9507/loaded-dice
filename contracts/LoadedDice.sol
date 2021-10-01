// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title LoadedDice contract
 * @dev Extends ERC721 Non-Fungible Token Standard basic implementation
 */
contract LoadedDice is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    string public PROV =
        "b80d60a4defcca5af3ed6526d8c0f86089b9400659c89da2b2725b32f8686d4a";
    uint256 public constant craniumPrice = 60000000000000000; // 0.06 ETH
    uint256 public constant maxCraniumPurchase = 100;
    uint256 public MAX_LOADED_DICE = 10762;
    bool public saleIsActive = false;

    string private _baseURIextended;
    mapping(uint256 => string) private _tokenURIs;

    constructor() ERC721("LoadedDice", "LD") {}

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function reserveLoadedDice() public onlyOwner {
        uint256 supply = totalSupply();
        uint256 i;
        for (i = 0; i < 40; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    function mintLoadedDice(uint256 numberOfTokens) public payable {
        require(saleIsActive, "Sale must be active to mint LoadedDice");
        require(
            numberOfTokens <= maxCraniumPurchase,
            "Can only mint 100 tokens at a time"
        );
        require(
            totalSupply().add(numberOfTokens) <= MAX_LOADED_DICE,
            "Purchase would exceed max supply of LoadedDice"
        );
        require(
            craniumPrice.mul(numberOfTokens) <= msg.value,
            "Ether value sent is not correct"
        );

        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_LOADED_DICE) {
                _safeMint(msg.sender, mintIndex);
            }
        }
    }
}
