const PoliticsCollectible = artifacts.require("./PoliticsCollectible");

module.exports = function(deployer) {
    deployer.deploy(PoliticsCollectible);
};
