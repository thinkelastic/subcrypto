// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISubscription.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract SubscriptionContract is ISubscription, ERC721URIStorage { 
    // Mapping from subscription ID to block number at the time the contract
    // was created
    mapping(uint256 => SubscriptionStatus) private _subscriptionStatus;
    
    // Mapping from subscription ID to block number at the time the contract
    // was created
    mapping(uint256 => uint256) private _subscriptionCreatedBlock;

    // Mapping from subscription ID to block number at the time the contract
    // was signed
    mapping(uint256 => uint256) private _subscriptionSignedBlock;
    
    // Mapping from subscription ID to block number at the time the contract
    // was modified
    mapping(uint256 => uint256) private _subscriptionModifiedBlock;
    
    // Mapping from subscription ID to lenght of the subscription period in days
    mapping(uint256 => uint256) private _subscriptionPeriodLength;
    
    // Mapping from subscription ID to number of periods the subscription is
    // valid. If the subscription is open ended the value MUST be 0
    mapping(uint256 => uint256) private _subscriptionPeriodCount;
    
    // Mapping from subscription ID to the cost of the subscription per period
    mapping(uint256 => uint256) private _subscriptionPeriodCost;
    
    // Mapping from subscription ID to data associated with the subscription
    mapping(uint256 => bytes) private _subscriptionData;
    
    
    constructor() ERC721("Subscription Contract", "SCT")
    {
    }

    function createSubscriptionContract(
        address _to,
        uint256 _subscriptionId,
        string memory _serviceURI,
        uint256 _periodLength,
        uint256 _periodCount,
        uint256 _periodCost,
        bytes memory _data
    ) external override
    {
        _safeMint(msg.sender, _subscriptionId);
        _setTokenURI(_subscriptionId, _serviceURI);
        
        _subscriptionPeriodLength[_subscriptionId] = _periodLength;
        _subscriptionPeriodCount[_subscriptionId] = _periodCount;
        _subscriptionPeriodCost[_subscriptionId] = _periodCost;
        _subscriptionData[_subscriptionId] = _data;
        
        _subscriptionCreatedBlock[_subscriptionId] = block.timestamp;
        _subscriptionModifiedBlock[_subscriptionId] = block.timestamp;

        _subscriptionStatus[_subscriptionId] = SubscriptionStatus.OFFERED;
        approve(_to, _subscriptionId);
        
        emit ContractCreated(
            msg.sender,
            _to,
            _subscriptionId,
            _serviceURI,
            _periodLength,
            _periodCount,
            _periodCost,
            _data);

        emit StatusChanged(msg.sender, _subscriptionId, SubscriptionStatus.OFFERED);
    }
    
    function signSubscriptionContract(uint256 _subscriptionId) external override
    {
        address owner = ownerOf(_subscriptionId);
        safeTransferFrom(owner, msg.sender, _subscriptionId);
        
        _subscriptionSignedBlock[_subscriptionId] = block.timestamp;
        _subscriptionModifiedBlock[_subscriptionId] = block.timestamp;
        
        _subscriptionStatus[_subscriptionId] = SubscriptionStatus.ACTIVE;
        
        emit ContractSigned(msg.sender, _subscriptionId);
        emit StatusChanged(msg.sender, _subscriptionId, SubscriptionStatus.ACTIVE);
    }
    
    function getSubscriptionStatus(
        uint256 _subscriptionId
    ) external override view returns (SubscriptionStatus)
    {
        return _subscriptionStatus[_subscriptionId];
    }
    
    function renewSubscription(
        uint256 _subscriptionId,
        uint256 _newSubscriptionId
    ) external override
    {
        address owner = ownerOf(_subscriptionId);
        string memory serviceURI = this.tokenURI(_subscriptionId);
        
        uint256 periodLength  = _subscriptionPeriodLength[_subscriptionId];
        uint256 periodCount  = _subscriptionPeriodCount[_subscriptionId];
        uint256 periodCost  = _subscriptionPeriodCost[_subscriptionId];

        bytes memory data  = _subscriptionData[_subscriptionId];
        
        this.createSubscriptionContract(owner, _newSubscriptionId, serviceURI, periodLength, periodCount, periodCost, data);
        this.signSubscriptionContract(_newSubscriptionId);
        
        _subscriptionStatus[_subscriptionId] = SubscriptionStatus.RENEWED;
        
        emit StatusChanged(msg.sender, _subscriptionId, SubscriptionStatus.RENEWED);
    }
    
    function pauseSubscription(uint256 _subscriptionId) external override
    {
        _subscriptionModifiedBlock[_subscriptionId] = block.timestamp;
        _subscriptionStatus[_subscriptionId] = SubscriptionStatus.PAUSED;
        
        emit StatusChanged(msg.sender,_subscriptionId, SubscriptionStatus.PAUSED);
    }

    function resumeSubscription(uint256 _subscriptionId) external override
    {
        _subscriptionModifiedBlock[_subscriptionId] = block.timestamp;
        
        // Need to adjust period Count/Lenght
        
        _subscriptionStatus[_subscriptionId] = SubscriptionStatus.ACTIVE;
    }
    
    function terminateSubscription(uint256 _subscriptionId) external override
    {
        _subscriptionModifiedBlock[_subscriptionId] = block.timestamp;
        _subscriptionStatus[_subscriptionId] = SubscriptionStatus.TERMINATED;
    }

    function cancelSubscription(uint256 _subscriptionId) external override
    {
        _subscriptionModifiedBlock[_subscriptionId] = block.timestamp;
        _subscriptionStatus[_subscriptionId] = SubscriptionStatus.TERMINATED;
    }
}