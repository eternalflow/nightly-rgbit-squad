pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';
import './resolvers/DataResolver.sol';

import './IndexBasis.sol';

import './interfaces/IData.sol';
import './interfaces/IIndexBasis.sol';
import './interfaces/INftRoot.sol';

abstract contract Generative {

    modifier useRNG {
        initRNG();
        _;
    }

    function initRNG() pure internal {
        rnd.shuffle();
    }

    function rand256() pure internal returns (uint256 rand) {
        rand = rnd.next();
    }

    // returns true with m/n probability
    function roll(uint16 m, uint16 n) private pure returns (bool result) {
        uint256 rand = rnd.next(n) + 1;
        result = rand > m;
    }

}
contract NftRoot is DataResolver, IndexResolver, INftRoot, Generative {

    address static _addrOwner;
    uint256 _totalMinted;
    address public _addrBasis;

    constructor(TvmCell codeIndex, TvmCell codeData) public {
        tvm.accept();
        _codeIndex = codeIndex;
        _codeData = codeData;
    }

    function _mint() internal {
        TvmCell codeData = _buildDataCode(address(this));
        TvmCell stateData = _buildDataState(codeData, _totalMinted);
        uint256 material = rand256();
        new Data{
            stateInit: stateData,
            value: 1.1 ton
        }(msg.sender, _codeIndex, material);

        _totalMinted++;
    }

    function buy() public override useRNG {
        require(msg.value >= 5 ton, 108);
        _mint();
    }

    function mint() public override useRNG {
        require(msg.sender == _addrOwner, 100);
        require(msg.value == 0 ton, 100);
        tvm.accept();
        _mint();
    }

    function deployBasis(TvmCell codeIndexBasis) public override {
        require(msg.sender == _addrOwner, 100);
        require(msg.value > 0.5 ton, 104);
        uint256 codeHasData = resolveCodeHashData();
        TvmCell state = tvm.buildStateInit({
            contr: IndexBasis,
            varInit: {
                _codeHashData: codeHasData,
                _addrRoot: address(this)
            },
            code: codeIndexBasis
        });
        _addrBasis = new IndexBasis{stateInit: state, value: 0.4 ton}();
    }

    function destructBasis() public override view {
        require(msg.sender == _addrOwner, 100);
        IIndexBasis(_addrBasis).destruct();
    }

    function getInfo() public override view returns (uint256 totalMinted) {
        totalMinted = _totalMinted;
    }
}
