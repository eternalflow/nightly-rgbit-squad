pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './interfaces/IData.sol';
import './resolvers/IndexResolver.sol';
import './libraries/NightlyArt.sol';


contract Data is IData, IndexResolver, Nightly {
    uint128 constant MIN_FOR_DEPLOY = 1 ton;

    address _addrRoot;
    address _addrOwner;
    
    NightlyRgbitSquad blocks;
    using NightlyArt for NightlyRgbitSquad;

    uint256 static _id;

    constructor(address addrOwner, TvmCell codeIndex, uint256 entropy) public {
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), 101);
        (address addrRoot) = optSalt.get().toSlice().decode(address);
        require(msg.sender == addrRoot);
        require(msg.value >= MIN_FOR_DEPLOY);
        tvm.accept();
        _addrRoot = addrRoot;
        _addrOwner = addrOwner;
        _codeIndex = codeIndex;
        blocks = art(entropy);
    }

    function asSVG() public override returns (string svg) {
        svg = blocks.render();
    }

    function transferOwnership(address addrTo) public override {
        require(msg.sender == _addrOwner, 100);
        require(msg.value >= MIN_FOR_DEPLOY, 103);

        address oldIndexOwner = resolveIndex(_addrRoot, address(this), _addrOwner);
        IIndex(oldIndexOwner).destruct();
        address oldIndexOwnerRoot = resolveIndex(address(0), address(this), _addrOwner);
        IIndex(oldIndexOwnerRoot).destruct();

        _addrOwner = addrTo;

        deployIndex(addrTo);
    }

    function deployIndex(address owner) private {
        TvmCell codeIndexOwner = _buildIndexCode(_addrRoot, owner);
        TvmCell stateIndexOwner = _buildIndexState(codeIndexOwner, address(this));
        new Index{stateInit: stateIndexOwner, value: 0.4 ton}(_addrRoot);

        TvmCell codeIndexOwnerRoot = _buildIndexCode(address(0), owner);
        TvmCell stateIndexOwnerRoot = _buildIndexState(codeIndexOwnerRoot, address(this));
        new Index{stateInit: stateIndexOwnerRoot, value: 0.4 ton}(_addrRoot);
    }

    function getInfo() public view override returns (
        address addrRoot,
        address addrOwner,
        address addrData
    ) {
        addrRoot = _addrRoot;
        addrOwner = _addrOwner;
        addrData = address(this);
    }

    function getOwner() public view override returns(address addrOwner) {
        addrOwner = _addrOwner;
    }
}
