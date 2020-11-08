print_hello = function()
    print("Hi from utils land!")
end

debug_msg = function(override, message)
    if (debug or override) then
        print('debug: ', tostring(message))
    end
end