//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "base64-sol/base64.sol";
error ERC721Metadata__URI_QueryFor_NonExistentToken();
contract DynamicSVGnft is ERC721, Ownable {
    uint256 private s_tokenIndex;
    string private s_lowImageURI;
    string private s_highImageURI;
    mapping(uint256 => int256) private s_tokenIdToHighValues;
    AggregatorV3Interface internal immutable i_priceFeed;
    
    event CreatedNFT(uint256 indexed tokenId, int256 highValue);

    constructor(
        address pf,
        string memory lowImageURI,
        string memory highImageURI
    ) ERC721("DynamicSVGnft", "DSN"){
        i_priceFeed = AggregatorV3Interface(pf);
        s_highImageURI = highImageURI;
        s_lowImageURI = lowImageURI;
        s_tokenIndex = 0;
    }

    function mintNFT(int256 highvalue) public {
        s_tokenIdToHighValues[s_tokenIndex] = highvalue;
        _safeMint(msg.sender, s_tokenIndex);
        s_tokenIndex = s_tokenIndex + 1;
        emit CreatedNFT(s_tokenIndex,highvalue);
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = _baseURI();
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) {
            revert ERC721Metadata__URI_QueryFor_NonExistentToken();
        }
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        string memory imageURI = s_lowImageURI;
        if (price >= s_tokenIdToHighValues[tokenId]) {
            imageURI = s_highImageURI;
        }
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(), // You can add whatever name here
                                '", "description":"An NFT that changes based on the Chainlink Feed", ',
                                '"attributes": [{"trait_type": "coolness", "value": 100}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function getLowSVG() public view returns (string memory) {
        return s_lowImageURI;
    }

    function getHighSVG() public view returns (string memory) {
        return s_highImageURI;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return i_priceFeed;
    }

    function getTokenIndex() public view returns (uint256) {
        return s_tokenIndex;
    }
}
