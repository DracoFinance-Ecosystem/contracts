// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./owner/Operator.sol";
import "./interfaces/ITaxable.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";

/*
    ____  ____  ___   __________     ___________   _____    _   ______________
   / __ \/ __ \/   | / ____/ __ \   / ____/  _/ | / /   |  / | / / ____/ ____/
  / / / / /_/ / /| |/ /   / / / /  / /_   / //  |/ / /| | /  |/ / /   / __/   
 / /_/ / _, _/ ___ / /___/ /_/ /  / __/ _/ // /|  / ___ |/ /|  / /___/ /___   
/_____/_/ |_/_/  |_\____/\____/  /_/   /___/_/ |_/_/  |_/_/ |_/\____/_____/   

    http://draco.finance
*/
contract TaxOfficeV2 is Operator {
    using SafeMath for uint256;

    address public draco;
    address public uniRouter;
    address public wftm = address(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);

    constructor(address _draco, address _pair) public {
        require(_draco != address(0), "draco address cannot be 0");
        require(_pair != address(0), "pair address cannot be 0");
        draco = _draco;
        uniRouter = _pair;
    }

    mapping(address => bool) public taxExclusionEnabled;

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
        return _excludeAddressFromTax(_address);
    }

    function _excludeAddressFromTax(address _address) private returns (bool) {
        if (!ITaxable(draco).isAddressExcluded(_address)) {
            return ITaxable(draco).excludeAddress(_address);
        }
    }

    function includeAddressInTax(address _address) external onlyOperator returns (bool) {
        return _includeAddressInTax(_address);
    }

    function _includeAddressInTax(address _address) private returns (bool) {
        if (ITaxable(draco).isAddressExcluded(_address)) {
            return ITaxable(draco).includeAddress(_address);
        }
    }

    function taxRate() external view returns (uint256) {
        return ITaxable(draco).taxRate();
    }

    function addLiquidityTaxFree(
        address token,
        uint256 amtDraco,
        uint256 amtToken,
        uint256 amtDracoMin,
        uint256 amtTokenMin
    )
        external
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(amtDraco != 0 && amtToken != 0, "amounts can't be 0");
        _excludeAddressFromTax(msg.sender);

        IERC20(draco).transferFrom(msg.sender, address(this), amtDraco);
        IERC20(token).transferFrom(msg.sender, address(this), amtToken);
        _approveTokenIfNeeded(draco, uniRouter);
        _approveTokenIfNeeded(token, uniRouter);

        _includeAddressInTax(msg.sender);

        uint256 resultAmtDraco;
        uint256 resultAmtToken;
        uint256 liquidity;
        (resultAmtDraco, resultAmtToken, liquidity) = IUniswapV2Router(uniRouter).addLiquidity(
            draco,
            token,
            amtDraco,
            amtToken,
            amtDracoMin,
            amtTokenMin,
            msg.sender,
            block.timestamp
        );

        if(amtDraco.sub(resultAmtDraco) > 0) {
            IERC20(draco).transfer(msg.sender, amtDraco.sub(resultAmtDraco));
        }
        if(amtToken.sub(resultAmtToken) > 0) {
            IERC20(token).transfer(msg.sender, amtToken.sub(resultAmtToken));
        }
        return (resultAmtDraco, resultAmtToken, liquidity);
    }

    function addLiquidityETHTaxFree(
        uint256 amtDraco,
        uint256 amtDracoMin,
        uint256 amtFtmMin
    )
        external
        payable
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(amtDraco != 0 && msg.value != 0, "amounts can't be 0");
        _excludeAddressFromTax(msg.sender);

        IERC20(draco).transferFrom(msg.sender, address(this), amtDraco);
        _approveTokenIfNeeded(draco, uniRouter);

        _includeAddressInTax(msg.sender);

        uint256 resultAmtDraco;
        uint256 resultAmtFtm;
        uint256 liquidity;
        (resultAmtDraco, resultAmtFtm, liquidity) = IUniswapV2Router(uniRouter).addLiquidityETH{value: msg.value}(
            draco,
            amtDraco,
            amtDracoMin,
            amtFtmMin,
            msg.sender,
            block.timestamp
        );

        if(amtDraco.sub(resultAmtDraco) > 0) {
            IERC20(draco).transfer(msg.sender, amtDraco.sub(resultAmtDraco));
        }
        return (resultAmtDraco, resultAmtFtm, liquidity);
    }

    function setTaxableDracoOracle(address _dracoOracle) external onlyOperator {
        ITaxable(draco).setDracoOracle(_dracoOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(draco).setTaxOffice(_newTaxOffice);
    }

    function taxFreeTransferFrom(
        address _sender,
        address _recipient,
        uint256 _amt
    ) external {
        require(taxExclusionEnabled[msg.sender], "Address not approved for tax free transfers");
        _excludeAddressFromTax(_sender);
        IERC20(draco).transferFrom(_sender, _recipient, _amt);
        _includeAddressInTax(_sender);
    }

    function setTaxExclusionForAddress(address _address, bool _excluded) external onlyOperator {
        taxExclusionEnabled[_address] = _excluded;
    }

    function _approveTokenIfNeeded(address _token, address _router) private {
        if (IERC20(_token).allowance(address(this), _router) == 0) {
            IERC20(_token).approve(_router, type(uint256).max);
        }
    }
}
