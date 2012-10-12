// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Shared.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Put any classes that are used on both the client and server here.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

math.randomseed(Shared.GetSystemTime())
// math.random() is more random the more you call it. Don't ask.
for i = 1, 100 do math.random() end

// Utility and constants
Script.Load("lua/Globals.lua")
Script.Load("lua/DamageTypes.lua")
Script.Load("lua/Debug.lua")
Script.Load("lua/CollisionRep.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/Actor.lua")
Script.Load("lua/AnimatedModel.lua")
Script.Load("lua/Vector.lua")
Script.Load("lua/Table.lua")
Script.Load("lua/Entity.lua")
Script.Load("lua/Effects.lua")
Script.Load("lua/NetworkMessages.lua")
Script.Load("lua/TechTreeConstants.lua")
Script.Load("lua/TechData.lua")
Script.Load("lua/TechNode.lua")
Script.Load("lua/TechTree.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Order.lua")
Script.Load("lua/PropDynamic.lua")
Script.Load("lua/Blip.lua")
Script.Load("lua/MapBlip.lua")
Script.Load("lua/ParticleEffect.lua")
Script.Load("lua/SensorBlip.lua")
Script.Load("lua/SoundEffect.lua")
Script.Load("lua/TrackYZ.lua")
Script.Load("lua/TeamMessenger.lua")
Script.Load("lua/TokenBucket.lua")
Script.Load("lua/RingBuffer.lua")
Script.Load("lua/BuildUtility.lua")

Script.Load("lua/Balance.lua")
Script.Load("lua/BalanceHealth.lua")
Script.Load("lua/BalanceMisc.lua")

Script.Load("lua/TeamJoin.lua")

// Neutral structures
Script.Load("lua/ResourcePoint.lua")
Script.Load("lua/ResourceTower.lua")
Script.Load("lua/Door.lua")
Script.Load("lua/Reverb.lua")
Script.Load("lua/Location.lua")
Script.Load("lua/Trigger.lua")
Script.Load("lua/Ladder.lua")
Script.Load("lua/MinimapExtents.lua")
Script.Load("lua/DeathTrigger.lua")
Script.Load("lua/TimedEmitter.lua")
Script.Load("lua/Gamerules.lua")
Script.Load("lua/NS2Gamerules.lua")
Script.Load("lua/TechPoint.lua")
Script.Load("lua/BaseSpawn.lua")
Script.Load("lua/ReadyRoomSpawn.lua")
Script.Load("lua/Pheromone.lua")
Script.Load("lua/Weapons/ViewModel.lua")

// Marine structures
Script.Load("lua/MAC.lua")
Script.Load("lua/Mine.lua")
Script.Load("lua/Extractor.lua")
Script.Load("lua/Armory.lua")
Script.Load("lua/ArmsLab.lua")
Script.Load("lua/Observatory.lua")
Script.Load("lua/PhaseGate.lua")
Script.Load("lua/RoboticsFactory.lua")
Script.Load("lua/PrototypeLab.lua")
Script.Load("lua/CommandStructure.lua")
Script.Load("lua/CommandStation.lua")
Script.Load("lua/Sentry.lua")
Script.Load("lua/ARC.lua")
Script.Load("lua/InfantryPortal.lua")
Script.Load("lua/DropPack.lua")
Script.Load("lua/AmmoPack.lua")
Script.Load("lua/MedPack.lua")
Script.Load("lua/CatPack.lua")
Script.Load("lua/Effect.lua")
Script.Load("lua/AmbientSound.lua")
Script.Load("lua/Particles.lua")

// Alien Comm Abilities
Script.Load("lua/CommAbilities/Alien/CragUmbra.lua")
Script.Load("lua/CommAbilities/Alien/CragBabblers.lua")
Script.Load("lua/Babbler.lua")
Script.Load("lua/CommAbilities/Alien/ShadeInk.lua")

// Alien structures
Script.Load("lua/Harvester.lua")
Script.Load("lua/Infestation.lua")
Script.Load("lua/Hive.lua")
Script.Load("lua/Shell.lua")
Script.Load("lua/Crag.lua")
Script.Load("lua/WhipBomb.lua")
Script.Load("lua/Whip.lua")
Script.Load("lua/Veil.lua")
Script.Load("lua/Shift.lua")
Script.Load("lua/Spur.lua")
Script.Load("lua/Shade.lua")
Script.Load("lua/Hydra.lua")
Script.Load("lua/Clog.lua")
Script.Load("lua/Cyst.lua")
Script.Load("lua/Drifter.lua")
Script.Load("lua/Egg.lua")
Script.Load("lua/Embryo.lua")
Script.Load("lua/Hallucination.lua")

// Base players
Script.Load("lua/ReadyRoomPlayer.lua")
Script.Load("lua/Spectator.lua")
Script.Load("lua/FilmSpectator.lua")
Script.Load("lua/AlienSpectator.lua")
Script.Load("lua/MarineSpectator.lua")
Script.Load("lua/Ragdoll.lua")
Script.Load("lua/MarineCommander.lua")
Script.Load("lua/AlienCommander.lua")

// Character class behaviors
Script.Load("lua/Marine.lua")
Script.Load("lua/JetpackMarine.lua")
Script.Load("lua/Exosuit.lua") // pickupable version
Script.Load("lua/Exo.lua")
Script.Load("lua/Skulk.lua")
Script.Load("lua/Gorge.lua")
Script.Load("lua/Lerk.lua")
Script.Load("lua/Fade.lua")
Script.Load("lua/Onos.lua")

// Weapons
Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/Weapons/Marine/Rifle.lua")
Script.Load("lua/Weapons/Marine/Pistol.lua")
Script.Load("lua/Weapons/Marine/Shotgun.lua")
Script.Load("lua/Weapons/Marine/Axe.lua")
Script.Load("lua/Weapons/Marine/Minigun.lua")
Script.Load("lua/Weapons/Marine/Claw.lua")
Script.Load("lua/Weapons/Marine/GrenadeLauncher.lua")
Script.Load("lua/Weapons/Marine/Flamethrower.lua")
Script.Load("lua/Weapons/Marine/LayMines.lua")
Script.Load("lua/Weapons/Marine/Welder.lua")
Script.Load("lua/Jetpack.lua")

Script.Load("lua/PowerPoint.lua")
Script.Load("lua/SentryBattery.lua")
Script.Load("lua/Sayings.lua")
Script.Load("lua/NS2Utility.lua")
Script.Load("lua/WeaponUtility.lua")
Script.Load("lua/TeamInfo.lua")
Script.Load("lua/GameInfo.lua")
Script.Load("lua/AlienTeamInfo.lua")
Script.Load("lua/PathingUtility.lua")
Script.Load("lua/DAKLoader.lua")

gHeightMap = gHeightMap // survive hotloading; will be nil the first time

local function LoadHeightmap()

    // Load height map
    gHeightMap = HeightMap()   
    local heightmapFilename = string.format("maps/overviews/%s.hmp", Shared.GetMapName())
    
    if not gHeightMap:Load(heightmapFilename) then
        Shared.Message("Couldn't load height map " .. heightmapFilename)
        gHeightMap = nil
    end

end

local function OnMapPostLoad()
    LoadHeightmap()

end

function GetHeightmap()
    return gHeightMap
end

/**
 * Called when two physics bodies collide.
 */
function OnPhysicsCollision(body1, body2)

    local entity1 = body1:GetEntity()
    local entity2 = body2:GetEntity()
    
    if (entity1 ~= nil and entity1.OnCollision ~= nil) then
        entity1:OnCollision(entity2)
    end
    
    if (entity2 ~= nil and entity2.OnCollision ~= nil) then
        entity2:OnCollision(entity1)
    end

end

// Set the callback function when there's a collision
Event.Hook("PhysicsCollision", OnPhysicsCollision)

/**
 * Called when one physics body enters into a trigger body.
 */
function OnPhysicsTrigger(enterObject, triggerObject, enter)

    PROFILE("Shared:OnPhysicsTrigger")

    local enterEntity   = enterObject:GetEntity()
    local triggerEntity = triggerObject:GetEntity()
    
    if enterEntity ~= nil and triggerEntity ~= nil then
    
        if (enter) then
        
            if (enterEntity.OnTriggerEntered ~= nil) then
                enterEntity:OnTriggerEntered(enterEntity, triggerEntity)
            end
            
            if (triggerEntity.OnTriggerEntered ~= nil) then
                triggerEntity:OnTriggerEntered(enterEntity, triggerEntity)
            end
            
        else
        
            if (enterEntity.OnTriggerExited ~= nil) then
                enterEntity:OnTriggerExited(enterEntity, triggerEntity)
            end
            
            if (triggerEntity.OnTriggerExited ~= nil) then
                triggerEntity:OnTriggerExited(enterEntity, triggerEntity)
            end
            
        end
        
    end

end

// Set the callback functon when there's a trigger
Event.Hook("PhysicsTrigger", OnPhysicsTrigger)

// turn on to show outline of view box trace.
Shared.DbgTraceViewBox = false

/**
 * Support view aligned box traces. The world-axis aligned box traces doesn't work as soon as you have the
 * least tilt or yaw on the box (such as placing structures on tilted surfaces (like walls). This is a
 * better-than-nothing replacement until engine support comes along.
 *
 * The view aligned box places the view along the z-axis. You specify the x,y extents, the roll around the z-axis and
 * the start and endpoints.
 *
 * 9 traces are used, one on each corner, one in the middle of each side and one in the middle.
 *
 * A possible expansion would be to add more traces for larger boxes to keep an upper limit of the size of a missed object.
 *
 * It returns a trace look-alike (ie a table containing an endPoint, fraction and normal)
 */ 
function Shared.TraceViewBox(x, y, roll, startPoint, endPoint, mask, filter)

    // find the shortest trace of the 9 traces that we are going to do
    local shortestTrace = nil

    // first start by doing a simple ray trace though the middle
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Default, mask, filter)
    if trace.fraction < 1 then
        shortestTrace = trace
    end 
    if Shared.DbgTraceViewBox then
        DebugLine(startPoint,trace.endPoint,30,trace.fraction < 1 and 1 or 0,1,0,1)
    end

    local coords = Coords.GetLookIn(startPoint, endPoint - startPoint)
    local angles = Angles()
    angles:BuildFromCoords(coords)
    angles.roll = roll
    coords = angles:GetCoords()
    local points = {}

    for dx =-1,1 do
        for dy = -1,1 do
            local v1 = Vector(dx * x,dy * y, 0)
            local p1 = startPoint + coords:TransformVector(v1)
            local p2 = endPoint + coords:TransformVector(v1)
            trace = Shared.TraceRay(p1, p2, CollisionRep.Default, mask, filter)
            if trace.fraction < 1 then
                if shortestTrace == nil or shortestTrace.fraction > trace.fraction then
                    shortestTrace = trace
                end
            end
            if Shared.DbgTraceViewBox then
                DebugLine(p1,trace.endPoint,30,trace.fraction < 1 and 1 or 0,1,0,1)
            end
        end 
    end
    
    local makeResult = function(fraction, endPoint, normal, entity)
        return { fraction=fraction, endPoint=endPoint, normal=normal, entity=entity }
    end
    
    if shortestTrace then 
        return makeResult(shortestTrace.fraction, startPoint + (endPoint - startPoint) * shortestTrace.fraction, shortestTrace.normal, shortestTrace.entity)
    end
    // Make the normal non-nil to be consistent with the engine's trace results.
    return makeResult(1, endPoint, Vector.yAxis)
    
end

Event.Hook("MapPostLoad", OnMapPostLoad)
