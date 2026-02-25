--waf core lib
require 'config'

config_output_illegal_html=[[
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="zh-cn" />
<title>辽宁移动</title>
</head>
<body>
<h1 align="center">MESSAGE
</body>
</html>
]] 


function get_first_split_text(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end

    local text
    if string.find(inputstr, ",") then
        local t = {}
        --local num =0
        for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
            table.insert(t, str)
            -- num=num+1
            break
        end
        text=t[1]
    else
        text=inputstr;
    end
    return text
end

function is_ipv6(str)
    local pattern = "^([%x:]+)$"
    return string.match(str, pattern) ~= nil
end

function is_ipv4(str)
    local nums = {}
    for num in string.gmatch(str, "%d+") do
        table.insert(nums, tonumber(num))
    end
    if #nums == 4 then
        for _, v in ipairs(nums) do
            if v < 0 or v > 255 then
                return false
            end
        end
        return true
    else
        return false
    end
end


function isInternalIP(ip)
    local parts = {}
    for word in string.gmatch(ip, "%d+") do
        table.insert(parts, tonumber(word))
    end

    local a, b, c, d = table.unpack(parts)

    -- 检查是否为内网地址
    if (a == 10) then
        return true
    elseif (a == 172 and b >= 16 and b <= 31) then
        return true
    elseif (a == 192 and b == 168) then
        return true
    elseif (a == 127) then
        return true
    end

    return false
end



--Get the client IP
function get_client_ip()

    local ms =  ngx.now() 
    local CLIENT_IP = ngx.req.get_headers()["X_real_ip"]

    log_print( CLIENT_IP,' X_real_ip '..ms)

    if CLIENT_IP == nil then
        CLIENT_IP = ngx.req.get_headers()["X_Forwarded_For"]
    end

    log_print( CLIENT_IP,' X_Forwarded_For '..ms)
    if CLIENT_IP == nil then
        CLIENT_IP  = ngx.var.remote_addr
    end

    log_print( CLIENT_IP,' remote_addr'..ms)
    if CLIENT_IP == nil then
        return "unknown"
    end

    if type(CLIENT_IP) ~= "string" then 

        if type(CLIENT_IP) == "table" then
            log_print(table.concat(CLIENT_IP),' get_client_ip err table '..ms)

            return CLIENT_IP[1]

        end 
 
        log_print( 'unknown',' get_client_ip err '..type(CLIENT_IP)..' '..ms)

        return "unknown"

    end 

    -- CLIENT_IP
    local  real_ip =  get_first_split_text(CLIENT_IP,",")

    log_print( real_ip,' get_client_ip real_ip ')

    return real_ip 
end



--Get the client user agent
function get_user_agent()
    USER_AGENT = ngx.var.http_user_agent
    if USER_AGENT == nil then
       USER_AGENT = "unknown"
    end
    return USER_AGENT
end

--Get WAF rule
function get_rule(rulefilename)

    --log_print(rulefilename," get_rule")

    local io = require 'io'
    local RULE_PATH = config_rule_dir
    local RULE_FILE = io.open(RULE_PATH..'/'..rulefilename,"r")

    log_print(RULE_PATH..'/'..rulefilename," get_rule")

    if RULE_FILE == nil then
        return
    end
    local RULE_TABLE = {}
    for line in RULE_FILE:lines() do
        table.insert(RULE_TABLE,line)
    end
    RULE_FILE:close()

    return(RULE_TABLE)
end

--WAF log record for json,(use logstash codec => json)
function log_record(method,url,data,ruletag)
    local cjson = require("cjson")
    local io = require 'io'
    local LOG_PATH = config_log_dir
    local CLIENT_IP = get_client_ip()
    local USER_AGENT = get_user_agent()
    local SERVER_NAME = ngx.var.server_name
    local LOCAL_TIME = ngx.localtime()
    local log_json_obj = {
                 client_ip = CLIENT_IP,
                 local_time = LOCAL_TIME,
                 server_name = SERVER_NAME,
                 user_agent = USER_AGENT,
                 attack_method = method,
                 req_url = url,
                 req_data = data,
                 rule_tag = ruletag,
              }
    local LOG_LINE = cjson.encode(log_json_obj)
    local LOG_NAME = LOG_PATH..'/'..ngx.today().."_waf.log"
    local file = io.open(LOG_NAME,"a")
    if file == nil then
        return
    end
    file:write(LOG_LINE.."\n")
    file:flush()
    file:close()
end

function log_record_simple(tag , data)
     
    -- local REQ_URI = ngx.var.request_uri
    -- local LOG_PATH = config_log_dir
    -- local LOG_NAME = LOG_PATH..'/'..tag..'_'..ngx.today()..".log"
    -- local file = io.open(LOG_NAME,"a")
    -- if file == nil then
    --     return
    -- end
    -- file:write(os.date("[%Y-%m-%d %H:%M:%S] ")..data..' '..REQ_URI.."\n")
    -- file:flush()
    -- file:close()

    ngx.log(ngx.ERR, ' { WAF:'..tag..' | '..data..' }')

end

--WAF return
function waf_output()
    if config_waf_output == "redirect" then
        ngx.redirect(config_waf_redirect_url, 301)
    else
        ngx.header.content_type = "text/html"
        ngx.status = ngx.HTTP_FORBIDDEN
        ngx.say(config_output_html)
        ngx.exit(ngx.status)
    end
end

function waf_illegal_output(status,message)
     ngx.header.content_type = "text/html" 
     local  content = string.gsub(config_output_illegal_html,"MESSAGE",message)
     ngx.say(content)
     ngx.exit(status)
end

function log_print(message , scene)
    local content = message;
    local flag = scene

    if type(content) == "table" then

            --ngx.log(ngx.ERR, table.concat(content," == "),flag)

            return 
    end


    --ngx.log(ngx.ERR, content,flag)
    
end