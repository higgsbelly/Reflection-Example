// SPDX-License-Identifier: MIT

pragma solidity >=0.8.19 <0.9.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol"; //swap security for utils in remix
import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol"; //swap security for utils in remix
import {ReflectionMetadata} from "./ReflectionMetadata.sol";

error MaxSupplyReached();
error InsufficientFunds();

//@author @higgsbelly
contract Reflection is ERC721, Ownable, Pausable, IERC2981, ReentrancyGuard {
    using SafeCast for uint256;

    //Interface
    ReflectionMetadata public reflectionMetadata;

    //Contract Variables Definition and Initialization
    uint256 public totalSupply = 0;
    uint256 public cost = 330000000000000000;
    uint256 public maxSupply = 999;
    bytes32 public merkleRoot;
    bool public allowlistMintEnabled = false;

    struct TokenData {
        bytes32 seed;
    }

    mapping(uint256 => TokenData) public tokenData;
    mapping(address => bool) public allowlistClaimed;

    //Royalty Information
    address public defaultRoyaltyReceiver = 0xaC0762C5B7500a9C60cCE8BDFB4036c0152E5a1b; //Artist address
    mapping(uint256 => address) royaltyReceivers;
    uint256 public defaultRoyaltyPercentage = 500; // BPS
    mapping(uint256 => uint256) royaltyPercentages;

    constructor() ERC721("Reflection", "REF") Ownable(msg.sender) {
        _pause();
    }

    function setReflectionMetadata(address _reflectionMetatdata) public onlyOwner {
        reflectionMetadata = ReflectionMetadata(_reflectionMetatdata);
    }

    function tokenSVG(uint256 _tokenId) public view returns (string memory) {
        return (reflectionMetadata.getTokenSVG(_tokenId));
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setAllowlistMintEnabled(bool _state) public onlyOwner {
        allowlistMintEnabled = _state;
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function pause() external onlyOwner {
        _pause();
    }

    function setCost(uint256 _cost) public onlyOwner {
        cost = _cost;
    }

    function tokenURI(uint256 _tokenId) public view virtual override(ERC721) returns (string memory) {
        return reflectionMetadata.buildMetadata(_tokenId);
    }

    function mintForAddress(address _receiver) public onlyOwner {
        //Verify Contract Requirements
        if (totalSupply >= maxSupply) revert MaxSupplyReached();

        //Index totalSUpply
        uint256 tokenId = totalSupply;
        totalSupply++;

        //Set Token Hash
        tokenData[tokenId].seed = keccak256(
            abi.encodePacked(blockhash(block.number - 1), block.number, block.timestamp, _msgSender(), tokenId)
        );

        _safeMint(_receiver, tokenId);
    }

    function allowlistMint(bytes32[] calldata _merkleProof) public payable nonReentrant {
        //Verify Contract Requirements
        if (totalSupply >= maxSupply) revert MaxSupplyReached();
        if (msg.value < cost) revert InsufficientFunds();
        // Verify allowlist requirements
        require(allowlistMintEnabled, "The allowlist sale is not enabled!");
        require(!allowlistClaimed[_msgSender()], "Address already claimed!");
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Invalid proof!");

        //Index totalSUpply
        uint256 tokenId = totalSupply;
        totalSupply++;

        //Set Token Hash
        tokenData[tokenId].seed = keccak256(
            abi.encodePacked(blockhash(block.number - 1), block.number, block.timestamp, _msgSender(), tokenId)
        );

        allowlistClaimed[_msgSender()] = true;
        _safeMint(msg.sender, tokenId);
    }

    function mint() public payable whenNotPaused {
        if (totalSupply >= maxSupply) revert MaxSupplyReached();
        if (msg.value < cost) revert InsufficientFunds();

        uint256 tokenId = totalSupply;
        totalSupply++;

        tokenData[tokenId].seed = keccak256(
            abi.encodePacked(blockhash(block.number - 1), block.number, block.timestamp, _msgSender(), tokenId)
        );
        _safeMint(msg.sender, tokenId);
    }

    function withdraw() public onlyOwner nonReentrant {
        (bool os,) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    /*//////////////////////////////////////////////////////////////////////////
                        ERC2981 Functions START
    //////////////////////////////////////////////////////////////////////////*/

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        public
        view
        virtual
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = royaltyReceivers[_tokenId] != address(0) ? royaltyReceivers[_tokenId] : defaultRoyaltyReceiver;
        royaltyAmount = royaltyPercentages[_tokenId] != 0
            ? (_salePrice * royaltyPercentages[_tokenId]) / 10000
            : (_salePrice * defaultRoyaltyPercentage) / 10000;
    }

    function setDefaultRoyaltyReceiver(address _receiver) external onlyOwner {
        defaultRoyaltyReceiver = _receiver;
    }

    function setRoyaltyReceiver(uint256 _tokenId, address _newReceiver) external onlyOwner {
        royaltyReceivers[_tokenId] = _newReceiver;
    }

    function setRoyaltyPercentage(uint256 _tokenId, uint256 _percentage) external onlyOwner {
        royaltyPercentages[_tokenId] = _percentage;
    }

    /*//////////////////////////////////////////////////////////////////////////
                        ERC2981 Functions END
    //////////////////////////////////////////////////////////////////////////*/
}
