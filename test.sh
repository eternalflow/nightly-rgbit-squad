#!/usr/bin/env bash

# npx tondev se reset &> /dev/null

. util.sh

# createWallet alice 10000000000
# createWallet bob 10000000000

input=$(printf 'codeData:%s' "$(npx tonos-cli decode stateinit --tvc build/Data.tvc | tail -n +5 | jq -r .code)")
input=$input,$(printf 'codeIndex:%s' "$(npx tonos-cli decode stateinit --tvc build/Index.tvc | tail -n +5 | jq -r .code)")

# npx tondev contract run -a 0:3036eb00ab5e3e6824d564b53c4e37f999e8d3db2cb1d878db1d20ae3a5408b6 external/SafeMultisigWallet sendTransaction --input value:10000000000,bounce:false,flags:0,payload:\"\",dest:\"0:5c20e1b2b983f25f08f1e8eeccec3108c5a7258ec2da05d0c12fc7ae4362d2b8\"
npx tondev contract deploy build/NftRoot --signer dev -d _addrOwner:\"0:$(addressWallet alice)\" -i $input 2>&1 
NftRootAddress=$(addressContract2 build/NftRoot)
echo "Deployed NftRoot ${NftRootAddress}"


submitTransaction2 alice build/NftRoot $NftRootAddress mint "{}" 0
submitTransaction2 bob build/NftRoot $NftRootAddress buy "{}" 7000000000

echo "Alice $(balanceWallet alice)"
echo "Bob $(balanceWallet bob)"


