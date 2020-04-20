const Funding = artifacts.require("Funding");
const SECONDS_IN_1_HOUR = 3600;
const HOURS_IN_A_DAY = 24;

const DAY = SECONDS_IN_1_HOUR * HOURS_IN_A_DAY;

//const FINNEY = 10**15;
//const goal = (100*FINNEY).toString();
const GOAL = 10 ** 15;

module.exports = function(deployer) {
  deployer.deploy(Funding, DAY, GOAL);
  //deployer.deploy(Funding);
};
