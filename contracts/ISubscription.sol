// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum SubscriptionStatus {
    OFFERED,
    ACTIVE,
    PAUSED,
    TERMINATED,
    RENEWED,
    EXPIRED
}
    
interface ISubscription {
    /// @dev This emits when the Subscription Contract is created
    event ContractCreated(
        address indexed from,
        address indexed to,
        uint256 indexed subscriptionId,
        string serviceURI,
        uint256 periodLength,
        uint256 periodCount,
        uint256 periodCost,
        bytes data
    );
    
     /// @dev This emits when the Subscription Contract is signed
    event ContractSigned(
        address indexed from,
        uint256 indexed subscriptionId);

    /// @dev This emits when an subscription is renewed
    event Renewed(
        address indexed from,
        uint256 subscriptionId,
        uint256 periodLength,
        uint256 periodCount,
        uint256 periodCost
    );

    /// @dev This emits when the state of a Subscription is changed.
    event StatusChanged(
        address indexed from,
        uint256 indexed subscriptionId,
        SubscriptionStatus status
    );

    /// @notice Creates a new subscription contract and waits for the
    ///  consumer to sign it
    /// @param _subscriptionId to be used as NFT tokenId
    /// @param _to Address of the consumer that is receiving the service
    /// @param _serviceURI The service unique resource identifier
    /// @param _periodLength The length of the subscription period in days
    /// @param _periodCount The period number. If `periodCount` == 0 the
    ///  subscription is open ended
    /// @param _periodCost The cost per period
    /// @param _data Additional data with no specified format, sent in 
    ///  call to `_to` see ERC721TokenReceiver for reference
    function createSubscriptionContract(
        address _to,
        uint256 _subscriptionId,
        string memory _serviceURI,
        uint256 _periodLength,
        uint256 _periodCount,
        uint256 _periodCost,
        bytes memory _data
    ) external;
    
    /// @notice The consumer signs the subscription and the NFT is
    ///  transferred to the `_to` address using SafeTransferFrom
    /// @param _subscriptionId Throws if `_subscriptionId` is not a valid
    ///  Subscription address or `msg.sender` does not match the `_to` 
    ///  address for this SubscriptionContract
    function signSubscriptionContract(uint256 _subscriptionId) external;
    
    /// @notice Returns the status of the subscription
    /// @param _subscriptionId Throws if `_subscriptionId` is not a valid
    ///  Subscription
    /// @return Status of the subscription unless throwing
    function getSubscriptionStatus(
        uint256 _subscriptionId
    ) external view returns (SubscriptionStatus);
    
    /// @notice Creates a new subscription contract using the terms of
    ///  of the original subscription. The periodCount will include any
    ///  number of periods left on the original subscription. The previous
    ///  subscription status will change to RENEWED.
    /// @param _subscriptionId Throws if `_subscriptionId` is not a valid
    ///  Subscription or is not in valid state
    /// @param _newSubscriptionId to be used as NFT tokenId for the new
    ///  Subscription
    function renewSubscription(
        uint256 _subscriptionId,
        uint256 _newSubscriptionId) external;
    
    /// @notice Set the status of a subscription to `PAUSED`. Throws if
    ///  subscription cannot be paused
    /// @param _subscriptionId Throws if `_subscriptionId` is not a valid
    ///  Subscription.
    function pauseSubscription(uint256 _subscriptionId) external;
    /// @notice Set the status of a subscription to `PAUSED`. Throws if
    ///  subscription cannot be resumed
    /// @param _subscriptionId Throws if `_subscriptionId` is not a valid
    ///  Subscription.
    function resumeSubscription(uint256 _subscriptionId) external;
    
    /// @notice Set the status of a subscription to `TERMINATED`. Throws
    ///  if subscription cannot be terminated
    /// @param _subscriptionId Throws if `_subscriptionId` is not a valid
    ///  Subscription
    function terminateSubscription(uint256 _subscriptionId) external;

    /// @notice Set the status of a subscription to `CANCELLED`. Throws
    ///  if subscription cannot be cancelled
    /// @param _subscriptionId Throws if `_subscriptionId` is not a valid
    ///  Subscription
    function cancelSubscription(uint256 _subscriptionId) external;
}