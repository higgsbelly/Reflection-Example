// SPDX-License-Identifier: MIT

pragma solidity >=0.8.19 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {Reflection} from "../src/Reflection.sol";
import {ReflectionGenerator} from "../src/ReflectionGenerator.sol";
import {ReflectionSVG} from "../src/ReflectionMetadata.sol";
import {ReflectionMetadata} from "../src/ReflectionMetadata.sol";
import {LayerStore} from "../src/LayerStore.sol";

contract DeployNFTContract is Script {
    LayerStore layerStore = LayerStore(0x6B5014d71b90B494D63F3881Fa996b9393265D5D);

    function run(address _newOwner)
        external
        returns (Reflection, ReflectionGenerator, ReflectionSVG, ReflectionMetadata)
    {
        vm.startBroadcast();
        address newOwner = _newOwner;
        Reflection reflection = new Reflection();
        ReflectionGenerator reflectionGenerator = new ReflectionGenerator();
        ReflectionSVG reflectionSVG = new ReflectionSVG();
        ReflectionMetadata reflectionMetadata = new ReflectionMetadata();

        reflectionMetadata.setLayerStore(address(layerStore));
        reflectionMetadata.setReflectionGenerator(address(reflectionGenerator));
        reflectionMetadata.setReflectionSVG(address(reflectionSVG));

        reflectionSVG.setReflection(payable(address(reflection)));
        reflectionSVG.setReflectionGenerator(address(reflectionGenerator));
        reflectionSVG.setLayerStore(address(layerStore));

        reflectionGenerator.setReflection(payable(address(reflection)));

        reflection.setReflectionMetadata(address(reflectionMetadata));

        // Transfer ownership to the new owner
        reflection.transferOwnership(newOwner);

        vm.stopBroadcast();
        return (reflection, reflectionGenerator, reflectionSVG, reflectionMetadata);
    }
}
