# rzy_personalmenu
**rzy_personalmenu** is a **Personalmenu** for FiveM developed on top of [ESX](https://github.com/ESX-Org/es_extended) and [NativeUI](https://github.com/FrazzIe/NativeUILua)

### Important
- **You are not allowed to modify the resource name**
- **You are not allowed to modify the repository and re-release it, you can only fork it**
- **If you want to contribute (like translation) you can make a pull request or open a new issue**

**Please, KEEP IN MIND i've done this to train myself in Lua. Cuse tbh if I had in idea to release it only, it would be dumb cuse krz_personalmenu do the same job.**

### Links & Support
- **Discord Username**: RZY#2004


### Features
- NativeUI
- Inventory System:
    - Use item
    - Give item
    - Drop item
- Weapons System
    - Give weapon
- Wallet
    - Job and rank
    - Gang et rank (if double job enabled into the config)
    - Money
    - Dirty Money
    - Bank money
    - License's (driver et weapon), Identity Card
    - Drop and give money / dirty money
- Bills
- Clothing
    - clothes
    - Accessories
- Animations
    - You have every animations
    - You can stop the animations by pressing "X" or by clicking the button to stop it
- Procedures
- Enterprise management
- Gang management (if double job enabled into the config)
- Various:
    - Gang Actions
        - Handcuff someone
        - Kidnap someone
        - Take out of the vehicle someone
        - Put someone into a vehicle
    - Citizen Action
        - Sleep
        - Carry
    - Options
        - Change voice
        - Enable/disable minimap
        - Save ped
    - Infos:
        - See how much peoples are online, how much EMS, LSPD, mechanic and cardealer are online's too
- Admin:
    - Players connected list:
        - For each players you can:
            - Spec the player
            - Kick the player
            - Revive the player (using esx_ambulancejob)
            - Give money to the player
            - TP ourself to the player
    - Godmod
    - Noclip
    - Super Jump
    - Infinite Stamina
    - Fast Run
- Config file:
    - Fully customizable config file
    

### Credits / Thanks
- Korioz for:
    - Idea
    - Démarches
    - KeyboardInput function

### Requirements
This order also applies in the startup order.

- [es_extended](https://github.com/ESX-Org/es_extended) **Double job one is better**
- [esx_addonaccount](https://github.com/ESX-Org/esx_addonaccount)
- [esx_addoninventory](https://github.com/ESX-Org/esx_addoninventory)
- [esx_datastore](https://github.com/ESX-Org/esx_datastore)
- [esx_billing](https://github.com/ESX-Org/esx_billing)
- [esx_society](https://github.com/ESX-Org/esx_society)
- [esx_ambulancejob](https://github.com/ESX-Org/esx_ambulancejob)
- [skinchanger](https://github.com/ESX-Org/skinchanger)
- [esx_skin](https://github.com/ESX-Org/esx_skin)
- [esx_accessories](https://github.com/ESX-Org/esx_accessories)
- Optional: [jsfour-idcard](https://github.com/jonassvensson4/jsfour-idcard)

### Download & Installation

### Using Git

```
cd resources
git clone https://github.com/Riziebtw/rzy_personalmenu
```

### Manually
- Download https://github.com/Riziebtw/rzy_personalmenu/releases/latest
- Put it in the `resource/[plugins]` directory

## Installation
- Configure your `server.cfg` to look like this
- Make sure you add this at the bottom of your start order after all esx scripts

```
start rzy_personalmenu
```
# Legal
### License
rzy_personalmenu - ESX Personal Menu

Copyright (C) 2020 RZY

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
