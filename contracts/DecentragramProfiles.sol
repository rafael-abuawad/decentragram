// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {ERC721} from "@solmate/tokens/ERC721.sol";
import {Owned} from "@solmate/auth/Owned.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
/*                      STRUCTS                               */
/*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

struct Profile {
    string profileURI;
    string name;
    string handle;
    string bio;
}


contract DecentragramProfiles is ERC721, Owned {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      CUSTOM ERRORS                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    error InstagramPost__HasAlreadyLikedPost();
    error InstagramPost__HasNotLikedPost();
    error InstagramPost__CallerIsNotOwnerOrAdmin();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      STORAGE                               */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    mapping(uint256 id => Profile profile) private _profiles;
    uint256 private _ids = 1;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      CONSTRUCTOR                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    constructor() ERC721("Decentagram Posts", "DPOSTS") Owned(msg.sender) {}

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      EXTERNAL METHODS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function mint(Profile memory profile) external onlyOwner returns (uint256) {
        uint256 id = _ids;
        _mint(msg.sender, id);
        _profiles[id] = profile;
        _ids += 1;
        return id;
    }

    function burn(uint256 id) external returns (bool) {
        if (msg.sender != ownerOf(id) || msg.sender != owner) {
            revert InstagramPost__CallerIsNotOwnerOrAdmin();
        }
        _burn(id);
        return true;
    }
    
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      PUBLIC VIEW METHODS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function tokenURI(uint256 id) public view override returns (string memory) {
        return _tokenURI(id);
    }

    function totalSupply() public view returns (uint256) {
        return _ids;
    }
    
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      PUBLIC VIEW METHODS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function _tokenURI(uint256 id) internal view returns (string memory) {
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    abi.encodePacked(
                        "{",
                            '"image":"', _profiles[id].profileURI, '",',
                            '"description":"', _profiles[id].bio, '",',
                            '"attributes": ', _tokenAttributes(id),
                        "}"
                    )
                )
            )
        );
    }

    function _tokenAttributes(uint256 id) internal view returns (string memory) {
        return string(
            abi.encodePacked(
                "[",
                    '{"trait_type":"name","value":"', _profiles[id].name, '"},',
                    '{"trait_type":"handle","value":"@', _profiles[id].handle, '"},',
                    '{"trait_type":"profile_uri","value":"', _profiles[id].profileURI, '"},',
                    '{"trait_type":"bio","value":"', _profiles[id].bio, '"}',
                "]"
            )
        );
    }
}
