debug_msg = function(override, message)
    if (debug or override) then
        print('debug: ', tostring(message))
    end
end