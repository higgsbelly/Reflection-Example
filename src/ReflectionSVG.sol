//SPDX-License-Identifier: MIT

pragma solidity >=0.8.19 <0.9.0;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {LayerStore} from "./LayerStore.sol";
import {ReflectionGenerator} from "./ReflectionGenerator.sol";
import {Reflection} from "./Reflection.sol";

//@author @higgsbelly
contract ReflectionSVG is Ownable {
    //Interface
    LayerStore public layerStore;
    ReflectionGenerator public reflectionGenerator;
    Reflection public reflection;

    struct LayerIndex {
        uint256 layer0;
        uint256 layer1;
        uint256 layer2;
        uint256 layer3;
        uint256 layer4;
        uint256 layer5;
        uint256 layer6;
        uint256 layer7;
        uint256 layer8;
        uint256 layer9;
        uint256 layer10;
        uint256 layer11;
        uint256 layer12;
        uint256 layer13;
        uint256 layer14;
        uint256 layer15;
        uint256 layer16;
        uint256 layer17;
        uint256 layer18;
        uint256 layer19;
        uint256 layer20;
        uint256 layer21;
    }

    constructor() Ownable(msg.sender) {}

    function setLayerStore(address _layerStore) public onlyOwner {
        layerStore = LayerStore(_layerStore);
    }

    function setReflectionGenerator(address _reflectionGenerator) public onlyOwner {
        reflectionGenerator = ReflectionGenerator(_reflectionGenerator);
    }

    function setReflection(address payable _reflection) public onlyOwner {
        reflection = Reflection(_reflection);
    }

    function addressToString(uint256 _tokenId) public view returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(reflection.ownerOf(_tokenId)))); // Convert address to bytes32
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42); // Length of 0x + 40 characters
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(abi.encodePacked(str, str, str, str));
    }

    function layerReq(uint256 _tokenId) public view returns (LayerIndex memory data) {
        uint256 final_text_index = reflectionGenerator.getTraitColumn(_tokenId, 17);
        return (
            LayerIndex({
                layer0: 0,
                layer1: 100 + reflectionGenerator.getTraitColumn(_tokenId, 0),
                layer2: 200,
                layer3: 300,
                layer4: 400 + reflectionGenerator.getTraitColumn(_tokenId, 1),
                layer5: 500 + reflectionGenerator.getTraitColumn(_tokenId, 2),
                layer6: 600 + reflectionGenerator.getTraitColumn(_tokenId, 3),
                layer7: 700 + reflectionGenerator.getTraitColumn(_tokenId, 4),
                layer8: 800 + reflectionGenerator.getTraitColumn(_tokenId, 5),
                layer9: 900,
                layer10: 1000 + reflectionGenerator.getTraitColumn(_tokenId, 6),
                layer11: 1100 + reflectionGenerator.getTraitColumn(_tokenId, 7),
                layer12: 1200 + reflectionGenerator.getTraitColumn(_tokenId, 8),
                layer13: 1300 + reflectionGenerator.getTraitColumn(_tokenId, 9),
                layer14: 1400 + reflectionGenerator.getTraitColumn(_tokenId, 10),
                layer15: 1500 + reflectionGenerator.getTraitColumn(_tokenId, 11),
                layer16: 1600 + reflectionGenerator.getTraitColumn(_tokenId, 12),
                layer17: 1700 + reflectionGenerator.getTraitColumn(_tokenId, 13),
                layer18: 1800 + reflectionGenerator.getTraitColumn(_tokenId, 14),
                layer19: 1900 + reflectionGenerator.getTraitColumn(_tokenId, 15),
                layer20: 2000 + reflectionGenerator.getTraitColumn(_tokenId, 16),
                layer21: 2200 + (final_text_index) * 100
                    + reflectionGenerator.getTraitColumn(_tokenId, 18 + uint8(final_text_index))
            })
        );
    }

    function getSVGStatic(uint256 _tokenId) public view returns (string memory) {
        string memory packedData;
        uint256 final_text_index = reflectionGenerator.getTraitColumn(_tokenId, 17);
        packedData = string(
            abi.encodePacked(
                layerStore.getSvgLayer(0),
                layerStore.getSvgLayer(100 + (reflectionGenerator.getTraitColumn(_tokenId, 0))), //colors layer100, rarity_row 0
                layerStore.getSvgLayer(200),
                '<g id="owner"><text class="fortyeightrows">',
                addressToString(_tokenId),
                "</text></g>",
                layerStore.getSvgLayer(300)
            )
        );

        for (uint256 i = 4; i < 9; i++) {
            packedData = string(
                abi.encodePacked(
                    packedData,
                    layerStore.getSvgLayer((i * 100 + (reflectionGenerator.getTraitColumn(_tokenId, uint8(i - 3)))))
                ) // byteGAN_clip (1) thru invasion_clip (5)
            );
        }

        packedData = string(
            abi.encodePacked(packedData, layerStore.getSvgLayer(900)) //canvas
        );

        for (uint256 i = 10; i < 21; i++) {
            packedData = string(
                abi.encodePacked(
                    packedData,
                    layerStore.getSvgLayer((i * 100 + (reflectionGenerator.getTraitColumn(_tokenId, uint8(i - 4)))))
                ) //byteGAN (6) thru skull_overlay(16)
            );
        }

        packedData = string(
            abi.encodePacked(
                packedData,
                layerStore.getSvgLayer(
                    //final_text type                                       //picks column for hex, binary, or byteGAN
                    (
                        2200 + uint256(final_text_index) * 100
                            + reflectionGenerator.getTraitColumn(_tokenId, 18 + uint8(final_text_index))
                    )
                )
            ) //final_text
        );

        return (string(abi.encodePacked(packedData, layerStore.getSvgLayer(2500))));
    }
}
