# bitcoin-core.daemon -conf=$(pwd)/bitcoin.conf -datadir=$(pwd)/bitcoin_data --port=18444

dfx start --enable-bitcoin --background --clean

dfx deploy --specified-id ml52i-qqaaa-aaaar-qaaba-cai ckbtc_minter --argument '(variant{
	Init = record {
		btc_network = variant { Regtest };
		ledger_id = principal "mc6ru-gyaaa-aaaar-qaaaq-cai";
		ecdsa_key_name = "dfx_test_key";
		retrieve_btc_min_amount = 10_000;
		max_time_in_queue_nanos = 10_000_000_000;
		min_confirmations = opt 1;
		mode = variant { GeneralAvailability };
		kyt_fee = opt 100;
		kyt_principal = opt principal "pvm5g-xaaaa-aaaar-qaaia-cai"                
	}
})'

PRINCIPAL="$(dfx identity get-principal)"

dfx deploy --specified-id mc6ru-gyaaa-aaaar-qaaaq-cai ckbtc_ledger --argument '(variant{
	Init = record{
		token_symbol = "ckBTC";
		token_name = "ckBTC";
		minting_account = record { owner = principal "ml52i-qqaaa-aaaar-qaaba-cai" };
		transfer_fee = 10;
		metadata = vec {};
		max_memo_length = opt 80;
		initial_balances = vec {};
		archive_options = record {
			num_blocks_to_archive = 10_000;
			trigger_threshold = 20_000;
			controller_id = principal "'$PRINCIPAL'";
			cycles_for_archive_creation = opt 1_000_000_000_000;
			max_message_size_bytes = null;
			node_max_memory_size_bytes = opt 3_221_225_472;
		};
		feature_flags = opt record { icrc2 = true };
	}
})'

dfx deploy --specified-id pvm5g-xaaaa-aaaar-qaaia-cai ckbtc_kyt --argument '(variant{
	InitArg = record {
		api_key = "";
		minter_id = principal "ml52i-qqaaa-aaaar-qaaba-cai";
		maintainers = vec {principal "'$PRINCIPAL'" };
		mode = variant { AcceptAll };
	}
})'

dfx canister call ckbtc_kyt set_api_key '(record { api_key = "" })'

dfx deploy --specified-id mm444-5iaaa-aaaar-qaabq-cai ckbtc_index --argument '(opt variant{
	Init = record{
		ledger_id = principal "mc6ru-gyaaa-aaaar-qaaaq-cai";
	}
})'

dfx deploy --specified-id vxkom-oyaaa-aaaar-qafda-cai ckbtc_converter --argument 'true'

dfx ledger fabricate-cycles --canister vxkom-oyaaa-aaaar-qafda-cai --cycles 10_000_000_000_000 # 10T

# dfx deploy --specified-id 6fwhw-fyaaa-aaaap-qb7ua-cai schnorr_canister

# dfx canister call ckbtc_converter dynamonium_ckbtc_get_address '(vec { principal "ayr2v-v5ute-m3knd-ex52m-bczjv-2mrom-n22o4-v5t2o-hpxso-e7zdb-6ae" })'

# dfx canister call ckbtc_converter dynamonium_ckbtc_generate_address