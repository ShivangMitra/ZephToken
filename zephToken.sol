// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.7.2/token/ERC20/ERC20.sol";

///Token holders will be able to destroy their tokens.
import "@openzeppelin/contracts@4.7.2/token/ERC20/extensions/ERC20Burnable.sol";

import "@openzeppelin/contracts@4.7.2/security/Pausable.sol";
import "@openzeppelin/contracts@4.7.2/access/AccessControl.sol";

///Without paying gas, token holders will be able to allow third parties to transfer from their account.
import "@openzeppelin/contracts@4.7.2/token/ERC20/extensions/draft-ERC20Permit.sol";

/// @custom:security-contact shivangmitra8@gmail.com
contract ZephToken is ERC20, ERC20Burnable, Pausable, AccessControl, ERC20Permit {

    ///Flexible mechanism with a separate role for each privileged action. A role can have many authorized accounts.
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    ///Grant all the roles to the deployer and create an initial amount of tokens for the deployer.
    constructor() ERC20("ZephToken", "ZPT", msg.sender, address(this)) ERC20Permit("ZephToken") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _mint(msg.sender, 100000 * 10 ** decimals());
    }

    ///Privileged accounts will be able to pause the functionality marked as whenNotPaused. Useful for emergency response.
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    ///Privileged accounts will be able to unpause the functionality marked as whenNotPaused.
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    ///Privileged accounts will be able to create more supply.
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    ///Before transfering any amount from one account to another we check if this functionality is paused or not.
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    /*
        "_transfer" function in the ERC20.sol has been modified.
        The Token now favours the Admin/Owner of the Token.
        Each transaction deducts 5% of the transfered amount as Income Tax.
        This tax can be collected by the Admin/Owner at any point.
    */

    ///Admin can view the amount of tax collected.
    function current_tax_collected() public view onlyRole(DEFAULT_ADMIN_ROLE) returns(uint256){
        return balanceOf(address(this));
    }

    //Admin can transfer the current total tax collected to their account.
    function transfer_tax() public onlyRole(DEFAULT_ADMIN_ROLE){
        _transfer(address(this), msg.sender, current_tax_collected());
    }
}
