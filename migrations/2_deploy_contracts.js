const CountriesCollectible = artifacts.require("./CountriesCollectible");

module.exports = function(deployer) {
    deployer.deploy(CountriesCollectible);
};
