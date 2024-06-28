--WAF Action
require 'config'
require 'lib' 

--args
local rulematch = ngx.re.find
local unescape = ngx.unescape_uri

local cclimit = ngx.shared.cclimit
local my_whiteips_cached = ngx.shared.whiteips
local my_blackips_cached = ngx.shared.blackips

function white_ip_ignore_url_check()

    local REQ_URI = ngx.var.uri
    log_print(REQ_URI," white_ip_ignore_url_check starting ") 
    if WHITE_IP_IGNORE_URL_RULES ~= nil then
        for _,rule in pairs(WHITE_IP_IGNORE_URL_RULES) do
            if rule ~= "" and rulematch(REQ_URI,rule,"jo") then
                log_print( REQ_URI," white_ip_ignore_url_check true")
                return true
            end
        end
    end
    log_print( REQ_URI," white_ip_ignore_url_check false")
    return false 
end

--allow white ip
function white_ip_check()
     if config_white_ip_check == "on" then

        local uuid =  ngx.now() 
        if white_ip_ignore_url_check() then
            return false ;
        end 

        local client_ip = get_client_ip()
        log_print( client_ip," white_ip_check "..uuid)

        if client_ip == "unknown" then
            return false 
        end

        if is_ipv6(client_ip) then
            return false 
        end


        if is_ipv4(client_ip) then

            if isInternalIP(client_ip) then
                log_print( client_ip," white_ip_check isInternalIP "..uuid)
                return false 
            end

            local o1, o2, o3, o4 = client_ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")
            local ip_address = o1..'.'..o2..'.'..o3..'.'

            log_print(ip_address," white_ip_check ip_address C  "..uuid)

            local is_match = my_whiteips_cached:get(ip_address)
        
            log_print( is_match," white_ip_check is_match "..uuid)

            if is_match ~= nil then
                return false
            end

            log_print( client_ip," is intercept white_ip_check "..uuid)
            log_record_simple("whiteip",client_ip)

            --waf_illegal_output(403,"系统繁忙,稍后在试1")
            ngx.redirect(config_waf_white_ip_redirect_url, 301)

            return true 

        end 

        log_print( client_ip," white_ip_check is not ipv4 "..uuid)
        log_record_simple("whiteip",client_ip)

        --waf_illegal_output(403,"系统繁忙,稍后在试1")
         ngx.exit(403) 
    
        return true 
        
    end
end



--deny black ip
function black_ip_check()
     if config_black_ip_check == "on" then 

        local REQ_URI=ngx.var.uri
        if rulematch(REQ_URI,"waf.do$","jo")  then
            log_print(REQ_URI,' black_ip_check ignore') 
            return false 
        end 


        local BLACK_IP = get_client_ip()

        local is_match = my_blackips_cached:get(BLACK_IP)
        log_print( is_match,BLACK_IP.." black_ip_check is_match")

        if is_match ~= nil then

            local nowCoun,err = cclimit:get(BLACK_IP)
            if nowCoun == nil  then
                nowCoun = 0
            end 
            log_record_simple("blackip",BLACK_IP ..' cc_attack_counter num='..tostring(nowCoun) )
            ngx.exit(403)
            return true
        end

    end
    return false  
end


--allow white url
function white_url_check()
    if config_white_url_check == "on" then 
        local REQ_URI = ngx.var.uri
        if URL_WHITE_RULES ~= nil then
            for _,rule in pairs(URL_WHITE_RULES) do
                if rule ~= "" and rulematch(REQ_URI,rule,"jo") then
                    log_print( REQ_URI," white_url_check true ")
                    return true
                end
            end
        end
    end

    return false 
end

 
-- function is_cc_attack_on()

--     local client_ip = get_client_ip();
--     if CC_ATTACK_IP_RULES == nil then
--         return false 
--     end

--     local ischeck=false
--     for _,ip in pairs(CC_ATTACK_IP_RULES) do
--         if ip == client_ip  then
--             ischeck = true 
--             break
--         end
--     end

--     log_print(CC_TOKEN,' cc_attack_check ischeck '..tostring(ischeck))
--     if ischeck == false then 
--         log_print(CC_TOKEN,' cc_attack_check ischeck = false xx ') 
--         return false 
--     end 

--     return true 
   
-- end
--deny cc attack



function cc_attack_ignore_url_check()

    local REQ_URI = ngx.var.uri
    log_print(REQ_URI," white_ip_ignore_url_check starting ") 
    if CC_ATTACK_URL_RULES ~= nil then
        for _,rule in pairs(CC_ATTACK_URL_RULES) do
            if rule ~= "" and rulematch(REQ_URI,rule,"jo") then
                log_print( REQ_URI," cc_attack_ignore_url_check true")
                return true
            end
        end
    end
    log_print( REQ_URI," cc_attack_ignore_url_check false")
    return false 
end

function cc_attack_check()

   

    if config_cc_check == "on" then


        local uuid =  ngx.now() 
        local ATTACK_URI=ngx.var.uri
        local client_ip = get_client_ip()
        local CC_TOKEN = client_ip

        if rulematch(ATTACK_URI,"\\.(html|jsp)$","jo")  then
            log_print(CC_TOKEN,' cc_attack_check is html '..uuid) 
            return false 
        end 

        if cc_attack_ignore_url_check() then
            log_print(CC_TOKEN,' cc_attack_check white url '..uuid) 
            return false 
        end


        local CCcount = tonumber(string.match(config_cc_rate,'(.*)/'))
        local CCseconds=tonumber(string.match(config_cc_rate,'/(.*)'))

        log_print(CC_TOKEN,' cc_attack_check CCcount = '.. tostring(CCcount) .. ' CCseconds='..tostring(CCseconds)..' '..uuid ) 

        local nowCount,errMsg
        local success,err = cclimit:add(CC_TOKEN,1,CCseconds)
        if success then
            nowCount = 1 
        else
            local newval,err = cclimit:incr(CC_TOKEN,1)
            nowCount = newval
            errMsg = err
        end

        if nowCount == nil then 
            log_print(CC_TOKEN,' cc_attack_check err'..tostring(err)..' '..uuid  ) 
            return false 
        end 

        --log_print(CC_TOKEN,' cc_attack_check success='..tostring(success)..'  nowCount = '.. tostring(nowCount) ..' '..uuid  ) 
    
        log_record_simple('cc_attack_counter',' num='..nowCount..' ip='..client_ip )
        if nowCount > CCcount then 

            local black_success,black_err = my_blackips_cached:add(client_ip,1,10080)
            if black_success ~= nil then
                log_record_simple('CC_Attack',' num='..nowCount..' '..client_ip..' '..tostring(black_success) )
            end

            ngx.exit(403)
            
            return true
            
        end 

    end

    return false

end

--deny cookie
function cookie_attack_check()
    if config_cookie_check == "on" then
        local COOKIE_RULES = get_rule('cookie.rule')
        local USER_COOKIE = ngx.var.http_cookie
        if USER_COOKIE ~= nil then
            for _,rule in pairs(COOKIE_RULES) do
                if rule ~="" and rulematch(USER_COOKIE,rule,"jo") then
                    log_record('Deny_Cookie',ngx.var.request_uri,"-",rule)
                    if config_waf_enable == "on" then
                        waf_output()
                        return true
                    end
                end
             end
	 end
    end
    return false
end

--deny url
function url_attack_check()
    if config_url_check == "on" then
        local URL_RULES = get_rule('url.rule')
        local REQ_URI = ngx.var.request_uri
        for _,rule in pairs(URL_RULES) do
            if rule ~="" and rulematch(REQ_URI,rule,"jo") then
                log_record('Deny_URL',REQ_URI,"-",rule)
                if config_waf_enable == "on" then
                    waf_output()
                    return true
                end
            end
        end
    end
    return false
end

--deny url args
function url_args_attack_check()

    log_print( config_url_args_check," url_args_attack_check config")

    if config_url_args_check == "on" then
        
        if ARGS_RULES == nil then
            log_print("nil"," url_args_attack_check ARGS_RULES")
            return false 
        end

        log_print( ARGS_RULES[1]," url_args_attack_check ARGS_RULES")
       
        for _,rule in pairs(ARGS_RULES) do
            local REQ_ARGS = ngx.req.get_uri_args()
            for key, val in pairs(REQ_ARGS) do
                if type(val) == 'table' then
                    ARGS_DATA = table.concat(val, " ")
                else
                    ARGS_DATA = val
                end

                log_print(ARGS_DATA," url_args_attack_check ARGS_DATA")
                
                if ARGS_DATA and type(ARGS_DATA) ~= "boolean" and rule ~="" and rulematch(unescape(ARGS_DATA),rule,"jo") then
                    log_record_simple('Deny_URL_Args',ngx.var.request_uri..' '..unescape(ARGS_DATA)..' '..rule)
                    if config_waf_enable == "on" then
                        waf_output()
                        return true
                    end
                end
            end
        end
    end

    return false
end
--deny user agent
function user_agent_attack_check()

    log_print( config_user_agent_check," user_agent_attack_check")

    if config_user_agent_check == "on" then
        
        local USER_AGENT = ngx.var.http_user_agent
        if USER_AGENT_RULES == nil then
            return false 
        end

        if USER_AGENT ~= nil then
            for _,rule in pairs(USER_AGENT_RULES) do
                if rule ~="" and rulematch(USER_AGENT,rule,"jo") then
                    log_record('Deny_USER_AGENT',ngx.var.request_uri,"-",rule)
                    if config_waf_enable == "on" then
                        waf_output()
                        return true
                    end
                end
            end
        end
    end
    return false
end

--deny post
function post_attack_check()
    if config_post_check == "on" then
        local POST_RULES = get_rule('post.rule')
        for _,rule in pairs(ARGS_RULES) do
            local POST_ARGS = ngx.req.get_post_args()
        end
        return true
    end
    return false
end




function load_rule_config()
    ngx.log(ngx.ERR, " load load_rule_config starting! ")


    ARGS_RULES = get_rule('args.rule')
    if ARGS_RULES ~= nil then 
        log_print( table.concat(ARGS_RULES,"\n")," init ARGS_RULES")
    end 

    URL_WHITE_RULES = get_rule('whiteurl.rule')
    if URL_WHITE_RULES ~= nil then 
        log_print( table.concat(URL_WHITE_RULES,"\n")," init URL_WHITE_RULES")
    end 

    USER_AGENT_RULES = get_rule('useragent.rule')
    if USER_AGENT_RULES ~= nil then 
        log_print( table.concat(USER_AGENT_RULES,"\n")," init USER_AGENT_RULES")
    end 

     
    WHITE_IP_IGNORE_URL_RULES =get_rule('whiteipignoreurl.rule') 
    if WHITE_IP_IGNORE_URL_RULES ~= nil then 
        log_print( table.concat(WHITE_IP_IGNORE_URL_RULES,"\n")," init WHITE_IP_IGNORE_URL_RULES")
    end 


  

     CC_ATTACK_URL_RULES =get_rule('ccattackurl.rule') 
     if CC_ATTACK_URL_RULES ~= nil then 
         log_print( table.concat(CC_ATTACK_URL_RULES,"\n")," init CC_ATTACK_URL_RULES")
     end 


    -- CC_ATTACK_IP_RULES =get_rule('ccattackip.rule') 
    -- if CC_ATTACK_IP_RULES ~= nil then 
    --     log_print( table.concat(CC_ATTACK_IP_RULES,"\n")," init CC_ATTACK_IP_RULES")
    -- end 

 

    ngx.log(ngx.ERR, " load load_rule_config finished! ")

end 
 
 
function load_black_ip_cached() 
   ngx.log(ngx.ERR, "load blackip.lua starting! ")

   my_blackips_cached:set("whiteips","2")
   my_blackips_cached:set("127.0.0.","1")

   IP_BLACK_RULES =  get_rule("blackip.rule")

   if IP_BLACK_RULES == nil then
        ngx.log(ngx.ERR, " IP_BLACK_RULES IS EMPTY ")
        return 
   end

   for _,rule in pairs(IP_BLACK_RULES) do

        if rule ~= "" then 
            my_blackips_cached:set(rule,"1")
        end 

   end

   ngx.log(ngx.ERR, " load blackip.lua finished! ")

end 

function load_white_ip_cached() 
   ngx.log(ngx.ERR, "load whiteip.lua starting! ")

   my_whiteips_cached:set("whiteips","2")
   my_whiteips_cached:set("127.0.0.","1")

   local IP_WHITE_RULES =  get_rule("whiteip.rule")

   if IP_WHITE_RULES == nil then
        ngx.log(ngx.ERR, " IP_WHITE_RULES IS EMPTY ")
        return 
   end

   for _,rule in pairs(IP_WHITE_RULES) do

        if rule ~= "" then 
            my_whiteips_cached:set(rule,"1")
        end 

   end

   ngx.log(ngx.ERR, " load whiteip.lua finished! ")

end 


load_rule_config()
load_white_ip_cached()
load_black_ip_cached()

ngx.log(ngx.ERR, "init.lua process= "..ngx.worker.pid()) 

if ngx.worker.id() ~= nil then
    ngx.log(ngx.ERR, "init.lua process id = ".. ngx.worker.id()) 
else 
    ngx.log(ngx.ERR, "init.lua process id = nil ") 
end 



