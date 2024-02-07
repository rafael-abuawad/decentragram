// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Owned} from "@solmate/auth/Owned.sol";
import {DecentragramPosts, Post} from "./DecentragramPosts.sol";
import {DecentragramProfiles, Profile} from "./DecentragramProfiles.sol";

contract Decentragram is Owned {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      CONSTANTS                             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    uint256 private constant ENTRANCE_FEE = 0.01 ether;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      CUSTOM ERRORS                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    error Decentragram__InvalidRegistrationFee();
    error Decentragram__UserAlreadyHasAProfile();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      STORAGE                               */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    DecentragramPosts private immutable _decentragramPosts;
    DecentragramProfiles private immutable _decentragramProfiles;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      CONSTRUCTOR                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    constructor(address postsAddress, address profilesAddress) Owned(msg.sender) {
        _decentragramPosts = DecentragramPosts(postsAddress);
        _decentragramProfiles = DecentragramProfiles(profilesAddress);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      PUBLIC METHODS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function register(Profile memory profile) public payable {
        if (msg.value != ENTRANCE_FEE) {
            revert Decentragram__UserAlreadyHasAProfile();
        }
        if (_decentragramProfiles.balanceOf(msg.sender) != 0) {
            revert Decentragram__InvalidRegistrationFee();
        }
        _decentragramProfiles.mint(profile); 
    }

    function collectFees() public payable {
        (bool sent, ) = payable(owner).call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}
