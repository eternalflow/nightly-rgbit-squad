#!/usr/bin/env bash

rm -fr *.abi.json *.tvc *.log build/*
npx tondev sol compile NftRoot.sol -o build
npx tondev sol compile Data.sol -o build
npx tondev sol compile Index.sol -o build
npx tondev sol compile IndexBasis.sol -o build
