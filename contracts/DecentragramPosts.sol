// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {ERC721} from "@solmate/tokens/ERC721.sol";
import {Owned} from "@solmate/auth/Owned.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract InstagramPost is ERC721, Owned {
    error InstagramPost__HasAlreadyLikedPost();
    error InstagramPost__HasNotLikedPost();

    mapping(uint256 => mapping(address => bool)) _hasLikedPost;
    mapping(uint256 => uint256) private _likes;
    mapping(uint256 => string) private _descriptions;
    mapping(uint256 => string) private _images;
    uint256 private _ids;

    constructor() ERC721("Decentagram Posts", "DPOSTS") Owned(msg.sender) {}

    function post(string memory descr, string memory img) external onlyOwner returns (bool) {
        uint256 id = _ids;
        _mint(msg.sender, id);
        _images[id] = img;
        _descriptions[id] = descr;
        _ids += 1;
        return true;
    }

    function like(uint256 id) external {
        if (!_hasLikedPost[id][msg.sender]) {
            revert InstagramPost__HasAlreadyLikedPost();
        }

        _hasLikedPost[id][msg.sender] = true;
        _likes[id] += 1;
    }

    function removeLike(uint256 id) external {
        if (_hasLikedPost[id][msg.sender]) {
            revert InstagramPost__HasNotLikedPost();
        }

        _hasLikedPost[id][msg.sender] = false;
        _likes[id] -= 1;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return _tokenURI(id);
    }

    function likes(uint256 id) external view returns (uint256) {
        return _likes[id];
    }

    function description(uint256 id) external view returns (string memory) {
        return _descriptions[id];
    }

    function image(uint256 id) external view returns (string memory) {
        return _images[id];
    }

    function totalSupply() external view returns (uint256) {
        return _ids;
    }

    function _tokenURI(uint256 id) internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            '{',
                                '"image":"', _images[id], '",',
                                '"description":"', _descriptions[id], '",',
                                '"attributes": ', _tokenAttributes(id),
                            '}'
                        )
                    )
                )
            );
    }

    function _tokenAttributes(uint256 id) internal view returns (string memory) {
        return string(
            abi.encodePacked(
                '[',
                    '{"trait_type":"Likes","value":', Strings.toString(_likes[id]), '},',
                    '{"trait_type":"Description","value":"', _descriptions[id], '"}',
                ']'
            )
        );
    }

}