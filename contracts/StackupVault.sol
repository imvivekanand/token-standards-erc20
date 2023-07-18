// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {sToken} from "./sToken.sol";

contract StackupVault {
    // mapping of token address to underlying tokens and claim tokens
    mapping(address => IERC20) public tokens;
    mapping(address => sToken) public claimTokens;

    constructor(address uniAddr, address linkAddr) {
        // initialize mapping of underlying token address => claim tokens
        // initialize mapping of underlying token address => underlying tokens
        claimTokens[uniAddr] = new sToken("Claim Uni", "sUNI");
        claimTokens[linkAddr] = new sToken("Claim Link", "sLINK");
        tokens[uniAddr] = IERC20(uniAddr);
        tokens[linkAddr] = IERC20(linkAddr);
    }

    function deposit(address tokenAddr, uint256 amount) external {
        // transfer underlying tokens from user to vault, assume that user has already approved vault to transfer underlying tokens
        // mint sTokens
        IERC20 token = tokens[tokenAddr];
        sToken claimToken = claimTokens[tokenAddr];

        require(
            token.transferFrom(msg.sender, address(this), amount),
            "transferFrom failed"
        );

        claimToken.mint(msg.sender, amount);
    }

    function withdraw(address tokenAddr, uint256 amount) external {
        // burn sTokens
        // transfer underlying tokens from vault to user

        IERC20 token = tokens[tokenAddr];
        sToken claimToken = claimTokens[tokenAddr];

        claimToken.burn(msg.sender, amount);

        require(
            token.transfer(msg.sender, amount),
            "transfer failed"
        );
    }
}
