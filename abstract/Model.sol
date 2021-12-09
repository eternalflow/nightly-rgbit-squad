pragma ton-solidity ^0.43.0;


struct NightlyRgbitSquad {
    uint16 area;
    uint16 atomSize;
    uint16 hCount;
    uint16 vCount;
    uint32[] rgbits;
}

abstract contract Nightly {
    uint8 constant NIGHTLY_RGBATOM = 0x000055;

    uint16 constant ATOM_SIZE = 10;
    uint16 constant SIZE_H = 16;
    uint16 constant SIZE_V = 16;
    uint16 constant AREA = SIZE_H * SIZE_V;

    

    function art(uint256 material) public pure returns (NightlyRgbitSquad nft) {
        for (uint i = 0; i < 256; i++) {
            uint32 nightlyUnit = uint32((material >> i) ^ NIGHTLY_RGBATOM);
            bool existence = ((material >> i) & 1) > 0;
            uint32 rgbit = uint32(existence ? nightlyUnit : NIGHTLY_RGBATOM);
            nft.rgbits.push(rgbit);
        }
    }
}
