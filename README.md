# 🎯 VD Mini HUD (QBCore)

A clean, modern, and lightweight HUD resource for FiveM servers using **QBCore**.  
Designed to provide essential player information in a minimal and stylish interface.

---

## ✨ Features

- 💰 Real-time **cash & bank display**
- 🆔 Player ID display
- 💼 Job & grade display
- 🕵️ Gang & rank display
- 🔫 Weapon info support (toggleable)
- 🎨 Clean UI with smooth animations
- ⚡ Optimized & lightweight

---

## 📸 Screenshot

![VD Mini HUD Preview](https://cdn.discordapp.com/attachments/1453794858765385800/1484187084653592757/image.png?ex=69bd506f&is=69bbfeef&hm=a7f2658a9b2cc4edd1ac57290e4267e94a38b6be82731216f0c73dab1f3c886c&)

---

## 📁 Resource Structure

```
vd-minihud/
│
├── client.lua
├── server.lua
├── config.lua
├── fxmanifest.lua
│
└── html/
    ├── ui.html
    ├── img/
    │   └── logo.png
    └── font/
        └── bankgothic.ttf
```

---

## ⚙️ Installation

1. Download or clone this repository
2. Place the folder into your server's `resources` directory
3. Add the resource to your `server.cfg`:

```
ensure vd-minihud
```

4. Make sure you are using **QBCore**

---

## 🔧 Configuration

Edit `config.lua`:

```lua
Config = {
    jobLegal = true,   -- Show legal job
    jobGang = true,    -- Show gang info
    playerId = true,   -- Show player ID
    weaponInfo = true  -- Show weapon info
}
```

---

## 🧠 Requirements

- QBCore Framework

---

## 🚀 Events Used

- `QBCore:Client:OnPlayerLoaded`
- `QBCore:Client:OnJobUpdate`
- `QBCore:Client:OnGangUpdate`

---

## 🛠️ Customization

You can modify:

- UI styles inside `html/ui.html`
- Colors, layout, and animations via CSS
- Data handling inside `client.lua`

---

## 👨‍💻 Author

**VoidEngineCC**

---

## 📜 License

Free to use and modify.  
Credit is appreciated but not required.

---

## 💡 Notes

- HUD automatically hides when:
  - Spawn UI is open
  - NUI is focused
- Optimized updates to prevent performance issues

---

## ❤️ Support

If you like this resource, consider giving it a ⭐ on GitHub!
