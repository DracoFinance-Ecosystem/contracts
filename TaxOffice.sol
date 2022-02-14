// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./owner/Operator.sol";
import "./interfaces/ITaxable.sol";

/*
    ____  ____  ___   __________     ___________   _____    _   ______________
   / __ \/ __ \/   | / ____/ __ \   / ____/  _/ | / /   |  / | / / ____/ ____/
  / / / / /_/ / /| |/ /   / / / /  / /_   / //  |/ / /| | /  |/ / /   / __/   
 / /_/ / _, _/ ___ / /___/ /_/ /  / __/ _/ // /|  / ___ |/ /|  / /___/ /___   
/_____/_/ |_/_/  |_\____/\____/  /_/   /___/_/ |_/_/  |_/_/ |_/\____/_____/   

    http://draco.finance
*/
contract TaxOffice is Operator {
    address public draco;

    constructor(address _draco) public {
        require(_draco != address(0), "draco address cannot be 0");
        draco = _draco;
    }

    function setTaxTiersTwap(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(draco).setTaxTiersTwap(_index, _value);
    }

    function setTaxTiersRate(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(draco).setTaxTiersRate(_index, _value);
    }

    function enableAutoCalculateTax() public onlyOperator {
        ITaxable(draco).enableAutoCalculateTax();
    }

    function disableAutoCalculateTax() public onlyOperator {
        ITaxable(draco).disableAutoCalculateTax();
    }

    function setTaxRate(uint256 _taxRate) public onlyOperator {
        ITaxable(draco).setTaxRate(_taxRate);
    }

    function setBurnThreshold(uint256 _burnThreshold) public onlyOperator {
        ITaxable(draco).setBurnThreshold(_burnThreshold);
    }

    function setTaxCollectorAddress(address _taxCollectorAddress) public onlyOperator {
        ITaxable(draco).setTaxCollectorAddress(_taxCollectorAddress);
    }

    function excludeAddressFromTax(address _address) external onlyOperator returns (bool) {
        return ITaxable(draco).excludeAddress(_address);
    }

    function includeAddressInTax(address _address) external onlyOperator returns (bool) {
        return ITaxable(draco).includeAddress(_address);
    }

    function setTaxableDracoOracle(address _dracoOracle) external onlyOperator {
        ITaxable(draco).setDracoOracle(_dracoOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(draco).setTaxOffice(_newTaxOffice);
    }
}
