# More Solidity-specific Unit Tests with Truffle
Extend the Funding contract and start using some more Solidity-specific unit testing technique. In this exercise, you’ll learn how to:
*	Time travel: Manipulating `block.timestamp`.
*	Understand and use more unit-testing techniques.
*	Learn the difference between Solidity Testing and JavaScript Testing.

## Original Source
"Ethereum: Test-driven development with Solidity (part 2)" by [Michal Zalecki](https://michalzalecki.com/ethereum-test-driven-introduction-to-solidity-part-2/)

## Prerequisites
You should have finished the implementation outlined in this exercise:
*	Develop and Unit Test Smart Contracts with Truffle

## Requirements
*	Ganache CLI 	v6.9.1 (older versions are not compatible with this exercise)
*	Truffle 		v5.1.10 (core: 5.1.10)
*	Solidity 	v0.6.6 (solc)
*	Web3.js 	v1.2.6
*	NodeJS 	v13.5.0

NOTE: If you want to run on newer versions, you may or you may not encounter an error specific to this exercise. If you do, please downgrade to this version of truffle. Remember to run the command as an administrator
```bash
$ npm uninstall –g truffle ganache-cli
$ npm install -g truffle@5.1.10 ganache-cli@6.9.1
$ npm install -g solc@0.6.6
$ npm install -g web3@1.2.6
```
## Manipulating Time
Our donators can now donate, but there is no time constraint. We would like users to send us some Ether but only until fundraising is finished. We can get a current block timestamp by reading now property. If you start writing tests in Solidity, you will quickly realize that there is no easy way to manipulate block time from the testing smart contract. There is also no sleep method which would allow us to set a tiny duration, wait for a second or two and try again simulating that time for donating is up.
I have already mentioned that there is no easy way to manipulate block time from Solidity (at least at the time of writing). JSON-RPC is a stateless, remote procedure call protocol. Ethereum provides multiple methods which we can remotely execute. One of the use cases for it is creating Oracles. We are not going to use JSON-RPC directly but through Web3.js which provides a convenient abstraction for RPC calls.
 
 
Calling increaseTime results in two RPC calls. You will not find them on Ethereum wiki page. Both `evm_increaseTime` and `evm_mine` are non-standard methods provided by Ganache - blockchain for Ethereum development we use when running tests.
We need to modify a lot of files to include the time in our contract and tests. So let’s start with our migration file.
 
Now let’s change our Funding contract.

Because we changed our constructor in the Funding contract to accept duration we need to now to pass that information every time we create an instance. To make this easier we will use the `beforeEach` function that creates an instance before each test for us and we need to remove everywhere that we created instance our self.
 
Then add the `beforeEach()` setup function and write a new test utilizing the timeTravel we wrote.
* Finishes fundraising when time is up time-travel test.

Now we are ready with our JavaScript testing and we need to fix the Solidity testing contract to work with our changes to the Funding contract.
Again we need to remove everywhere where we made an instance of Funding as we are going to use `beforeEach`.
 
We need to also update the last test and rename the funding variable.
 
Tests should now be passing.

## Modifiers and testing throws
We can now tell whether fundraising finished, but we are not doing anything with this information. Let’s put a limitation on how long people can donate.

Since Solidity 0.4.13, a throw is deprecated. New function for handling state-reverting exceptions are `require()`, `assert()` and `revert()`.
All exceptions bubble up, and there is no `try...catch` in Solidity. So how to test for throws using just Solidity? Low-level call function returns false if an error occurred and true otherwise. You can also use a proxy contract to achieve the same in what you may consider as more elegant way.
Let’s add a new test to our testing contract.
 
In JavaScript we can just use `try...catch` to handle an error.
 
We can now restrict time for calling donate in Funding contract with `onlyNotFinished` modifier.

Both new tests should now pass.

## Withdrawal
We accept donations, but it is not yet possible to withdraw any funds. An owner should be able to do it only when the goal has been reached. We also cannot set a goal. We would like to do it when deploying a contract — as we did when we were setting contract duration.
 
Next up, let’s test withdrawing from the contract by the owner.
 
Now, let’s try withdrawing by someone else and making sure the contract throws.
 
From Solidity, we are not able to select an address from which we want to make a transaction. By design, address of the smart contract is going to be used. What we can do to test withdrawal from an account which is not an owner is to use deployed contract instead of using created by a testing contract. Trying to withdraw in such case should always fail. One restriction is that you cannot specify a constructor params — the migration script has already deployed this contract.

Don’t forget to update the old tests to reflect the new constructor we are about to write. It will accept an additional argument for the fundraising goal:
 

Let’s now write the equivalent test cases in JavaScript.
First, update the `beforeEach` function and add a third account, from which we will donate.
 
Now add the two additional test cases, right below the `beforeEach` function.
 
You might have noticed that JavaScript is a lot easier and less hacky then a Solidity test case but we still have the nasty try catch and a regex. This is because the available `assert.throws` does not work well with async code.
Let’s now add the functionality to the Funding contract.

We already store the owner of the contract. Restricting access to particular functions using an `onlyOwner` modifier is a popular convention. Popular enough to export it to a reusable piece of code but we will cover this later. The rest of the code should not come as a surprise, you have seen it all!
Now our new tests should be passing. Check to make sure.

## Refund
Currently, funds are stuck, and donators are unable to retrieve their Ether when a goal is not achieved within a specified time. We need to make sure it is possible. Two conditions have to be met so users can get their Ether back. Duration is set in a construct so if we set a 0 duration contract is finished from the beginning, but then we cannot donate to have something to withdraw. So we write tests for this case solely in JavaScript.
Let’s first write a test to check if a donator can withdraw his funds after fundraising duration is over and goal is not reached.
 
However, one should not be able to withdraw his funds after the duration is over if the goal is reached.
 
Finally, let’s check that the owner can only withdraw his funds after the duration is over and the goal is reached.

Implementing the refund function in Solidity can be tricky. Our intuition may tell us to loop through our donators and transfer them their funds. Problem with this solution is that the more donators we have the more gas to pay and it is not only looping but also making multiple transactions. We would like to keep the cost of running a function low and predictable. Let’s just allow each user to withdraw their donation.
 
We would like to save the amount to transfer first and then zero the balance. It is an implementation of the withdrawal pattern. Transferring an amount straight from the balances mapping introduces a security risk of re-entrancy — calling back multiple refunds.

## Code Coverage
1.	We should probably add code coverage reporting to our project, so that we can see how much of the code is “touched” by our tests. But first you should install Python 2.7 and Git if you haven’t already! You might need to install Windows-Build-Tools with `npm install windows-build-tools`.

2.	After that, open a command line, go to your project’s folder, and type:
```bash
$ npm init -y
$ npm install --save-dev solidity-coverage@0.6.2
```

3.	Now let’s copy this scripts and add them to our package.json:
```json
  "scripts": {
    "test": "truffle test",
    "test:coverage": "solidity-coverage"
  },
```
 
4.	Now to run your tests you should use the following command: `truffle run coverage`
```bash
$ npm run test:coverage
```

NOTE:  [Testing Recommendations](https://github.com/sc-forks/solidity-coverage)
```bash
1. init -y
2. npm install --save-dev solidity-coverage  //produces errors and warning.
3. truffle run coverage file "test/FundingTest.js"
```
Congratulations, you have all features implemented and decent test coverage.

## Conclusion
An important takeaway from this Exercise is to think twice before deciding when to test smart contracts using JavaScript and when using Solidity.

The rule of thumb is that smart contracts interacting with each other should be tested using Solidity. The rest can be tested using JavaScript, it is just easier. JavaScript testing is also closer to how you are going to use your contracts on a client. A well-written test suite can be a useful resource on how to interact with your smart contracts as well as introducing new features without worrying that you’ll break existing functionalities.

## Module
MI4: Module 1: E5
