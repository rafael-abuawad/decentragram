// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {ERC721} from "@solmate/tokens/ERC721.sol";
import {Owned} from "@solmate/auth/Owned.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
/*                      STRUCTS                               */
/*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/
struct Post {
    string description;
    string imageURI;
}

contract DecentragramPosts is ERC721, Owned {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      CUSTOM ERRORS                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    error InstagramPost__HasAlreadyLikedPost();
    error InstagramPost__HasNotLikedPost();
    error InstagramPost__CallerIsNotOwnerOrAdmin();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      STORAGE                               */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    mapping(uint256 id => mapping(address caller => bool hasLikedPost)) _hasLikedPost;
    mapping(uint256 id => uint256 likes) private _likes;
    mapping(uint256 id => Post post) private _posts;
    uint256 private _ids = 1;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      CONSTRUCTOR                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    constructor() ERC721("Decentagram Posts", "DPOSTS") Owned(msg.sender) {}

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      EXTERNAL METHODS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function mint(Post memory post) external returns (uint256) {
        uint256 id = _ids;
        _mint(msg.sender, id);
        _posts[id] = post;
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

    function like(uint256 id) external {
        if (!_hasLikedPost[id][msg.sender]) {
            revert InstagramPost__HasAlreadyLikedPost();
        }

        _hasLikedPost[id][msg.sender] = true;
        _likes[id] += 1;
    }

    function dislike(uint256 id) external {
        if (_hasLikedPost[id][msg.sender]) {
            revert InstagramPost__HasNotLikedPost();
        }

        _hasLikedPost[id][msg.sender] = false;
        _likes[id] -= 1;
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
    /*                      INTERNAL VIEW METHODS                 */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function _tokenURI(uint256 id) internal view returns (string memory) {
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    abi.encodePacked(
                        "{",
                            '"image":"', _posts[id].imageURI, '",',
                            '"description":"', _posts[id].description, '",',
                            '"attributes": ', _tokenAttributes(id),
                        "}"
                    )
                )
            )
        );
    }

    function _tokenAttributes(uint256 id) internal view returns (string memory) {
        string memory likes = Strings.toString(_likes[id]);
        return string(
            abi.encodePacked(
                "[",
                    '{"trait_type":"likes","value":', likes, "},",
                    '{"trait_type":"description","value":"', _posts[id].description, '"}',
                "]"
            )
        );
    }
}
