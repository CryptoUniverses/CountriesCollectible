# PoliticsCollectible

NFT based on ERC721

## Memo
truffle compile
truffle migrate
truffle console
const instance = await PoliticsCollectible.deployed()
const instance = await PoliticsCollectible.new()
await instance.createType('test', 1, 10, 10, 1)
await instance.buy(5, {from:'0x68f625FA9432E67FC73dDF82c1D94F62c63c8682', value: 1000000000000000000})
