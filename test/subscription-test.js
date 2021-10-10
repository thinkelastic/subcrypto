const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Subscription Lifecycle Test", function () {
  it("Should create a new subscription offer", async function () {
    const [producer, consumer] = await ethers.getSigners();
    const SubscriptionContract = await ethers.getContractFactory("SubscriptionContract");
    const subscription = await SubscriptionContract.deploy();
    await subscription.deployed();

    const subscriptionID = 1;
    const data = ethers.utils.hexlify([1, 2, 3, 4]);
    const createSubscription = await subscription.connect(producer).createSubscriptionContract(
        consumer.address,
        subscriptionID,
        "https://hello.world",
        1,
        1,
        1,
        data);

    await expect(createSubscription).to.emit(subscription,"ContractCreated");

    expect(await subscription.getSubscriptionStatus(subscriptionID)).to.equal(0);
    console.log("Subscription is OFFERED");
    
    await subscription.connect(consumer).signSubscriptionContract(subscriptionID);
     
    expect(await subscription.getSubscriptionStatus(subscriptionID)).to.equal(1);
    console.log("Subscription is SIGNED");
    
    await expect(subscription.connect(consumer).pauseSubscription(subscriptionID))
        .to.emit(subscription,"StatusChanged");
     
    expect(await subscription.getSubscriptionStatus(subscriptionID)).to.equal(2);
    console.log("Subscription is PAUSED");
  
    await subscription.connect(consumer).resumeSubscription(subscriptionID);
     
    expect(await subscription.getSubscriptionStatus(subscriptionID)).to.equal(1);
    console.log("Subscription is ACTIVE");
  });
});
