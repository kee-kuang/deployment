require 'init'
require 'lib'

local rulematch = ngx.re.find

function waf_main()

  

    local REQ_URI = ngx.var.uri
    if rulematch(REQ_URI,"\\.(js|css|png|jpg|jpeg|gif|ico|JPEG|mp4|PNG|TTF|woff｜json|js.gz|css.gz|html.gz|cgi)$","jo") then
        log_print( REQ_URI," ignore suffix")
        return 
    end


    
    local WHITE_IP = get_client_ip()
    if isInternalIP(WHITE_IP) then 
        log_print( WHITE_IP," isInternalIP" )
        return 
    end

 
 
    if black_ip_check() then
    elseif white_url_check() then
    elseif white_ip_check() then
    elseif user_agent_attack_check() then
    elseif cc_attack_check() then
   -- elseif cookie_attack_check() then
    --elseif white_url_check() then
    elseif url_attack_check() then
    elseif url_args_attack_check() then
   -- elseif post_attack_check() then
    else
        return
    end
end

waf_main()

