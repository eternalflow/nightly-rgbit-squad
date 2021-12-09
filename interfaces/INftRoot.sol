pragma ton-solidity >= 0.43.0;

interface INftRoot {
    function mint() external;
    function buy() external;
    function deployBasis(TvmCell codeIndexBasis) external;
    function destructBasis() external view;
    function getInfo() external view returns (uint256 totalMinted);
}
