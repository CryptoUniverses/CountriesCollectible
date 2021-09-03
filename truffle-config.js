const HDWalletProvider = require("@truffle/hdwallet-provider");
const NonceTrackerSubprovider = require("web3-provider-engine/subproviders/nonce-tracker")
const fs = require('fs');

const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {
    networks: {
        development: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "*",
        },
        rinkeby: {
            provider: () => new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/5f4e5b7535334db2a0436c4a3e65822b"),
            network_id: 4,
            gas: 5500000,
            confirmations: 2,
            timeoutBlocks: 200,
            skipDryRun: true
        },
        testnet: {
            provider: function () {
                var wallet = new HDWalletProvider(mnemonic, `https://data-seed-prebsc-1-s1.binance.org:8545`)
                    var nonceTracker = new NonceTrackerSubprovider()
                    wallet.engine._providers.unshift(nonceTracker)
                    nonceTracker.setEngine(wallet.engine)
                    return wallet
            },
            network_id: 97,
            confirmations: 10,
            timeoutBlocks: 200,
            skipDryRun: true
        },
    },

    mocha: {
        // timeout: 100000
    },

    compilers: {
        solc: {
            version: "0.8.7",    // Fetch exact version from solc-bin (default: truffle's version)
            // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
            settings: {          // See the solidity docs for advice about optimization and evmVersion
                optimizer: {
                    enabled: true,
                    runs: 200
                },
                evmVersion: "byzantium"
            }
        }
    },
};
