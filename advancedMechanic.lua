--[[
Copyright (C) Achimobil, seit 2022

Author: Achimobil

Contact:
https://github.com/Achimobil/FS25_AdvancedMechanic


Important:
No copy and use in own mods allowed.

Das verändern und wiederöffentlichen, auch in Teilen, ist untersagt und wird abgemahnt.
]]
-- Logging.info("AdvancedMechanic");
AdvancedMechanic = {};

-- Change torque multiplicator here
AdvancedMechanic.torqueScaleMultiplicator = 1.3;

-- DO NOT TOUCH CODE BELOW THIS LINE !!!

--- overwrite for Vehicle load
-- @param function superFunc the original function
function AdvancedMechanic:loadFinished(superFunc)
    local xmlFile = self.xmlFile;
    local rootName = xmlFile:getRootName();

--     Logging.info("AdvancedMechanic:loadFinished for %s", xmlFile.filename);

    -- alle mit TransmissionType DEFAULT anpassen auf schnelles schalten
    xmlFile:iterate(rootName..".motorized.motorConfigurations.motorConfiguration",function(_, key)
        local transmissionGroupTypeKey = key..".transmission.groups#type";
        local transmissionGroupType = xmlFile:getValue(transmissionGroupTypeKey);
        if transmissionGroupType == "DEFAULT" then

            local transmissionGroupTimeKey = key..".transmission.groups#changeTime";
            xmlFile:setValue(transmissionGroupTimeKey, 100);

            local transmissionAutoGearChangeTimeKey = key..".transmission#autoGearChangeTime";
            xmlFile:setValue(transmissionAutoGearChangeTimeKey, 100);

            local transmissionGearChangeTimeKey = key..".transmission#gearChangeTime";
            xmlFile:setValue(transmissionGearChangeTimeKey, 100);

--             Logging.info("AdvancedMechanic changed to fast shift for %s", xmlFile.filename);
        end
    end)

    -- Drehmoment aller Motoren erhöhen
    xmlFile:iterate(rootName..".motorized.motorConfigurations.motorConfiguration",function(_, key)
        AdvancedMechanic.ChangeXmlValueByMultiplicator(xmlFile, key..".motor#torqueScale", AdvancedMechanic.torqueScaleMultiplicator, "vehicle.motorized.motorConfigurations.motorConfiguration(0).motor#torqueScale");
    end)

    superFunc(self);
end

--- Method for multiply a value in the xmlFile at the given path
-- @param XMLFile xmlFile File to modify
-- @param string path Path to manipulate in the xmlFile
-- @param number multiplicator The Multiplicator to use
-- @param string fallbackPath Path to read when normal path is nil
function AdvancedMechanic.ChangeXmlValueByMultiplicator(xmlFile, path, multiplicator, fallbackPath)
    local oldValue = xmlFile:getValue(path);
    if oldValue == nil then
        oldValue = xmlFile:getValue(fallbackPath);
    end
    if oldValue == nil then
        Logging.warning("AdvancedMechanic path not found '%s' and '%s'", path, fallbackPath);
    end
    local newValue = oldValue * multiplicator;
--     Logging.info("AdvancedMechanic Change '%s' from %s to %s", path, oldValue, newValue);
    xmlFile:setValue(path, newValue);
end

Vehicle.loadFinished = Utils.overwrittenFunction(Vehicle.loadFinished, AdvancedMechanic.loadFinished)
