// SPDX-License-Identifier: MIT
//Contract to construct metadata for Reflection NFT contract.

pragma solidity >=0.8.19 <0.9.0;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReflectionSVG} from "./ReflectionSVG.sol";
import {ReflectionGenerator} from "./ReflectionGenerator.sol";
import {LayerStore} from "./LayerStore.sol";
import {Base64} from "./Base64.sol";

//@author @higgsbelly
contract ReflectionMetadata is Ownable {
    //Interfaces
    ReflectionSVG public reflectionSVG;
    ReflectionGenerator public reflectionGenerator;
    LayerStore public layerStore;

    constructor() Ownable(msg.sender) {}

    function setReflectionSVG(address _reflectionSVG) public onlyOwner {
        reflectionSVG = ReflectionSVG(_reflectionSVG);
    }

    function setReflectionGenerator(address _reflectionGenerator) public onlyOwner {
        reflectionGenerator = ReflectionGenerator(_reflectionGenerator);
    }

    function setLayerStore(address _layerStore) public onlyOwner {
        layerStore = LayerStore(_layerStore);
    }

    function getTokenSVG(uint256 _tokenId) public view returns (string memory) {
        return (
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,", Base64.encode(bytes(reflectionSVG.getSVGStatic(_tokenId)))
                )
            )
        );
    }

    function buildMetadata(uint256 _tokenId) public view returns (string memory) {
        string memory tokenName = getTitle(_tokenId);
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        tokenName,
                        '", "description":"',
                        layerStore.getSvgLayer(2),
                        '","attributes":[',
                        reflectionGenerator.getJSONAttributes(_tokenId),
                        '], "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(reflectionSVG.getSVGStatic(_tokenId))),
                        '"}'
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function getTitle(uint256 index) public view returns (string memory) {
        bytes memory data = bytes(layerStore.getSvgLayer(1));
        uint256 offset = 0;
        uint256 length;

        for (uint256 i = 0; i < index; ++i) {
            length = toUint(data, offset) * 2; // Length is in bytes, each byte represented by 2 hex characters
            offset += length + 4; // Skip the length (4 characters) and the title
        }

        length = toUint(data, offset) * 2; // Length is in bytes, each byte represented by 2 hex characters
        offset += 4; // Skip the length prefix

        bytes memory titleBytes = new bytes(length / 2);
        for (uint256 i = 0; i < length / 2; ++i) {
            titleBytes[i] =
                bytes1(fromHexChar(uint8(data[offset + 2 * i])) * 16 + fromHexChar(uint8(data[offset + 2 * i + 1])));
        }

        return string(titleBytes);
    }

    // Convert a hex string to a uint
    function toUint(bytes memory data, uint256 offset) internal pure returns (uint256 result) {
        for (uint256 i = 0; i < 4; i++) {
            uint8 c = uint8(data[offset + i]);
            if (c >= 48 && c <= 57) {
                // '0' - '9'
                result = result * 16 + (c - 48);
            } else if (c >= 97 && c <= 102) {
                // 'a' - 'f'
                result = result * 16 + (c - 87);
            } else if (c >= 65 && c <= 70) {
                // 'A' - 'F'
                result = result * 16 + (c - 55);
            }
        }
        return result;
    }

    // Convert a single hex character to a byte
    function fromHexChar(uint8 c) internal pure returns (uint8) {
        if (bytes1(c) >= bytes1("0") && bytes1(c) <= bytes1("9")) {
            return c - uint8(bytes1("0"));
        }
        if (bytes1(c) >= bytes1("a") && bytes1(c) <= bytes1("f")) {
            return 10 + c - uint8(bytes1("a"));
        }
        if (bytes1(c) >= bytes1("A") && bytes1(c) <= bytes1("F")) {
            return 10 + c - uint8(bytes1("A"));
        }
        revert("Invalid hex character");
    }
}
