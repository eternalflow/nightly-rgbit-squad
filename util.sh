#!/usr/bin/env bash

addressWallet() {
    name="${1:-alice}"
    address=$(npx tondev contract info --signer "${name}" external/SafeMultisigWallet | grep Address | cut -d':' -f3 | cut -d' ' -f1)
    printf "%s" "${address}"
}

addressWallet2() {
    name="${1:-alice}"
    address=$(npx tondev contract info --signer "${name}" external/SafeMultisigWallet | grep Address | cut -d':' -f3 | cut -d' ' -f1)
    printf "0:%s" "${address}"
}

addressContract() {
    contract="${1}"
    address=$(npx tondev contract info "${contract}" | grep Address | cut -d':' -f3 | cut -d' ' -f1)
    printf "%s" "${address}"
}

addressContract2() {
    contract="${1}"
    address=$(npx tondev contract info "${contract}" -d _addrOwner:\"0:$(addressWallet alice)\"| grep Address | cut -d':' -f3 | cut -d' ' -f1)
    printf "0:%s" "${address}"
}

balanceAccount() {
  address="${1}"
  format="${2:-${EVER_FORMAT:-true}}"
  balance=$(npx tonos-cli account "${address}" | grep balance | cut -d' ' -f8)
  if [ "${format}" == "true" ]; then
    printf "%s" "$(toEVER "${balance}")"
  else
    printf "%s" "${balance}"
  fi
}

balanceContract() {
    contract="${1}"
    format="${2:-${EVER_FORMAT:-true}}"
    printf "%s" "$(balanceAccount "$(addressContract "${contract}")" "${format}")"
}

balanceWallet() {
    name="${1:-alice}"
    format="${2:-${EVER_FORMAT:-true}}"
    printf "%s" "$(balanceAccount "$(addressWallet "${name}")" "${format}")"
}

toEVER() {
  printf '%.2f' "$((${1}))e-9"
}

createWallet() {
  name="${1:-alice}"
  value="${2:-100051425001}"
  if [ ! -f external/SafeMultisigWallet.abi.json ]; then
      wget --quiet https://raw.githubusercontent.com/tonlabs/ton-labs-contracts/5ee039e4d093b91b6fdf7d77b9627e2e7d37f000/solidity/safemultisig/SafeMultisigWallet.tvc
      wget --quiet https://raw.githubusercontent.com/tonlabs/ton-labs-contracts/5ee039e4d093b91b6fdf7d77b9627e2e7d37f000/solidity/safemultisig/SafeMultisigWallet.abi.json
  fi
  npx tondev signer generate "${name}" >> tondev.log 2>&1
  keyPublic="0x$(npx tondev signer info "${name}" | jq -r .keys.public)"
  input="owners:[$keyPublic],reqConfirms:1"
  echo "$(TZ=EET date) createWallet" >> tondev.log 2>&1
  npx tondev contract run -a 0:3036eb00ab5e3e6824d564b53c4e37f999e8d3db2cb1d878db1d20ae3a5408b6 external/SafeMultisigWallet sendTransaction --input value:10000000000,bounce:false,flags:0,payload:\"\",dest:\"0:"$(addressWallet "${name}")"\"
  npx tondev contract deploy --signer "${name}" external/SafeMultisigWallet --value "${value}" --input "${input}" >> tondev.log 2>&1
  echo "Created wallet 0:$(addressWallet "${name}") with $(balanceWallet "${name}") for ${name}"
}

submitTransaction() {
  signer=${1}
  contractName=${2}
  method=${3}
  param=${4}
  value=${5:-10000000} # 0.01
  address="0:$(addressContract2 "${contractName}")"
  body=$(npx tonos-cli body --abi "${contractName}.abi.json" "${method}" "${param}" | grep body | cut -d' ' -f3)
  input="dest:'${address}',value:${value},allBalance:false,bounce:true,payload:'$body'"
  echo "$(TZ=EET date) submitTransaction" >> tondev.log 2>&1
  echo "submitTransaction ${method} ${param} to ${contractName}"
  npx tondev contract run --signer "${signer}" external/SafeMultisigWallet submitTransaction --input "$input" >> tondev.log 2>&1
}

submitTransaction2() {
    # alice $NAME $RootNFTAddress mint "{}" 0
  signer=${1}
  contractName=${2}
  address=${3}
  method=${4}
  param=${5}
  value=${6:-10000000} # 0.01
  
  body=$(npx tonos-cli body --abi "${contractName}.abi.json" "${method}" "${param}" | grep body | cut -d' ' -f3)
  input="dest:'${address}',value:${value},allBalance:false,bounce:true,payload:'$body'"
  echo "$(TZ=EET date) submitTransaction" >> tondev.log 2>&1
  echo "submitTransaction ${method} ${param} to ${contractName}"
  npx tondev contract run --signer "${signer}" external/SafeMultisigWallet submitTransaction --input "$input" >> tondev.log 2>&1
}
