pragma ton-solidity >= 0.43.0;

import "../abstract/Model.sol";

library NightlyArt {

    function renderBlock(
        uint32 rgbit, uint idx, uint16 atomSize, uint16 hCount, uint16 vCount
    ) public pure returns (string svgRect) 
    {
        uint x = idx % hCount * atomSize;
        uint y = idx / vCount * atomSize;
        svgRect = format(
            "<rect x='{}' y='{}' fill='rgba({},{},{},{})' width='{}' height='{}' />", 
            x, y, 
            (rgbit >> 16) & 0xf, (rgbit >> 8) & 0xf, rgbit & 0xf, 1, 
            atomSize, atomSize);
    }

    function render(NightlyRgbitSquad mdl) public pure returns (string svg) {
        string open = "<svg xmlns='http://www.w3.org/2000/svg'><g>";
        string rects;
        for (uint i = 0; i < mdl.area; i++) {
            rects.append(
                renderBlock(mdl.rgbits[i], i, mdl.atomSize, mdl.hCount, mdl.vCount)
            );
        }
        string close = "</g></svg>";
        svg = open + rects + close;
    }
}
