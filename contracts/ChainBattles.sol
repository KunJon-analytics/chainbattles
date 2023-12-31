// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    struct Attributes {
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
    }

    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping(uint256 => Attributes) public tokenIdToAttributes;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function getAttributess(
        uint256 tokenId
    ) public view returns (Attributes memory attributes) {
        attributes = tokenIdToAttributes[tokenId];
    }

    function generateCharacter(
        uint256 tokenId
    ) public view returns (string memory) {
        Attributes memory attribute = tokenIdToAttributes[tokenId];
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels: ",
            attribute.level.toString(),
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Speed: ",
            attribute.speed.toString(),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Strength: ",
            attribute.strength.toString(),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Life: ",
            attribute.life.toString(),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    // not advised for use in a working app
    function createRandomTrait() public view returns (uint) {
        return uint(blockhash(block.number - 1)) % 10;
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToAttributes[newItemId] = Attributes(
            0,
            createRandomTrait(),
            createRandomTrait(),
            createRandomTrait()
        );
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing token");
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this token to train it"
        );
        Attributes storage currentAttributes = tokenIdToAttributes[tokenId];
        currentAttributes.level++;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
