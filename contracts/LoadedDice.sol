// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

/**
 * @title LoadedDice contract
 * @dev Extends ERC721 Non-Fungible Token Standard basic implementation
 */
contract LoadedDice is ERC721, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    constructor() ERC721("LoadedDice", "LD") {}

    uint256 public constant loadedDicePrice = 60000000000000000; // 0.06 ETH
    uint256 public constant maxLoadedDicePurchase = 100;
    uint256 public MAX_LOADED_DICE = 10762;
    bool public saleIsActive = false;

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // allows owner to reserve
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

    function mintLoadedDice(uint256 numberOfTokens) public payable {
        require(saleIsActive, "Sale must be active to mint LoadedDice");
        require(
            numberOfTokens <= maxLoadedDicePurchase,
            "Can only mint 100 tokens at a time"
        );
        require(
            totalSupply().add(numberOfTokens) <= MAX_LOADED_DICE,
            "Purchase would exceed max supply of LoadedDice"
        );
        require(
            loadedDicePrice.mul(numberOfTokens) <= msg.value,
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
