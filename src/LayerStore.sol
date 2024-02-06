// SPDX-License-Identifier: MIT
// Simple contract to store large strings of text for use in other contracts.
//   1. Owner has the ability to store text strings of any size by writing to the same layer multiple times.
//   2. Max write size per write is 24kb.
//   3. Layers can be deleted and re-written if necessary.
// Credit to 0xsequence for SSTORE2 utilized in this contract.

pragma solidity >=0.8.19 <0.9.0;

import {Base64} from "./Base64.sol";
import {SSTORE2} from "./SSTORE2.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract LayerStore is Ownable {
    mapping(uint256 => address[]) public svgLayers;

    constructor() Ownable(msg.sender) {}

    function storeSvgLayer(uint256 _layerId, string calldata _svgLayer) external onlyOwner {
        address layerPointer = SSTORE2.write(bytes(_svgLayer));
        svgLayers[_layerId].push(layerPointer);
    }

    function getSvgLayer(uint256 _layerId) public view returns (string memory) {
        require(svgLayers[_layerId].length > 0, "LayerStore: Nonexistent layer");

        bytes memory svgLayer;
        for (uint256 i = 0; i < svgLayers[_layerId].length; i++) {
            svgLayer = abi.encodePacked(svgLayer, SSTORE2.read(svgLayers[_layerId][i]));
        }
        return string(svgLayer);
    }

    function deleteSvgLayer(uint256 _layerId) external onlyOwner {
        // Clear the existing array of addresses for this layerId
        require(svgLayers[_layerId].length > 0, "LayerStore: Nonexistent layer");
        delete svgLayers[_layerId];
    }
}
