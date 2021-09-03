# PoliticsCollectible

ERC721 collectible based on the most famous real or fictitious politicians

## Base function
 - Buy
 - Sell
 - Play lottery
 - transfer

## TODO
 - Test
 - Front

## Dev Memo

```bash
truffle compile
truffle migrate
truffle console
const instance = await PoliticsCollectible.deployed()
const instance = await PoliticsCollectible.new()
await instance.createType('test', 1, 10, 10, 1, false)
await instance.buy(1, {from:'0x68f625FA9432E67FC73dDF82c1D94F62c63c8682', value: 1000000000000000000})
```
