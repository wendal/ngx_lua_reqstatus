-- zheng-ji
--

local uri_args = ngx.req.get_uri_args()
local svrname_key = uri_args["domain"]
local keep = uri_args["keep"] ~= nil
local as_json = uri_args["format"] == "json"
if not svrname_key then
    ngx.print("host arg not found.")
    ngx.exit(ngx.HTTP_OK)
end

local reqmonit = require("reqmonit")
local count, avg, total_time, server_err_num, bytes_sent, request_length = reqmonit.analyse(ngx.shared.statics_dict, svrname_key, keep)
local qps = 0
if total_time > 0 then
    qps = count / total_time
end
if as_json then
	ngx.say("{")
	ngx.say("\"name\":", "\"", svrname_key, "\",")
	ngx.say("\"sinceLast\":", total_time, ",")
	--ngx.say("Average Req Time Sec:", avg, "\",")
	ngx.say("\"count\":", count, ",")
	ngx.say("\"qps\":", qps, ",")
	ngx.say("\"5xx\":\t", server_err_num, ",")
	ngx.say("\"sent\":\t", bytes_sent, ",")
	ngx.say("\"read\":\t", request_length)
	ngx.say("}")
else
	ngx.say("Server Name key:\t", svrname_key)
	ngx.say("Seconds SinceLast:\t", total_time)
	ngx.say("Average Req Time Sec:\t", avg)
	ngx.say("Request Count:\t", count)
	ngx.say("Requests Per Secs:\t", qps)
	ngx.say("5xx num:\t", server_err_num)
	ngx.say("Bytes Sent:\t", bytes_sent)
	ngx.say("Bytes Read:\t", request_length)
end