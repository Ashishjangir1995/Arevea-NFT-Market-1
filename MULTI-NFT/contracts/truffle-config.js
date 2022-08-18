const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
module.exports = {
  networks: {
    loc_developement_developement: {
      network_id: "*",
      port: 7545,
      host: "127.0.0.1"
    },
    inf_inf_rinkeby: {
      network_id: 4,
      gasPrice: 100000000000,
      provider: new HDWalletProvider(fs.readFileSync('c:\\Users\\Home\\Desktop\\New folder\\.sol', 'utf-8'), "https://rinkeby.infura.io/v3/2a536e0ce3834520a70677bd44045fa4")
    }
  },
  mocha: {},
  compilers: {
    solc: {
      version: "0.8.15"
    }
  }
};
