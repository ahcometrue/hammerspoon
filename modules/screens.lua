-- Reference(https://github.com/bezhermoso/dotfiles/tree/master/hammerspoon)

local window = require "hs.window"
local hotkey = require "hs.hotkey"
local fnutils = require "hs.fnutils"
local geometry = require "hs.geometry"
local mouse = require "hs.mouse"
local layout = require 'hs.layout'
local alert = require 'hs.alert'
local screen = require 'hs.screen'

-- {{{ Multiple Screen Focus Switch
local SwitchScreenKey = '.';
--One hotkey should just suffice for dual-display setups as it will naturally
--cycle through both.
--A second hotkey to reverse the direction of the focus-shift would be handy
--for setups with 3 or more displays.

--Predicate that checks if a window belongs to a screen
local function isInScreen(sc, win)
    return win:screen() == sc
end

local function moveMouseToScreen(sc)
    local pt = geometry.rectMidPoint(sc:fullFrame())
    mouse.setAbsolutePosition(pt)
end

local function focusScreen(sc, moveMouse)
    --Get windows within screen, ordered from front to back.
    --If no windows exist, bring focus to desktop. Otherwise, set focus on
    --front-most application window.
    if not sc then return end

    local windows = fnutils.filter(
    window.orderedWindows(),
    fnutils.partial(isInScreen, sc))
    local windowToFocus = #windows > 0 and windows[1] or window.desktop()
    windowToFocus:focus()

    if moveMouse then moveMouseToScreen(sc) end
end

--Bring focus to next display/screen
hotkey.bind(hyper, SwitchScreenKey, function ()
    local focused = window.focusedWindow()
    if not focused then return end
    local sc = focused:screen()
    if not sc then return end
    focusScreen(window.focusedWindow():screen():next(), true)
end)

--Bring focus to previous display/screen
hotkey.bind(hyperShift, SwitchScreenKey, function()
    local focused = window.focusedWindow()
    if not focused then return end
    local sc = focused:screen()
    if not sc then return end
    focusScreen(window.focusedWindow():screen():previous(), true)
end)

-- }}}
-- {{{ Multiple Screen Layouts

-- {{{ custom layout
layout.left33 = geometry.rect(0, 0, 0.333, 1)
layout.left66 = geometry.rect(0, 0, 0.666, 1)
layout.right33 = geometry.rect(0.666, 0, 0.333, 1)
layout.right66 = geometry.rect(0.333, 0, 0.666, 1)
layout.topLeftQuad = geometry.rect(0, 0, 0.5, 0.5)
layout.topRightQuad = geometry.rect(0.5, 0, 0.5, 0.5)
layout.bottomLeftQuad = geometry.rect(0, 0.5, 0.5, 0.5)
layout.bottomRightQuad = geometry.rect(0.5, 0.5, 0.5, 0.5)
layout.bottom = geometry.rect(0, 0.5, 1, 0.5)
-- }}}

function generate_layout()
    local screenlist = screen.allScreens()
    local count = #screenlist

    local primaryScreenName = screen.primaryScreen():name()
    -- if only have one screen, minorScreenName == primaryScreenName;
    local minorScreenName = screen.primaryScreen():next():name()

    local mylayout= {
    -- {{{
        --  Format reminder:
        --      {"App name", "Window name", "Display Name", "unitrect", "framerect", "fullframerect"},
        --      geometry.rect('X','Y','Width','Height')
        --      geometry.unitrect(X%,Y%,Width%,Height%)
        -- primaryScreen
        {"Finder",            nil,          primaryScreenName, layout.topLeftQuad, nil, nil},
        {"iTerm2",            nil,          primaryScreenName, layout.maximized, nil, nil},
        {"Google Chrome",     nil,          primaryScreenName, layout.maximized, nil, nil},
        {"Evernote",          "Colors",     primaryScreenName, geometry(0.9, 0, 0.1, 0.4), nil, nil},
        -- minorScreenName
        {"AppCleaner",        nil,          minorScreenName, layout.bottomLeftQuad, nil, nil},
        {"Dash",              nil,          minorScreenName, layout.left70, nil, nil},
        {"App Store",         nil,          minorScreenName, layout.left75, nil, nil},
        {"Preview",           nil,          minorScreenName, layout.left75, nil, nil},
        {"WeChat",            nil,          minorScreenName, layout.left50, nil, nil},
        {"iTunes",            "iTunes",     minorScreenName, layout.maximized, nil, nil},
    -- }}}
    }

    alert.show("Layout Apply")
    return mylayout
end

-- See: http://www.hammerspoon.org/docs/hs.layout.html#apply
hotkey.bind(hyper, '1', function() layout.apply(generate_layout()) end)
--  }}}
