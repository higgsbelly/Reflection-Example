// SPDX-License-Identifier: MIT

pragma solidity >=0.8.19 <0.9.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Vm} from "forge-std/Vm.sol";

import {DeployNFTContract} from "../script/DeployNFTContract.s.sol";
import {Reflection} from "../src/Reflection.sol";
import {ReflectionGenerator} from "../src/ReflectionGenerator.sol";
import {ReflectionSVG} from "../src/ReflectionMetadata.sol";
import {ReflectionMetadata} from "../src/ReflectionMetadata.sol";
import {LayerStore} from "../src/LayerStore.sol";

contract ContractTest is Test {
    DeployNFTContract deployer;
    Reflection ref;
    ReflectionGenerator refGen;
    ReflectionSVG refSVG;
    ReflectionMetadata refMeta;
    LayerStore lay = LayerStore(0x6B5014d71b90B494D63F3881Fa996b9393265D5D);
    address public USER = makeAddr("user");

    function setUp() public {
        deployer = new DeployNFTContract();
        (ref, refGen, refSVG, refMeta) = deployer.run(address(this));
    }

    function testMint() public {
        // Impersonate the owner account
        vm.startPrank(address(this)); // Assuming the contract itself deployed the Reflection contract

        // Unpause the contract
        ref.unpause();

        // Stop impersonating the owner
        vm.stopPrank();

        vm.startPrank(USER);

        //will through EVM memory error if any URI requests are made for 999. Too much for the local env
        for (uint256 i = 0; i < 999; i++) {
            ref.mint{value: 0}();

            uint256 supply = ref.totalSupply();
            bytes32 seed = ref.tokenData(supply - 1);

            //string memory _uri = ref.tokenURI(supply - 1);
            string memory _svg = ref.tokenSVG(supply - 1);
            //string memory _title = refMeta.getTitle(i);
            //console.log("tokenId:", i, "Title:", _title);

            console.logBytes32(seed);
            /*console.log("tokenId:", supply - 1);
            console.log(refSVG.layerReq(supply - 1).layer1);
            console.log(refSVG.layerReq(supply - 1).layer4);
            console.log(refSVG.layerReq(supply - 1).layer5);
            console.log(refSVG.layerReq(supply - 1).layer6);
            console.log(refSVG.layerReq(supply - 1).layer7);
            console.log(refSVG.layerReq(supply - 1).layer8);
            console.log(refSVG.layerReq(supply - 1).layer10);
            console.log(refSVG.layerReq(supply - 1).layer11);
            console.log(refSVG.layerReq(supply - 1).layer12);
            console.log(refSVG.layerReq(supply - 1).layer13);
            console.log(refSVG.layerReq(supply - 1).layer14);
            console.log(refSVG.layerReq(supply - 1).layer15);
            console.log(refSVG.layerReq(supply - 1).layer16);
            console.log(refSVG.layerReq(supply - 1).layer17);
            console.log(refSVG.layerReq(supply - 1).layer18);
            console.log(refSVG.layerReq(supply - 1).layer19);
            console.log(refSVG.layerReq(supply - 1).layer20);
            console.log(refSVG.layerReq(supply - 1).layer21);*/
        }

        vm.stopPrank();
    }
}
