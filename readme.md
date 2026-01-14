**first step(1):**



go to your **es\_extended** and find **player.lua** file



**es\_extended\\server\\classes** <-- in this file is the **player.lua** file



in code find self.metadata = metadata (**ctrl + f** and paste this self.metadata = metadata )



when you find that code(self.metadata = metadata), put this one below it self.adminDuznost = false -- I repeat, put it below it, do not delete this code you found.





**next step(2):**



stay in the same file and find this:



function self.triggerEvent(eventName, ...)
    assert(type(eventName) == "string", "eventName should be string!") -- It may be different, but it is mostly similar, depending on the version of the extended
    TriggerClientEvent(eventName, self.source, ...)
end



also put this code below that:



self.staviDuznost = function(bool)
    self.adminDuznost = bool
end



self.proveriDuznost = function()
    return self.adminDuznost
end



and that's it :D



**I'll leave a link to the pictures here where you can see what it looks like for me:**

https://imgur.com/a/v5dX94S

https://drive.google.com/file/d/1bS3gX0OIMH4YZAcuSS7QGBn23vdVQtSk/view?usp=sharing

I put two links just in case one expires





**next step(3):**



**download** this https://github.com/tjscriptss/tj_communityservice for working community service for players


lazicdev -- discord