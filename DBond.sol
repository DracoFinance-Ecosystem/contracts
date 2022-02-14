// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

import "./owner/Operator.sol";

/*
    ____  ____  ___   __________     ___________   _____    _   ______________
   / __ \/ __ \/   | / ____/ __ \   / ____/  _/ | / /   |  / | / / ____/ ____/
  / / / / /_/ / /| |/ /   / / / /  / /_   / //  |/ / /| | /  |/ / /   / __/   
 / /_/ / _, _/ ___ / /___/ /_/ /  / __/ _/ // /|  / ___ |/ /|  / /___/ /___   
/_____/_/ |_/_/  |_\____/\____/  /_/   /___/_/ |_/_/  |_/_/ |_/\____/_____/   

    http://draco.finance
*/

contract DBond is ERC20Burnable, Operator {
    /**
     * @notice Constructs the DRACO Bond ERC-20 contract.
     */
    constructor() public ERC20("DBOND", "DBOND") {}

    /**
     * @notice Operator mints basis bonds to a recipient
     * @param recipient_ The address of recipient
     * @param amount_ The amount of basis bonds to mint to
     * @return whether the process has been done
     */
    function mint(address recipient_, uint256 amount_) public onlyOperator returns (bool) {
        uint256 balanceBefore = balanceOf(recipient_);
        _mint(recipient_, amount_);
        uint256 balanceAfter = balanceOf(recipient_);

        return balanceAfter > balanceBefore;
    }

    function burn(uint256 amount) public override {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount) public override onlyOperator {
        super.burnFrom(account, amount);
    }
}
