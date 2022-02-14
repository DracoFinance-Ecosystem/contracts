// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
    ____  ____  ___   __________     ___________   _____    _   ______________
   / __ \/ __ \/   | / ____/ __ \   / ____/  _/ | / /   |  / | / / ____/ ____/
  / / / / /_/ / /| |/ /   / / / /  / /_   / //  |/ / /| | /  |/ / /   / __/   
 / /_/ / _, _/ ___ / /___/ /_/ /  / __/ _/ // /|  / ___ |/ /|  / /___/ /___   
/_____/_/ |_/_/  |_\____/\____/  /_/   /___/_/ |_/_/  |_/_/ |_/\____/_____/   

    http://draco.finance
*/
contract DracoTaxOracle is Ownable {
    using SafeMath for uint256;

    IERC20 public draco;
    IERC20 public wftm;
    address public pair;

    constructor(
        address _draco,
        address _wftm,
        address _pair
    ) public {
        require(_draco != address(0), "draco address cannot be 0");
        require(_wftm != address(0), "wftm address cannot be 0");
        require(_pair != address(0), "pair address cannot be 0");
        draco = IERC20(_draco);
        wftm = IERC20(_wftm);
        pair = _pair;
    }

    function consult(address _token) external view returns (uint144 amountOut) {
        require(_token == address(draco), "token needs to be draco");
        uint256 dracoBalance = draco.balanceOf(pair);
        uint256 wftmBalance = wftm.balanceOf(pair);
        return uint144(dracoBalance.div(wftmBalance));
    }

    function setDraco(address _draco) external onlyOwner {
        require(_draco != address(0), "draco address cannot be 0");
        draco = IERC20(_draco);
    }

    function setWftm(address _wftm) external onlyOwner {
        require(_wftm != address(0), "wftm address cannot be 0");
        wftm = IERC20(_wftm);
    }

    function setPair(address _pair) external onlyOwner {
        require(_pair != address(0), "pair address cannot be 0");
        pair = _pair;
    }



}
