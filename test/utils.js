const timeTravel = (web3, seconds) => {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [seconds],
            id: new Date().getTime()
        }, (err, res) => {
            if (err) {
                return reject(err);
            }

            web3.currentProvider.send({
                jsonrpc: "2.0",
                method: "evm_mine",
                id: new Date().getTime()
            }, (err, res) => {
                return err ? reject(err) : resolve(res);
            });
        });
    });
};
module.exports = {
    timeTravel
};
