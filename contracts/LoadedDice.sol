// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;
import "@chainlink/contracts/src/v0.7/VRFConsumerBase.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

/**
 * @title LoadedDice contract
 * @dev Extends ERC721 Non-Fungible Token Standard basic implementation
 */
contract LoadedDice is ERC721, Ownable, VRFConsumerBase {
    using SafeMath for uint256;
    using Strings for uint256;

    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;

    uint256 public centerRange = 100;
    uint256 public amplitudeRange = 1;

    constructor()
        ERC721("LoadedDice", "LD")
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9,
            0xa36085F69e2889c224210F603D836748e7dC0088
        )
    {
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10**18; // 0.1 LINK (Varies by network)
    }

    uint256 public constant loadedDicePrice = 60000000000000000; // 0.06 ETH
    uint256 public constant maxLoadedDicePurchase = 100;
    uint256 public MAX_LOADED_DICE = 10762;
    bool public saleIsActive = false;

    mapping(uint256 => uint256[]) public diceAttributes;
    mapping(bytes32 => address) public requests;

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
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
                getRandomNumber();
            }
        }
    }

    function getRandomNumber() public returns () {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );

        bytes32 requestId = requestRandomness(keyHash, fee);
        requests[requestId] = msg.sender;
        return requestId;
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        randomResult = randomness;

        uint256 tokenId = totalSupply();
        _safeMint(requests[requestId], tokenId);

        uint256[] diceAttributes = [];
        for (uint256 i = 0; i < 3; i++) {
            diceAttributes.push(randomness % centerRange);
            diceAttributes.push(randomness % amplitudeRange);
        }

        diceAttributes[tokenId] = diceAttributes;
    }
}
