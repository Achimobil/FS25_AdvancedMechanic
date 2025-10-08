--[[
Copyright (C) Achimobil, seit 2022

Author: Achimobil

Contact:
https://github.com/Achimobil/FS25_AdvancedMechanic


Important:
No copy and use in own mods allowed.

Das verändern und wiederöffentlichen, auch in Teilen, ist untersagt und wird abgemahnt.
]]
Logging.devInfo("AdvancedMechanic");
AdvancedMechanic = {};

-- Change torque multiplicator here
AdvancedMechanic.torqueScaleMultiplicator = 1.3;

-- DO NOT TOUCH CODE BELOW THIS LINE !!!

--- overwrite for Vehicle load
-- @param function superFunc the original function
function AdvancedMechanic:loadFinished(superFunc)
    local xmlFile = self.xmlFile;
    local rootName = xmlFile:getRootName();

    Logging.devInfo("AdvancedMechanic:loadFinished for %s", xmlFile.filename);

    -- alle mit TransmissionType DEFAULT anpassen auf schnelles schalten
    xmlFile:iterate(rootName..".motorized.motorConfigurations.motorConfiguration",function(_, key)
        local transmissionGroupTypeKey = key..".transmission.groups#type";
        local transmissionGroupType = xmlFile:getValue(transmissionGroupTypeKey);
        if transmissionGroupType == "DEFAULT" then

            local transmissionGroupTimeKey = key..".transmission.groups#changeTime";
            xmlFile:setValue(transmissionGroupTimeKey, 10);

            local transmissionAutoGearChangeTimeKey = key..".transmission#autoGearChangeTime";
            xmlFile:setValue(transmissionAutoGearChangeTimeKey, 10);

            local transmissionGearChangeTimeKey = key..".transmission#gearChangeTime";
            xmlFile:setValue(transmissionGearChangeTimeKey, 10);

            Logging.info("AdvancedMechanic changed to fast shift for %s", xmlFile.filename);
        end
    end)

    -- Drehmoment aller Motoren erhöhen
    xmlFile:iterate(rootName..".motorized.motorConfigurations.motorConfiguration",function(_, key)
        AdvancedMechanic.ChangeXmlValueByMultiplicator(xmlFile, key..".motor#torqueScale", AdvancedMechanic.torqueScaleMultiplicator);
    end)

    superFunc(self);
end

--- Method for multiply a value in the xmlFile at the given path
-- @param XMLFile xmlFile File to modify
-- @param string path Path to manipulate in the xmlFile
-- @param number multiplicator The Multiplicator to use
function AdvancedMechanic.ChangeXmlValueByMultiplicator(xmlFile, path, multiplicator)
    local oldValue = xmlFile:getValue(path);
    local newValue = oldValue * multiplicator;
    Logging.devInfo("AdvancedMechanic Change '%s' from %s to %s", path, oldValue, newValue);
    xmlFile:setValue(path, newValue);
end

Vehicle.loadFinished = Utils.overwrittenFunction(Vehicle.loadFinished, AdvancedMechanic.loadFinished)
