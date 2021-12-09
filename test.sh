#!/usr/bin/env bash

npx tondev se reset &> /dev/null

. util.sh

createWallet alice 10000000000
createWallet bob 10000000000

input=$(printf 'codeData:%s' "$(npx tonos-cli decode stateinit --tvc build/Data.tvc | tail -n +5 | jq -r .code)")
input=$input,$(printf 'codeIndex:%s' "$(npx tonos-cli decode stateinit --tvc build/Index.tvc | tail -n +5 | jq -r .code)")

# pushd build
npx tondev contract deploy build/NftRoot -d _addrOwner:\"0:$(addressWallet alice)\" -i $input --value 10000000000 2>&1
# popd
NftRootAddress=$(addressContract2 build/NftRoot)
echo "Deployed NftRoot ${NftRootAddress}"


submitTransaction2 alice build/NftRoot $NftRootAddress mint "{}" 0
submitTransaction2 bob build/NftRoot $NftRootAddress buy "{}" 7000000000

echo "Alice $(balanceWallet alice)"
echo "Bob $(balanceWallet bob)"


