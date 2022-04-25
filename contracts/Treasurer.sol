//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./GobeamToken.sol";

contract Treasurer {
    GobeamToken goToken;
    address public treasurer;
    address public newTreasurer;

    event TreasurerOwnershipTransferred(
        address indexed _from,
        address indexed _to
    );

    constructor() {
        treasurer = msg.sender;
    }

    modifier onlyTreasurer() {
        require(
            msg.sender == treasurer,
            "Access denied: You should be Treasurer!"
        );
        _;
    }

    function transferTreasurerOwnership(address _newTreasurer)
        public
        onlyTreasurer
    {
        newTreasurer = _newTreasurer;
    }

    function acceptTreasurerOwnership() public {
        require(msg.sender == newTreasurer);
        emit TreasurerOwnershipTransferred(treasurer, newTreasurer);
        treasurer = newTreasurer;
        newTreasurer = address(0);
    }
}
