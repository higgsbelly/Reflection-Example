// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Reflection} from "./Reflection.sol";

//@author @higgsbelly
contract ReflectionGenerator is Ownable {
    bytes public heloise = "\x48\xC3\xA9\x6C\x6F\xC3\xAF\x73\x65";
    bytes public lemartre = "\x4C\x65\x6D\x61\xC3\xAE\x74\x72\x65";
    uint256[168] internal rarity = [
        26,
        52,
        84,
        118,
        134,
        142,
        180,
        218, // color: 0
        40,
        80,
        110,
        125,
        140,
        170,
        210,
        225, // byteGAN_clip: 1
        31,
        62,
        93,
        124,
        132,
        163,
        194,
        225, //skull_clip: 2
        16,
        48,
        80,
        112,
        144,
        176,
        192,
        224, //highlight_clip: 3
        32,
        64,
        85,
        117,
        149,
        170,
        202,
        234, //shadow_clip: 4
        16,
        48,
        80,
        112,
        144,
        176,
        208,
        240, //invasion_clip: 5
        128,
        256,
        0,
        0,
        0,
        0,
        0,
        0, //byteGAN: 6
        20,
        55,
        70,
        105,
        155,
        180,
        185,
        205, //gan_strokes: 7
        112,
        176,
        192,
        256,
        0,
        0,
        0,
        0, //skull: 8
        64,
        80,
        128,
        192,
        256,
        0,
        0,
        0, //background: 9
        28,
        57,
        85,
        114,
        142,
        171,
        199,
        228, // diff_strokes: 10
        30,
        60,
        90,
        120,
        150,
        180,
        210,
        240, // circles: 11
        32,
        62,
        90,
        116,
        140,
        166,
        194,
        224, //touchup_strokes: 12
        8,
        24,
        48,
        96,
        160,
        208,
        232,
        248, //lighten_strokes: 13
        54,
        128,
        192,
        256,
        0,
        0,
        0,
        0, //darken_strokes: 14
        112,
        144,
        256,
        0,
        0,
        0,
        0,
        0, //highlight: 15
        64,
        72,
        104,
        136,
        256,
        0,
        0,
        0, // skull_overlay: 16
        85,
        170,
        256,
        0,
        0,
        0,
        0,
        0, // final_text: 17
        30,
        60,
        90,
        120,
        150,
        180,
        210,
        240, //ft_binary: 18
        256,
        0,
        0,
        0,
        0,
        0,
        0,
        0, // ft_byteGAN: 19
        30,
        60,
        90,
        120,
        150,
        180,
        210,
        240 // ft_hex: 20
    ];

    string[90] internal traitValue = [
        "saturated",
        "muted",
        "bled",
        "illuminated",
        "diffused",
        "burned",
        "erased",
        "aged",
        "painted",
        "meme",
        "sememe",
        "satoshi",
        "neuron",
        "bit",
        "wei",
        "quanta",
        "node",
        "cent",
        "Delhi",
        "Berlin",
        "Fort Worth",
        "Washington DC",
        "Ethereum",
        "New York",
        "Tokyo",
        "Los Angeles",
        "Paris",
        "faith",
        "growth",
        "knowledge",
        "stability",
        "purpose",
        "revenge",
        "utility",
        "order",
        "logic",
        "horror vacui",
        "k-means clustering",
        "style transfer",
        "symmetry",
        "hough lines",
        "gan",
        "error reduction",
        "feedback loops",
        "diffusion",
        "spiritual",
        "social",
        "cosmological",
        "rational",
        "emotional",
        "existential",
        "creative",
        "mechanical",
        "unconditional",
        "Joan of Arc",
        string(heloise),
        string(lemartre),
        "Descartes",
        "Pandora",
        "de Beauvoir",
        "Daft Punk",
        "Le dessinateur",
        "La Mettrie",
        "technical",
        "chaotic",
        "balanced",
        "melodic",
        "reflective",
        "precise",
        "expressive",
        "logical",
        "irrational",
        "free",
        "flexible",
        "principled",
        "structured",
        "limited",
        "balanced",
        "guided",
        "predetermined",
        "deterministic",
        "genesis",
        "primordial",
        "monocameral",
        "bicameral",
        "reflective",
        "augmented",
        "superintelligence",
        "singularity",
        "eschaton"
    ];

    string[10] internal traitName =
        ["Affection", "Quantity", "Place", "State", "Position", "Relation", "Substance", "Quality", "Action", "Time"];

    Reflection public reflection;

    constructor() Ownable(msg.sender) {}

    function setReflection(address payable _reflection) public onlyOwner {
        reflection = Reflection(_reflection);
    }

    function updateRarity(uint256 index, uint256 newValue) public onlyOwner {
        // Check that the index is within the bounds of the array
        require(index < rarity.length, "Index out of bounds");

        // Update the value at the specified index
        rarity[index] = newValue;
    }

    function readRarity(uint256 index) public view returns (uint256 _rarityElement) {
        // Check that the index is within the bounds of the array
        require(index < rarity.length, "Index out of bounds");
        return (rarity[index]);
    }

    function updateTraitValue(uint256 index, string memory newValue) public onlyOwner {
        // Check that the index is within the bounds of the array
        require(index < rarity.length, "Index out of bounds");

        // Update the value at the specified index
        traitValue[index] = newValue;
    }

    function readTraitValue(uint256 index) public view returns (string memory) {
        // Check that the index is within the bounds of the array
        require(index < rarity.length, "Index out of bounds");
        return (traitValue[index]);
    }

    function getSeedInt(uint256 _tokenId, uint8 _traitRow) public view returns (uint8 _index) {
        bytes32 seed = reflection.tokenData(_tokenId);
        return (uint8(bytes1(seed << _traitRow * 8)));
    }

    // Each set of rarities will need to be padded for the layer with the most options. Currently set for 9 options
    function getTraitColumn(uint256 _tokenId, uint8 _traitRow) public view returns (uint256 traitColumn) {
        uint256 _seedInt = getSeedInt(_tokenId, _traitRow);
        uint256 _traitColumn = (
            (_seedInt < rarity[_traitRow * 8])
                ? 0
                : (_seedInt < rarity[_traitRow * 8 + 1])
                    ? 1
                    : (_seedInt < rarity[_traitRow * 8 + 2])
                        ? 2
                        : (_seedInt < rarity[_traitRow * 8 + 3])
                            ? 3
                            : (_seedInt < rarity[_traitRow * 8 + 4])
                                ? 4
                                : (_seedInt < rarity[_traitRow * 8 + 5])
                                    ? 5
                                    : (_seedInt < rarity[_traitRow * 8 + 6]) ? 6 : (_seedInt < rarity[_traitRow * 8 + 7]) ? 7 : 8
        );

        return (_traitColumn);
    }

    function getJSONAttributes(uint256 _tokenId) public view returns (string memory) {
        string memory attributes;
        uint8[10] memory _traitRow = [0, 1, 2, 3, 4, 7, 10, 11, 12, 13]; //rows of layers that correspond to traits
        uint256 i;
        uint256 length = 10;
        unchecked {
            do {
                attributes = string(
                    abi.encodePacked(
                        attributes,
                        getJSONTraitItem(
                            traitName[i], traitValue[i * 9 + getTraitColumn(_tokenId, _traitRow[i])], i == length - 1
                        )
                    )
                );
            } while (++i < length);
        }
        return attributes;
    }

    function getJSONTraitItem(string memory _typeName, string memory _typeValue, bool lastItem)
        internal
        pure
        returns (string memory)
    {
        return string(
            abi.encodePacked('{"trait_type": "', _typeName, '", "value": "', _typeValue, '"}', lastItem ? "" : ",")
        );
    }
}
