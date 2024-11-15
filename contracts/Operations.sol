// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract Admin is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable
{
    // Mappings for managing roles
    mapping(address => bool) public canForward;
    mapping(address => bool) public canMint;
    mapping(address => uint256) public mintAmount;
    mapping(address => bool) public trustedContract;
    mapping(address => bool) public isBlackListed;

    // Mappings for whitelisting external and internal users
    mapping(address => bool) public isExternalSenderWhitelisted;
    mapping(address => bool) public isInternalUserWhitelisted;

    // Events for tracking changes
    event AddedBlackList(address indexed _user);
    event RemovedBlackList(address indexed _user);
    event MintAmountAdded(address indexed _user);
    event MintAmountRemoved(address indexed _user);
    event WhitelistedForwarder(address indexed _user);
    event BlackListedForwarder(address indexed _user);
    event WhitelistedMinter(address indexed _user);
    event BlackListedMinter(address indexed _user);
    event WhitelistedContract(address indexed _user);
    event BlackListedContract(address indexed _user);
    event WhitelistedExternalSender(address indexed _user);
    event BlackListedExternalSender(address indexed _user);
    event WhitelistedInternalUser(address indexed _user);
    event BlackListedInternalUser(address indexed _user);

    // Initializer function for upgradeable contracts
    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        // Initialization logic
        canForward[_msgSender()] = true;
        canMint[_msgSender()] = true;
    }

    // Security Measures
    modifier onlyOwnerOrTrustedContract() {
        require(
            owner() == _msgSender() || trustedContract[_msgSender()],
            "Not authorized"
        );
        _;
    }

    modifier notBlacklisted(address _user) {
        require(!isBlackListed[_user], "User is blacklisted");
        _;
    }

    modifier onlyWhitelistedExternalSender(address _user) {
        require(
            isExternalSenderWhitelisted[_user],
            "Not a whitelisted external sender"
        );
        _;
    }

    modifier onlyWhitelistedInternalUser(address _user) {
        require(
            isInternalUserWhitelisted[_user],
            "Not a whitelisted internal user"
        );
        _;
    }

    // Functions for managing external user whitelist
    function whitelistExternalSender(
        address _User
    ) public onlyOwnerOrTrustedContract returns (bool) {
        require(
            !isExternalSenderWhitelisted[_User],
            "User already whitelisted"
        );
        isExternalSenderWhitelisted[_User] = true;
        emit WhitelistedExternalSender(_User);
        return true;
    }

    function blacklistExternalSender(
        address _User
    ) public onlyOwnerOrTrustedContract returns (bool) {
        require(isExternalSenderWhitelisted[_User], "User not whitelisted");
        isExternalSenderWhitelisted[_User] = false;
        emit BlackListedExternalSender(_User);
        return true;
    }

    // Functions for managing internal user whitelist
    function whitelistInternalUser(
        address _User
    ) public onlyOwnerOrTrustedContract returns (bool) {
        require(!isInternalUserWhitelisted[_User], "User already whitelisted");
        isInternalUserWhitelisted[_User] = true;
        emit WhitelistedInternalUser(_User);
        return true;
    }

    function blacklistInternalUser(
        address _User
    ) public onlyOwnerOrTrustedContract returns (bool) {
        require(isInternalUserWhitelisted[_User], "User not whitelisted");
        isInternalUserWhitelisted[_User] = false;
        emit BlackListedInternalUser(_User);
        return true;
    }

    // Functions for managing forwarders and minters
    function AddCanForward(
        address _User
    )
        public
        onlyOwnerOrTrustedContract
        notBlacklisted(_User)
        onlyWhitelistedExternalSender(_User)
        returns (bool)
    {
        require(!canForward[_User], "User already added as forwarder");
        canForward[_User] = true;
        emit WhitelistedForwarder(_User);
        return true;
    }

    function RemoveCanForward(
        address _User
    ) public onlyOwnerOrTrustedContract notBlacklisted(_User) returns (bool) {
        require(canForward[_User], "User is not a forwarder");
        canForward[_User] = false;
        emit BlackListedForwarder(_User);
        return true;
    }

    function AddCanMint(
        address _User
    )
        public
        onlyOwnerOrTrustedContract
        notBlacklisted(_User)
        onlyWhitelistedInternalUser(_User)
        returns (bool)
    {
        require(!canMint[_User], "User already added as minter");
        canMint[_User] = true;
        emit WhitelistedMinter(_User);
        return true;
    }

    function RemoveCanMint(
        address _User
    ) public onlyOwnerOrTrustedContract notBlacklisted(_User) returns (bool) {
        require(canMint[_User], "User is not a minter");
        canMint[_User] = false;
        emit BlackListedMinter(_User);
        return true;
    }

    // Adding trusted contracts
    function addTrustedContract(
        address _trustedContract
    ) public onlyOwner returns (bool) {
        trustedContract[_trustedContract] = true;
        return true;
    }

    function removeTrustedContract(
        address _trustedContract
    ) public onlyOwner returns (bool) {
        trustedContract[_trustedContract] = false;
        return true;
    }

    // Authorize upgrades for UUPS proxy pattern
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
