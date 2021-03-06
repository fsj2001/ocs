%%% mod_ocs_rest_accepted_content.erl
%%% vim: ts=3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% @copyright 2016 - 2017 SigScale Global Inc.
%%% @end
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
-module(mod_ocs_rest_accepted_content).
-copyright('Copyright (c) 2016 - 2017 SigScale Global Inc.').

-export([do/1]).

-include_lib("inets/include/httpd.hrl").

-spec do(ModData) -> Result when
	ModData :: #mod{},
	Result :: {proceed, OldData} | {proceed, NewData} | {break, NewData} | done,
	OldData :: list(),
	NewData :: [{response,{StatusCode,Body}}] | [{response,{response,Head,Body}}]
			| [{response,{already_sent,StatusCode,Size}}],
	StatusCode :: integer(),
	Body :: iolist() | nobody | {Fun, Arg},
	Head :: [HeaderOption],
	HeaderOption :: {Option, Value} | {code, StatusCode},
	Option :: accept_ranges | allow
			| cache_control | content_MD5
			| content_encoding | content_language
			| content_length | content_location
			| content_range | content_type | date
			| etag | expires | last_modified
			| location | pragma | retry_after
			| server | trailer | transfer_encoding,
	Value :: string(),
	Size :: term(),
	Fun :: fun((Arg) -> sent| close | Body),
	Arg :: [term()].
% % @doc Erlang web server API callback function.
do(#mod{method = Method, parsed_header = Headers, request_uri = Uri,
		data = Data} = _ModData) ->
	case proplists:get_value(status, Data) of
		{_StatusCode, _PhraseArgs, _Reason} ->
			{proceed, Data};
		undefined ->
			case proplists:get_value(response, Data) of
				undefined ->
					Path = http_uri:decode(Uri),
					case string:tokens(Path, "/?") of
						["ocs", "v1", "client"] ->
							check_content_type_header(Headers, Method, ocs_rest_res_client, Data);
						["ocs", "v1", "client", _Id] ->
							check_content_type_header(Headers, Method, ocs_rest_res_client, Data);
						["ocs", "v1", "log", "ipdr"] ->
							check_content_type_header(Headers, Method, ocs_rest_res_usage, Data);
						["ocs", "v1", "log", "ipdr", _Id] ->
							check_content_type_header(Headers, Method, ocs_rest_res_usage, Data);
						["ocs", "v1", "log", "http"] ->
							check_content_type_header(Headers, Method, ocs_rest_res_http, Data);
						["ocs", "v1", "log", "balance"] ->
							check_content_type_header(Headers, Method, ocs_rest_res_balance, Data);
						["ocs", "v1", "log", "balance" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_balance, Data);
						["usageManagement", "v1", "usage"] ->
							check_content_type_header(Headers, Method, ocs_rest_res_usage, Data);
						["usageManagement", "v1", "usage" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_usage, Data);
						["usageManagement", "v1", "usageSpecification" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_usage, Data);
						["partyManagement", "v1", "individual"] ->
							check_content_type_header(Headers, Method, ocs_rest_res_user, Data);
						["partyManagement", "v1", "individual", _Id] ->
							check_content_type_header(Headers, Method, ocs_rest_res_user, Data);
						["balanceManagement", "v1", "product",_Id, "balanceTopup"] ->
							check_content_type_header(Headers, Method, ocs_rest_res_balance, Data);
						["balanceManagement", "v1", "service",_Id, "balanceTopup"] ->
							check_content_type_header(Headers, Method, ocs_rest_res_balance, Data);
						["balanceManagement", "v1", "bucket" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_balance, Data);
						["balanceManagement", "v1", "product", _, "bucket" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_balance, Data);
						["balanceManagement", "v1", "product", _Id, "accumulatedBalance"] ->
							check_content_type_header(Headers, Method, ocs_rest_res_balance, Data);
						["balanceManagement", "v1", "service", _Id, "accumulatedBalance"] ->
							check_content_type_header(Headers, Method, ocs_rest_res_balance, Data);
						["balanceManagement", "v1", "balanceAdjustment"] ->
							check_content_type_header(Headers, Method, ocs_rest_res_balance, Data);
						["catalogManagement", "v2", "productOffering" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_product, Data);
						["catalogManagement", "v2", "catalog" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_product, Data);
						["catalogManagement", "v2", "category" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_product, Data);
						["catalogManagement", "v2", "productSpecification" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_product, Data);
						["catalogManagement", "v2", "plaSpecification" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_resource, Data);
						["catalogManagement", "v2", "pla" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_resource, Data);
						["productInventoryManagement", "v2", "product" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_product, Data);
						["productInventoryManagement", "schema", "OCS.yml" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_product, Data);
						["catalogManagement", "v2", "resourceSpecification" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_resource, Data);
						["catalogManagement", "v2", "resourceCandidate" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_resource, Data);
						["catalogManagement", "v2", "resourceCatalog" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_resource, Data);
						["catalogManagement", "v2", "resourceCategory" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_resource, Data);
						["resourceInventoryManagement", "v1", "logicalResource" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_resource, Data);
						["resourceInventoryManagement", "v1", "pla" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_resource, Data);
						["catalogManagement", "v2", "serviceSpecification" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_service, Data);
						["serviceInventoryManagement", "v2", "service" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_service, Data);
						["serviceInventoryManagement", "schema", "OCS.yml" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_service, Data);
						["productCatalogManagement", "v2", "productSpecification"] ->
							check_content_type_header(Headers, Method, ocs_rest_res_product, Data);
						["resourceCatalogManagement", "v2", "plaSpecification" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_resource, Data);
						["resourceCatalogManagement", "v2", "resourceSpecification" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_resource, Data);
						["serviceCatalogManagement", "v2", "serviceSpecification" | _] ->
							check_content_type_header(Headers, Method, ocs_rest_res_service, Data);
						_ ->
							{proceed, Data}
					end;
				_ ->
					{proceed,  Data}
			end
	end.

%% @hidden
check_content_type_header(Headers, Method, Module, Data) ->
	case lists:keyfind("content-type", 1, Headers) of
		false when Method == "DELETE"; Method == "GET" ->
			check_accept_header(Headers, Module, [{resource, Module} | Data]);
		{_, []} when Method == "DELETE"; Method == "GET" ->
			check_accept_header(Headers, Module, [{resource, Module} | Data]);
		{_, ProvidedType} ->
			AcceptedTypes = Module:content_types_accepted(),
			case lists:member(ProvidedType, AcceptedTypes) of
				true ->
					check_accept_header(Headers, Module, [{resource, Module},
							{content_type,  ProvidedType} | Data]);
				false ->
					Response = "<h2>HTTP Error 415 - Unsupported Media Type</h2>",
					{proceed, [{response, {415, Response}} | Data]}
			end;
		false ->
			Response = "<h2>HTTP Error 400 - Bad Request</h2>",
			{proceed, [{response, {400, Response}} | Data]}
	end.

%% @hidden
check_accept_header(Headers, Module, Data) ->
	case lists:keyfind("accept", 1, Headers) of
		{_, AcceptType} ->
			Representations = Module:content_types_provided(),
			case lists:member(AcceptType, Representations) of
				true ->
					{proceed, [{accept, AcceptType} | Data]};
				false ->
					Response = "<h2>HTTP Error 415 - Unsupported Media Type</h2>",
					{proceed, [{response, {415, Response}} | Data]}
			end;
		false ->
			{proceed, Data}
	end.

