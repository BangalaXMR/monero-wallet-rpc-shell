#!/bin/bash

# Monero Wallet RPC bindings in Shell
# For using this script like a library, you need to import it in your project with $ source monero-wallet-rpc.sh

# Configuration
RPC_IP="127.0.0.1"
RPC_PORT="18082"
RPC_USER="your_rpc_username"                # Change this to your RPC username
RPC_PASSWORD="your_rpc_password"            # Change this to your RPC password
RPC_BINARIES="/path/to/monero-wallet-rpc" # $(find /*/*/* -type f -executable -name "monero-wallet-rpc" 2>/dev/null)
RPC_URL="http://$RPC_IP:$RPC_PORT/json_rpc"
DEAMON_URL="http://IP:PORT"
WALLET_DIR="/path/to/Monero/wallets"
# Function to start a wallet-rpc-server
start_rpc() {
    $RPC_BINARIES \
    --detach \
    --wallet-dir $WALLET_DIR \
    --rpc-bind-ip $RPC_IP \
    --rpc-bind-port $RPC_PORT \
    --rpc-login $RPC_USER:$RPC_PASSWORD \
    --daemon-address $DEAMON_URL \
}

# Function to stop a wallet-rpc-server
stop_rpc() {
    killall "monero-wallet-rpc"
}

rpc_call() {
    curl "$RPC_URL" -s -u  "$RPC_USER":"$RPC_PASSWORD" --digest -d "$json_payload" -H 'Content-Type: application/json' | jq '.result'
    # Example: curl "$RPC_URL" -s -u  "$RPC_USER":"$RPC_PASSWORD" --digest -d "$(jq -n --argjson account_index "$1" --argjson address_indices "$2" '{"jsonrpc":"2.0","id":"0","method":"get_balance","params":{"account_index":$account_index,"address_indices":$address_indices}}')" -H 'Content-Type: application/json' | jq
}

# Function to get balances
get_balance() {
if [ -z "$2" ]; then
json_payload=$(jq -n --argjson account_index "$1" '{"jsonrpc":"2.0","id":"0","method":"get_balance","params":{"account_index":$account_index}}')
else
json_payload=$(jq -n --argjson account_index "$1" --argjson address_indices "$2" '{"jsonrpc":"2.0","id":"0","method":"get_balance","params":{"account_index":$account_index,"address_indices":$address_indices}}')
fi
rpc_call
}

# Function to get wallet address
get_address() {
    json_payload=$(jq -n --argjson account_index "$1" --argjson address_index "$2" '{"jsonrpc":"2.0","id":"0","method":"get_address","params":{"account_index":$account_index,"address_index":$address_index}}')
    rpc_call
}

# Function to get address index
get_address_index() {
    json_payload=$(jq -n --arg address "$1" '{"jsonrpc":"2.0","id":"0","method":"get_address_index","params":{"address":$address}}')
    rpc_call
}

# Function to create a new address
create_address() {
    json_payload=$(jq -n --argjson account_index "$1" --arg label "$2" --argjson count "$3" '{"jsonrpc":"2.0","id":"0","method":"create_address","params":{"account_index":$account_index,"label":"$label","count":$count}}')
    rpc_call
}

# Function to label an address
label_address() {
    json_payload=$(jq -n --argjson major $1 --argjson minor $2 --arg label $3 '{"jsonrpc":"2.0","id":"0","method":"label_address","params":{"index":{"major":$major,"minor":$minor},"label":"$label"}}')
    rpc_call
}

# Function to label an account
label_account() {
    json_payload=$(jq -n --argjson account_index "$1" --argjson label "$2" '{"jsonrpc":"2.0","id":"0","method":"label_account","params":{"account_index":$account_index,"label":$label}}')
    rpc_call
}

# Function to create an account
create_account() {
    json_payload=$(jq -n --arg label "$1" '{"jsonrpc":"2.0","id":"0","method":"create_account","params":{"label":$label}}')
    rpc_call
}

# Function to get accounts
get_accounts() {
    json_payload=$(jq -n --arg tag "$1" '{"jsonrpc":"2.0","id":"0","method":"get_accounts","params":{"tag":"$tag"}}')
    rpc_call
}

# Function to get account tags
get_account_tags() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"get_account_tags","params":""}')
    rpc_call
}

# Function to tag accounts
tag_accounts() {
    json_payload=$(jq -n --arg tags "$1" --argjson accounts "$2" '{"jsonrpc":"2.0","id":"0","method":"tag_accounts","params":{"tags":$tags,"accounts":[$accounts]}}')
    rpc_call
}

# Function to untag accounts
untag_accounts() {
    json_payload=$(jq -n --argjson accounts "$1" '{"jsonrpc":"2.0","id":"0","method":"untag_accounts","params":{"accounts":$accounts}}')
    rpc_call
}

# Function to set account tag description
set_account_tag_description() {
    json_payload=$(jq -n --arg tag "$1" --arg description "$2" '{"jsonrpc":"2.0","id":"0","method":"set_account_tag_description","params":{"tag":$tag,"description":$description}}')
    rpc_call
}

# Function to get blockchain height
get_height() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"get_height"}')
    rpc_call
}

# Function to freeze funds
freeze() {
    json_payload=$(jq -n --arg key_image "$1" '{"jsonrpc":"2.0","id":"0","method":"freeze","params":{"key_image":"$key_image"}}')
    rpc_call
}

# Function to check frozen status
frozen() {
    json_payload=$(jq -n --arg key_image "$1" '{"jsonrpc":"2.0","id":"0","method":"frozen","params":{"key_image":"$key_image"}}')
    rpc_call
}

# Function to thaw funds
thaw() {
    json_payload=$(jq -n --arg key_image "$1" '{"jsonrpc":"2.0","id":"0","method":"thaw","params":{"key_image":"$key_image"}}')
    rpc_call
}

# Function to transfer funds
transfer() {
    json_payload=$(jq -n --argson amount "$1" --arg address "$2" --argjson account_index "$3" --argjson priority "$4" '{"jsonrpc":"2.0","id":"0","method":"transfer","params":{"destinations":[{"amount":$amount,"address":"$address"}],"account_index":$account_index,"priority":$priority}}')
    rpc_call
}

# Function to submit a transfer
submit_transfer() {
    json_payload=$(jq -n --arg tx_data "$1" '{"jsonrpc":"2.0","id":"0","method":"submit_transfer","params":{"tx_data":$tx_data}}')
    rpc_call
}

# Function to sweep dust
sweep_dust() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"sweep_dust"}')
    rpc_call
}

# Function to sweep all funds
sweep_all() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"sweep_all"}')
    rpc_call
}

# Function to sweep a single output
sweep_single() {
    json_payload=$(jq -n --arg address "$1" --arg key_image "$2" --argjson priority "$3" --argjson get_tx_key "$4"  '{"jsonrpc":"2.0","id":"0","method":"sweep_single","params":{"address":"$address","key_image":"$key_image","priority":$priority,"get_tx_key":$get_tx_key}}')
    rpc_call
}

# Function to relay a transaction
relay_tx() {
    json_payload=$(jq -n --arg raw_tx "$1" '{"jsonrpc":"2.0","id":"0","method":"relay_tx","params":{"hex":$raw_tx}}')
    rpc_call
}
# Function to get payments
get_payments() {
    json_payload=$(jq -n --arg payment_id "$1" '{"jsonrpc":"2.0","id":"0","method":"get_payments","params":{"payment_id":$payment_id}}')
    rpc_call
}

# Function to get bulk payments
get_bulk_payments() {
    json_payload=$(jq -n --arg payment_ids "$1" '{"jsonrpc":"2.0","id":"0","method":"get_bulk_payments","params":{"payment_ids":$payment_ids}}')
    rpc_call
}

# Function to get incoming transfers
incoming_transfers() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"incoming_transfers"}')
    rpc_call
}

# Function to query a key
query_key() {
    json_payload=$(jq -n --arg key_type "$1" '{"jsonrpc":"2.0","id":"0","method":"query_key","params":{"key_type":$key_type}}')
    rpc_call
}

# Function to make an integrated address
make_integrated_address() {
    json_payload=$(jq -n --argjson address "$1" --argjson payment_id "$2" '{"jsonrpc":"2.0","id":"0","method":"make_integrated_address","params":{"address":$address,"payment_id":$payment_id}}')
    rpc_call
}

# Function to split an integrated address
split_integrated_address() {
    json_payload=$(jq -n --arg integrated_address "$1" '{"jsonrpc":"2.0","id":"0","method":"split_integrated_address","params":{"integrated_address":$integrated_address}}')
    rpc_call
}

# Function to stop the wallet
stop_wallet() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"stop_wallet"}')
    rpc_call
}

# Function to rescan the blockchain
rescan_blockchain() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"rescan_blockchain"}')
    rpc_call
}

# Function to set transaction notes
set_tx_notes() {
    json_payload=$(jq -n --argjson txid "$1" --argjson notes "$2" '{"jsonrpc":"2.0","id":"0","method":"get_address","params":{"txid":$txid,"notes":$notes}}')
    rpc_call
}

# Function to get transaction notes
get_tx_notes() {
    json_payload=$(jq -n --arg txid "$1" '{"jsonrpc":"2.0","id":"0","method":"get_tx_notes","params":{"txid":$txid}}')
    rpc_call
}
# Function to set an attribute
set_attribute() {
    json_payload=$(jq -n --argjson key "$1" --argjson value "$2" '{"jsonrpc":"2.0","id":"0","method":"set_attribute","params":{"key":$key,"value":$value}}')
    rpc_call
}

# Function to get an attribute
get_attribute() {
    json_payload=$(jq -n --arg key "$1" '{"jsonrpc":"2.0","id":"0","method":"get_attribute","params":{"key":$key}}')
    rpc_call
}

# Function to get transaction key
get_tx_key() {
    json_payload=$(jq -n --arg txid "$1" '{"jsonrpc":"2.0","id":"0","method":"get_tx_key","params":{"txid":$txid}}')
    rpc_call
}
# Function to check transaction key
check_tx_key() {
    json_payload=$(jq -n --argjson txid "$1" --argjson tx_key "$2" '{"jsonrpc":"2.0","id":"0","method":"get_address","params":{"txid":$txid,"tx_key":$tx_key}}')
    rpc_call
}

# Function to get transaction proof
get_tx_proof() {
    json_payload=$(jq -n --argjson txid "$1" --arg address "$2" --argjson message "$3" '{"jsonrpc":"2.0","id":"0","method":"get_tx_proof","params":{"txid":$txid,"address":"$address","message":$message}}')
    rpc_call
}

# Function to check transaction proof
check_tx_proof() {
    json_payload=$(jq -n --argjson txid "$1" --arg address "$2" --argjson message "$3" --arg signature "$4" '{"jsonrpc":"2.0","id":"0","method":"check_tx_proof","params":{"txid":$txid,"address":$address,"message":"$message,"signature":$signature}}')
    rpc_call
}

# Function to get spend proof
get_spend_proof() {
    json_payload=$(jq -n --arg txid "$1" '{"jsonrpc":"2.0","id":"0","method":"get_spend_proof","params":{"txid":$txid}}')
    rpc_call
}

# Function to check spend proof
check_spend_proof() {
    json_payload=$(jq -n --argjson txid "$1" --argjson spend_proof "$2" '{"jsonrpc":"2.0","id":"0","method":"check_spend_proof","params":{"txid":$txid,"spend_proof":$spend_proof}}')
    rpc_call
}

# Function to get reserve proof
get_reserve_proof() {
    json_payload=$(jq -n --argjson all "$1" --argjson account_index "$2" --argjson amount "$3" --arg message "$4" '{"jsonrpc":"2.0","id":"0","method":"get_reserve_proof","params":{"all":$all,"account_index":$account_index,"amount":$amount,"message":$message}}')
    rpc_call
}

# Function to check reserve proof
check_reserve_proof() {
    json_payload=$(jq -n --arg address "$1" --arg message "$2" --arg signature "$3" '{"jsonrpc":"2.0","id":"0","method":"check_reserve_proof","params":{"address":$address,"message":$message,"signature":$signature}}')
    rpc_call
}

# Function to get transfers
get_transfers() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"get_transfers"}')
    rpc_call
}

# Function to get transfer by txid
get_transfer_by_txid() {
    json_payload=$(jq -n --arg txid "$1" '{"jsonrpc":"2.0","id":"0","method":"get_transfer_by_txid","params":{"txid":$txid}}')
    rpc_call
}

# Function to sign a message
sign() {
    json_payload=$(jq -n --arg message "$1" '{"jsonrpc":"2.0","id":"0","method":"sign","params":{"message":$message}}')
    rpc_call
}
# Function to verify a signature
verify() {
    json_payload=$(jq -n --argjson message "$1" --argjson signature "$2" '{"jsonrpc":"2.0","id":"0","method":"verify","params":{"message":$message,"signature":$signature}}')
    rpc_call
}

# Function to export outputs
export_outputs() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"export_outputs"}')
    rpc_call
}

# Function to import outputs
import_outputs() {
    json_payload=$(jq -n --arg outputs "$1" '{"jsonrpc":"2.0","id":"0","method":"import_outputs","params":{"outputs":$outputs}}')
    rpc_call
}

# Function to export key images
export_key_images() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"export_key_images"}')
    rpc_call
}

# Function to import key images
import_key_images() {
    json_payload=$(jq -n --arg key_images "$1" '{"jsonrpc":"2.0","id":"0","method":"import_key_images","params":{"key_images":$key_images}}')
    rpc_call
}

# Function to make a URI
make_uri() {
    json_payload=$(jq -n --argjson address "$1" --arg amount "$2" --argjson payment_id "$3" '{"jsonrpc":"2.0","id":"0","method":"make_uri","params":{"address":$address,"amount":"$amount","payment_id":$payment_id}}')
    rpc_call
}

# Function to parse a URI
parse_uri() {
    json_payload=$(jq -n --arg uri "$1" '{"jsonrpc":"2.0","id":"0","method":"parse_uri","params":{"uri":$uri}}')
    rpc_call
}

# Function to get address book
get_address_book() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"get_address_book"}')
    rpc_call
}

# Function to add an address book entry
add_address_book() {
    json_payload=$(jq -n --argjson address "$1" --argjson description "$2" '{"jsonrpc":"2.0","id":"0","method":"add_address_book","params":{"address":$address,"description":$description}}')
    rpc_call
}

# Function to edit an address book entry
edit_address_book() {
    json_payload=$(jq -n --argjson index "$1" --arg address "$2" --argjson description "$3" '{"jsonrpc":"2.0","id":"0","method":"edit_address_book","params":{"index":$index,"address":"$address","description":$description}}')
    rpc_call
}

# Function to delete an address book entry
delete_address_book() {
    json_payload=$(jq -n --arg index "$1" '{"jsonrpc":"2.0","id":"0","method":"delete_address_book","params":{"index":$index}}')
    rpc_call
}

# Function to refresh the wallet
refresh() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"refresh"}')
    rpc_call
}

# Function to enable auto refresh
auto_refresh() {
    json_payload=$(jq -n --arg enable "$1" '{"jsonrpc":"2.0","id":"0","method":"auto_refresh","params":{"enable":$enable}}')
    rpc_call
}

# Function to scan a transaction
scan_tx() {
    json_payload=$(jq -n --arg txid "$1" '{"jsonrpc":"2.0","id":"0","method":"scan_tx","params":{"txid":$txid}}')
    rpc_call
}

# Function to rescan spent outputs
rescan_spent() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"rescan_spent"}')
    rpc_call
}

# Function to start mining
start_mining() {
    json_payload=$(jq -n --argjson address "$1" --argjson threads "$2" '{"jsonrpc":"2.0","id":"0","method":"start_mining","params":{"address":$address,"threads":$threads}}')
    rpc_call
}

# Function to stop mining
stop_mining() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"get_version"}')
    rpc_call
}

# Function to get available languages
get_languages() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"get_languages"}')
    rpc_call
}

# Function to create a new wallet
create_wallet() {
    json_payload=$(jq -n --argjson filename "$1" --arg password "$2" --argjson language "$3" '{"jsonrpc":"2.0","id":"0","method":"get_tx_proof","params":{"filename":$filename,"password":"$password","language":$language}}')
    rpc_call
}

# Function to open a wallet
open_wallet() {
    json_payload=$(jq -n --arg filename "$1" --arg password "$2" '{"jsonrpc":"2.0","id":"0","method":"open_wallet","params":{"filename":$filename,"password":$password}}')
    rpc_call
}

# Function to close the wallet
close_wallet() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"close_wallet"}')
    rpc_call
}

# Function to change wallet password
change_wallet_password() {
    json_payload=$(jq -n --arg old_password "$1" --arg new_password "$2" '{"jsonrpc":"2.0","id":"0","method":"change_wallet_password","params":{"old_password":$old_password,"new_password":$new_password}}')
    rpc_call
}

# Function to generate wallet from keys
generate_from_keys() {
    json_payload=$(jq -n --argjson address "$1" --arg view_key "$2" --argjson spend_key "$3" '{"jsonrpc":"2.0","id":"0","method":"generate_from_keys","params":{"address":$address,"view_key":"$view_key","spend_key":$spend_key}}')
    rpc_call
}

# Function to restore a deterministic wallet
restore_deterministic_wallet() {
    json_payload=$(jq -n --arg filename "$1" --arg password "$2" --arg seed "$3" --argjson restore_height "$4" --arg language "$5" --argjson autosave_current "$6" '{"jsonrpc":"2.0","id":"0","method":"restore_deterministic_wallet","params":{"filename":"$filename","password":"$password","seed":"$seed","restore_height":$restore_height, "language":"$language","autosave_current":$autosave_current}}')
    rpc_call
}

# Function to check if wallet is multisig
is_multisig() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"is_multisig"}')
    rpc_call
}

# Function to prepare multisig
prepare_multisig() {
    json_payload=$(jq -n --arg multisig_info "$1" '{"jsonrpc":"2.0","id":"0","method":"prepare_multisig","params":{"multisig_info":$multisig_info}}')
    rpc_call
}

# Function to make a multisig wallet
make_multisig() {
    json_payload=$(jq -n --arg multisig_info "$1" '{"jsonrpc":"2.0","id":"0","method":"exchange_multisig_keys","params":{"multisig_info":$multisig_info}}')
    rpc_call
}

# Function to export multisig info
export_multisig_info() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"export_multisig_info"}')
    rpc_call
}

# Function to import multisig info
import_multisig_info() {
    json_payload=$(jq -n --arg multisig_info "$1" '{"jsonrpc":"2.0","id":"0","method":"import_multisig_info","params":{"multisig_info":$multisig_info}}')
    rpc_call
}

# Function to finalize multisig
finalize_multisig() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"finalize_multisig"}')
    rpc_call
}

# Function to exchange multisig keys
exchange_multisig_keys() {
    json_payload=$(jq -n --arg keys "$1" '{"jsonrpc":"2.0","id":"0","method":"exchange_multisig_keys","params":{"keys":$keys}}')
    rpc_call
}
# Function to get multisig key exchange booster
get_multisig_key_exchange_booster() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"get_multisig_key_exchange_booster"}')
    rpc_call
}

# Function to sign a multisig transaction
sign_multisig() {
    json_payload=$(jq -n --arg tx_data "$1" '{"jsonrpc":"2.0","id":"0","method":"sign_multisig","params":{"tx_data":$tx_data}}')
    rpc_call
}

# Function to submit a multisig transaction
submit_multisig() {
    json_payload=$(jq -n --arg tx_data "$1" '{"jsonrpc":"2.0","id":"0","method":"submit_multisig","params":{"tx_data":$tx_data}}')
    rpc_call
}

# Function to validate an address
validate_address() {
    json_payload=$(jq -n --arg address "$1" --argjson any_net_type "$2" --argjson allow_openalias "$3" '{"jsonrpc":"2.0","id":"0","method":"validate_address","params":{"address":$address,"any_net_type":$any_net_type,"allow_openalias":$allow_openalias}}')
    rpc_call
}
# Function to set the daemon
set_daemon() {
    json_payload=$(jq -n --arg daemon_address "$1" --argjson trusted "$2" --arg ssl_support "$3" --arg ssl_private_key_path "$4" --arg ssl_certificate_path "$5" --arg ssl_ca_file "$6" --arg ssl_allowed_fingerprints "$7" --argjson ssl_allow_any_cert "$8" '{"jsonrpc":"2.0","id":"0","method":"set_daemon","params":{"address":$daemon_address,"trusted":$trusted,"ssl_support":$ssl_support,"ssl_private_key_path":$ssl_private_key_path,"ssl_certificate_path":"$ssl_certificate_path","ssl_ca_file":"$ssl_ca_file","ssl_allowed_fingerprints":["$ssl_allowed_fingerprints"],"ssl_allow_any_cert":$ssl_allow_any_cert}}')
    rpc_call
}

# Function to set log level
set_log_level() {
    json_payload=$(jq -n --arg level "$1" '{"jsonrpc":"2.0","id":"0","method":"set_log_level","params":{"level":$level}}')
    rpc_call
}

# Function to set log categories
set_log_categories() {
    json_payload=$(jq -n --arg categories "$1" '{"jsonrpc":"2.0","id":"0","method":"set_log_categories","params":{"categories":$categories}}')
    rpc_call
}

# Function to estimate transaction size and weight
estimate_tx_size_and_weight() {
    json_payload=$(jq -n --argjson n_inputs "$1" --argjson n_outputs "$2" --argjson rct "$3" '{"jsonrpc":"2.0","id":"0","method":"estimate_tx_size_and_weight","params":{"n_inputs":1,"n_outputs":2,"rct":true}}')
    rpc_call
}
# Function to get wallet version
get_version() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"get_version"}')
    rpc_call
}

# Function to setup background sync
setup_background_sync() {
    json_payload=$(jq -n --arg enable "$1" '{"jsonrpc":"2.0","id":"0","method":"setup_background_sync","params":{"enable":$enable}}')
    rpc_call
}

# Function to start background sync
start_background_sync() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"start_background_sync"}')
    rpc_call
}

# Function to stop background sync
stop_background_sync() {
    json_payload=$(jq -n '{"jsonrpc":"2.0","id":"0","method":"stop_background_sync"}')
    rpc_call
}
