How to Add Admin Duty Feature in ESX (es_extended)
Step 1: Edit player.lua

Go to your es_extended folder and locate the player.lua file:

es_extended/server/classes/player.lua


Open the file and search for:

self.metadata = metadata


(Tip: use Ctrl + F to find it easily.)

Right below that line, add:

self.adminDuznost = false


⚠️ Do not delete the existing self.metadata = metadata line. Just add the new line right after it.

Step 2: Add Functions for Admin Duty

Stay in the same file (player.lua) and find this function:

function self.triggerEvent(eventName, ...)
    assert(type(eventName) == "string", "eventName should be string!") -- May vary by version
    TriggerClientEvent(eventName, self.source, ...)
end


Right below that function, add the following code:

self.staviDuznost = function(bool)
    self.adminDuznost = bool
end

self.proveriDuznost = function()
    return self.adminDuznost
end


✅ This will create functions to set and check admin duty status.

Step 3: Optional - Community Service Script

Download this script for a working community service feature for players:
https://github.com/tjscriptss/tj_communityservice

References

You can check how it looks in my setup using these links:

Imgur screenshots

Google Drive file

Discord: lazicdev
