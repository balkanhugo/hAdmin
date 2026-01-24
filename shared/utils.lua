-- =================================
-- SHARED UTILITY FUNCTIONS
-- =================================

-- Check if a player group has admin permissions
function IsAdmin(group)
    if not group then return false end
    return Config.Groups.index[group] and Config.Groups.index[group] > Config.Groups.index['user']
end

-- Check if a player has a specific permission
function HasPermission(playerGroup, permission)
    if not playerGroup or not permission then return false end
    
    local allowedGroups = Config.Permissions[permission]
    if not allowedGroups then return false end
    
    for _, group in ipairs(allowedGroups) do
        if playerGroup == group then
            return true
        end
    end
    
    return false
end

-- Get all admin groups
function GetAdminGroups()
    local adminGroups = {}
    for _, group in ipairs(Config.Groups.order) do
        if group ~= Config.Groups.default then
            table.insert(adminGroups, group)
        end
    end
    return adminGroups
end

-- Check if one group is higher than another
function IsGroupHigher(group1, group2)
    local index1 = Config.Groups.index[group1] or 0
    local index2 = Config.Groups.index[group2] or 0
    return index1 > index2
end

-- Check if one group is lower than another
function IsGroupLower(group1, group2)
    local index1 = Config.Groups.index[group1] or 0
    local index2 = Config.Groups.index[group2] or 0
    return index1 < index2
end

-- Get group label
function GetGroupLabel(group)
    return Config.Groups.labels[group] or group
end

-- Validate if a group exists
function IsValidGroup(group)
    return Config.Groups.index[group] ~= nil
end

-- Get permission level (numerical value)
function GetPermissionLevel(group)
    return Config.Groups.index[group] or 0
end
