# Inverse Kinematics(FABRIK) using figura.

## Example usecases:

* Rope Simulations
* Tendrils
* Tails
* Hair
* Accessories

## How to use:

1. Initialize the API by doing ``` local InverseKinematics = require("InverseKinematics") ```
2. Then create a new armature system by running ``` local armatureSystem = InverseKinematics:newArmatureSystem(pos,size,armatureLength) ``` where pos(Vector3), size(Integer) how many armatures are going to be in the system, armatureLength(Number) length of the each armature
## Methods:
### Armature System Methods:
* Create new armature system
```
    -- pos(Vector3)
    -- size(Integer)
    -- armatureLength(number)
    InverseKinematics:newArmatureSystem(pos,size,armatureLength) 

    -- pos(Vector3)
    -- armatureLengths(table of number)
    InverseKinematics:newArmatureSystem(pos,size,armatureLength) 
```
* Do a two step update proccess for the chain where the chain tries to reach the target in the most believable way possible
``` 
    -- endPoint(Vector3)
    armatureSystem:update(endPoint)
```
* Do a single step of the update proccess
``` 
    -- endPoint(Vector3)
    armatureSystem:step(endPoint)
```
* Go throught each armature
```  
    -- key(Integer)
    -- value(Armature)
    for key, value in pairs(armatureSystem.armatures) do
            --Code you want to do
    end
```
### Armature Methods:
* Set End/Start Positions of the Armature
```
    -- Set Start
    -- startVec(Vector3)
    armature:setStart(startVec)

    -- Set End
    -- endVec(Vector3)
    armature:setEnd(endVec)
```
* Get length of the Armature
```
    -- Returns Vector3
    armature:getLength()
```
* Made the Armature look at a point
```
    --target(Vector3)
    armature:lookAt(target)
```

