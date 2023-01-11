//SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
pragma solidity ^0.8;

contract BasicNFT is ERC721 {
    string public constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";
    uint private s_tokenIndex;

    constructor() public ERC721("Domgie", "DOG") {
        s_tokenIndex = 0;
    }

    function mintNFT() public returns (uint) {
        _safeMint(msg.sender, s_tokenIndex);
        s_tokenIndex = s_tokenIndex + 1;
        return s_tokenIndex;
    }

    function tokenURI(uint256 tokenId) public pure override returns (string memory) {
        // require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return TOKEN_URI;
    }

    function getTokenIndex() public returns (uint) {
        return s_tokenIndex;
    }
}
