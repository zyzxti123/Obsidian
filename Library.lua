--!strict

export type ESPContext = {
    Player: Player, Character: Model, Humanoid: Humanoid, RootPart: BasePart,
    Camera: Camera, Distance: number, Team: string, DeltaTime: number, Data: { [string]: any },
}
export type ESPItemResult = boolean | string | number | {
    Visible: boolean?, Text: string?, Value: number?, Max: number?,
    Color: Color3?, Transparency: number?, Segments: { { number } }?,
}

local cloneref = (cloneref or clonereference or function(instance: any)
    setthreadidentity(8)
    return instance
end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local GuiService: GuiService = cloneref(game:GetService("GuiService"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local SoundService: SoundService = cloneref(game:GetService("SoundService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local Teams: Teams = cloneref(game:GetService("Teams"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function()
    setthreadidentity(8)
    return shared
end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function()
    setthreadidentity(8)
end
local gethui = gethui or function()
    setthreadidentity(8)
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}
local Tooltips = {}

local BaseURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    TransparencyTexture = {
        RobloxId = 139785960036434,
        Path = "Obsidian/assets/TransparencyTexture.png",
        URL = BaseURL .. "assets/TransparencyTexture.png",

        Id = nil,
    },

    SaturationMap = {
        RobloxId = 4155801252,
        Path = "Obsidian/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",

        Id = nil,
    },

    LoadingIcon = {
        RobloxId = 97544096941083,
        Path = "Obsidian/assets/LoadingIcon.png",
        URL = BaseURL .. "assets/LoadingIcon.png",

        Id = nil,
    },

    CheckIcon = {
        RobloxId = 97682394690683,
        Path = "Obsidian/assets/CheckIcon.png",
        URL = BaseURL .. "assets/CheckIcon.png",

        Id = nil,
    },
}
do
    local function RecursiveCreatePath(Path: string, IsFile: boolean?)
        setthreadidentity(8)
        if not isfolder or not makefolder then
            return
        end

        local Segments = Path:split("/")
        local TraversedPath = ""

        if IsFile then
            table.remove(Segments, #Segments)
        end

        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then
                makefolder(TraversedPath .. Segment)
            end

            TraversedPath = TraversedPath .. Segment .. "/"
        end

        return TraversedPath
    end

    function CustomImageManager.AddAsset(
        AssetName: string,
        RobloxAssetId: number,
        URL: string,
        ForceRedownload: boolean?
    )
        setthreadidentity(8)
        if CustomImageManagerAssets[AssetName] ~= nil then
            error(string.format("Asset %q already exists", AssetName))
        end

        assert(typeof(RobloxAssetId) == "number", "RobloxAssetId must be a number")

        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId,
            Path = string.format("Obsidian/custom_assets/%s", AssetName),
            URL = URL,

            Id = nil,
        }

        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName: string)
        setthreadidentity(8)
        if not CustomImageManagerAssets[AssetName] then
            return nil
        end

        local AssetData = CustomImageManagerAssets[AssetName]
        if AssetData.Id then
            return AssetData.Id
        end

        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)

        if getcustomasset then
            local Success, NewID = pcall(getcustomasset, AssetData.Path)

            if Success and NewID then
                AssetID = NewID
            end
        end

        AssetData.Id = AssetID
        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName: string, ForceRedownload: boolean?)
        setthreadidentity(8)
        if not getcustomasset or not writefile or not isfile then
            return false, "missing functions"
        end

        local AssetData = CustomImageManagerAssets[AssetName]

        RecursiveCreatePath(AssetData.Path, true)

        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end

        local success, errorMessage = pcall(function()
            setthreadidentity(8)
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)

        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
    end
end

local Library = {
    LocalPlayer = LocalPlayer,
    IsRobloxFocused = true,

    --// Device \\--
    DevicePlatform = nil,
    IsMobile = false,

    --// Obsidian Windows \\--
    ScreenGui = nil,
    Floats = nil,
    Overlay = nil,

    Window = nil,
    WindowContainer = nil,
    KeyStatusComponents = {},
    AnonymousMode = false,
    AnonymousModeToggle = nil,
    CommandPalette = nil,
    Commands = {},
    FeatureBadgeStatuses = {
        Premium = { Color = Color3.fromRGB(255, 202, 72), Priority = 1 },
        Experimental = { Color = Color3.fromRGB(178, 112, 255), Priority = 2 },
        Unstable = { Color = Color3.fromRGB(255, 145, 70), Priority = 3 },
        Detected = { Color = Color3.fromRGB(245, 75, 90), Priority = 4 },
    },
    Flags = {
        AnonymousMode = false,
    },

    --// Search \\--
    SearchText = "",
    Searching = false,
    GlobalSearch = false,
    LastSearchTab = nil,

    --// Tabs \\--
    ActiveTab = nil,
    PreviousTab = nil,
    Tabs = {},
    TabButtons = {},

    --// Dependency Boxes \\--
    DependencyBoxes = {},

    --// Keybinds Frame \\--
    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},

    --// Notifications \\--
    Notifications = {},
    NotifySide = "Right",
    NotifyStyle = "Compact",
    NotifyLimit = 8,
    NotifyMaxWidth = 860,
    NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    --// Dialogues \\--
    Dialogues = {},
    ActiveDialog = nil,

    --// Loading Window \\--
    ActiveLoading = nil,

    --// Context Menu \\--
    ContextMenus = {},

    --// Corners \\--
    Corners = {},
    SpecificCorners = {},

    --// Animations \\--
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    TabTransitionInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TabSwipeOffset = 26,
    TabSwipeFrom = "bottom",

    WindowAnimationInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    DropdownTransitionInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    KeyPickerTransitionInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    GroupboxTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    RotatingChevronTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

    Animations = {
        ToggleWindow = false,
        TabSwitch = false,
        Groupbox = false,
        Dropdown = false,
        KeyPicker = false
    },

    --// States \\--
    Toggled = false,
    Unloaded = false,

    --// Elements \\--
    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,

    --// Options \\--
    ToggleKeybind = Enum.KeyCode.RightControl,
    ShowToggleFrameInKeybinds = true,

    NotifyOnError = false,
    ShowCustomCursor = false,
    ForceCheckbox = false,

    CantDragForced = false,
    DraggableElements = {},

    --// Pop Out \\--
    PopOutSnapDistance = 80,
    PopOutDragThreshold = 8,
    PopOutHoldTime = 0.15,

    --// Signals \\--
    Signals = {},
    UnloadSignals = {},

    OriginalMinSize = Vector2.new(480, 360),
    MinSize = Vector2.new(480, 360),
    DPIScale = 1,
    CornerRadius = 4,

    --// Scheme \\--
    IsLightTheme = false,
    Scheme = {
        BackgroundColor = Color3.fromRGB(15, 15, 15),
        MainColor = Color3.fromRGB(25, 25, 25),
        AccentColor = Color3.fromRGB(125, 85, 255),
        OutlineColor = Color3.fromRGB(40, 40, 40),
        FontColor = Color3.new(1, 1, 1),
        Font = Font.fromEnum(Enum.Font.Code),

        RedColor = Color3.fromRGB(255, 50, 50),
        DestructiveColor = Color3.fromRGB(220, 38, 38),
        DarkColor = Color3.new(0, 0, 0),
        WhiteColor = Color3.new(1, 1, 1),

        BackgroundImage = ""
    },

    --// Registry \\--
    Registry = {},
    Scales = {},
    ScalesOffset = {},

    --// Mouse \\--
    OriginalMouseIconEnabled = UserInputService.MouseIconEnabled,
    ShowCursorBinding = string.sub(tostring({}), 10),

    --// Image Manager \\--
    ImageManager = CustomImageManager,

    --// Misc \\--
    Notify = nil, Toggle = nil -- we love luau lsp
}

if RunService:IsStudio() then
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        Library.IsMobile = true
        Library.OriginalMinSize = Vector2.new(480, 240)
    else
        Library.IsMobile = false
        Library.OriginalMinSize = Vector2.new(480, 360)
    end
else
    pcall(function()
        setthreadidentity(8)
        Library.DevicePlatform = UserInputService:GetPlatform()
    end)

    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
    Library.OriginalMinSize = Library.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)
end

local Templates = {
    --// UI \\--
    Frame = {
        BorderSizePixel = 0,
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ImageButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
    },
    ScrollingFrame = {
        BorderSizePixel = 0,
    },
    TextLabel = {
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextBox = {
        BorderSizePixel = 0,
        FontFace = "Font",
        PlaceholderColor3 = function()
            setthreadidentity(8)
            local H, S, V = Library.Scheme.FontColor:ToHSV()
            return Color3.fromHSV(H, S, V / 2)
        end,
        Text = "",
        TextColor3 = "FontColor",
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder,
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    },

    --// Library \\--
    Window = {
        Title = "No Title",
        Footer = "No Footer",
        KeyStatus = false,
        AnonymousMode = false,
        CommandPalette = true,
        CommandPaletteKeybind = Enum.KeyCode.K,
        CommandPaletteRequireControl = true,
        CommandPaletteMaxResults = 9,

        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(720, 600),
        IconSize = UDim2.fromOffset(30, 30),

        AutoShow = true,
        Center = true,
        Resizable = true,
        AlwaysOnTop = false,

        --// Window Snapping \\--
        Snapping = false,
        SnapDistance = 28,
        SnapMargin = 8,
        SnapAvoidCoreGui = true,

        SearchbarSize = UDim2.fromScale(1, 1),
        GlobalSearch = false,

        CornerRadius = 4,
        NotifySide = "Right",
        NotifyStyle = "Compact",
        NotifyLimit = 8,
        ShowCustomCursor = false,

        Font = Enum.Font.Code,
        ToggleKeybind = Enum.KeyCode.RightControl,

        ShowMobileButtons = true,
        MobileButtonsSide = "Left",

        UnlockMouseWhileOpen = true,

        EnableSidebarResize = false,
        EnableCompacting = true,
        DisableCompactingSnap = false,
        SidebarCompacted = false,
        MinContainerWidth = 256,

        --// Snapping \\--
        MinSidebarWidth = 128,
        SidebarCompactWidth = 48,
        SidebarCollapseThreshold = 0.5,

        --// Dragging \\--
        CompactWidthActivation = 128,

        --// Background \\--
        BackgroundImage = "",

        --// Animations \\--
        Animations = {
            ToggleWindow = false,
            TabSwitch = false,
            Groupbox = false,
            Dropdown = false,
            KeyPicker = false
        },

        TabTransitionTime = 0.22,
        TabSwipeOffset = 26,
        TabSwipeFrom = "bottom"
    },
    KeyStatus = {
        Enabled = true,
        Provider = "Luarmor",
        Status = nil,
        Developer = false,
        Username = LocalPlayer.Name,
        DisplayName = LocalPlayer.DisplayName,
        UserId = LocalPlayer.UserId,
        Anonymous = false,
        RemainingTime = nil,
        Lifetime = nil,
        GetRemainingTime = nil,
        LifetimeText = nil,
        DurationLabel = "Access remaining",
        StatusColors = {
            Freemium = Color3.fromRGB(145, 145, 155),
            Premium = Color3.fromRGB(125, 85, 255),
            Developer = Color3.fromRGB(67, 196, 128),
            Expired = Color3.fromRGB(235, 75, 75),
            ["IN-DEV"] = Color3.fromRGB(245, 185, 70),
        },
    },
    Groupbox = {
        Side = 1,
        Name = "Groupbox",
        IconName = nil,
        Description = nil,
        Visible = true,
        Collapsed = false,
        DisableCollapsing = false,
        PopOut = true,
    },
    Tabbox = {
        Side = 1,
        Name = nil,
        PopOut = true,
    },
    List = {
        Name = "List",
        IconName = nil,
        Height = 240,
        Visible = true,
        Collapsed = false,
        DisableCollapsing = false,
    },
    Dialog = {
        Title = "Dialog",
        Description = "Description",
        AutoDismiss = true,
        OutsideClickDismiss = true,
        FooterButtons = {}
    },
    Loading = {
        Title = "mspaint",
        Icon = 95816097006870,
        IconSize = UDim2.fromOffset(30, 30),

        LoadingIcon = CustomImageManager.GetAsset("LoadingIcon"),
        LoadingIconColor = nil,
        LoadingIconTweenTime = 1,

        CurrentStep = 0,
        TotalSteps = 10,

        ShowSidebar = false,
        AutoResizeHeight = false,
        AlwaysOnTop = true,

        WindowWidth = 450,
        WindowHeight = 275,

        ContentWidth = 450,
        SidebarWidth = 250,
    },
    Toggle = {
        Text = "Toggle",
        Default = false,

        Callback = function()
            setthreadidentity(8)
        end,
        Changed = function()
            setthreadidentity(8)
        end,

        Risky = false,
        Disabled = false,
        Visible = true,
    },
    Input = {
        Text = "Input",
        Default = "",
        Finished = false,
        Numeric = false,
        ClearTextOnFocus = true,
        ClearTextOnBlur = false,
        Placeholder = "",
        AllowEmpty = true,
        EmptyReset = "---",

        Callback = function()
            setthreadidentity(8)
        end,
        Changed = function()
            setthreadidentity(8)
        end,
        VerifyValue = nil,

        Disabled = false,
        Visible = true,
    },
    Slider = {
        Text = "Slider",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,

        Prefix = "",
        Suffix = "",

        Callback = function()
            setthreadidentity(8)
        end,
        Changed = function()
            setthreadidentity(8)
        end,

        Disabled = false,
        Visible = true,

        AllowRightClickInput = true
    },
    Dropdown = {
        Values = {},
        DisabledValues = {},
        ValueImages = {},

        Multi = false,
        DragSelect = false,
        SelectionControls = false,
        Prioritize = false,
        PriorityButtonsPosition = "Right",
        AutoSizeDropdown = false,
        MaxDropdownWidth = 440,
        MaxVisibleDropdownItems = 8,

        Callback = function()
            setthreadidentity(8)
        end,
        Changed = function()
            setthreadidentity(8)
        end,

        Disabled = false,
        Visible = true,
    },
    Viewport = {
        Object = nil,
        Camera = nil,
        Clone = true,
        AutoFocus = true,
        Interactive = false,
        Clickable = false,
        ToggleSelection = false,
        Selected = false,
        Callback = function()
            setthreadidentity(8)
        end,
        Text = nil,
        TextSize = 14,
        RichText = true,
        Height = 200,
        Visible = true,
    },
    Image = {
        Image = "",
        Transparency = 0,
        BackgroundTransparency = 0,
        Color = Color3.new(1, 1, 1),
        RectOffset = Vector2.zero,
        RectSize = Vector2.zero,
        ScaleType = Enum.ScaleType.Fit,
        Height = 200,
        Visible = true,
    },
    Video = {
        Video = "",
        Looped = false,
        Playing = false,
        Volume = 1,
        Height = 200,
        Visible = true,
    },
    UIPassthrough = {
        Instance = nil,
        Height = 24,
        Visible = true,
    },

    --// Addons \\-
    KeyPicker = {
        Text = "KeyPicker",

        Default = "None",
        DefaultModifiers = {},

        Blacklisted = {},
        BlacklistedModifiers = {},
        Whitelisted = {},
        WhitelistedModifiers = {},

        Mode = "Toggle",
        Modes = { "Always", "Toggle", "Hold" },
        SyncToggleState = false,

        Callback = function()
            setthreadidentity(8)
        end,
        ChangedCallback = function()
            setthreadidentity(8)
        end,
        Changed = function()
            setthreadidentity(8)
        end,
        Clicked = function()
            setthreadidentity(8)
        end,
    },
    ColorPicker = {
        Default = Color3.new(1, 1, 1),

        Resizable = true,

        Callback = function()
            setthreadidentity(8)
        end,
        Changed = function()
            setthreadidentity(8)
        end,
    },
}

local Places = {
    Bottom = { 0, 1 },
    Right = { 1, 0 },
}
local Sizes = {
    Left = { 0.5, 1 },
    Right = { 0.5, 1 },
}
local SideIndex = {
    left = 1,
    right = 2,
}

--// Scheme Functions \\--
local SchemeReplaceAlias = {
    RedColor = "Red",
    WhiteColor = "White",
    DarkColor = "Dark"
}

local SchemeAlias = {
    Red = "RedColor",
    White = "WhiteColor",
    Dark = "DarkColor"
}

local function GetSchemeValue(Index)
    setthreadidentity(8)
    if not Index then
        return nil
    end

    local ReplaceAliasIndex = SchemeReplaceAlias[Index]
    if ReplaceAliasIndex and Library.Scheme[ReplaceAliasIndex] ~= nil then
        Library.Scheme[Index] = Library.Scheme[ReplaceAliasIndex]
        Library.Scheme[ReplaceAliasIndex] = nil

        return Library.Scheme[Index]
    end

    local AliasIndex = SchemeAlias[Index]
    if AliasIndex and Library.Scheme[AliasIndex] ~= nil then
        warn(string.format("Scheme Value %q is deprecated, please use %q instead.", Index, AliasIndex))
        return Library.Scheme[AliasIndex]
    end

    return Library.Scheme[Index]
end

--// Basic Functions \\--
local function WaitForEvent(Event, Timeout, Condition)
    setthreadidentity(8)
    local Bindable = Instance.new("BindableEvent")
    local Connection = Event:Once(function(...)
        setthreadidentity(8)
        if not Condition or typeof(Condition) == "function" and Condition(...) then
            Bindable:Fire(true)
        else
            Bindable:Fire(false)
        end
    end)
    task.delay(Timeout, function()
        setthreadidentity(8)
        Connection:Disconnect()
        Bindable:Fire(false)
    end)

    local Result = Bindable.Event:Wait()
    Bindable:Destroy()

    return Result
end

local function IsMouseInput(Input: InputObject, IncludeM2: boolean?)
    setthreadidentity(8)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or (IncludeM2 == true and Input.UserInputType == Enum.UserInputType.MouseButton2)
        or Input.UserInputType == Enum.UserInputType.Touch
end
local function IsClickInput(Input: InputObject, IncludeM2: boolean?)
    setthreadidentity(8)
    return IsMouseInput(Input, IncludeM2)
        and Input.UserInputState == Enum.UserInputState.Begin
        and Library.IsRobloxFocused
end
local function IsHoverInput(Input: InputObject)
    setthreadidentity(8)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Input.UserInputState == Enum.UserInputState.Change
end
local function IsDragInput(Input: InputObject, IncludeM2: boolean?)
    setthreadidentity(8)
    return IsMouseInput(Input, IncludeM2)
        and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change)
        and Library.IsRobloxFocused
end
local function IsMouseClickInput(Input: InputObject)
    setthreadidentity(8)
    return Input.UserInputType == Enum.UserInputType.MouseButton1 or
        Input.UserInputType == Enum.UserInputType.MouseButton2 or
        Input.UserInputType == Enum.UserInputType.MouseButton3
end
local function IsMovementInput(Input: InputObject)
    setthreadidentity(8)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Library.IsRobloxFocused
end

local function GetTableSize(Table: { [any]: any })
    setthreadidentity(8)
    local Size = 0

    for _, _ in Table do
        Size += 1
    end

    return Size
end
local function IsSequentialArray(Table: { [any]: any })
    setthreadidentity(8)
    for Key in Table do
        if typeof(Key) ~= "number" or Key < 1 or Key % 1 ~= 0 then
            return false
        end
    end

    return true
end

local function StopTween(Tween: TweenBase, Destroy: boolean?)
    setthreadidentity(8)
    if not Tween then
        return
    end

    if Tween.PlaybackState == Enum.PlaybackState.Playing then
        Tween:Cancel()
    end

    if Destroy == true then
        pcall(Tween.Destroy, Tween)
    end
end

local function Trim(Text: string)
    setthreadidentity(8)
    return Text:match("^%s*(.-)%s*$")
end
local function Round(Value, Rounding)
    setthreadidentity(8)
    assert(Rounding >= 0, "Invalid rounding number.")

    if Rounding == 0 then
        return math.floor(Value)
    end

    return tonumber(string.format("%." .. Rounding .. "f", Value))
end

--// Fuzzy Search \\--
local function FuzzyScore(Text: string, Search: string): (boolean, number)
    setthreadidentity(8)
    if Search == "" then
        return true, 0
    end
    if Text == "" then
        return false, 0
    end

    --// Fast path: literal substring match (also the best possible score) \\--
    local ExactIdx = Text:find(Search, 1, true)
    if ExactIdx then
        local PrevChar = ExactIdx > 1 and Text:sub(ExactIdx - 1, ExactIdx - 1) or ""
        local AtBoundary = ExactIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

        return true, 1e5 - ExactIdx + (AtBoundary and 500 or 0) + (Search:len() * 5)
    end

    --// Fallback: fuzzy, in-order, non-consecutive character matching \\--
    local TextLen, SearchLen = Text:len(), Search:len()
    if SearchLen > TextLen then
        return false, 0
    end

    local SearchIdx = 1
    local Score = 0
    local RunLength = 0
    local LastMatchIdx = 0

    for TextIdx = 1, TextLen do
        if SearchIdx > SearchLen then
            break
        end

        if Text:sub(TextIdx, TextIdx) == Search:sub(SearchIdx, SearchIdx) then
            local PrevChar = TextIdx > 1 and Text:sub(TextIdx - 1, TextIdx - 1) or ""
            local AtBoundary = TextIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

            RunLength = (LastMatchIdx == TextIdx - 1) and (RunLength + 1) or 1
            Score += 1 + (AtBoundary and 6 or 0) + math.min(RunLength - 1, 5) * 3

            LastMatchIdx = TextIdx
            SearchIdx += 1
        end
    end

    if SearchIdx <= SearchLen then
        return false, 0 --// Not every Search character was found, in order
    end

    Score -= (LastMatchIdx - SearchLen) * 0.05 --// Slightly favour tighter matches
    return true, Score
end

local function NormalizeSearch(Search: string): string
    setthreadidentity(8)
    return (Search:gsub("%s+", ""))
end

local function TryFuzzyMatch(Text: any, Search: string): (boolean, number)
    setthreadidentity(8)
    if typeof(Text) ~= "string" or Text == "" then
        return false, 0
    end

    return FuzzyScore(Text:lower(), Search)
end

local function FuzzyMatchScore(Text: any, Search: string): number
    setthreadidentity(8)
    if typeof(Text) ~= "string" or Text == "" then
        return 0
    end

    local Normalized = NormalizeSearch(Text:lower())
    local Matched, Score = FuzzyScore(Normalized, Search)
    if not Matched then
        return 0
    end

    if Normalized == Search then
        Score += 1000
    end

    return Score
end

local function MatchesSearch(ElementInfo, Search: string, ForceMatch: boolean?): boolean
    setthreadidentity(8)
    if not ElementInfo then
        return false
    end
    if ForceMatch then
        return true
    end

    if TryFuzzyMatch(ElementInfo.Text, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.Tooltip, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.DisabledTooltip, Search) then
        return true
    end

    --// Optional: search inside Dropdown value lists, so e.g. searching a specific option name reveals the Dropdown that contains it \\--
    if typeof(ElementInfo.Values) == "table" then
        local Checked = 0
        for Key, Value in ElementInfo.Values do
            Checked += 1
            if Checked > 200 then
                break
            end

            if TryFuzzyMatch(Value, Search) or (typeof(Value) ~= "string" and TryFuzzyMatch(tostring(Value), Search)) then
                return true
            end
            if typeof(Key) == "string" and TryFuzzyMatch(Key, Search) then
                return true
            end
        end
    end

    return false
end

local function ApplySearchToList(List, Search: string, ForceVisible: boolean?): (number, number)
    setthreadidentity(8)
    local ListMatches = ForceVisible or TryFuzzyMatch(List.Text, Search)
    local VisibleElements = 0
    local BestScore = FuzzyMatchScore(List.Text, Search)

    for _, ElementInfo in List.Elements do
        if ElementInfo.Type == "Divider" then
            ElementInfo.Holder.Visible = false
            continue
        end

        local Visible = false
        if ElementInfo.SubButton then
            local MainVisible = ElementInfo.Visible and MatchesSearch(ElementInfo, Search, ListMatches)
            local SubVisible = ElementInfo.SubButton.Visible
                and MatchesSearch(ElementInfo.SubButton, Search, ListMatches)

            ElementInfo.Base.Visible = MainVisible
            ElementInfo.SubButton.Base.Visible = SubVisible
            Visible = MainVisible or SubVisible
        else
            Visible = ElementInfo.Visible ~= false and MatchesSearch(ElementInfo, Search, ListMatches)
        end

        ElementInfo.Holder.Visible = Visible
        if Visible then
            VisibleElements += 1
            BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
        end
    end

    List.Holder.Visible = List.Visible ~= false and (ListMatches or VisibleElements > 0)
    List:Resize()
    return if List.Holder.Visible then math.max(1, VisibleElements) else 0, BestScore
end

local function RestoreList(List)
    setthreadidentity(8)
    for _, ElementInfo in List.Elements do
        ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

        if ElementInfo.SubButton then
            ElementInfo.Base.Visible = ElementInfo.Visible
            ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
        end
    end

    List.Holder.Visible = List.Visible ~= false
    List:Resize()
end

local function GetPlayers(ExcludeLocalPlayer: boolean?)
    setthreadidentity(8)
    local PlayerList = Players:GetPlayers()

    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)
        if Idx then
            table.remove(PlayerList, Idx)
        end
    end

    table.sort(PlayerList, function(Player1, Player2)
        setthreadidentity(8)
        return Player1.Name:lower() < Player2.Name:lower()
    end)

    return PlayerList
end
local function GetTeams()
    setthreadidentity(8)
    local TeamList = Teams:GetTeams()

    table.sort(TeamList, function(Team1, Team2)
        setthreadidentity(8)
        return Team1.Name:lower() < Team2.Name:lower()
    end)

    return TeamList
end

function Library:UpdateDependencyBoxes()
    setthreadidentity(8)
    for _, Depbox in Library.DependencyBoxes do
        Depbox:Update(true)
    end

    if Library.Searching then
        Library:UpdateSearch(Library.SearchText)
    end
end

function Library:UpdateAddons(Parent)
    setthreadidentity(8)
    if not Parent or not Parent.Addons then
        return
    end

    for _, Addon in Parent.Addons do
        Addon:Update()
    end
end

local function CheckDepbox(Box, Search, ForceVisible: boolean?)
    setthreadidentity(8)
    local VisibleElements = 0
    local BestScore = 0

    for _, ElementInfo in Box.Elements do
        if ElementInfo.Type == "List" then
            local ListVisible, ListScore = ApplySearchToList(ElementInfo, Search, ForceVisible)
            VisibleElements += ListVisible
            BestScore = math.max(BestScore, ListScore)
            continue
        elseif ElementInfo.Type == "Divider" then
            ElementInfo.Holder.Visible = false
            continue
        elseif ElementInfo.SubButton then
            --// Check if any of the Buttons Name matches with Search
            local Visible = false

            --// Check if Search matches Element's Name and if Element is Visible
            if MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
                Visible = true
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
            else
                ElementInfo.Base.Visible = false
            end
            if MatchesSearch(ElementInfo.SubButton, Search, ForceVisible) and ElementInfo.SubButton.Visible then
                Visible = true
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.SubButton.Text, Search))
            else
                ElementInfo.SubButton.Base.Visible = false
            end
            ElementInfo.Holder.Visible = Visible
            if Visible then
                VisibleElements += 1
            end

            continue
        end

        --// Check if Search matches Element's Name and if Element is Visible
        if ElementInfo.Text and MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
            ElementInfo.Holder.Visible = true
            VisibleElements += 1
            BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
        else
            ElementInfo.Holder.Visible = false
        end
    end

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        local DepVisible, DepScore = CheckDepbox(Depbox, Search, ForceVisible)
        VisibleElements += DepVisible
        if DepScore > BestScore then
            BestScore = DepScore
        end
    end

    Box.Holder.Visible = VisibleElements > 0
    return VisibleElements, BestScore
end
local function RestoreDepbox(Box)
    setthreadidentity(8)
    for _, ElementInfo in Box.Elements do
        if ElementInfo.Type == "List" then
            RestoreList(ElementInfo)
            continue
        end

        ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

        if ElementInfo.SubButton then
            ElementInfo.Base.Visible = ElementInfo.Visible
            ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
        end
    end

    Box:Resize()
    Box.Holder.Visible = true

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        RestoreDepbox(Depbox)
    end
end

--// Pop Out
function SyncPopOutVisibility(Box: any)
    setthreadidentity(8)
    if not Box.PopOutFloat then
        return
    end

    Box.PopOutFloat.Visible = Box.BoxHolder.Visible ~= false and Box.Visible ~= false
end

local function DimPopOutClone(Root: GuiObject)
    setthreadidentity(8)
    for _, Descendant in Root:QueryDescendants("TextLabel, TextButton, TextBox") do
        Descendant.TextTransparency = math.max(Descendant.TextTransparency, 0.45)
    end

    for _, Descendant in Root:QueryDescendants("ImageLabel, ImageButton") do
        Descendant.ImageTransparency = math.max(Descendant.ImageTransparency, 0.45)
    end

    for _, Descendant in Root:QueryDescendants("GuiButton") do
        Descendant.Active = false
        Descendant.AutoButtonColor = false
    end
end

local function IsScreenPointOutsideMain(Point: Vector2): boolean
    setthreadidentity(8)
    local MainFrame = Library.Window and Library.Window.MainFrame
    if not MainFrame or not Library.Toggled or not MainFrame.Visible then
        return true
    end

    return not Library:MouseIsOverFrame(MainFrame, Point)
end

local function GetTopFloatAt(Point: Vector2): GuiObject?
    setthreadidentity(8)
    local Best: GuiObject? = nil
    local BestOrder = -math.huge
    local Floats = Library.Floats

    for _, Surface in Library.DraggableElements do
        if not Surface or not Surface.Parent or not Surface.Visible then
            continue
        end
        if Floats and Surface.Parent ~= Floats then
            continue
        end
        if not Library:MouseIsOverFrame(Surface, Point) then
            continue
        end

        local SiblingIndex = tonumber(select(2, pcall(function()
            setthreadidentity(8)
            return Surface:GetSiblingIndex()
        end))) or 0
        local Order = Surface.ZIndex * 100000 + SiblingIndex
        if Order >= BestOrder then
            BestOrder = Order
            Best = Surface
        end
    end

    return Best
end

local function GetPopOutBodyMaxHeight(Box: any, Reserved: number): number
    setthreadidentity(8)
    local Float = Box.PopOutFloat
    local ScreenGui = Library.ScreenGui
    if not Float or not ScreenGui then
        return math.huge
    end

    local Gap = 12 * Library.DPIScale
    local MaxBottom = ScreenGui.AbsolutePosition.Y + ScreenGui.AbsoluteSize.Y - Gap
    local Available = math.min(MaxBottom - Float.AbsolutePosition.Y, ScreenGui.AbsoluteSize.Y * 0.9)

    return math.max(0, Available / Library.DPIScale - Reserved)
end

--// Search
local function ApplySearchToTab(Tab, Search)
    setthreadidentity(8)
    if not Tab then
        return false, 0
    end

    local HasVisible = false
    local BestScore = 0

    --// If the Tab itself matches Search (by name/description), don't filter out its contents -- pull everything in the Tab along with it \\--
    local TabMatches = TryFuzzyMatch(Tab.Name, Search) or TryFuzzyMatch(Tab.Description, Search)
    BestScore = math.max(BestScore, FuzzyMatchScore(Tab.Name, Search), FuzzyMatchScore(Tab.Description, Search))

    for _, Groupbox in Tab.Groupboxes do
        if Groupbox.Visible == false then
            continue
        end

        --// Optional: matching the Groupbox's own name/description reveals every element inside it, without needing each one to match too
        local GroupboxMatches = TabMatches or (TryFuzzyMatch(Groupbox.Name, Search) or TryFuzzyMatch(Groupbox.Description, Search))
        BestScore = math.max(BestScore, FuzzyMatchScore(Groupbox.Name, Search), FuzzyMatchScore(Groupbox.Description, Search))

        local VisibleElements = 0
        for _, ElementInfo in Groupbox.Elements do
            if ElementInfo.Type == "List" then
                local ListVisible, ListScore = ApplySearchToList(ElementInfo, Search, GroupboxMatches)
                VisibleElements += ListVisible
                BestScore = math.max(BestScore, ListScore)
                continue
            elseif ElementInfo.Type == "Divider" then
                ElementInfo.Holder.Visible = false
                continue
            elseif ElementInfo.SubButton then
                --// Check if any of the Buttons Name matches with Search
                local Visible = false
                if MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                    Visible = true
                    BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
                else
                    ElementInfo.Base.Visible = false
                end

                if MatchesSearch(ElementInfo.SubButton, Search, GroupboxMatches) and ElementInfo.SubButton.Visible then
                    Visible = true
                    BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.SubButton.Text, Search))
                else
                    ElementInfo.SubButton.Base.Visible = false
                end

                ElementInfo.Holder.Visible = Visible
                if Visible then
                    VisibleElements += 1
                end

                continue
            end

            --// Check if Search matches Element's Name and if Element is Visible
            if ElementInfo.Text and MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                ElementInfo.Holder.Visible = true
                VisibleElements += 1
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
            else
                ElementInfo.Holder.Visible = false
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            local DepVisible, DepScore = CheckDepbox(Depbox, Search, GroupboxMatches)
            VisibleElements += DepVisible
            if DepScore > BestScore then
                BestScore = DepScore
            end
        end

        --// Update Groupbox Size and Visibility if found any element
        if VisibleElements > 0 then
            Groupbox:Resize()
            HasVisible = true
        end
        Groupbox.BoxHolder.Visible = VisibleElements > 0
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        local VisibleTabs = 0
        local VisibleElements = {}
        local SubTabScores = {}

        for _, SubTab in Tabbox.Tabs do
            VisibleElements[SubTab] = 0

            --// Optional: matching a Tabbox sub-tab's own name reveals every element inside it, without needing each one to match too
            local SubTabMatches = TabMatches or TryFuzzyMatch(SubTab.Name, Search)
            local SubScore = FuzzyMatchScore(SubTab.Name, Search)
            BestScore = math.max(BestScore, SubScore)

            for _, ElementInfo in SubTab.Elements do
                if ElementInfo.Type == "List" then
                    local ListVisible, ListScore = ApplySearchToList(ElementInfo, Search, SubTabMatches)
                    VisibleElements[SubTab] += ListVisible
                    SubScore = math.max(SubScore, ListScore)
                    BestScore = math.max(BestScore, ListScore)
                    continue
                elseif ElementInfo.Type == "Divider" then
                    ElementInfo.Holder.Visible = false
                    continue
                elseif ElementInfo.SubButton then
                    --// Check if any of the Buttons Name matches with Search
                    local Visible = false
                    if MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                        Visible = true
                        local ElementScore = FuzzyMatchScore(ElementInfo.Text, Search)
                        SubScore = math.max(SubScore, ElementScore)
                        BestScore = math.max(BestScore, ElementScore)
                    else
                        ElementInfo.Base.Visible = false
                    end

                    if MatchesSearch(ElementInfo.SubButton, Search, SubTabMatches) and ElementInfo.SubButton.Visible then
                        Visible = true
                        local ElementScore = FuzzyMatchScore(ElementInfo.SubButton.Text, Search)
                        SubScore = math.max(SubScore, ElementScore)
                        BestScore = math.max(BestScore, ElementScore)
                    else
                        ElementInfo.SubButton.Base.Visible = false
                    end

                    ElementInfo.Holder.Visible = Visible
                    if Visible then
                        VisibleElements[SubTab] += 1
                    end

                    continue
                end

                --// Check if Search matches Element's Name and if Element is Visible
                if ElementInfo.Text and MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                    ElementInfo.Holder.Visible = true
                    VisibleElements[SubTab] += 1
                    local ElementScore = FuzzyMatchScore(ElementInfo.Text, Search)
                    SubScore = math.max(SubScore, ElementScore)
                    BestScore = math.max(BestScore, ElementScore)
                else
                    ElementInfo.Holder.Visible = false
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                local DepVisible, DepScore = CheckDepbox(Depbox, Search, SubTabMatches)
                VisibleElements[SubTab] += DepVisible
                SubScore = math.max(SubScore, DepScore)
                BestScore = math.max(BestScore, DepScore)
            end

            SubTabScores[SubTab] = SubScore
        end

        local BestSubTab = nil
        local BestSubScore = -1

        for SubTab, Visible in VisibleElements do
            SubTab.ButtonHolder.Visible = Visible > 0
            if Visible > 0 then
                VisibleTabs += 1
                HasVisible = true

                local SubScore = SubTabScores[SubTab] or 0
                if SubScore > BestSubScore then
                    BestSubScore = SubScore
                    BestSubTab = SubTab
                end
            end
        end

        local ActiveSubTab = Tabbox.ActiveTab
        local ActiveSubVisible = ActiveSubTab and (VisibleElements[ActiveSubTab] or 0) > 0
        local ActiveSubScore = ActiveSubTab and (SubTabScores[ActiveSubTab] or -1) or -1

        if ActiveSubVisible and ActiveSubScore >= BestSubScore then
            ActiveSubTab:Resize()
        elseif BestSubTab then
            BestSubTab:Show()
        end

        --// Update Tabbox Visibility if any visible
        Tabbox.BoxHolder.Visible = VisibleTabs > 0
        SyncPopOutVisibility(Tabbox)
    end

    return HasVisible, BestScore
end
local function ResetTab(Tab)
    setthreadidentity(8)
    if not Tab then
        return
    end

    for _, Groupbox in Tab.Groupboxes do
        for _, ElementInfo in Groupbox.Elements do
            if ElementInfo.Type == "List" then
                RestoreList(ElementInfo)
                continue
            end

            ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

            if ElementInfo.SubButton then
                ElementInfo.Base.Visible = ElementInfo.Visible
                ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            RestoreDepbox(Depbox)
        end

        Groupbox:Resize()
        Groupbox.BoxHolder.Visible = Groupbox.Visible ~= false
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        for _, SubTab in Tabbox.Tabs do
            for _, ElementInfo in SubTab.Elements do
                if ElementInfo.Type == "List" then
                    RestoreList(ElementInfo)
                    continue
                end

                ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

                if ElementInfo.SubButton then
                    ElementInfo.Base.Visible = ElementInfo.Visible
                    ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                RestoreDepbox(Depbox)
            end

            SubTab.ButtonHolder.Visible = true
        end

        if Tabbox.ActiveTab then
            Tabbox.ActiveTab:Resize()
        end
        Tabbox.BoxHolder.Visible = true
        SyncPopOutVisibility(Tabbox)
    end
end

function Library:UpdateSearch(SearchText)
    setthreadidentity(8)
    Library.SearchText = SearchText

    local TabsToSearch = {}
    for _, Tab in Library.Tabs do
        if typeof(Tab) == "table" and not Tab.IsKeyTab then
            table.insert(TabsToSearch, Tab)
        end
    end

    for _, Tab in TabsToSearch do
        ResetTab(Tab)
    end

    local Search = NormalizeSearch(SearchText:lower())
    if Trim(Search) == "" then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end
    if not Library.GlobalSearch and Library.ActiveTab and Library.ActiveTab.IsKeyTab then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end

    Library.Searching = true

    local BestTab = nil
    local BestScore = -1
    local ActiveScore = -1
    local ActiveHasVisible = false

    for _, Tab in TabsToSearch do
        local HasVisible, Score = ApplySearchToTab(Tab, Search)
        if not HasVisible then
            continue
        end

        if Tab == Library.ActiveTab then
            ActiveHasVisible = true
            ActiveScore = Score
        end
        if Score > BestScore then
            BestScore = Score
            BestTab = Tab
        end
    end

    if not Library.GlobalSearch then
        for _, Tab in TabsToSearch do
            if Tab ~= BestTab then
                ResetTab(Tab)
            end
        end
    end

    local StayOnActive = ActiveHasVisible and ActiveScore >= BestScore
    if StayOnActive and Library.ActiveTab then
        Library.ActiveTab:RefreshSides()
    elseif BestTab then
        local SearchMarker = SearchText
        task.defer(function()
            setthreadidentity(8)
            if Library.SearchText ~= SearchMarker then
                return
            end

            if Library.ActiveTab ~= BestTab then
                BestTab:Show()
            elseif Library.ActiveTab then
                Library.ActiveTab:RefreshSides()
            end
        end)
    end

    Library.LastSearchTab = nil
end

function Library:AddToRegistry(Instance, Properties)
    setthreadidentity(8)
    Library.Registry[Instance] = Properties
end

function Library:RemoveFromRegistry(Instance)
    setthreadidentity(8)
    Library.Registry[Instance] = nil
end

function Library:UpdateColorsUsingRegistry()
    setthreadidentity(8)
    for Instance, Properties in Library.Registry do
        for Property, Index in Properties do
            local SchemeValue = GetSchemeValue(Index)

            if SchemeValue or typeof(Index) == "function" then
                Instance[Property] = SchemeValue or Index()
            end
        end
    end
end

function Library:SetDPIScale(DPIScale: number)
    setthreadidentity(8)
    Library.DPIScale = DPIScale / 100
    Library.MinSize = Library.OriginalMinSize * Library.DPIScale

    for _, UIScale in Library.Scales do
        UIScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[UIScale]) or 0)
    end

    for _, Option in Options do
        if Option.Type == "Dropdown" then
            Option:RecalculateListSize()
            Option:RefreshPool()
        end
    end

    for _, Notification in Library.Notifications do
        Notification:Resize()
    end

    (Library :: any):UpdateNotificationPositions(true)
end

function Library:GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
    setthreadidentity(8)
    local ConnectionType = typeof(Connection)
    if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
        table.insert(Library.Signals, Connection)
    end

    return Connection
end

function Library:GetLuarmorKeyStatus(Overrides: { [string]: any }?): { [string]: any }
    setthreadidentity(8)
    local Info = table.clone(Overrides or {})
    local IsPremium = LRM_IsUserPremium
    local SecondsLeft = LRM_SecondsLeft
    local UserNote = tostring(LRM_UserNote or "")
    local ScriptVersion = tostring(LRM_ScriptVersion or "")
    local NormalizedNote = string.lower((string.gsub(UserNote, "^%s*(.-)%s*$", "%1")))
    local Environment = getgenv and getgenv() or _G
    local ScriptKey = type(Environment) == "table" and rawget(Environment, "script_key") or nil
    local HasScriptKey = typeof(ScriptKey) == "string" and ScriptKey ~= ""
    local IsDeveloper = Info.Developer == true or NormalizedNote == "developer"
    local IsDevelopmentEnvironment = string.upper(ScriptVersion) == "IN-DEV"

    Info.Provider = "Luarmor"
    Info.Developer = IsDeveloper or IsDevelopmentEnvironment
    Info.Status = if IsDevelopmentEnvironment
        then "IN-DEV"
        elseif IsDeveloper then "Developer"
        else Info.Status or (if IsPremium == true or HasScriptKey then "Premium" else "Freemium")

    if IsDevelopmentEnvironment then
        Info.RemainingTime = math.huge
        Info.Lifetime = math.huge
        Info.LifetimeText = "IN-DEV"
        Info.DurationLabel = "Environment"
    elseif Info.RemainingTime == nil and typeof(SecondsLeft) == "number" then
        Info.RemainingTime = if SecondsLeft < 0 then math.huge else SecondsLeft
    end

    if Info.Lifetime == nil and typeof(Info.RemainingTime) == "number" then
        Info.Lifetime = Info.RemainingTime
    end

    if Info.LifetimeText == nil and Info.RemainingTime == math.huge then
        Info.LifetimeText = "Lifetime"
    elseif Info.LifetimeText == nil and Info.RemainingTime == nil and (IsDeveloper or IsPremium == true or HasScriptKey) then
        Info.LifetimeText = "Expiration unavailable"
    end

    return Info
end

function Library:GetAnonymousMode(): boolean
    setthreadidentity(8)
    return Library.AnonymousMode == true
end

function Library:SetAnonymousMode(State: boolean)
    setthreadidentity(8)
    assert(typeof(State) == "boolean", "Anonymous mode must be a boolean")

    Library.AnonymousMode = State
    Library.Flags.AnonymousMode = State

    for _, Component in Library.KeyStatusComponents do
        if not Component.Destroyed and typeof(Component.ApplyAnonymousMode) == "function" then
            Component:ApplyAnonymousMode(State)
        end
    end

    local Toggle = Library.AnonymousModeToggle
    if Toggle and not Toggle.Destroyed and Toggle.Value ~= State then
        Toggle:SetValue(State)
    end
end

function Library:GetFeatureBadges(Info: { [string]: any }?): { string }
    setthreadidentity(8)
    local Badges = {}
    local Added = {}

    local function AddBadge(Value: unknown)
        setthreadidentity(8)
        if typeof(Value) ~= "string" then
            return
        end

        local NormalizedValue = string.lower(Value)
        for Name in Library.FeatureBadgeStatuses do
            if string.lower(Name) == NormalizedValue and not Added[Name] then
                Added[Name] = true
                table.insert(Badges, Name)
                return
            end
        end
    end

    if typeof(Info) == "table" then
        AddBadge(Info.Status)

        if typeof(Info.Badges) == "string" then
            AddBadge(Info.Badges)
        elseif typeof(Info.Badges) == "table" then
            for Key, Value in Info.Badges do
                if typeof(Key) == "number" then
                    AddBadge(Value)
                elseif Value == true then
                    AddBadge(Key)
                end
            end
        end

        for Name in Library.FeatureBadgeStatuses do
            if Info[Name] == true then
                AddBadge(Name)
            end
        end
    end

    table.sort(Badges, function(First: string, Second: string): boolean
        setthreadidentity(8)
        return Library.FeatureBadgeStatuses[First].Priority < Library.FeatureBadgeStatuses[Second].Priority
    end)
    return Badges
end

function Library:FormatFeatureText(Text: string, Badges: { string }?): string
    setthreadidentity(8)
    assert(typeof(Text) == "string", "Feature text must be a string")

    if typeof(Badges) ~= "table" or #Badges == 0 then
        return Text
    end

    local Parts = table.create(#Badges)
    for Index, Name in Badges do
        local Status = Library.FeatureBadgeStatuses[Name]
        if not Status then
            continue
        end

        local Color = Status.Color
        local Red = math.round(Color.R * 255)
        local Green = math.round(Color.G * 255)
        local Blue = math.round(Color.B * 255)
        Parts[Index] = `<font color="rgb({Red},{Green},{Blue})">[{string.upper(Name)}]</font>`
    end

    return `{Text}  {table.concat(Parts, " ")}`
end

function Library:BindFeatureBadges(Element: { [string]: any }, Info: { [string]: any }, UpdateDisplay: (string) -> ()): ()
    setthreadidentity(8)
    local Badges = Library:GetFeatureBadges(Info)
    Element.Badges = Badges

    function Element:SetFeatureBadges(NewBadges: string | { string } | { [string]: boolean })
        setthreadidentity(8)
        local BadgeInfo = { Badges = NewBadges }
        Element.Badges = Library:GetFeatureBadges(BadgeInfo)
        UpdateDisplay(Library:FormatFeatureText(Element.Text or "", Element.Badges))

        if Element.Command and not Element.Command.Destroyed then
            Element.Command.Badges = table.clone(Element.Badges)
            if Library.CommandPalette and Library.CommandPalette.Visible then
                Library.CommandPalette:Refresh()
            end
        end
    end

    function Element:GetFeatureBadges(): { string }
        setthreadidentity(8)
        return table.clone(Element.Badges)
    end

    UpdateDisplay(Library:FormatFeatureText(Element.Text or "", Badges))
end

function Library:RegisterElementCommand(Element: { [string]: any }, Groupbox: { [string]: any }, Info: { [string]: any })
    setthreadidentity(8)
    local Window = Library.Window
    if not Window or typeof(Window.RegisterCommand) ~= "function" or Info.CommandPalette == false then
        return
    end

    local Text = Info.CommandName or Element.Text
    if typeof(Text) ~= "string" or Text == "" then
        return
    end

    local Tab = Groupbox.Tab
    local TabName = Tab and Tab.Name or "Interface"
    local GroupboxName = Groupbox.Name or "Controls"

    Element.Command = Window:RegisterCommand({
        Id = `Element:{tostring(Element)}`,
        Name = Text,
        Description = Info.CommandDescription or `{TabName} / {GroupboxName}`,
        Keywords = Info.CommandKeywords,
        Badges = Element.Badges,
        Element = Element,
        Action = function()
            setthreadidentity(8)
            Window:RevealElement(Element, Groupbox)

            if typeof(Info.CommandAction) == "function" then
                Library:SafeCallback(Info.CommandAction, Element)
            elseif Element.Type == "Toggle" and not Element.Disabled then
                Element:SetValue(not Element.Value)
            elseif Element.Type == "Button" and not Element.Disabled and not Element.Risky and not Element.DoubleClick then
                Library:SafeCallback(Element.Func)
            end
        end,
    })
end

function IsValidCustomIcon(Icon: string)
    setthreadidentity(8)
    return typeof(Icon) == "string" and (Icon:match("^rbxasset://textures/") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

local function IsCustomAssetIcon(Icon: string, IncludeAssetId: boolean)
    setthreadidentity(8)
    return typeof(Icon) == "string" and (Icon:match("^content://") or (Icon:match("^rbxasset://%x+/") or Icon:match("^rbxasset://[^/]+/")) or (IncludeAssetId == true and Icon:match("^rbxassetid://")))
end

type Icon = {
    Url: string,
    Id: number,
    IconName: string,
    ImageRectOffset: Vector2,
    ImageRectSize: Vector2,
}

type IconModule = {
    Icons: { string },
    GetAsset: (Name: string) -> Icon?,
}

local FetchIcons = false
local Icons: IconModule | nil = nil

function Library:GetIcon(IconName: string)
    setthreadidentity(8)
    if not FetchIcons or not Icons then
        return
    end

    local Success, Icon = pcall(Icons.GetAsset, IconName)
    if not Success then
        return
    end

    return Icon
end

function Library:GetCustomIcon(IconName: string): any
    setthreadidentity(8)
    if not IconName then
        return nil
    end

    if tonumber(IconName) then
        IconName = string.format("rbxassetid://%s", tostring(IconName))
    end

    if IsCustomAssetIcon(IconName, true) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
        }
    elseif IsValidCustomIcon(IconName) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true,
        }
    end

    local LucideIcon = Library:GetIcon(IconName)
    if LucideIcon then
        return LucideIcon
    end

    return nil
end

function Library:ApplyLucideIcon(ImageGui: any, Icon: any, Rotation: number?)
    setthreadidentity(8)
    if not ImageGui or not Icon then
        return
    end

    if not (ImageGui:IsA("ImageLabel") or ImageGui:IsA("ImageButton")) then
        return
    end

    ImageGui.Image = Icon.Url or ImageGui.Image
    ImageGui.ImageRectOffset = Icon.ImageRectOffset or ImageGui.ImageRectOffset
    ImageGui.ImageRectSize = Icon.ImageRectSize or ImageGui.ImageRectSize
    ImageGui.Rotation = Rotation or ImageGui.Rotation
end

function Library:Validate(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
    setthreadidentity(8)
    if typeof(Table) ~= "table" then
        return Template
    end

    for k, v in Template do
        if typeof(k) == "number" then
            continue
        end

        if typeof(v) == "table" then
            Table[k] = Library:Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end

    return Table
end

--// Creator Functions \\--
local function FillInstance(Table: { [string]: any }, Instance: GuiObject)
    setthreadidentity(8)
    local ThemeProperties = Library.Registry[Instance] or {}

    for key, value in Table do
        if key ~= "Text" then
            local SchemeValue = GetSchemeValue(value)

            if SchemeValue or typeof(value) == "function" then
                ThemeProperties[key] = value
                value = SchemeValue or value()
            else
                ThemeProperties[key] = nil
            end
        end

        Instance[key] = value
    end

    if GetTableSize(ThemeProperties) > 0 then
        Library.Registry[Instance] = ThemeProperties
    end
end

local function New(ClassName: string, Properties: { [string]: any }): any
    setthreadidentity(8)
    setthreadidentity(8)
    local Instance = Instance.new(ClassName)

    if Templates[ClassName] then
        FillInstance(Templates[ClassName], Instance)
    end
    FillInstance(Properties, Instance)

    if Properties["Parent"] and not Properties["ZIndex"] then
        pcall(function()
            setthreadidentity(8)
            Instance.ZIndex = Properties.Parent.ZIndex
        end)
    end

    return Instance
end

--// Main Instances \\-
local function SafeParentUI(Instance: Instance, Parent: Instance | () -> Instance)
    setthreadidentity(8)
    local success, _error = pcall(function()
        setthreadidentity(8)
        if not Parent then
            Parent = CoreGui
        end

        local DestinationParent
        if typeof(Parent) == "function" then
            DestinationParent = Parent()
        else
            DestinationParent = Parent
        end

        Instance.Parent = DestinationParent
    end)

    if not (success and Instance.Parent) then
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function ParentUI(UI: Instance, SkipHiddenUI: boolean?)
    setthreadidentity(8)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end

    pcall(protectgui, UI)
    SafeParentUI(UI, gethui)
end

local function SetAlwaysOnTop(Gui: ScreenGui, Enabled: boolean)
    setthreadidentity(8)
    if not Gui then
        return
    end

    pcall(function()
        setthreadidentity(8)
        if sethiddenproperty then
            sethiddenproperty(Gui, "OnTopOfCoreBlur", Enabled)
        elseif setscriptable then
            setscriptable(Gui, "OnTopOfCoreBlur", true)
            Gui.OnTopOfCoreBlur = Enabled
            setscriptable(Gui, "OnTopOfCoreBlur", false)
        end
    end)
end

local ScreenGui = New("ScreenGui", {
    Name = "Obsidian",
    DisplayOrder = 998,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui

ScreenGui.DescendantRemoving:Connect(function(Instance)
    setthreadidentity(8)
    task.defer(function()
        setthreadidentity(8)
        if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
            return
        end

        Library:RemoveFromRegistry(Instance)
    end)
end)

local ModalElement = New("TextButton", {
    BackgroundTransparency = 1,
    Modal = false,
    Size = UDim2.fromScale(0, 0),
    AnchorPoint = Vector2.zero,
    Text = "",
    ZIndex = -999,
    Parent = ScreenGui,
})

--// Floats and Overlays
local Floats = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 10,
    Active = false,
    Parent = ScreenGui,
})

local Overlay = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 20,
    Active = false,
    Parent = ScreenGui,
})

Library.Floats = Floats
Library.Overlay = Overlay

--// Cursor
local Cursor, CursorCustomImage
do
    Cursor = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(9, 1),
        Visible = false,
        ZIndex = 11000,
        Parent = ScreenGui,
    })

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 2, 1, 2),
        ZIndex = 1,
        Parent = Cursor,
    })
    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        ZIndex = 2,
        Parent = Cursor,
    })

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(3, 11),
        ZIndex = 1,
        Parent = Cursor,
    })
    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(1, 9),
        ZIndex = 2,
        Parent = Cursor,
    })

    CursorCustomImage = New("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 3,
        Visible = false,
        Parent = Cursor,
    })
end

local function RestoreMouseIcon()
    setthreadidentity(8)
    pcall(function()
        setthreadidentity(8)
        RunService:UnbindFromRenderStep(Library.ShowCursorBinding)
        RunService.RenderStepped:Wait()
    end)

    UserInputService.MouseIconEnabled = Library.OriginalMouseIconEnabled
    if Cursor then Cursor.Visible = false end
end

--// Notification \\--
local NotificationArea
local NotifyOrder = {}
do
    NotificationArea = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.new(0, 300, 1, -6),
        ZIndex = 200,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = NotificationArea,
        })
    )
end

Library:GiveSignal(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function(): ()
    setthreadidentity(8)
    for _, notification in Library.Notifications do notification:Resize() end
    if Library.UpdateNotificationPositions then Library:UpdateNotificationPositions(true) end
end))

--// Icons \\--
local CheckIcon, ArrowIcon, PriorityUpIcon, PriorityDownIcon, ResizeIcon, KeyIcon, MoveIcon, PopOutIcon, CloseIcon
function Library:SetIconModule(module: IconModule)
    setthreadidentity(8)
    FetchIcons = true
    Icons = module

    CheckIcon = Library:GetIcon("check")
    ArrowIcon = Library:GetIcon("chevron-up")
    PriorityUpIcon = Library:GetIcon("arrow-up")
    PriorityDownIcon = Library:GetIcon("arrow-down")
    ResizeIcon = Library:GetIcon("move-diagonal-2")
    KeyIcon = Library:GetIcon("key")
    MoveIcon = Library:GetIcon("move")
    PopOutIcon = Library:GetIcon("square-arrow-down-left")
    CloseIcon = Library:GetIcon("x")
end

local OnlineFetchIcons, OnlineIcons = pcall(function()
    setthreadidentity(8)
    return (loadstring(
        game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua")
    ) :: () -> IconModule)()
end)
if OnlineFetchIcons and OnlineIcons then
    Library:SetIconModule(OnlineIcons)
end

--// Lib Functions \\--
function Library:ResetCursorIcon()
    setthreadidentity(8)
    CursorCustomImage.Visible = false
    CursorCustomImage.Size = UDim2.fromOffset(20, 20)
end

function Library:ChangeCursorIcon(ImageId: string)
    setthreadidentity(8)
    if not ImageId or ImageId == "" then
        Library:ResetCursorIcon()
        return
    end

    local Icon = Library:GetCustomIcon(ImageId)
    assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

    CursorCustomImage.Visible = true
    Library:ApplyLucideIcon(CursorCustomImage, Icon)
end

function Library:ChangeCursorIconSize(Size: UDim2)
    setthreadidentity(8)
    assert(typeof(Size) == "UDim2", "UDim2 expected.")
    CursorCustomImage.Size = Size
end

function Library:GetBetterColor(Color: Color3, Add: number): Color3
    setthreadidentity(8)
    Add = Add * (Library.IsLightTheme and -4 or 2)
    return Color3.fromRGB(
        math.clamp(Color.R * 255 + Add, 0, 255),
        math.clamp(Color.G * 255 + Add, 0, 255),
        math.clamp(Color.B * 255 + Add, 0, 255)
    )
end

function Library:GetLighterColor(Color: Color3): Color3
    setthreadidentity(8)
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, math.max(0, S - 0.1), math.min(1, V + 0.1))
end

function Library:GetDarkerColor(Color: Color3): Color3
    setthreadidentity(8)
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, S, V / 2)
end

function Library:GetKeyString(KeyCode: Enum.KeyCode)
    setthreadidentity(8)
    if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
        return string.char(KeyCode.Value)
    end

    return KeyCode.Name
end

function Library:GetTextBounds(Text: string, Font: Font, Size: number, Width: number?): (number, number)
    setthreadidentity(8)

    local width = Width or workspace.CurrentCamera.ViewportSize.X - 32
    local parameters = Instance.new("GetTextBoundsParams")
    parameters.Text = Text
    parameters.RichText = true
    parameters.Font = Font
    parameters.Size = Size
    parameters.Width = width

    local success, bounds = pcall(TextService.GetTextBoundsAsync, TextService, parameters)
    if success and typeof(bounds) == "Vector2" then
        return bounds.X, bounds.Y
    end

    local legacySuccess, legacyBounds = pcall(
        TextService.GetTextSize,
        TextService,
        Text,
        Size,
        Font.Weight.Value >= Enum.FontWeight.Bold.Value and Enum.Font.GothamBold or Enum.Font.Gotham,
        Vector2.new(width, 1e6)
    )
    if legacySuccess and typeof(legacyBounds) == "Vector2" then
        return legacyBounds.X, legacyBounds.Y
    end

    local characterWidth = Size * 0.55
    local estimatedWidth = math.min(width, #Text * characterWidth)
    local estimatedLines = math.max(1, math.ceil(#Text * characterWidth / math.max(width, 1)))
    return estimatedWidth, estimatedLines * Size
end

function Library:MouseIsOverFrame(Frame: GuiObject, Mouse: Vector2): boolean
    setthreadidentity(8)
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    return Mouse.X >= AbsPos.X
        and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y
        and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

function Library:IsInsideFrame(ParentFrame: GuiObject, Frame: GuiObject)
    setthreadidentity(8)
    local GuiPos = Frame.AbsolutePosition
    local GuiSize = Frame.AbsoluteSize

    local FramePos = ParentFrame.AbsolutePosition
    local FrameSize = ParentFrame.AbsoluteSize

    return GuiPos.X >= FramePos.X
        and GuiPos.X + GuiSize.X <= FramePos.X + FrameSize.X
        and GuiPos.Y >= FramePos.Y
        and GuiPos.Y + GuiSize.Y <= FramePos.Y + FrameSize.Y
end

function Library:SafeCallback(Func: (...any) -> ...any, ...: any)
    setthreadidentity(8)
    if not (Func and typeof(Func) == "function") then
        return
    end

    local Result = table.pack(xpcall(Func, function(Error)
        setthreadidentity(8)
        task.defer(error, debug.traceback(Error, 2))
        if Library.NotifyOnError and Library.Notify then
            Library:Notify(Error)
        end

        return Error
    end, ...))

    if not Result[1] then
        return nil
    end

    return table.unpack(Result, 2, Result.n)
end

function GetOverlappingDraggable(UI: GuiObject, TargetPos: Vector2?)
    setthreadidentity(8)
    local Pos1 = TargetPos or UI.AbsolutePosition
    local Size1 = UI.AbsoluteSize

    for _, Other in ipairs(Library.DraggableElements) do
        if Other == UI or not Other.Visible or not Other.Parent then
            continue
        end

        local Pos2 = Other.AbsolutePosition
        local Size2 = Other.AbsoluteSize

        if Pos1.X < Pos2.X + Size2.X and
            Pos1.X + Size1.X > Pos2.X and
            Pos1.Y < Pos2.Y + Size2.Y and
            Pos1.Y + Size1.Y > Pos2.Y then
            return Other
        end
    end

    return nil
end

function GetNonOverlappingPosition(UI: GuiObject, StartPos: UDim2?)
    setthreadidentity(8)
    local ScreenSize = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)) - Vector2.new(100, 100)
    local Start = StartPos and Vector2.new(StartPos.X.Offset, StartPos.Y.Offset) or Vector2.new(6, 6)
    local Padding = 6

    local CurrentX = Start.X
    local CurrentY = Start.Y

    local Size = UI.AbsoluteSize
    if Size.X == 0 and Size.Y == 0 then
        RunService.RenderStepped:Wait()
        Size = UI.AbsoluteSize
    end

    if Size.X == 0 then Size = Vector2.new(150, 40) end

    local MaxXInColumn = Size.X

    while true do
        local Obstacle = GetOverlappingDraggable(UI, Vector2.new(CurrentX, CurrentY))
        if not Obstacle then
            break
        end

        if Obstacle.AbsoluteSize.X > MaxXInColumn then
            MaxXInColumn = Obstacle.AbsoluteSize.X
        end

        local NextY = Obstacle.AbsolutePosition.Y + Obstacle.AbsoluteSize.Y + Padding
        if NextY + Size.Y > ScreenSize.Y - Padding then
            local NextX = CurrentX + MaxXInColumn + Padding

            if NextX + Size.X > ScreenSize.X - Padding then
                break
            end

            CurrentY = Start.Y
            CurrentX = NextX
            MaxXInColumn = Size.X
        else
            CurrentY = NextY
        end
    end

    return UDim2.fromOffset(CurrentX, CurrentY)
end

function PositionDraggable(UI: GuiObject, StartPos: UDim2?)
    setthreadidentity(8)
    UI.Position = GetNonOverlappingPosition(UI, StartPos)
end

--// Window Snapping \\--
local function GetCoreGuiInset(): (Vector2, Vector2)
    setthreadidentity(8)
    local Success, TopLeft, BottomRight = pcall(function()
        setthreadidentity(8)
        return GuiService:GetGuiInset()
    end)

    if Success and TopLeft and BottomRight then
        return TopLeft, BottomRight
    end

    return Vector2.zero, Vector2.zero
end

local function GetSnapEdges(ElemSize: Vector2, ViewportSize: Vector2, Margin: number, AvoidCoreGui: boolean)
    setthreadidentity(8)
    local SafeMin, SafeMax = Vector2.zero, ViewportSize

    if AvoidCoreGui then
        local TopLeftInset, BottomRightInset = GetCoreGuiInset()
        SafeMin = TopLeftInset
        SafeMax = ViewportSize - BottomRightInset
    end

    local TargetsX = {
        LeftEdge = SafeMin.X + Margin,
        Center = SafeMin.X + (SafeMax.X - SafeMin.X - ElemSize.X) / 2,
        RightEdge = SafeMax.X - ElemSize.X - Margin,
    }
    local TargetsY = {
        TopEdge = SafeMin.Y + Margin,
        Center = SafeMin.Y + (SafeMax.Y - SafeMin.Y - ElemSize.Y) / 2,
        BottomEdge = SafeMax.Y - ElemSize.Y - Margin,
    }

    return TargetsX, TargetsY
end

local function GetClosestSnapTarget(Value: number, Targets: { [string]: number }, Distance: number): (number?, string?)
    setthreadidentity(8)
    local ClosestName, ClosestValue, ClosestDist = nil, nil, Distance

    for Name, Target in Targets do
        local Dist = math.abs(Value - Target)
        if Dist <= ClosestDist then
            ClosestDist = Dist
            ClosestName = Name
            ClosestValue = Target
        end
    end

    return ClosestValue, ClosestName
end

local function GetSnapGuideOffset(Name: string, SnappedValue: number, ElemDimension: number): number
    setthreadidentity(8)
    if Name == "RightEdge" or Name == "BottomEdge" then
        return SnappedValue + ElemDimension
    elseif Name == "Center" then
        return SnappedValue + ElemDimension / 2
    end

    return SnappedValue -- LeftEdge / TopEdge
end

function Library:MakeDraggable(
    UI: GuiObject,
    DragFrame: GuiObject,
    IgnoreToggled: boolean?,
    IsMainWindow: boolean?,
    SnapConfig: { Enabled: boolean, Distance: number?, Margin: number?, AvoidCoreGui: boolean? }?
)
    setthreadidentity(8)
    local StartPos
    local FramePos
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    local SnapGuideX, SnapGuideY

    local function GetSnapGuides()
        setthreadidentity(8)
        if not SnapGuideX then
            SnapGuideX = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0, 2, 1, 0),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end

        if not SnapGuideY then
            SnapGuideY = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end

        return SnapGuideX, SnapGuideY
    end

    local function HideSnapGuides()
        setthreadidentity(8)
        if SnapGuideX then
            SnapGuideX.Visible = false
        end
        if SnapGuideY then
            SnapGuideY.Visible = false
        end
    end

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        setthreadidentity(8)
        if not IsClickInput(Input) or IsMainWindow and Library.CantDragForced then
            return
        end

        StartPos = Input.Position
        FramePos = UI.Position
        Dragging = true

        Changed = Input.Changed:Connect(function()
            setthreadidentity(8)
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            HideSnapGuides()

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        setthreadidentity(8)
        if
            (not IgnoreToggled and not Library.Toggled)
            or (IsMainWindow and Library.CantDragForced)
            or not (ScreenGui and ScreenGui.Parent)
        then
            Dragging = false
            HideSnapGuides()

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            local NewX = FramePos.X.Offset + Delta.X
            local NewY = FramePos.Y.Offset + Delta.Y

            if SnapConfig and SnapConfig.Enabled then
                local ViewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
                local Distance = SnapConfig.Distance or 28
                local Margin = SnapConfig.Margin or 8

                local AbsX = FramePos.X.Scale * ViewportSize.X + NewX
                local AbsY = FramePos.Y.Scale * ViewportSize.Y + NewY

                local ElemSize = UI.AbsoluteSize
                local TargetsX, TargetsY = GetSnapEdges(ElemSize, ViewportSize, Margin, SnapConfig.AvoidCoreGui ~= false)
                local SnappedX, SnappedXName = GetClosestSnapTarget(AbsX, TargetsX, Distance)
                local SnappedY, SnappedYName = GetClosestSnapTarget(AbsY, TargetsY, Distance)

                if SnappedX then
                    NewX = SnappedX - FramePos.X.Scale * ViewportSize.X
                end
                if SnappedY then
                    NewY = SnappedY - FramePos.Y.Scale * ViewportSize.Y
                end

                local GuideX, GuideY = GetSnapGuides()
                GuideX.Visible = SnappedX ~= nil
                if SnappedX then
                    GuideX.Position = UDim2.fromOffset(GetSnapGuideOffset(SnappedXName, SnappedX, ElemSize.X), 0)
                end

                GuideY.Visible = SnappedY ~= nil
                if SnappedY then
                    GuideY.Position = UDim2.fromOffset(0, GetSnapGuideOffset(SnappedYName, SnappedY, ElemSize.Y))
                end
            end

            UI.Position = UDim2.new(FramePos.X.Scale, NewX, FramePos.Y.Scale, NewY)
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        setthreadidentity(8)
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        if SnapGuideX then
            SnapGuideX:Destroy()
        end
        if SnapGuideY then
            SnapGuideY:Destroy()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeResizable(UI: GuiObject, DragFrame: GuiObject, Callback: () -> ()?)
    setthreadidentity(8)
    local StartPos
    local FrameSize
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        setthreadidentity(8)
        if not IsClickInput(Input) then
            return
        end

        StartPos = Input.Position
        FrameSize = UI.Size
        Dragging = true

        Changed = Input.Changed:Connect(function()
            setthreadidentity(8)
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        setthreadidentity(8)
        if not UI.Visible or not (ScreenGui and ScreenGui.Parent) then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            UI.Size = UDim2.new(
                FrameSize.X.Scale,
                math.clamp(FrameSize.X.Offset + Delta.X, Library.MinSize.X, math.huge),
                FrameSize.Y.Scale,
                math.clamp(FrameSize.Y.Offset + Delta.Y, Library.MinSize.Y, math.huge)
            )
            if Callback then
                Library:SafeCallback(Callback)
            end
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        setthreadidentity(8)
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeCover(Holder: GuiObject, Place: string)
    setthreadidentity(8)
    local Pos = Places[Place] or { 0, 0 }
    local Size = Sizes[Place] or { 1, 0.5 }

    local Cover = New("Frame", {
        AnchorPoint = Vector2.new(Pos[1], Pos[2]),
        BackgroundColor3 = Holder.BackgroundColor3,
        Position = UDim2.fromScale(Pos[1], Pos[2]),
        Size = UDim2.fromScale(Size[1], Size[2]),
        Parent = Holder,
    })

    return Cover
end

function Library:MakeLine(Frame: GuiObject, Info)
    setthreadidentity(8)
    local Line = New("Frame", {
        AnchorPoint = Info.AnchorPoint or Vector2.zero,
        BackgroundColor3 = "OutlineColor",
        LayoutOrder = Info.LayoutOrder or 0,
        Position = Info.Position,
        Size = Info.Size,
        ZIndex = Info.ZIndex or Frame.ZIndex,
        Parent = Frame,
    })

    return Line
end

function Library:AddOutline(Frame: GuiObject)
    setthreadidentity(8)
    local OutlineStroke = New("UIStroke", {
        Color = "OutlineColor",
        Thickness = 1,
        ZIndex = 2,
        Parent = Frame,
    })
    local ShadowStroke = New("UIStroke", {
        Color = "DarkColor",
        Thickness = 1.5,
        ZIndex = 1,
        Parent = Frame,
    })
    return OutlineStroke, ShadowStroke
end

function Library:AddBlank(Frame: GuiObject, Size: UDim2)
    setthreadidentity(8)
    return New("Frame", {
        BackgroundTransparency = 1,
        Size = Size or UDim2.fromScale(0, 0),
        Parent = Frame,
    })
end

--// Animations \\--
local TransparencyCache = {}
local ActiveTabTweens = setmetatable({}, { __mode = "k" })

function Library:PlayTabAnimation(Tab, Showing: boolean, OnComplete: (() -> ())?)
    setthreadidentity(8)
    local tabData = type(Tab) == "table" and Tab or nil
    local TabContainer = if tabData then tabData.Container else Tab
    if typeof(TabContainer) ~= "Instance" or not TabContainer:IsA("GuiObject") then
        if OnComplete then
            OnComplete()
        end

        return
    end

    local Existing = ActiveTabTweens[TabContainer]
    if Existing then
        StopTween(Existing, true)
        ActiveTabTweens[TabContainer] = nil
    end

    local BaseZIndex = TabContainer.ZIndex
    if not (Library.Animations and Library.Animations.TabSwitch) then
        TabContainer.Visible = Showing
        TabContainer.Position = UDim2.fromScale(0, 0)
        TabContainer.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end

        return
    end

    if Showing then
        local TweenInfo = Library.TabTransitionInfo or TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local Offset = Library.TabSwipeOffset or 26
        local SwipeFrom = string.lower(Library.TabSwipeFrom or "bottom")
        local StartPosition
        local StartingPositions = {
            Left = UDim2.fromOffset(-Offset, 0),
            Right = UDim2.fromOffset(Offset, 0),
            Top = UDim2.fromOffset(0, -Offset),
            Bottom = UDim2.fromOffset(0, Offset),
        }

        if SwipeFrom == "auto" and tabData and tabData.Button and Library.PreviousTab then
            local CurrentOrder = tabData.Button.LayoutOrder
            local PreviousOrder = Library.PreviousTab.Button.LayoutOrder
            if CurrentOrder and PreviousOrder then -- this may be unnecessary but oh well
                StartPosition = CurrentOrder > PreviousOrder and StartingPositions.Top or StartingPositions.Bottom -- bigger order means its under the current button
            else
                StartPosition = StartingPositions.Bottom
            end
        elseif SwipeFrom == "left" then
            StartPosition = StartingPositions.Left
        elseif SwipeFrom == "top" then
            StartPosition = StartingPositions.Top
        elseif SwipeFrom == "right" then
            StartPosition = StartingPositions.Right
        else -- bottom (Default)
            StartPosition = StartingPositions.Bottom
        end

        TabContainer.ZIndex = BaseZIndex + 1
        TabContainer.Position = StartPosition
        TabContainer.Visible = true

        local Tween = TweenService:Create(TabContainer, TweenInfo, {
            Position = UDim2.fromScale(0, 0)
        })

        ActiveTabTweens[TabContainer] = Tween
        Tween:Play()

        local Connection; Connection = Tween.Completed:Connect(function(PlaybackState)
            setthreadidentity(8)
            if Connection then
                Connection:Disconnect()
            end

            if ActiveTabTweens[TabContainer] == Tween then
                ActiveTabTweens[TabContainer] = nil
            end

            if PlaybackState == Enum.PlaybackState.Cancelled then
                return
            end

            TabContainer.ZIndex = BaseZIndex
            if OnComplete then
                OnComplete()
            end
        end)
    else
        TabContainer.Visible = false
        TabContainer.Position = UDim2.fromScale(0, 0)
        TabContainer.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end
    end
end

--// Pop Out \\--
function Library:MakeBoxPopOut(Box: any, Options: {
    Enabled: boolean?,
    Header: GuiObject?,
    Children: (() -> { GuiObject })?,
    Before: (() -> ())?,
    After: (() -> ())?,
})
    setthreadidentity(8)
    Box.PoppedOut = false
    Box.PopOutEnabled = Options.Enabled ~= false
    Box.PopOutFloat = nil
    Box.PopOutPlaceholder = nil

    if not Box.PopOutEnabled then
        function Box:SetPoppedOut(_Value: boolean, _SetPoppedOut: UDim2)
            setthreadidentity(8)
        end
        function Box:TogglePoppedOut()
            setthreadidentity(8)
        end
        function Box:RefreshPopOutPlaceholder()
            setthreadidentity(8)
        end
        return
    end

    local BoxHolder = Box.BoxHolder
    local Holder = Box.Holder
    local Header = Options.Header

    local Placeholder
    local PlaceholderHeader
    local Float
    local FloatScale

    local HandledChildren: { GuiObject } = {}
    local OriginalParents: { [GuiObject]: Instance? } = {}
    local OriginalLayoutOrders: { [GuiObject]: number } = {}

    local DragState: "Idle" | "Holding" | "Dragging" = "Idle"
    local DragInput: InputObject?
    local PressMouse: Vector2?

    local DragStartPos: UDim2?
    local DragChanged: RBXScriptConnection?
    local DragDidMove = false

    --// UI Handler
    local function RaiseFloat()
        setthreadidentity(8)
        if not Float or not Floats then
            return
        end

        local MaxZ = Float.ZIndex
        for _, Child in Floats:GetChildren() do
            if Child:IsA("GuiObject") and Child ~= Float then
                MaxZ = math.max(MaxZ, Child.ZIndex)
            end
        end

        Float.ZIndex = MaxZ + 1
        if Float.Parent == Floats then
            Float.Parent = Overlay
        end
        Float.Parent = Floats
    end

    local function CreatePlaceholder()
        setthreadidentity(8)
        local Frame = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 0.12,
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = BoxHolder,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius),
                Parent = Frame,
            })
        )
        Library:AddOutline(Frame)

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Frame
        DimPopOutClone(PlaceholderHeader)

        if PopOutIcon then
            local PlaceholderDockIcon = New("ImageButton", {
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                ImageColor3 = "WhiteColor",
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(22, 22),
                ZIndex = PlaceholderHeader.ZIndex + 1,
                Parent = Frame,
            })
            Library:ApplyLucideIcon(PlaceholderDockIcon, PopOutIcon)
            PlaceholderDockIcon.MouseButton1Click:Connect(function()
                setthreadidentity(8)
                Box:SetPoppedOut(false)
            end)
        end

        return Frame
    end

    function Box:RefreshPopOutPlaceholder()
        setthreadidentity(8)
        if not Box.PoppedOut or not Placeholder or not Header then
            return
        end

        if PlaceholderHeader then
            PlaceholderHeader:Destroy()
            PlaceholderHeader = nil
        end

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Placeholder
        DimPopOutClone(PlaceholderHeader)
    end

    function Box:SetPoppedOut(Value: boolean, FloatPosition: UDim2?)
        setthreadidentity(8)
        if not Box.PopOutEnabled or Box.Destroyed then
            return
        end

        Value = Value == true
        if Box.PoppedOut == Value then
            if Value and FloatPosition and Float then
                Float.Position = FloatPosition
            end
            return
        end

        if Value then
            if Options.Before then
                Options.Before()
            end

            local BoxChildren = if Options.Children then Options.Children() else { Holder }
            HandledChildren = {}

            table.clear(OriginalParents)
            table.clear(OriginalLayoutOrders)

            for _, Child in BoxChildren do
                if not Child or not Child.Parent then
                    continue
                end

                table.insert(HandledChildren, Child)
                OriginalParents[Child] = Child.Parent
                OriginalLayoutOrders[Child] = Child.LayoutOrder
            end

            if #HandledChildren == 0 then
                return
            end

            local Width = Holder.AbsoluteSize.X / Library.DPIScale
            if Width < 50 then
                Width = 200
            end

            local AbsolutePosition = Holder.AbsolutePosition
            Placeholder = CreatePlaceholder()
            Box.PopOutPlaceholder = Placeholder

            Float = New("Frame", {
                Active = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Position = FloatPosition or UDim2.fromOffset(
                    AbsolutePosition.X / Library.DPIScale,
                    AbsolutePosition.Y / Library.DPIScale
                ),
                Size = UDim2.fromOffset(Width, 0),
                ZIndex = 1,
                Parent = Floats,
            })
            FloatScale = New("UIScale", {
                Parent = Float,
            })
            table.insert(Library.Scales, FloatScale)
            FloatScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[FloatScale]) or 0)

            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = Float,
            })

            for _, Child in HandledChildren do
                Child.Parent = Float
            end

            if not table.find(Library.DraggableElements, Float) then
                table.insert(Library.DraggableElements, Float)
            end

            Box.PopOutFloat = Float
            Box.PoppedOut = true
            SyncPopOutVisibility(Box)
            RaiseFloat()

            Float:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                setthreadidentity(8)
                Box:Resize()
            end)

            if Options.After then
                Options.After()
            end

            return
        end

        if Float then
            local DraggableIndex = table.find(Library.DraggableElements, Float)
            if DraggableIndex then
                table.remove(Library.DraggableElements, DraggableIndex)
            end
        end

        if FloatScale then
            local ScaleIndex = table.find(Library.Scales, FloatScale)
            if ScaleIndex then
                table.remove(Library.Scales, ScaleIndex)
            end

            FloatScale = nil
        end

        for _, Child in HandledChildren do
            if not Child or not Child.Parent then
                continue
            end

            Child.Parent = OriginalParents[Child] or BoxHolder
            Child.LayoutOrder = OriginalLayoutOrders[Child] or 0
        end

        if Placeholder then
            Placeholder:Destroy()
            Placeholder = nil
        end

        PlaceholderHeader = nil

        if Float then
            Float:Destroy()
            Float = nil
        end

        Box.PopOutFloat = nil
        Box.PopOutPlaceholder = nil
        Box.PoppedOut = false
        table.clear(HandledChildren)
        table.clear(OriginalParents)
        table.clear(OriginalLayoutOrders)

        if Options.After then
            Options.After()
        end
    end

    function Box:TogglePoppedOut()
        setthreadidentity(8)
        Box:SetPoppedOut(not Box.PoppedOut)
    end

    --// Drag Handler
    local function StopDrag()
        setthreadidentity(8)
        if DragState == "Idle" then
            return
        end

        local WasDragging = DragState == "Dragging"
        local DidMove = DragDidMove
        DragState = "Idle"
        DragInput = nil
        PressMouse = nil
        DragStartPos = nil
        DragDidMove = false

        if DragChanged and DragChanged.Connected then
            DragChanged:Disconnect()
            DragChanged = nil
        end

        if not WasDragging or not Box.PoppedOut or not Float then
            return
        end

        local FloatCenter = Float.AbsolutePosition + (Float.AbsoluteSize * 0.5)
        local NearPlaceholder = false
        if Library.Toggled and Placeholder and Placeholder.Parent then
            local PlaceholderCenter = Placeholder.AbsolutePosition + (Placeholder.AbsoluteSize * 0.5)
            NearPlaceholder = (FloatCenter - PlaceholderCenter).Magnitude <= Library.PopOutSnapDistance
        end

        if NearPlaceholder or (DidMove and not IsScreenPointOutsideMain(FloatCenter)) then
            Box:SetPoppedOut(false)
        end
    end

    local function BeginDrag(Input: InputObject)
        setthreadidentity(8)
        if DragState ~= "Idle" or Box.Destroyed or not (ScreenGui and ScreenGui.Parent) then
            return
        end

        local Point = Vector2.new(Input.Position.X, Input.Position.Y)
        local Top = GetTopFloatAt(Point)
        if Box.PoppedOut then
            if not Float or Top ~= Float then
                return
            end
        elseif Top ~= nil and not Header:IsDescendantOf(Top) then
            return
        end

        DragState = "Holding"
        DragInput = Input
        PressMouse = Vector2.new(Input.Position.X, Input.Position.Y)
        DragStartPos = nil
        DragDidMove = false

        if Box.PoppedOut and Float then
            RaiseFloat()
        end

        DragChanged = Input.Changed:Connect(function()
            setthreadidentity(8)
            if Input.UserInputState == Enum.UserInputState.End then
                StopDrag()
            end
        end)

        task.delay(Library.PopOutHoldTime, function()
            setthreadidentity(8)
            if (DragState :: any) ~= "Holding" or DragInput ~= Input then
                return
            end

            DragState = "Dragging"
            if Box.PoppedOut and Float then
                RaiseFloat()
                DragStartPos = Float.Position
            end
        end)
    end

    local function UpdateDrag(Input: InputObject)
        setthreadidentity(8)
        if DragState ~= "Dragging" or not PressMouse then
            return
        end
        if not (ScreenGui and ScreenGui.Parent) then
            StopDrag()
            return
        end

        local MousePosition = Vector2.new(Input.Position.X, Input.Position.Y)
        local Delta = MousePosition - PressMouse

        if not Box.PoppedOut then
            if Delta.Magnitude < Library.PopOutDragThreshold then
                return
            end

            Box:SetPoppedOut(true)
            if not Float then
                return
            end

            RaiseFloat()
            DragStartPos = Float.Position
            DragDidMove = true
        elseif Delta.Magnitude >= Library.PopOutDragThreshold then
            DragDidMove = true
        end

        if Float and DragStartPos then
            Float.Position = UDim2.new(
                DragStartPos.X.Scale,
                DragStartPos.X.Offset + Delta.X,
                DragStartPos.Y.Scale,
                DragStartPos.Y.Offset + Delta.Y
            )
        end
    end

    local function BindDragSource(Gui: GuiObject)
        setthreadidentity(8)
        Library:GiveSignal(Gui.InputBegan:Connect(function(Input: InputObject)
            setthreadidentity(8)
            if IsClickInput(Input) then
                BeginDrag(Input)
            end
        end))
    end

    BindDragSource(Header)
    for _, Descendant in Header:QueryDescendants("GuiObject:not(ImageButton)") do
        BindDragSource(Descendant)
    end

    Library:GiveSignal(Header.DescendantAdded:Connect(function(Descendant)
        setthreadidentity(8)
        if Descendant:IsA("GuiObject") and not Descendant:IsA("ImageButton") then
            BindDragSource(Descendant)
        end
    end))

    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
        setthreadidentity(8)
        if IsHoverInput(Input) then
            UpdateDrag(Input)
        end
    end))
end

--// Deprecated \\--
function Library:MakeOutline(Frame: GuiObject, Corner: number?, ZIndex: number?)
    setthreadidentity(8)
    warn("Obsidian:MakeOutline is deprecated, please use Obsidian:AddOutline instead.")
    local Holder = New("Frame", {
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromOffset(-2, -2),
        Size = UDim2.new(1, 4, 1, 4),
        ZIndex = ZIndex,
        Parent = Frame,
    })

    local Outline = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = ZIndex,
        Parent = Holder,
    })

    if Corner and Corner > 0 then
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner + 1),
            Parent = Holder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner),
            Parent = Outline,
        })
    end

    return Holder, Outline
end

function Library:AddDraggableLabel(...)
    setthreadidentity(8)
    local Params = select(1, ...)
    local Text
    local Icon
    local IconPosition = "left"

    if typeof(Params) == "table" then
        Text = Params.Text
        Icon = Params.Icon
        IconPosition = Params.IconPosition or "left"
    elseif typeof(Params) == "string" then
        Text = Params
        Icon = select(2, ...)
        IconPosition = select(3, ...) or "left"
    end

    if typeof(IconPosition) ~= "string" then
        IconPosition = "left"
    end

    IconPosition = string.lower(IconPosition)
    assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

    local DraggableLabel = {
        Connections = {},
        Destroyed = false
    }

    local IconImage
    local Label = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(6, 6),
        Text = Text,
        TextSize = 15,
        ZIndex = 1,
        Parent = Floats,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Label,
        })
    )

    local Padding = New("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Label,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Label,
        })
    )

    Library:AddOutline(Label)
    Library:MakeDraggable(Label, Label, true)

    function DraggableLabel:SetText(Text: string)
        setthreadidentity(8)
        Label.Text = Text
    end

    function DraggableLabel:SetIcon(NewIcon: string)
        setthreadidentity(8)
        Icon = NewIcon

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        if IsNotEmpty then
            local CustomIcon = Library:GetCustomIcon(Icon)
            assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            IconImage = IconImage or New("ImageLabel", {
                BackgroundTransparency = 1,
                ImageColor3 = "FontColor",
                Size = UDim2.fromOffset(16, 16),
                ZIndex = 2,
                Parent = Label,
            })

            Library:ApplyLucideIcon(IconImage, CustomIcon)
        end

        if IconImage then IconImage.Visible = IsNotEmpty end
        DraggableLabel:SetIconPosition(IconPosition)
    end

    function DraggableLabel:SetIconPosition(NewPosition: string)
        setthreadidentity(8)
        IconPosition = string.lower(NewPosition)
        assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        Padding.PaddingLeft = UDim.new(0, (IsNotEmpty and IconPosition == "left") and 34 or 12)
        Padding.PaddingRight = UDim.new(0, (IsNotEmpty and IconPosition == "right") and 34 or 12)

        if IconImage then
            if IconPosition == "left" then
                IconImage.AnchorPoint = Vector2.new(0, 0.5)
                IconImage.Position = UDim2.new(0, -22, 0.5, 0)
            else
                IconImage.AnchorPoint = Vector2.new(1, 0.5)
                IconImage.Position = UDim2.new(1, 22, 0.5, 0)
            end
        end
    end

    function DraggableLabel:SetVisible(Visible: boolean)
        setthreadidentity(8)
        Label.Visible = Visible
    end

    DraggableLabel:SetIcon(Icon)
    DraggableLabel.Label = Label

    if not table.find(Library.DraggableElements, Label) then
        table.insert(Library.DraggableElements, Label)
    end

    PositionDraggable(Label, Label.Position)

    function DraggableLabel:Destroy()
        setthreadidentity(8)
        DraggableLabel.Destroyed = true

        if DraggableLabel.Connections then
            for _, connection in DraggableLabel.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Label)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Label then
            Label:Destroy()
        end
    end

    return DraggableLabel
end

function Library:AddDraggableButton(...)
    setthreadidentity(8)
    local Params = select(1, ...)

    local Text
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Text = Params.Text
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" then
        Text = Params
        Func = select(2, ...)
        ExcludeScaling = select(3, ...)
        ExcludeDragging = select(4, ...)
    end

    local DraggableButton = {
        Connections = {},
        Destroyed = false
    }

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        TextSize = 16,
        ZIndex = 1,
        Parent = Floats,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local MaxClickDistance = ExcludeDragging and 12 or math.huge
    Button.InputBegan:Connect(function(Input: InputObject)
        setthreadidentity(8)
        if not IsClickInput(Input) then
            return
        end

        local StartPos = Input.Position
        local Changed
        Changed = Input.Changed:Connect(function()
            setthreadidentity(8)
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            if (Input.Position - StartPos).Magnitude <= MaxClickDistance then
                Library:SafeCallback(Func, DraggableButton)
            end

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    function DraggableButton:SetText(Text: string)
        setthreadidentity(8)
        local X, Y = Library:GetTextBounds(Text, Library.Scheme.Font, 16)

        Button.Text = Text
        Button.Size = UDim2.fromOffset(X * 2, Y * 2)
    end

    Library:MakeDraggable(Button, Button, true)
    DraggableButton:SetText(Text)
    DraggableButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    function DraggableButton:Destroy()
        setthreadidentity(8)
        DraggableButton.Destroyed = true

        if DraggableButton.Connections then
            for _, connection in DraggableButton.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Button)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Button then
            Button:Destroy()
        end
    end

    return DraggableButton
end

function Library:AddDraggableMenu(Name: string)
    setthreadidentity(8)
    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 1,
        Parent = Floats,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    Library:MakeLine(Holder, {
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 1),
    })

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Text = Name,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = Label,
    })

    local Container = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 7),
        Parent = Container,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
        Parent = Container,
    })

    Library:MakeDraggable(Holder, Label, true)

    if not table.find(Library.DraggableElements, Holder) then
        table.insert(Library.DraggableElements, Holder)
    end

    PositionDraggable(Holder, Holder.Position)

    return Holder, Container
end

function Library:AddDraggableImageButton(...)
    setthreadidentity(8)
    local Params = select(1, ...)

    local Icon
    local IconSize
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Icon = Params.Icon
        IconSize = Params.IconSize or 24
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" or typeof(Params) == "number" then
        Icon = Params
        IconSize = select(2, ...)
        Func = select(3, ...)
        ExcludeScaling = select(4, ...)
        ExcludeDragging = select(5, ...)
    end

    local DraggableImageButton = {}

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(IconSize + 12, IconSize + 12),
        Text = "",
        ZIndex = 1,
        Parent = Floats,
    })

    local IconImage = New("ImageLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(IconSize, IconSize),
        ImageColor3 = "FontColor",
        ZIndex = 2,
        Parent = Button,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local MaxClickDistance = ExcludeDragging and 12 or math.huge
    Button.InputBegan:Connect(function(Input: InputObject)
        setthreadidentity(8)
        if not IsClickInput(Input) then
            return
        end

        local StartPos = Input.Position
        local Changed
        Changed = Input.Changed:Connect(function()
            setthreadidentity(8)
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            if (Input.Position - StartPos).Magnitude <= MaxClickDistance then
                Library:SafeCallback(Func, DraggableImageButton)
            end

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    function DraggableImageButton:SetIcon(NewIcon: string)
        setthreadidentity(8)
        Icon = NewIcon or Icon

        local CustomIcon = Library:GetCustomIcon(Icon)
        assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        Library:ApplyLucideIcon(IconImage, CustomIcon)
    end

    function DraggableImageButton:SetIconSize(NewSize: number)
        setthreadidentity(8)
        IconSize = NewSize
        IconImage.Size = UDim2.fromOffset(IconSize, IconSize)
        Button.Size = UDim2.fromOffset(IconSize + 12, IconSize + 12)
    end

    Library:MakeDraggable(Button, Button, true)
    DraggableImageButton:SetIcon(Icon)
    DraggableImageButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    return DraggableImageButton
end

--// Watermark - Deprecated \\--
do
    local WatermarkLabel = Library:AddDraggableLabel("")
    WatermarkLabel:SetVisible(false)

    function Library:SetWatermark(Text: string)
        setthreadidentity(8)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetText(Text)
    end

    function Library:SetWatermarkVisibility(Visible: boolean)
        setthreadidentity(8)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetVisible(Visible)
    end
end

--// Context Menu \\--
local CurrentMenu
function Library:AddContextMenu(
    Holder: GuiObject,
    Size: UDim2 | () -> (),
    Offset: { [number]: number } | () -> {},
    List: number?,
    ActiveCallback: (Active: boolean) -> ()?,
    IgnoreCornerRadius: boolean?,
    SpecificCornersOnly: ("top" | "bottom" | "no_left" | "no_top_left")?, -- stupid way of doing this
    AnimationType: ("Dropdown" | "KeyPicker" | "none")?
)
    setthreadidentity(8)
    local Menu
    local HolderGui = Holder:FindFirstAncestorOfClass("ScreenGui")
    local ParentGui = Overlay
    if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
        ParentGui = HolderGui
    end

    if List then
        Menu = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.None,
            AutomaticSize = List == 1 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            BackgroundColor3 = "BackgroundColor",
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarImageColor3 = "OutlineColor",
            ScrollBarThickness = List == 2 and 2 or 0,
            Size = typeof(Size) == "function" and Size() or Size,
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    else
        Menu = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = typeof(Size) == "function" and Size() or Size,
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    end
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Menu,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Parent = Menu,
    })

    local Corner;
    if IgnoreCornerRadius ~= true then
        if SpecificCornersOnly == "top" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "bottom" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_top_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        else
            Corner = New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.Corners, Corner)
        end
    end

    local Table = {
        Connections = {},
        Destroyed = false,

        Active = false,
        ActiveCallback = ActiveCallback,

        Holder = Holder,
        Menu = Menu,
        Corner = Corner,

        List = nil,
        Signal = nil,

        Size = Size,
        AutoSizeY = List == 1,

        OpenCloseTween = nil,
        Animated = function()
            setthreadidentity(8)
            if not AnimationType or AnimationType == "none" then
                return false
            end

            if not (Library.Animations and Library.Animations[AnimationType] == true) then
                return false
            end

            return true, Library[string.format("%sTransitionInfo", AnimationType)] or TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    }

    if List == 1 then
        Table.List = New("UIListLayout", {
            Parent = Menu,
        })
    end

    function Table:Open()
        setthreadidentity(8)
        if CurrentMenu == Table then
            return
        elseif CurrentMenu then
            CurrentMenu:Close()
        end

        CurrentMenu = Table
        Table.Active = true
        Menu.ZIndex = 1

        local TargetParent = if ParentGui == Overlay then Overlay else ParentGui
        Menu.Parent = nil
        Menu.Parent = TargetParent

        if typeof(Offset) == "function" then
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset()[2])
            )
        else
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset[2])
            )
        end

        local TargetSize = typeof(Table.Size) == "function" and Table.Size() or Table.Size

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, true)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TweenInfo = Table.Animated()
        if IsAnimated == true then
            local OpenSize = TargetSize
            if Table.AutoSizeY then
                local FullHeight = Menu.AbsoluteSize.Y

                Menu.AutomaticSize = Enum.AutomaticSize.None
                OpenSize = UDim2.new(TargetSize.X.Scale, TargetSize.X.Offset, 0, FullHeight)
            end

            Menu.Size = UDim2.new(OpenSize.X.Scale, OpenSize.X.Offset, 0, 0)
            Menu.Visible = true

            local Tween = TweenService:Create(Menu, TweenInfo, { Size = OpenSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                setthreadidentity(8)
                if Connection then
                    Connection:Disconnect()
                end

                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil

                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            Tween:Play()
        else
            Menu.Size = TargetSize
            Menu.Visible = true
        end

        Table.Signal = Holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            setthreadidentity(8)
            if typeof(Offset) == "function" then
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset()[2])
                )
            else
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset[2])
                )
            end

            local HolderAllowed = Library:IsInsideFrame(Library.WindowContainer, Holder)
            if not HolderAllowed then
                for _, Surface in Library.DraggableElements do
                    if not (Surface and Library:IsInsideFrame(Surface, Holder)) then
                        continue
                    end

                    HolderAllowed = true
                    break
                end
            end

            if not HolderAllowed and Table.Active then
                Table:Close()
            end
        end)
    end

    function Table:Close()
        setthreadidentity(8)
        if CurrentMenu ~= Table then
            return
        end

        if Table.Signal then
            Table.Signal:Disconnect()
            Table.Signal = nil
        end

        Table.Active = false
        CurrentMenu = nil

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, false)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TweenInfo = Table.Animated()
        if IsAnimated == true then
            if Table.AutoSizeY then
                Menu.AutomaticSize = Enum.AutomaticSize.None
            end

            local CurrentSize = Menu.Size
            local CollapsedSize = UDim2.new(CurrentSize.X.Scale, CurrentSize.X.Offset, 0, 0)

            local Tween = TweenService:Create(Menu, TweenInfo, { Size = CollapsedSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function(PlaybackState)
                setthreadidentity(8)
                if Connection then
                    Connection:Disconnect()
                end

                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil

                    Menu.Visible = false
                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            Tween:Play()
        else
            Menu.Visible = false
        end
    end

    function Table:Toggle()
        setthreadidentity(8)
        if Table.Active then
            Table:Close()
        else
            Table:Open()
        end
    end

    function Table:SetSize(Size)
        setthreadidentity(8)
        Table.Size = Size
        Menu.Size = typeof(Size) == "function" and Size() or Size
    end

    function Table:Destroy()
        setthreadidentity(8)
        Table.Destroyed = true

        if Table.Connections then
            for _, Connection in Table.Connections do
                Connection:Disconnect()
            end
        end

        if CurrentMenu == Table then
            Table:Close()
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local MenuIndex = table.find(Library.ContextMenus, Table)
        if MenuIndex then
            table.remove(Library.ContextMenus, MenuIndex)
        end

        if Menu then
            Menu:Destroy()
        end
    end

    table.insert(Library.ContextMenus, Table)
    return Table
end

Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
    setthreadidentity(8)
    if Library.Unloaded then
        return
    end

    if IsClickInput(Input, true) then
        local Location = Input.Position

        if
            CurrentMenu
            and not (
                Library:MouseIsOverFrame(CurrentMenu.Menu, Location)
                or Library:MouseIsOverFrame(CurrentMenu.Holder, Location)
            )
        then
            CurrentMenu:Close()
        end
    end
end))

--// Tooltip \\--
local TooltipLabel = New("TextLabel", {
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundColor3 = "BackgroundColor",
    TextSize = 14,
    TextWrapped = true,
    Visible = false,
    ZIndex = 30,
    Parent = ScreenGui,
})
New("UIPadding", {
    PaddingBottom = UDim.new(0, 2),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
    PaddingTop = UDim.new(0, 2),
    Parent = TooltipLabel,
})
table.insert(
    Library.Scales,
    New("UIScale", {
        Parent = TooltipLabel,
    })
)
New("UIStroke", {
    Color = "OutlineColor",
    Parent = TooltipLabel,
})
table.insert(
    Library.Corners,
    New("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius / 2),
        Parent = TooltipLabel,
    })
)
TooltipLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    setthreadidentity(8)
    if Library.Unloaded then
        return
    end

    local X, _ = Library:GetTextBounds(
        TooltipLabel.Text,
        TooltipLabel.FontFace,
        TooltipLabel.TextSize,
        (workspace.CurrentCamera.ViewportSize.X - TooltipLabel.AbsolutePosition.X - 8) / Library.DPIScale
    )

    TooltipLabel.Size = UDim2.fromOffset(X + 8, 0)
end)

local CurrentHoverInstance
function Library:AddTooltip(InfoStr: string, DisabledInfoStr: string, HoverInstance: GuiObject)
    setthreadidentity(8)
    local TooltipTable = {
        Disabled = false,
        Hovering = false,
        Signals = {},
    }

    local function DoHover()
        setthreadidentity(8)
        if
            CurrentHoverInstance == HoverInstance
            or Library.ActiveDialog
            or (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
            or (TooltipTable.Disabled and typeof(DisabledInfoStr) ~= "string")
            or (not TooltipTable.Disabled and typeof(InfoStr) ~= "string")
        then
            return
        end
        CurrentHoverInstance = HoverInstance

        local HolderGui = HoverInstance:FindFirstAncestorOfClass("ScreenGui")
        if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
            TooltipLabel.Parent = HolderGui
        else
            TooltipLabel.Parent = ScreenGui
        end

        TooltipLabel.Text = TooltipTable.Disabled and DisabledInfoStr or InfoStr
        TooltipLabel.Visible = true

        while
            (Library.Toggled or Library.ActiveLoading)
            and not Library.ActiveDialog
            and Library:MouseIsOverFrame(HoverInstance, Mouse)
            and not (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
        do
            TooltipLabel.Position = UDim2.fromOffset(
                Mouse.X + (Library.ShowCustomCursor and 8 or 14),
                Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
            )

            RunService.RenderStepped:Wait()
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end

    local function GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
        setthreadidentity(8)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end

        return Connection
    end

    GiveSignal(HoverInstance.MouseEnter:Connect(DoHover))
    GiveSignal(HoverInstance.MouseMoved:Connect(DoHover))
    GiveSignal(HoverInstance.MouseLeave:Connect(function()
        setthreadidentity(8)
        if CurrentHoverInstance ~= HoverInstance then
            return
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end))

    function TooltipTable:Destroy()
        setthreadidentity(8)
        for Index = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Index)
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end

        if CurrentHoverInstance == HoverInstance then
            if TooltipLabel then
                TooltipLabel.Visible = false
            end

            CurrentHoverInstance = nil
        end
    end

    table.insert(Tooltips, TooltipLabel)
    return TooltipTable
end

function Library:OnUnload(Callback)
    setthreadidentity(8)
    table.insert(Library.UnloadSignals, Callback)
end

local BaseAddons = {}
do
    local Funcs = {}

    function Funcs:AddKeyPicker(Idx, Info)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.KeyPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        if ParentObj.Type == "Button" or ParentObj.Type == "SubButton" then
            assert(Info.Mode == "Press", "KeyPicker on Buttons can only be applied with the 'Press' mode.")

            ToggleLabel = ParentObj.Base
        end

        local KeyPicker = {
            Connections = {},

            Text = Info.Text,
            Value = Info.Default, -- Key
            Modifiers = Info.DefaultModifiers, -- Modifiers
            DisplayValue = Info.Default, -- Picker Text

            Blacklisted = Info.Blacklisted,
            BlacklistedModifiers = Info.BlacklistedModifiers,
            Whitelisted = Info.Whitelisted,
            WhitelistedModifiers = Info.WhitelistedModifiers,

            Toggled = false,
            Mode = Info.Mode,
            SyncToggleState = Info.SyncToggleState,

            Callback = Info.Callback,
            ChangedCallback = Info.ChangedCallback,
            Changed = Info.Changed,
            Clicked = Info.Clicked,

            Type = "KeyPicker",
        }

        if KeyPicker.Mode == "Press" then
            assert(ParentObj.Type == "Label" or ParentObj.Type == "Button" or ParentObj.Type == "SubButton", "KeyPicker with the mode 'Press' can be only applied on Labels and Buttons.")

            KeyPicker.SyncToggleState = false
            Info.Modes = { "Press" }
            Info.Mode = "Press"
        end

        if KeyPicker.SyncToggleState then
            Info.Modes = { "Toggle", "Hold" }

            if not table.find(Info.Modes, Info.Mode) then
                Info.Mode = "Toggle"
            end
        end

        local Picking = false
        local IsForButton = ParentObj.Type == "Button" or ParentObj.Type == "SubButton"

        -- Special Keys
        local SpecialKeys = {
            ["MB1"] = Enum.UserInputType.MouseButton1,
            ["MB2"] = Enum.UserInputType.MouseButton2,
            ["MB3"] = Enum.UserInputType.MouseButton3,
        }

        local SpecialKeysInput = {
            [Enum.UserInputType.MouseButton1] = "MB1",
            [Enum.UserInputType.MouseButton2] = "MB2",
            [Enum.UserInputType.MouseButton3] = "MB3",
        }

        -- Modifiers
        local Modifiers = {
            ["LAlt"] = Enum.KeyCode.LeftAlt,
            ["RAlt"] = Enum.KeyCode.RightAlt,

            ["LCtrl"] = Enum.KeyCode.LeftControl,
            ["RCtrl"] = Enum.KeyCode.RightControl,

            ["LShift"] = Enum.KeyCode.LeftShift,
            ["RShift"] = Enum.KeyCode.RightShift,

            ["Tab"] = Enum.KeyCode.Tab,
            ["CapsLock"] = Enum.KeyCode.CapsLock,
        }

        local ModifiersInput = {
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",

            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",

            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",

            [Enum.KeyCode.Tab] = "Tab",
            [Enum.KeyCode.CapsLock] = "CapsLock",
        }

        local IsModifierInput = function(Input)
            setthreadidentity(8)
            return Input.UserInputType == Enum.UserInputType.Keyboard and ModifiersInput[Input.KeyCode] ~= nil
        end

        local GetActiveModifiers = function()
            setthreadidentity(8)
            local ActiveModifiers = {}

            for Name, Input in Modifiers do
                if table.find(ActiveModifiers, Name) then
                    continue
                end
                if not UserInputService:IsKeyDown(Input) then
                    continue
                end

                table.insert(ActiveModifiers, Name)
            end

            return ActiveModifiers
        end

        local AreModifiersHeld = function(Required)
            setthreadidentity(8)
            if not (typeof(Required) == "table" and GetTableSize(Required) > 0) then
                return true
            end

            local ActiveModifiers = GetActiveModifiers()
            local Holding = true

            for _, Name in Required do
                if table.find(ActiveModifiers, Name) then
                    continue
                end

                Holding = false
                break
            end

            return Holding
        end

        local IsInputDown = function(Input)
            setthreadidentity(8)
            if not Input then
                return false
            end

            if SpecialKeysInput[Input.UserInputType] ~= nil then
                return UserInputService:IsMouseButtonPressed(Input.UserInputType)
                    and not UserInputService:GetFocusedTextBox()
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                return UserInputService:IsKeyDown(Input.KeyCode) and not UserInputService:GetFocusedTextBox()
            else
                return false
            end
        end

        local ConvertToInputModifiers = function(CurrentModifiers)
            setthreadidentity(8)
            local InputModifiers = {}

            for _, name in CurrentModifiers do
                table.insert(InputModifiers, Modifiers[name])
            end

            return InputModifiers
        end

        local VerifyModifiers = function(CurrentModifiers)
            setthreadidentity(8)
            if typeof(CurrentModifiers) ~= "table" then
                return {}
            end

            local ValidModifiers = {}

            for _, name in CurrentModifiers do
                if not Modifiers[name] then
                    continue
                end

                table.insert(ValidModifiers, name)
            end

            return ValidModifiers
        end

        KeyPicker.Modifiers = VerifyModifiers(KeyPicker.Modifiers)

        local SlideOverflow = true
        local LastDisplayText = nil
        local MaxPickerWidth = 85
        local SlidingLabel

        local SlideForwardTween
        local SlideBackTween
        local HandleForwardTween = function(State)
            setthreadidentity(8)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideBackTween then
                SlideBackTween:Play()
            end
        end

        local HandleBackTween = function(State)
            setthreadidentity(8)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideForwardTween then
                SlideForwardTween:Play()
            end
        end

        local SlideForwardConn, SlideBackConn
        local CancelSlidingTweens = function()
            setthreadidentity(8)
            if SlideForwardConn then
                SlideForwardConn:Disconnect()
                SlideForwardConn = nil
            end

            if SlideBackConn then
                SlideBackConn:Disconnect()
                SlideBackConn = nil
            end

            if SlideForwardTween then
                StopTween(SlideForwardTween, true)
                SlideForwardTween = nil
            end

            if SlideBackTween then
                StopTween(SlideBackTween, true)
                SlideBackTween = nil
            end

            RunService.RenderStepped:Wait()
        end

        local Picker = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromOffset(18, 18),
            Text = (IsForButton and SlideOverflow) and "" or KeyPicker.Value,
            TextSize = 14,
            TextTransparency = 0.4,
            Parent = ToggleLabel,
        })

        if IsForButton and SlideOverflow then
            Picker.ClipsDescendants = true

            SlidingLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = KeyPicker.Value,
                TextSize = 14,
                FontFace = Picker.FontFace,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = Picker,
            })

            Library:AddToRegistry(SlidingLabel, {
                TextColor3 = "FontColor",
            })
        end

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Picker,
        })

        local PickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Picker,
        }); table.insert(Library.SpecificCorners, PickerCorner)

        local PickerHoverTween = nil

        local function ApplyPickerTextTransparency(Transparency: number)
            setthreadidentity(8)
            StopTween(PickerHoverTween)
            PickerHoverTween = nil

            Picker.TextTransparency = Transparency
            if SlidingLabel then
                SlidingLabel.TextTransparency = Transparency
            end
        end

        local function TweenPickerTextTransparency(Transparency: number)
            setthreadidentity(8)
            StopTween(PickerHoverTween)

            PickerHoverTween = TweenService:Create(Picker, Library.TweenInfo, {
                TextTransparency = Transparency,
            })
            PickerHoverTween:Play()

            if SlidingLabel then
                TweenService:Create(SlidingLabel, Library.TweenInfo, {
                    TextTransparency = Transparency,
                }):Play()
            end
        end

        table.insert(KeyPicker.Connections, Picker.MouseEnter:Connect(function()
            setthreadidentity(8)
            if ParentObj.Disabled then
                return
            end

            TweenPickerTextTransparency(0)
        end))

        table.insert(KeyPicker.Connections, Picker.MouseLeave:Connect(function()
            setthreadidentity(8)
            if ParentObj.Disabled then
                return
            end

            TweenPickerTextTransparency(0.4)
        end))

        if IsForButton then
            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 21),
                Parent = ToggleLabel.Parent,
            })

            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 9),
                Parent = Holder,
            })

            New("UIFlexItem", {
                FlexMode = Enum.UIFlexMode.Fill,
                Parent = ToggleLabel,
            })

            ToggleLabel.Parent = Holder
            Picker.Parent = Holder

            Picker.Size = UDim2.new(0, 18, 1, 0)
        end

        local KeybindsToggle = { Normal = KeyPicker.Mode ~= "Toggle" }
        do
            local Holder = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Text = "",
                Visible = not Info.NoUI,
                Parent = Library.KeybindContainer,
            })

            local Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0, 1),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = Holder,
            })

            local Checkbox = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(14, 14),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = Holder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Checkbox,
                })
            )
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Checkbox,
            })

            local CheckImage = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 1,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = Checkbox,
            })
            if CheckIcon then
                Library:ApplyLucideIcon(CheckImage, CheckIcon)
            end

            function KeybindsToggle:Display(State)
                setthreadidentity(8)
                Label.TextTransparency = State and 0 or 0.5
                CheckImage.ImageTransparency = State and 0 or 1
            end

            function KeybindsToggle:SetText(Text)
                setthreadidentity(8)
                Label.Text = Text
            end

            function KeybindsToggle:SetVisibility(Visibility)
                setthreadidentity(8)
                Holder.Visible = Visibility
            end

            function KeybindsToggle:SetNormal(Normal)
                setthreadidentity(8)
                KeybindsToggle.Normal = Normal

                Holder.Active = not Normal
                Label.Position = Normal and UDim2.fromOffset(0, 0) or UDim2.fromOffset(22, 0)
                Checkbox.Visible = not Normal
            end

            KeyPicker.DoClick = function(...)
                setthreadidentity(8)
            end --// make luau lsp shut up
            table.insert(KeyPicker.Connections, Holder.MouseButton1Click:Connect(function()
                setthreadidentity(8)
                if KeybindsToggle.Normal then
                    return
                end

                KeyPicker.Toggled = not KeyPicker.Toggled
                KeyPicker:DoClick()
            end))

            KeybindsToggle.Holder = Holder
            KeybindsToggle.Label = Label
            KeybindsToggle.Checkbox = Checkbox
            KeybindsToggle.Loaded = true
            table.insert(Library.KeybindToggles, KeybindsToggle)
        end

        local ModeButtons = {}
        local ModeCorners = {}
        local TotalModeButtons = GetTableSize(Info.Modes)
        local MenuCornersOnly = if TotalModeButtons == 1 then "no_left" else "no_top_left"

        local MenuTable
        MenuTable = Library:AddContextMenu(Picker, UDim2.fromOffset(62, 0), function()
            setthreadidentity(8)
            return { Picker.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            setthreadidentity(8)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            PickerCorner.TopLeftRadius = Half
            PickerCorner.BottomLeftRadius = Half
            PickerCorner.TopRightRadius = Active and Zero or Half
            PickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = MenuTable and MenuTable.Corner
            if MenuCorner then
                if MenuCornersOnly == "no_left" then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.BottomLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                else
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end

            for _, Entry in ModeCorners do
                local Corner = Entry.Corner
                if Entry.Style == "single" then
                    Corner.TopLeftRadius = Zero
                    Corner.BottomLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomRightRadius = Half
                elseif Entry.Style == "first" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomLeftRadius = Zero
                    Corner.BottomRightRadius = Zero
                elseif Entry.Style == "last" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Zero
                    Corner.BottomLeftRadius = Half
                    Corner.BottomRightRadius = Half
                end
            end
        end, false, MenuCornersOnly, "KeyPicker")
        KeyPicker.Menu = MenuTable

        for Index, Mode in Info.Modes do
            local ModeButton = {}

            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, IsForButton and 21 or (TotalModeButtons == 1 and 18 or 19)),
                Text = Mode,
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = MenuTable.Menu,
            })

            if Index == 1 and TotalModeButtons == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "single" })
            elseif Index == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, 0),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "first" })
            elseif Index == TotalModeButtons then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "last" })
            end

            function ModeButton:Select()
                setthreadidentity(8)
                for _, Button in ModeButtons do
                    Button:Deselect()
                end

                KeyPicker.Mode = Mode

                Button.BackgroundTransparency = 0
                Button.TextTransparency = 0

                MenuTable:Close()
            end

            function ModeButton:Deselect()
                setthreadidentity(8)
                KeyPicker.Mode = nil

                Button.BackgroundTransparency = 1
                Button.TextTransparency = 0.5
            end

            table.insert(KeyPicker.Connections, Button.MouseButton1Click:Connect(function()
                setthreadidentity(8)
                ModeButton:Select()
            end))

            table.insert(KeyPicker.Connections, Button.MouseEnter:Connect(function()
                setthreadidentity(8)
                if KeyPicker.Mode == Mode then
                    return
                end

                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 0.7,
                    TextTransparency = 0.1,
                }):Play()
            end))

            table.insert(KeyPicker.Connections, Button.MouseLeave:Connect(function()
                setthreadidentity(8)
                if KeyPicker.Mode == Mode then
                    return
                end

                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                    TextTransparency = 0.5,
                }):Play()
            end))

            if KeyPicker.Mode == Mode then
                ModeButton:Select()
            end

            ModeButtons[Mode] = ModeButton
        end

        local SetPickingState = function(State, SkipUpdate: boolean?)
            setthreadidentity(8)
            Picking = State
            Library.IsPicking = State

            if ParentObj then
                ParentObj.AnyKeyPickerPicking = Picking
            end

            if IsForButton then
                ToggleLabel.Visible = not Picking
                LastDisplayText = nil
                RunService.RenderStepped:Wait()
            end

            if SkipUpdate ~= true then
                (KeyPicker :: any):Update()
            end
        end

        function KeyPicker:Display(PickerText)
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            local DisplayText = PickerText or KeyPicker.DisplayValue
            if IsForButton and SlideOverflow then
                local X, _Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    10000
                )

                local OffsetScale = X + 9
                local TextChanged = LastDisplayText ~= DisplayText
                local LabelWidth

                SlidingLabel.Text = DisplayText
                LastDisplayText = DisplayText

                if Picking then
                    Picker.Size = UDim2.new(1, 0, 1, 0)
                    RunService.RenderStepped:Wait()
                    LabelWidth = Picker.AbsoluteSize.X

                    if LabelWidth <= 0 then
                        LabelWidth = MaxPickerWidth
                    end
                else
                    LabelWidth = math.min(OffsetScale, MaxPickerWidth)
                    Picker.Size = UDim2.new(0, LabelWidth, 1, 0)
                end

                if OffsetScale > LabelWidth then
                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SlidingLabel.Size = UDim2.new(0, OffsetScale, 1, 0)

                    local OverflowDistance = OffsetScale - LabelWidth - 4.5
                    if OverflowDistance > 0 then
                        if TextChanged or not SlideForwardTween then
                            SlidingLabel.Position = UDim2.fromOffset(4.5, 0)
                            CancelSlidingTweens()

                            local Duration = math.max(OverflowDistance / 25, 0.35)
                            local TweenInfo = TweenInfo.new(
                                Duration,
                                Enum.EasingStyle.Linear,
                                Enum.EasingDirection.InOut
                            )

                            SlideForwardTween = TweenService:Create(SlidingLabel, TweenInfo, {
                                Position = UDim2.fromOffset(-OverflowDistance, 0),
                            })

                            SlideBackTween = TweenService:Create(SlidingLabel, TweenInfo, {
                                Position = UDim2.fromOffset(4.5, 0),
                            })

                            SlideForwardTween:Play()

                            if SlideForwardConn then
                                SlideForwardConn:Disconnect()
                            end

                            if SlideBackConn then
                                SlideBackConn:Disconnect()
                            end

                            SlideForwardConn = SlideForwardTween.Completed:Connect(HandleForwardTween)
                            SlideBackConn = SlideBackTween.Completed:Connect(HandleBackTween)
                        end
                    else
                        CancelSlidingTweens()

                        SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                        SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                        SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                    end
                else
                    CancelSlidingTweens()

                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                    SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                    SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                end
            else
                local X, Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    ToggleLabel.AbsoluteSize.X
                )
                Picker.Text = DisplayText
                Picker.Size = IsForButton and UDim2.new(0, X + 9, 1, 0) or UDim2.fromOffset((X + 9), (Y + 4))
            end
        end

        function KeyPicker:Update()
            setthreadidentity(8)
            local Disabled = ParentObj.Disabled == true

            if Disabled and Picking then
                SetPickingState(false, true)
            end

            KeyPicker:Display()

            Picker.Active = not Disabled
            ApplyPickerTextTransparency(Disabled and 0.8 or 0.4)

            if Disabled then
                if MenuTable.Active then
                    MenuTable:Close()
                end
            end

            if Info.NoUI then
                return
            end

            if KeyPicker.Mode == "Toggle" and ParentObj.Type == "Toggle" and ParentObj.Disabled then
                KeybindsToggle:SetVisibility(false)
                return
            end

            local State = KeyPicker:GetState()
            local ShowToggle = Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"

            if KeyPicker.SyncToggleState and ParentObj.Value ~= State then
                ParentObj:SetValue(State)
            end

            if KeybindsToggle.Loaded then
                if ShowToggle then
                    KeybindsToggle:SetNormal(false)
                else
                    KeybindsToggle:SetNormal(true)
                end

                KeybindsToggle:SetText(("[%s] %s (%s)"):format(KeyPicker.DisplayValue, KeyPicker.Text, KeyPicker.Mode))
                KeybindsToggle:SetVisibility(true)
                KeybindsToggle:Display(State)
            end
        end

        function KeyPicker:GetState()
            setthreadidentity(8)
            if KeyPicker.Mode == "Always" then
                return true
            elseif KeyPicker.Mode == "Hold" then
                local Key = KeyPicker.Value
                if Key == "None" then
                    return false
                end

                if not AreModifiersHeld(KeyPicker.Modifiers) then
                    return false
                end

                if Picking then
                    return false
                end

                if SpecialKeys[Key] ~= nil then
                    if Library.Toggled then
                        return false
                    end

                    return UserInputService:IsMouseButtonPressed(SpecialKeys[Key])
                        and not UserInputService:GetFocusedTextBox()
                else
                    return UserInputService:IsKeyDown(Enum.KeyCode[Key] :: any) and not UserInputService:GetFocusedTextBox()
                end
            else
                return KeyPicker.Toggled
            end
        end

        function KeyPicker:OnChanged(Func)
            setthreadidentity(8)
            KeyPicker.Changed = Func
        end

        function KeyPicker:OnClick(Func)
            setthreadidentity(8)
            KeyPicker.Clicked = Func
        end

        function KeyPicker:DoClick()
            setthreadidentity(8)
            if Picking or ParentObj.Disabled then
                return
            end

            if KeyPicker.Mode == "Press" then
                if KeyPicker.Toggled and Info.WaitForCallback == true then
                    return
                end

                KeyPicker.Toggled = true
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)

            if IsForButton then
                Library:SafeCallback(ParentObj.Func, KeyPicker.Toggled)
            end

            if Library.ToggleKeybind == KeyPicker and Library.Toggle then
                Library:Toggle()
            end

            if KeyPicker.Mode == "Press" then
                KeyPicker.Toggled = false
            end
        end

        function KeyPicker:RunChanged(IsKeyValid, KeyCode)
            setthreadidentity(8)
            if ParentObj.Disabled then
                return
            end

            if IsKeyValid == nil or KeyCode == nil then
                IsKeyValid, KeyCode = pcall(function()
                    setthreadidentity(8)
                    if KeyPicker.Value == "None" then
                        return nil
                    end

                    if SpecialKeys[KeyPicker.Value] == nil then
                        return Enum.KeyCode[KeyPicker.Value]
                    end

                    return SpecialKeys[KeyPicker.Value]
                end)
            end

            local NewModifiers = ConvertToInputModifiers(KeyPicker.Modifiers)
            Library:SafeCallback(KeyPicker.ChangedCallback, KeyCode, NewModifiers)
            Library:SafeCallback(KeyPicker.Changed, KeyCode, NewModifiers)
        end

        function KeyPicker:SetValue(Data)
            setthreadidentity(8)
            local Key, Mode, Modifiers = Data[1], Data[2], Data[3]

            local IsKeyValid, KeyCode = pcall(function()
                setthreadidentity(8)
                if Key == "None" then
                    Key = nil
                    return nil
                end

                if SpecialKeys[Key] == nil then
                    return Enum.KeyCode[Key]
                end

                return SpecialKeys[Key]
            end)

            if Key == nil then
                KeyPicker.Value = "None"
            elseif IsKeyValid then
                KeyPicker.Value = Key
            else
                KeyPicker.Value = "Unknown"
            end

            KeyPicker.Modifiers =
                VerifyModifiers(if typeof(Modifiers) == "table" then Modifiers else KeyPicker.Modifiers)
            KeyPicker.DisplayValue = if GetTableSize(KeyPicker.Modifiers) > 0
                then (table.concat(KeyPicker.Modifiers, " + ") .. " + " .. KeyPicker.Value)
                else KeyPicker.Value

            if ModeButtons[Mode] then
                ModeButtons[Mode]:Select()
            end

            KeyPicker:Update()
            KeyPicker:RunChanged(IsKeyValid, KeyCode)
        end

        function KeyPicker:SetText(Text)
            setthreadidentity(8)
            KeybindsToggle:SetText(Text)
            KeyPicker:Update()
        end

        table.insert(KeyPicker.Connections, Picker.MouseButton1Click:Connect(function()
            setthreadidentity(8)
            if Picking or Library.IsPicking or ParentObj.Disabled then
                return
            end

            SetPickingState(true)

            if IsForButton and SlideOverflow then
                KeyPicker:Display("...")
            else
                Picker.Text = "..."
                Picker.Size = IsForButton and UDim2.new(0, 29, 1, 0) or UDim2.fromOffset(29, 18)
            end

            -- Wait for any input --
            local ActiveModifiers = {}
            local CurrentInput = nil

            local IsValidInput = function(InputObj)
                setthreadidentity(8)
                if InputObj.KeyCode == Enum.KeyCode.Escape then
                    return true
                end

                local IsMod = IsModifierInput(InputObj)
                local KeyName
                if SpecialKeysInput[InputObj.UserInputType] ~= nil then
                    KeyName = SpecialKeysInput[InputObj.UserInputType]
                elseif InputObj.UserInputType == Enum.UserInputType.Keyboard then
                    if IsMod then
                        KeyName = ModifiersInput[InputObj.KeyCode]
                    else
                        KeyName = InputObj.KeyCode.Name
                    end
                end

                if KeyName then
                    if IsMod then
                        if KeyPicker.WhitelistedModifiers and #KeyPicker.WhitelistedModifiers > 0 and not table.find(KeyPicker.WhitelistedModifiers, KeyName) then
                            return false
                        end

                        if KeyPicker.BlacklistedModifiers and table.find(KeyPicker.BlacklistedModifiers, KeyName) then
                            return false
                        end
                    else
                        if KeyPicker.Whitelisted and #KeyPicker.Whitelisted > 0 and not table.find(KeyPicker.Whitelisted, KeyName) then
                            return false
                        end

                        if KeyPicker.Blacklisted and table.find(KeyPicker.Blacklisted, KeyName) then
                            return false
                        end
                    end
                end

                return true
            end

            -- Wait for the first valid InputBegan --
            while true do
                local InputObj = UserInputService.InputBegan:Wait()
                if UserInputService:GetFocusedTextBox() ~= nil then
                    SetPickingState(false)
                    return
                end

                if IsValidInput(InputObj) then
                    CurrentInput = InputObj
                    break
                end
            end

            -- If it's a modifier key, we wait for either its release or another input --
            while IsModifierInput(CurrentInput) do
                if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                    break
                end

                -- Display the current state including the current modifier key --
                local ModName = ModifiersInput[CurrentInput.KeyCode]
                if ModName then
                    local text = if #ActiveModifiers > 0 then table.concat(ActiveModifiers, " + ") .. " + " .. ModName .. " + ..." else ModName .. " + ..."
                    KeyPicker:Display(text)
                end

                local NextInput = nil
                local Released = false

                local BeganConn
                local EndedConn

                BeganConn = UserInputService.InputBegan:Connect(function(InputObj)
                    setthreadidentity(8)
                    if UserInputService:GetFocusedTextBox() ~= nil then
                        return
                    end
                    if IsValidInput(InputObj) then
                        NextInput = InputObj
                    end
                end)

                EndedConn = UserInputService.InputEnded:Connect(function(InputObj)
                    setthreadidentity(8)
                    if InputObj.KeyCode == CurrentInput.KeyCode then
                        Released = true
                    end
                end)

                repeat
                    task.wait()
                until Released or NextInput or UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded

                if BeganConn then BeganConn:Disconnect() end
                if EndedConn then EndedConn:Disconnect() end

                if UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded then
                    SetPickingState(false)
                    return
                end

                if Released then
                    break -- Use modifier key as bind
                elseif NextInput then
                    -- Add another modifier or continue to normal key
                    local OldModName = ModifiersInput[CurrentInput.KeyCode]
                    if OldModName and not table.find(ActiveModifiers, OldModName) then
                        ActiveModifiers[#ActiveModifiers + 1] = OldModName
                    end

                    CurrentInput = NextInput
                    if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                        break
                    end
                end
            end

            local Key = "Unknown"
            if SpecialKeysInput[CurrentInput.UserInputType] ~= nil then
                Key = SpecialKeysInput[CurrentInput.UserInputType]
            elseif CurrentInput.UserInputType == Enum.UserInputType.Keyboard then
                Key = CurrentInput.KeyCode == Enum.KeyCode.Escape and "None" or CurrentInput.KeyCode.Name
            end

            ActiveModifiers = if CurrentInput.KeyCode == Enum.KeyCode.Escape or Key == "Unknown" then {} else ActiveModifiers

            KeyPicker.Toggled = if ParentObj.Type == "Toggle" then ParentObj.Value else false
            KeyPicker:SetValue({ Key, KeyPicker.Mode, ActiveModifiers })

            repeat
                task.wait()
            until not IsInputDown(CurrentInput) or UserInputService:GetFocusedTextBox()

            SetPickingState(false)
        end))

        table.insert(KeyPicker.Connections, Picker.MouseButton2Click:Connect(function()
            setthreadidentity(8)
            if ParentObj.Disabled then
                return
            end

            MenuTable:Toggle()
        end))

        table.insert(KeyPicker.Connections, UserInputService.InputBegan:Connect(function(Input: InputObject)
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            local IsMouse = IsMouseClickInput(Input)
            if
                ParentObj.Disabled
                or KeyPicker.Mode == "Always"
                or KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
                or Library.IsPicking
                or UserInputService:GetFocusedTextBox()
                or (IsMouse and Library.Toggled)
            then
                return
            end

            local Key = KeyPicker.Value
            local HoldingModifiers = AreModifiersHeld(KeyPicker.Modifiers)
            local HoldingKey = false

            if
                Key
                and HoldingModifiers == true
                and (
                    SpecialKeysInput[Input.UserInputType] == Key
                    or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key)
                )
            then
                HoldingKey = true
            end

            if KeyPicker.Mode == "Toggle" then
                if HoldingKey then
                    KeyPicker.Toggled = not KeyPicker.Toggled
                    KeyPicker:DoClick()
                end
            elseif KeyPicker.Mode == "Press" then
                if HoldingKey then
                    KeyPicker:DoClick()
                end
            end

            KeyPicker:Update()
        end))

        table.insert(KeyPicker.Connections, UserInputService.InputEnded:Connect(function(Input: InputObject)
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            local IsMouse = IsMouseClickInput(Input)
            if
                ParentObj.Disabled
                or KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
                or Library.IsPicking
                or UserInputService:GetFocusedTextBox()
                or (IsMouse and Library.Toggled)
            then
                return
            end

            KeyPicker:Update()
        end))

        KeyPicker:Update()

        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end

        table.insert(ParentObj.Addons, KeyPicker)

        KeyPicker.Default = KeyPicker.Value
        KeyPicker.DefaultModifiers = table.clone(KeyPicker.Modifiers or {})

        function KeyPicker:Destroy()
            setthreadidentity(8)
            KeyPicker.Destroyed = true

            if SlideForwardConn then
                SlideForwardConn:Disconnect()
                SlideForwardConn = nil
            end

            if SlideBackConn then
                SlideBackConn:Disconnect()
                SlideBackConn = nil
            end

            if KeyPicker.Connections then
                for _, Connection in KeyPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if KeybindsToggle and KeybindsToggle.Loaded then
                if KeybindsToggle.Holder then
                    KeybindsToggle.Holder:Destroy()
                end
                local KTIdx = table.find(Library.KeybindToggles, KeybindsToggle)
                if KTIdx then
                    table.remove(Library.KeybindToggles, KTIdx)
                end
            end

            if MenuTable then
                MenuTable:Destroy()
            end

            if IsForButton and SlideOverflow then
                if SlideForwardTween then
                    SlideForwardTween:Destroy()
                end

                if SlideBackTween then
                    SlideBackTween:Destroy()
                end
            end

            if Picker then
                Picker:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, KeyPicker)

                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            Options[Idx] = nil
        end

        Options[Idx] = KeyPicker

        return self
    end

    local HueSequenceTable = {}
    for Hue = 0, 1, 0.1 do
        table.insert(HueSequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
    end
    function Funcs:AddColorPicker(Idx, Info)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.ColorPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        local ColorPicker = {
            Connections = {},
            Destroyed = false,

            Value = Info.Default,

            Transparency = Info.Transparency or 0,
            Title = Info.Title,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Type = "ColorPicker",
        }
        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = ColorPicker.Value:ToHSV()

        local Holder = New("TextButton", {
            BackgroundColor3 = ColorPicker.Value,
            Size = UDim2.fromOffset(18, 18),
            Text = "",
            Parent = ToggleLabel,
        })

        local HolderStroke = New("UIStroke", {
            Color = Library:GetDarkerColor(ColorPicker.Value),
            Parent = Holder,
        })

        local ColorPickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Holder,
        }); table.insert(Library.SpecificCorners, ColorPickerCorner)

        local HolderTransparency = New("ImageLabel", {
            Image = CustomImageManager.GetAsset("TransparencyTexture"),
            ImageTransparency = (1 - ColorPicker.Transparency),
            ScaleType = Enum.ScaleType.Tile,
            Position = UDim2.new(0, -1, 0, -1),
            Size = UDim2.new(1, 2, 1, 2),
            TileSize = UDim2.fromOffset(9, 9),
            Parent = Holder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HolderTransparency,
            })
        )

        --// Color Menu \\--
        local MapSize = Library.IsMobile and 140 or 200
        local BarWidth = 16
        local MenuWidth = MapSize + BarWidth + 6 + 12
        if Info.Transparency then
            MenuWidth += BarWidth + 6
        end

        local ColorMenu
        local FooterCorner
        ColorMenu = Library:AddContextMenu(
            Holder,
            UDim2.fromOffset(MenuWidth, 0),
            function()
                setthreadidentity(8)
                return { 0.5, Holder.AbsoluteSize.Y + 1.5 }
            end,
            1, function(Active: boolean)
                setthreadidentity(8)
                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)

                ColorPickerCorner.TopLeftRadius = Half
                ColorPickerCorner.TopRightRadius = Half
                ColorPickerCorner.BottomRightRadius = Active and Zero or Half
                ColorPickerCorner.BottomLeftRadius = Active and Zero or Half

                local MenuCorner = ColorMenu and ColorMenu.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end

                if FooterCorner then
                    FooterCorner.TopLeftRadius = Zero
                    FooterCorner.TopRightRadius = Zero
                    FooterCorner.BottomLeftRadius = Half
                    FooterCorner.BottomRightRadius = Half
                end
            end, false, "no_top_left")
        ColorMenu.List.Padding = UDim.new(0, 0)
        ColorPicker.ColorMenu = ColorMenu

        --// Content Holder \\--
        local ContentHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = ColorMenu.Menu,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = ContentHolder,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = ContentHolder,
        })

        --// Footer \\--
        local FooterHeight = Library.IsMobile and 30 or 22

        local FooterBackground = New("Frame", {
            BackgroundColor3 = function()
                setthreadidentity(8)
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Size = UDim2.new(1, 0, 0, FooterHeight),
            Parent = ColorMenu.Menu,
        })
        FooterCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = FooterBackground,
        })
        table.insert(Library.SpecificCorners, FooterCorner)
        Library:MakeLine(FooterBackground, {
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.new(1, 0, 0, 1),
        })

        local FooterBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = FooterBackground,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, Info.Resizable and (FooterHeight + 4) or 6),
            Parent = FooterBar,
        })

        local FooterInfoLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            TextTransparency = 0.5,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = FooterBar,
        })

        local function RefreshFooterInfo()
            setthreadidentity(8)
            FooterInfoLabel.Text = string.format(
                "#%s • %d, %d, %d",
                ColorPicker.Value:ToHex(),
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255)
            )
        end
        RefreshFooterInfo()

        if typeof(ColorPicker.Title) == "string" then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 8),
                Text = ColorPicker.Title,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ContentHolder,
            })
        end

        local ColorHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, MapSize),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = ColorHolder,
        })

        --// Sat Map
        local SatVipMap = New("ImageButton", {
            BackgroundColor3 = ColorPicker.Value,
            Image = CustomImageManager.GetAsset("SaturationMap"),
            Size = UDim2.fromOffset(MapSize, MapSize),
            Parent = ColorHolder,
        })

        local SatVibCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            Size = UDim2.fromOffset(6, 6),
            Parent = SatVipMap,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SatVibCursor,
        })
        New("UIStroke", {
            Color = "DarkColor",
            Parent = SatVibCursor,
        })

        --// Hue
        local HueSelector = New("TextButton", {
            Size = UDim2.fromOffset(BarWidth, MapSize),
            Text = "",
            Parent = ColorHolder,
        })
        New("UIGradient", {
            Color = ColorSequence.new(HueSequenceTable),
            Rotation = 90,
            Parent = HueSelector,
        })

        local HueCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            BorderColor3 = "DarkColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0.5, ColorPicker.Hue),
            Size = UDim2.new(1, 2, 0, 1),
            Parent = HueSelector,
        })

        --// Alpha
        local TransparencySelector, TransparencyColor, TransparencyCursor
        if Info.Transparency then
            TransparencySelector = New("ImageButton", {
                Image = CustomImageManager.GetAsset("TransparencyTexture"),
                ScaleType = Enum.ScaleType.Tile,
                Size = UDim2.fromOffset(BarWidth, MapSize),
                TileSize = UDim2.fromOffset(8, 8),
                Parent = ColorHolder,
            })

            TransparencyColor = New("Frame", {
                BackgroundColor3 = ColorPicker.Value,
                Size = UDim2.fromScale(1, 1),
                Parent = TransparencySelector,
            })
            New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Parent = TransparencyColor,
            })

            TransparencyCursor = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "WhiteColor",
                BorderColor3 = "DarkColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0.5, ColorPicker.Transparency),
                Size = UDim2.new(1, 2, 0, 1),
                Parent = TransparencySelector,
            })
        end

        --// Resizing \\--
        local ResizeGrabber
        if Info.Resizable then
            local BaseMapSize = 200
            local BaseBarWidth = BarWidth
            local BasePadding = 6
            local MinMapSize = 140

            ColorPicker.MapWidth = MapSize
            ColorPicker.MapHeight = MapSize

            local function GetBarWidth(MapWidth)
                setthreadidentity(8)
                return math.clamp(math.floor((MapWidth / BaseMapSize) * BaseBarWidth + 0.5), 12, 24)
            end

            local function GetContentWidth(MapWidth)
                setthreadidentity(8)
                local CurrentBarWidth = GetBarWidth(MapWidth)
                local Width = MapWidth + CurrentBarWidth + BasePadding
                if Info.Transparency then
                    Width += (CurrentBarWidth + BasePadding)
                end

                return Width + 12
            end

            local FixedVerticalOverhead = 6 + 6 + 8 + 20 + 8 + 20 + FooterHeight
            if typeof(ColorPicker.Title) == "string" then
                FixedVerticalOverhead += 8 + 8
            end

            local function ClampToViewport(NewWidth, NewHeight)
                setthreadidentity(8)
                local Camera = workspace.CurrentCamera
                if not Camera then
                    return NewWidth, NewHeight
                end

                local ViewportSize = Camera.ViewportSize
                local ScreenMargin = 12

                local MaxWidth = ViewportSize.X - ColorMenu.Menu.AbsolutePosition.X - ScreenMargin
                local MaxHeight = ViewportSize.Y - ColorMenu.Menu.AbsolutePosition.Y - ScreenMargin - FixedVerticalOverhead

                while NewWidth > MinMapSize and GetContentWidth(NewWidth) > MaxWidth do
                    NewWidth -= 4
                end

                if NewHeight > MaxHeight then
                    NewHeight = math.max(MinMapSize, math.floor(MaxHeight))
                end

                return NewWidth, NewHeight
            end

            local function UpdateColorMenuSize(NewWidth, NewHeight)
                setthreadidentity(8)
                NewWidth = math.max(MinMapSize, math.floor(NewWidth + 0.5))
                NewHeight = math.max(MinMapSize, math.floor(NewHeight + 0.5))
                NewWidth, NewHeight = ClampToViewport(NewWidth, NewHeight)

                if NewWidth == ColorPicker.MapWidth and NewHeight == ColorPicker.MapHeight then
                    return
                end

                local CurrentBarWidth = GetBarWidth(NewWidth)
                local CursorSize = math.clamp(math.floor((math.min(NewWidth, NewHeight) / BaseMapSize) * 6 + 0.5), 4, 10)

                ColorHolder.Size = UDim2.new(1, 0, 0, NewHeight)
                SatVipMap.Size = UDim2.fromOffset(NewWidth, NewHeight)
                SatVibCursor.Size = UDim2.fromOffset(CursorSize, CursorSize)
                HueSelector.Size = UDim2.new(0, CurrentBarWidth, 0, NewHeight)

                if TransparencySelector then
                    TransparencySelector.Size = UDim2.new(0, CurrentBarWidth, 0, NewHeight)
                end

                ColorPicker.MapWidth = NewWidth
                ColorPicker.MapHeight = NewHeight
                ColorMenu:SetSize(UDim2.new(0, GetContentWidth(NewWidth), 0, 0))
            end

            ResizeGrabber = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -Library.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = FooterBackground,
            })
            local ResizeGrabberIcon = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = ResizeGrabber,
            })
            if ResizeIcon then
                Library:ApplyLucideIcon(ResizeGrabberIcon, ResizeIcon)
            end

            table.insert(ColorPicker.Connections, ResizeGrabber.InputBegan:Connect(function(Input: InputObject)
                setthreadidentity(8)
                Library.CantDragForced = true
                local StartMouse = Vector2.new(Mouse.X, Mouse.Y)
                local StartWidth = ColorPicker.MapWidth
                local StartHeight = ColorPicker.MapHeight

                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Delta = Vector2.new(Mouse.X, Mouse.Y) - StartMouse
                    UpdateColorMenuSize(StartWidth + Delta.X, StartHeight + Delta.Y)

                    RunService.RenderStepped:Wait()
                end

                Library.CantDragForced = false
            end))
        end

        local InfoHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = InfoHolder,
        })

        local HueBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "#??????",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local HueBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = HueBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HueBox,
            })
        )

        local RgbBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "?, ?, ?",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local RgbBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = RgbBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = RgbBox,
            })
        )

        --// Context Menu \\--
        local ContextMenu
        ContextMenu = Library:AddContextMenu(Holder, UDim2.fromOffset(93, 0), function()
            setthreadidentity(8)
            return { Holder.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            setthreadidentity(8)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            ColorPickerCorner.TopLeftRadius = Half
            ColorPickerCorner.BottomLeftRadius = Half
            ColorPickerCorner.TopRightRadius = Active and Zero or Half
            ColorPickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = ContextMenu and ContextMenu.Corner
            if MenuCorner then
                MenuCorner.TopLeftRadius = Zero
                MenuCorner.TopRightRadius = Half
                MenuCorner.BottomRightRadius = Half
                MenuCorner.BottomLeftRadius = Half
            end
        end, false, "no_top_left")
        ColorPicker.ContextMenu = ContextMenu
        ContextMenu.List.Padding = UDim.new(0, 6)
        do
            local function CreateButton(Text, Func)
                setthreadidentity(8)
                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = Text,
                    TextSize = 14,
                    Parent = ContextMenu.Menu,
                })

                table.insert(ColorPicker.Connections, Button.MouseButton1Click:Connect(function()
                    setthreadidentity(8)
                    Library:SafeCallback(Func)
                    ContextMenu:Close()
                end))

                table.insert(ColorPicker.Connections, Button.MouseEnter:Connect(function()
                    setthreadidentity(8)
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 0.7,
                    }):Play()
                end))

                table.insert(ColorPicker.Connections, Button.MouseLeave:Connect(function()
                    setthreadidentity(8)
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 1,
                    }):Play()
                end))
            end

            CreateButton("Copy color", function()
                setthreadidentity(8)
                Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }
            end)

            ColorPicker.SetValueRGB = function(...)
                setthreadidentity(8)
            end --// make luau lsp shut up
            CreateButton("Paste color", function()
                setthreadidentity(8)
                if not Library.CopiedColor then
                    return
                end

                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
            end)

            if setclipboard then
                CreateButton("Copy Hex", function()
                    setthreadidentity(8)
                    setclipboard(tostring(ColorPicker.Value:ToHex()))
                end)

                CreateButton("Copy RGB", function()
                    setthreadidentity(8)
                    setclipboard(table.concat({
                        math.floor(ColorPicker.Value.R * 255),
                        math.floor(ColorPicker.Value.G * 255),
                        math.floor(ColorPicker.Value.B * 255),
                    }, ", "))
                end)
            end
        end

        --// Copy/Paste Buttons \\--
        local ActionHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = ActionHolder,
        })

        local CopyColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Copy color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = CopyColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = CopyColorButton,
            })
        )

        local PasteColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Paste color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = PasteColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = PasteColorButton,
            })
        )

        local CopyColorOriginalText = CopyColorButton.Text
        local PasteColorOriginalText = PasteColorButton.Text
        local CopyColorResetId = 0
        local PasteColorResetId = 0

        table.insert(ColorPicker.Connections, CopyColorButton.MouseEnter:Connect(function()
            setthreadidentity(8)
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))

        table.insert(ColorPicker.Connections, CopyColorButton.MouseLeave:Connect(function()
            setthreadidentity(8)
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseEnter:Connect(function()
            setthreadidentity(8)
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseLeave:Connect(function()
            setthreadidentity(8)
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, CopyColorButton.MouseButton1Click:Connect(function()
            setthreadidentity(8)
            Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }

            CopyColorResetId += 1
            local ThisResetId = CopyColorResetId
            CopyColorButton.Text = "Copied color"

            task.delay(1, function()
                setthreadidentity(8)
                if ColorPicker.Destroyed or ThisResetId ~= CopyColorResetId then
                    return
                end

                CopyColorButton.Text = CopyColorOriginalText
            end)
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseButton1Click:Connect(function()
            setthreadidentity(8)
            PasteColorResetId += 1
            local ThisResetId = PasteColorResetId

            if not Library.CopiedColor then
                PasteColorButton.Text = "Nothing to paste"
            else
                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
                PasteColorButton.Text = "Pasted color"
            end

            task.delay(1, function()
                setthreadidentity(8)
                if ColorPicker.Destroyed or ThisResetId ~= PasteColorResetId then
                    return
                end

                PasteColorButton.Text = PasteColorOriginalText
            end)
        end))

        --// End \\--
        function ColorPicker:SetHSVFromRGB(Color)
            setthreadidentity(8)
            ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
        end

        function ColorPicker:Display()
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)

            SatVipMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
            if TransparencyColor then
                TransparencyColor.BackgroundColor3 = ColorPicker.Value
            end

            SatVibCursor.Position = UDim2.fromScale(ColorPicker.Sat, 1 - ColorPicker.Vib)
            HueCursor.Position = UDim2.fromScale(0.5, ColorPicker.Hue)
            if TransparencyCursor then
                TransparencyCursor.Position = UDim2.fromScale(0.5, ColorPicker.Transparency)
            end

            HueBox.Text = "#" .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255),
            }, ", ")

            RefreshFooterInfo()
        end

        local function ApplyHolderVisual(Disabled: boolean)
            setthreadidentity(8)
            Holder.Active = not Disabled
            HolderStroke.Transparency = Disabled and 0.5 or 0
            Holder.BackgroundTransparency = Disabled and 0.5 or 0

            if Disabled then
                Holder.BackgroundColor3 = ColorPicker.Value:Lerp(Library.Scheme.BackgroundColor, 0.5)
                HolderTransparency.ImageTransparency = math.clamp((1 - ColorPicker.Transparency) + 0.5, 0, 1)
            else
                Holder.BackgroundColor3 = ColorPicker.Value
                HolderStroke.Color = Library:GetDarkerColor(ColorPicker.Value)
                HolderTransparency.ImageTransparency = (1 - ColorPicker.Transparency)
            end
        end

        function ColorPicker:RunChanged()
            setthreadidentity(8)
            if ParentObj.Disabled then
                return
            end

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
        end

        function ColorPicker:Update()
            setthreadidentity(8)
            ColorPicker:Display()

            local Disabled = ParentObj.Disabled == true
            ApplyHolderVisual(Disabled)

            if Disabled then
                if ColorMenu.Active then
                    ColorMenu:Close()
                end

                if ContextMenu.Active then
                    ContextMenu:Close()
                end
            end

            ColorPicker:RunChanged()
        end

        function ColorPicker:OnChanged(Func)
            setthreadidentity(8)
            ColorPicker.Changed = Func
        end

        function ColorPicker:SetValue(HSV, Transparency)
            setthreadidentity(8)
            if typeof(HSV) == "Color3" then
                ColorPicker:SetValueRGB(HSV, Transparency)
                return
            end

            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        function ColorPicker:SetValueRGB(Color, Transparency)
            setthreadidentity(8)
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        table.insert(ColorPicker.Connections, Holder.MouseButton1Click:Connect(function()
            setthreadidentity(8)
            if ParentObj.Disabled then
                return
            end

            ColorMenu:Toggle()
        end))

        table.insert(ColorPicker.Connections, Holder.MouseButton2Click:Connect(function()
            setthreadidentity(8)
            if ParentObj.Disabled then
                return
            end

            ContextMenu:Toggle()
        end))

        table.insert(ColorPicker.Connections, SatVipMap.InputBegan:Connect(function(Input: InputObject)
            setthreadidentity(8)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local MinX = SatVipMap.AbsolutePosition.X
                local MaxX = MinX + SatVipMap.AbsoluteSize.X
                local LocationX = math.clamp(Mouse.X, MinX, MaxX)

                local MinY = SatVipMap.AbsolutePosition.Y
                local MaxY = MinY + SatVipMap.AbsoluteSize.Y
                local LocationY = math.clamp(Mouse.Y, MinY, MaxY)

                local OldSat = ColorPicker.Sat
                local OldVib = ColorPicker.Vib
                ColorPicker.Sat = (LocationX - MinX) / (MaxX - MinX)
                ColorPicker.Vib = 1 - ((LocationY - MinY) / (MaxY - MinY))

                if ColorPicker.Sat ~= OldSat or ColorPicker.Vib ~= OldVib then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end))

        table.insert(ColorPicker.Connections, HueSelector.InputBegan:Connect(function(Input: InputObject)
            setthreadidentity(8)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local Min = HueSelector.AbsolutePosition.Y
                local Max = Min + HueSelector.AbsoluteSize.Y
                local Location = math.clamp(Mouse.Y, Min, Max)

                local OldHue = ColorPicker.Hue
                ColorPicker.Hue = (Location - Min) / (Max - Min)

                if ColorPicker.Hue ~= OldHue then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end))

        if TransparencySelector then
            table.insert(ColorPicker.Connections, TransparencySelector.InputBegan:Connect(function(Input: InputObject)
                setthreadidentity(8)
                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Min = TransparencySelector.AbsolutePosition.Y
                    local Max = TransparencySelector.AbsolutePosition.Y + TransparencySelector.AbsoluteSize.Y
                    local Location = math.clamp(Mouse.Y, Min, Max)

                    local OldTransparency = ColorPicker.Transparency
                    ColorPicker.Transparency = (Location - Min) / (Max - Min)

                    if ColorPicker.Transparency ~= OldTransparency then
                        ColorPicker:Update()
                    end

                    RunService.RenderStepped:Wait()
                end
            end))
        end

        table.insert(ColorPicker.Connections, HueBox.FocusLost:Connect(function(Enter)
            setthreadidentity(8)
            if not Enter then
                return
            end

            local Success, Color = pcall(Color3.fromHex, HueBox.Text)
            if Success and typeof(Color) == "Color3" then
                ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
            end

            ColorPicker:Update()
        end))

        table.insert(ColorPicker.Connections, RgbBox.FocusLost:Connect(function(Enter)
            setthreadidentity(8)
            if not Enter then
                return
            end

            local R, G, B = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
            if R and G and B then
                ColorPicker:SetHSVFromRGB(Color3.fromRGB(R, G, B))
            end

            ColorPicker:Update()
        end))

        for _, BoxPair in {
            { HueBox, HueBoxStroke },
            { RgbBox, RgbBoxStroke }
        } do
            local TextBoxInstance, Stroke = BoxPair[1], BoxPair[2]

            table.insert(ColorPicker.Connections, TextBoxInstance.Focused:Connect(function()
                setthreadidentity(8)
                Library.Registry[Stroke].Color = "AccentColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(ColorPicker.Connections, TextBoxInstance.FocusLost:Connect(function()
                setthreadidentity(8)
                Library.Registry[Stroke].Color = "OutlineColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        ColorPicker:Update()

        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end

        table.insert(ParentObj.Addons, ColorPicker)

        ColorPicker.Default = ColorPicker.Value

        function ColorPicker:Destroy()
            setthreadidentity(8)
            ColorPicker.Destroyed = true

            if ColorPicker.Connections then
                for _, Connection in ColorPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if ColorMenu then
                ColorMenu:Destroy()
            end

            if ResizeGrabber then
                ResizeGrabber:Destroy()
            end

            if ContextMenu then
                ContextMenu:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, ColorPicker)

                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            Options[Idx] = nil
        end

        Options[Idx] = ColorPicker

        return self
    end

    BaseAddons.__index = Funcs
    BaseAddons.__namecall = function(_, Key, ...)
        setthreadidentity(8)
        return Funcs[Key](...)
    end
end

local BaseList = {}
local BaseGroupbox = {}
do
    local Funcs = {}

    function Funcs:AddDivider(...)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        local Params = select(1, ...)
        local Text
        local MarginTop = 0
        local MarginBottom = 0

        if typeof(Params) == "table" then
            Text = Params.Text
            MarginTop = Params.MarginTop or Params.Margin or 0
            MarginBottom = Params.MarginBottom or Params.Margin or 0
        elseif typeof(Params) == "string" then
            Text = Params
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 6 + MarginTop + MarginBottom),
            Parent = Container,
        })

        local InnerHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingTop = UDim.new(0, MarginTop),
            PaddingBottom = UDim.new(0, MarginBottom),
            Parent = Holder,
        })

        if Text then
            local TextLabel = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Text = Text,
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = InnerHolder,
            })

            local X, _ = Library:GetTextBounds(Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
            local SizeX = X // 2 + 10

            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
            New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
        else
            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Parent = InnerHolder,
            })
        end

        Groupbox:Resize()

        local Divider = {
            Connections = {},
            Destroyed = false,

            Holder = Holder,
            Text = Text,
            MarginTop = MarginTop,
            MarginBottom = MarginBottom,
            Type = "Divider",

            Parent = Groupbox,
        }

        function Divider:SetVisible(Value)
            setthreadidentity(8)
            Holder.Visible = Value == true
            Groupbox:Resize()
        end

        function Divider:Destroy()
            setthreadidentity(8)
            Divider.Destroyed = true

            if Divider.Connections then
                for _, Connection in Divider.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Divider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
        end

        table.insert(Groupbox.Elements, Divider)
        return Divider
    end

    function Funcs:AddLabel(...)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        local Data = {}
        local Addons = {}

        local First = select(1, ...)
        local Second = select(2, ...)

        if typeof(First) == "table" or typeof(Second) == "table" then
            local Params = typeof(First) == "table" and First or Second

            Data.Text = Params.Text or ""
            Data.DoesWrap = Params.DoesWrap or false
            Data.Size = Params.Size or 14
            Data.Visible = if typeof(Params.Visible) == "boolean" then Params.Visible else true
            Data.Idx = typeof(Second) == "table" and First or nil
        else
            Data.Text = First or ""
            Data.DoesWrap = Second or false
            Data.Size = 14
            Data.Visible = true
            Data.Idx = select(3, ...) or nil
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Label = {
            Connections = {},
            Destroyed = false,

            Text = Data.Text,
            DoesWrap = Data.DoesWrap,

            Addons = Addons,

            Visible = Data.Visible,
            Type = "Label",

            Parent = Groupbox,
        }

        local TextLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = Label.Text,
            TextSize = Data.Size,
            TextWrapped = Label.DoesWrap,
            TextXAlignment = Groupbox.IsKeyTab and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
            Visible = Label.Visible,
            Parent = Container,
        })

        function Label:Display()
            setthreadidentity(8)
            if not Label.DoesWrap then
                return
            end

            local Width = TextLabel.AbsoluteSize.X
            if Width <= 0 then return end

            local _, Y = Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, Width)
            TextLabel.Size = UDim2.new(1, 0, 0, Y + 4)
        end

        function Label:SetVisible(Visible: boolean)
            setthreadidentity(8)
            Label.Visible = Visible

            TextLabel.Visible = Label.Visible
            Groupbox:Resize()
        end

        function Label:SetText(Text: string)
            setthreadidentity(8)
            Label.Text = Text
            TextLabel.Text = Text

            Label:Display()
            Groupbox:Resize()
        end

        if Label.DoesWrap then
            Label:Display()

            local Last = TextLabel.AbsoluteSize
            table.insert(Label.Connections, TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                setthreadidentity(8)
                if TextLabel.AbsoluteSize == Last then
                    return
                end

                Label:Display()
                Last = TextLabel.AbsoluteSize

                Groupbox:Resize()
            end))
        else
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                Padding = UDim.new(0, 6),
                Parent = TextLabel,
            })
        end

        Groupbox:Resize()

        Label.TextLabel = TextLabel
        Label.Container = Container
        if not Data.DoesWrap then
            setmetatable(Label, BaseAddons)
        end

        Label.Holder = TextLabel
        table.insert(Groupbox.Elements, Label)

        if Data.Idx then
            Labels[Data.Idx] = Label
        else
            table.insert(Labels, Label)
        end

        function Label:Destroy()
            setthreadidentity(8)
            Label.Destroyed = true

            if Label.Connections then
                for _, Connection in Label.Connections do
                    Connection:Disconnect()
                end
            end

            if Label.Addons then
                for Index = #Label.Addons, 1, -1 do
                    local Addon = table.remove(Label.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            if TextLabel then
                TextLabel:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Label)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()

            if Data.Idx then
                Labels[Data.Idx] = nil
            else
                local LblIdx = table.find(Labels, Label)

                if LblIdx then
                    table.remove(Labels, LblIdx)
                end
            end
        end

        return Label
    end

    function Funcs:AddButton(...)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        local function GetInfo(...)
            setthreadidentity(8)
            local Info = {}

            local First = select(1, ...)
            local Second = select(2, ...)

            if typeof(First) == "table" or typeof(Second) == "table" then
                local Params = typeof(First) == "table" and First or Second

                Info.Text = Params.Text or ""
                Info.Func = Params.Func or Params.Callback or function()
                    setthreadidentity(8)
                end
                Info.DoubleClick = Params.DoubleClick

                Info.Tooltip = Params.Tooltip
                Info.DisabledTooltip = Params.DisabledTooltip

                Info.Risky = Params.Risky or false
                Info.Disabled = Params.Disabled or false
                Info.Visible = if typeof(Params.Visible) == "boolean" then Params.Visible else true
                Info.Idx = typeof(Second) == "table" and First or nil
                Info.Status = Params.Status
                Info.Badges = Params.Badges
                Info.Premium = Params.Premium
                Info.Experimental = Params.Experimental
                Info.Unstable = Params.Unstable
                Info.Detected = Params.Detected
                Info.CommandPalette = Params.CommandPalette
                Info.CommandName = Params.CommandName
                Info.CommandDescription = Params.CommandDescription
                Info.CommandKeywords = Params.CommandKeywords
                Info.CommandAction = Params.CommandAction
            else
                Info.Text = First or ""
                Info.Func = Second or function()
                    setthreadidentity(8)
                end
                Info.DoubleClick = false

                Info.Tooltip = nil
                Info.DisabledTooltip = nil

                Info.Risky = false
                Info.Disabled = false
                Info.Visible = true
                Info.Idx = select(3, ...) or nil
            end

            return Info
        end
        local Info = GetInfo(...)

        local Groupbox = self
        local Container = Groupbox.Container

        local Button = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Func = Info.Func,
            DoubleClick = Info.DoubleClick,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Tween = nil,
            Type = "Button",

            Parent = Groupbox,
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Parent = Container,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 9),
            Parent = Holder,
        })

        local function CreateButton(Button)
            setthreadidentity(8)
            local Base = New("TextButton", {
                Active = not Button.Disabled,
                BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor",
                Size = UDim2.fromScale(1, 1),
                Text = Button.Text,
                TextSize = 14,
                TextTransparency = 0.4,
                Visible = Button.Visible,
                Parent = Holder,
            })

            local Stroke = New("UIStroke", {
                Color = "OutlineColor",
                Transparency = Button.Disabled and 0.5 or 0,
                Parent = Base,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Base,
                })
            )

            return Base, Stroke
        end

        local function InitEvents(Button)
            setthreadidentity(8)
            table.insert(Button.Connections, Button.Base.MouseEnter:Connect(function()
                setthreadidentity(8)
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Base, Library.TweenInfo, {
                    TextTransparency = 0,
                })
                Button.Tween:Play()
            end))
            table.insert(Button.Connections, Button.Base.MouseLeave:Connect(function()
                setthreadidentity(8)
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Base, Library.TweenInfo, {
                    TextTransparency = 0.4,
                })
                Button.Tween:Play()
            end))

            table.insert(Button.Connections, Button.Base.MouseButton1Click:Connect(function()
                setthreadidentity(8)
                if Button.Disabled or Button.Locked then
                    return
                end

                if Button.DoubleClick then
                    Button.Locked = true

                    Button.Base.Text = "Are you sure?"
                    Button.Base.TextColor3 = Library.Scheme.AccentColor
                    Library.Registry[Button.Base].TextColor3 = "AccentColor"

                    local Clicked = WaitForEvent(Button.Base.MouseButton1Click, 0.5)

                    Button.Base.Text = Button.Text
                    Button.Base.TextColor3 = Button.Risky and Library.Scheme.RedColor or Library.Scheme.FontColor
                    Library.Registry[Button.Base].TextColor3 = Button.Risky and "RedColor" or "FontColor"

                    if Clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    RunService.RenderStepped:Wait() --// Mouse Button fires without waiting (i hate roblox)
                    Button.Locked = false
                    return
                end

                Library:SafeCallback(Button.Func)
            end))
        end

        Button.Base, Button.Stroke = CreateButton(Button)
        InitEvents(Button)
        Library:BindFeatureBadges(Button, Info, function(Text: string)
            setthreadidentity(8)
            Button.Base.Text = Text
        end)

        function Button:AddButton(...)
            setthreadidentity(8)
            local Info = GetInfo(...)

            local SubButton = {
                Connections = {},
                Destroyed = false,

                Text = Info.Text,
                Func = Info.Func,
                DoubleClick = Info.DoubleClick,

                Tooltip = Info.Tooltip,
                DisabledTooltip = Info.DisabledTooltip,
                TooltipTable = nil,

                Risky = Info.Risky,
                Disabled = Info.Disabled,
                Visible = Info.Visible,

                Tween = nil,
                Type = "SubButton",
            }

            Button.SubButton = SubButton
            SubButton.Base, SubButton.Stroke = CreateButton(SubButton)
            InitEvents(SubButton)

            function SubButton:UpdateColors()
                setthreadidentity(8)
                if Library.Unloaded then
                    return
                end

                StopTween(SubButton.Tween)

                SubButton.Base.BackgroundColor3 = SubButton.Disabled and Library.Scheme.BackgroundColor
                    or Library.Scheme.MainColor
                SubButton.Base.TextTransparency = SubButton.Disabled and 0.8 or 0.4
                SubButton.Stroke.Transparency = SubButton.Disabled and 0.5 or 0

                Library.Registry[SubButton.Base].BackgroundColor3 = SubButton.Disabled and "BackgroundColor"
                    or "MainColor"
            end

            function SubButton:SetDisabled(Disabled: boolean)
                setthreadidentity(8)
                SubButton.Disabled = Disabled

                if SubButton.TooltipTable then
                    SubButton.TooltipTable.Disabled = SubButton.Disabled
                end

                SubButton.Base.Active = not SubButton.Disabled
                SubButton:UpdateColors()
                Library:UpdateAddons(SubButton)
            end

            function SubButton:SetVisible(Visible: boolean)
                setthreadidentity(8)
                SubButton.Visible = Visible

                SubButton.Base.Visible = SubButton.Visible
                Groupbox:Resize()
            end

            function SubButton:SetText(Text: string)
                setthreadidentity(8)
                SubButton.Text = Text
                SubButton.Base.Text = Text
            end

            if typeof(SubButton.Tooltip) == "string" or typeof(SubButton.DisabledTooltip) == "string" then
                SubButton.TooltipTable =
                    Library:AddTooltip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Base)
                SubButton.TooltipTable.Disabled = SubButton.Disabled
            end

            if SubButton.Risky then
                SubButton.Base.TextColor3 = Library.Scheme.RedColor
                Library.Registry[SubButton.Base].TextColor3 = "RedColor"
            end

            SubButton:UpdateColors()

            if Info.Idx then
                Buttons[Info.Idx] = SubButton
            else
                table.insert(Buttons, SubButton)
            end

            SubButton.AddKeyPicker = BaseAddons.__index.AddKeyPicker

            function SubButton:Destroy()
                setthreadidentity(8)
                SubButton.Destroyed = true

                if SubButton.Connections then
                    for _, Connection in SubButton.Connections do
                        Connection:Disconnect()
                    end
                end

                if SubButton.TooltipTable then
                    SubButton.TooltipTable:Destroy()
                end

                if SubButton.Tween then
                    SubButton.Tween:Destroy()
                end

                if SubButton.Base then
                    SubButton.Base:Destroy()
                end

                if Info.Idx then
                    Buttons[Info.Idx] = nil
                else
                    local BIdx = table.find(Buttons, SubButton)

                    if BIdx then
                        table.remove(Buttons, BIdx)
                    end
                end
            end

            return SubButton
        end

        function Button:UpdateColors()
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            StopTween(Button.Tween)

            Button.Base.BackgroundColor3 = Button.Disabled and Library.Scheme.BackgroundColor
                or Library.Scheme.MainColor
            Button.Base.TextTransparency = Button.Disabled and 0.8 or 0.4
            Button.Stroke.Transparency = Button.Disabled and 0.5 or 0

            Library.Registry[Button.Base].BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor"
        end

        function Button:SetDisabled(Disabled: boolean)
            setthreadidentity(8)
            Button.Disabled = Disabled

            if Button.TooltipTable then
                Button.TooltipTable.Disabled = Button.Disabled
            end

            Button.Base.Active = not Button.Disabled
            Button:UpdateColors()
            Library:UpdateAddons(Button)
        end

        function Button:SetVisible(Visible: boolean)
            setthreadidentity(8)
            Button.Visible = Visible

            Holder.Visible = Button.Visible
            Groupbox:Resize()
        end

        function Button:SetText(Text: string)
            setthreadidentity(8)
            Button.Text = Text
            Button.Base.Text = Library:FormatFeatureText(Text, Button.Badges)
        end

        if typeof(Button.Tooltip) == "string" or typeof(Button.DisabledTooltip) == "string" then
            Button.TooltipTable = Library:AddTooltip(Button.Tooltip, Button.DisabledTooltip, Button.Base)
            Button.TooltipTable.Disabled = Button.Disabled
        end

        if Button.Risky then
            Button.Base.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Button.Base].TextColor3 = "RedColor"
        end

        Button:UpdateColors()
        Groupbox:Resize()

        Button.Holder = Holder
        table.insert(Groupbox.Elements, Button)

        if Info.Idx then
            Buttons[Info.Idx] = Button
        else
            table.insert(Buttons, Button)
        end

        Library:RegisterElementCommand(Button, Groupbox, Info)

        Button.AddKeyPicker = BaseAddons.__index.AddKeyPicker

        function Button:Destroy()
            setthreadidentity(8)
            Button.Destroyed = true

            if Button.Connections then
                for _, Connection in Button.Connections do
                    Connection:Disconnect()
                end
            end

            if Button.TooltipTable then
                Button.TooltipTable:Destroy()
            end

            if Button.Tween then
                Button.Tween:Destroy()
            end

            if Button.SubButton then
                Button.SubButton:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Button)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()

            if Info.Idx then
                Buttons[Info.Idx] = nil
            else
                local BIdx = table.find(Buttons, Button)

                if BIdx then
                    table.remove(Buttons, BIdx)
                end
            end
        end

        return Button
    end

    function Funcs:AddCheckbox(Idx, Info)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Checkbox",
            Type = "Toggle",

            Parent = Groupbox,
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(26, 0),
            Size = UDim2.new(1, -26, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })
        Library:BindFeatureBadges(Toggle, Info, function(Text: string)
            setthreadidentity(8)
            Label.Text = Text
        end)

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Checkbox = New("Frame", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Button,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Checkbox,
            })
        )

        local CheckboxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Checkbox,
        })

        local CheckImage = New("ImageLabel", {
            ImageColor3 = "FontColor",
            ImageTransparency = 1,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = Checkbox,
        })
        if CheckIcon then
            Library:ApplyLucideIcon(CheckImage, CheckIcon)
        end

        function Toggle:UpdateColors()
            setthreadidentity(8)
            Toggle:Display()
        end

        function Toggle:Display()
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            CheckboxStroke.Transparency = Toggle.Disabled and 0.5 or 0

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                CheckImage.ImageTransparency = Toggle.Value and 0.8 or 1

                Checkbox.BackgroundColor3 = Library.Scheme.BackgroundColor
                Library.Registry[Checkbox].BackgroundColor3 = "BackgroundColor"

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(CheckImage, Library.TweenInfo, {
                ImageTransparency = Toggle.Value and 0 or 1,
            }):Play()

            Checkbox.BackgroundColor3 = Library.Scheme.MainColor
            Library.Registry[Checkbox].BackgroundColor3 = "MainColor"
        end

        function Toggle:OnChanged(Func)
            setthreadidentity(8)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            setthreadidentity(8)
            if Toggle.Disabled then
                return
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            setthreadidentity(8)
            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            if not Toggle.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            setthreadidentity(8)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            Library:UpdateAddons(Toggle)

            Button.Active = not Toggle.Disabled
            Toggle:Display()

            Library:UpdateDependencyBoxes()
        end

        function Toggle:SetVisible(Visible: boolean)
            setthreadidentity(8)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            setthreadidentity(8)
            Toggle.Text = Text
            Label.Text = Library:FormatFeatureText(Text, Toggle.Badges)
        end

        table.insert(Toggle.Connections, Button.MouseButton1Click:Connect(function()
            setthreadidentity(8)
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle
        Library:RegisterElementCommand(Toggle, Groupbox, Info)

        function Toggle:Destroy()
            setthreadidentity(8)
            Toggle.Destroyed = true

            if Toggle.Command then
                Toggle.Command:Destroy()
            end

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then
                Toggle.TooltipTable:Destroy()
            end

            if Button then
                Button:Destroy()
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddToggle(Idx, Info)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        if Library.ForceCheckbox then
            return Funcs.AddCheckbox(self, Idx, Info)
        end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Switch",
            Type = "Toggle",

            Parent = Groupbox,
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })
        Library:BindFeatureBadges(Toggle, Info, function(Text: string)
            setthreadidentity(8)
            Label.Text = Text
        end)

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Switch = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromOffset(32, 18),
            Parent = Button,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Switch,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = Switch,
        })
        local SwitchStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Switch,
        })

        local Ball = New("Frame", {
            BackgroundColor3 = "FontColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Switch,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Ball,
        })

        function Toggle:UpdateColors()
            setthreadidentity(8)
            Toggle:Display()
        end

        function Toggle:Display()
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            local Offset = Toggle.Value and 1 or 0

            Switch.BackgroundTransparency = Toggle.Disabled and 0.75 or 0
            SwitchStroke.Transparency = Toggle.Disabled and 0.75 or 0

            Switch.BackgroundColor3 = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.MainColor
            SwitchStroke.Color = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.OutlineColor

            Library.Registry[Switch].BackgroundColor3 = Toggle.Value and "AccentColor" or "MainColor"
            Library.Registry[SwitchStroke].Color = Toggle.Value and "AccentColor" or "OutlineColor"

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                Ball.AnchorPoint = Vector2.new(Offset, 0)
                Ball.Position = UDim2.fromScale(Offset, 0)

                Ball.BackgroundColor3 = Library:GetDarkerColor(Library.Scheme.FontColor)
                Library.Registry[Ball].BackgroundColor3 = function()
                    setthreadidentity(8)
                    return Library:GetDarkerColor(Library.Scheme.FontColor)
                end

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(Ball, Library.TweenInfo, {
                AnchorPoint = Vector2.new(Offset, 0),
                Position = UDim2.fromScale(Offset, 0),
            }):Play()

            Ball.BackgroundColor3 = Library.Scheme.FontColor
            Library.Registry[Ball].BackgroundColor3 = "FontColor"
        end

        function Toggle:OnChanged(Func)
            setthreadidentity(8)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            setthreadidentity(8)
            if Toggle.Disabled then
                return
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            setthreadidentity(8)
            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            if not Toggle.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            setthreadidentity(8)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            Library:UpdateAddons(Toggle)

            Button.Active = not Toggle.Disabled
            Toggle:Display()

            Library:UpdateDependencyBoxes()
        end

        function Toggle:SetVisible(Visible: boolean)
            setthreadidentity(8)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            setthreadidentity(8)
            Toggle.Text = Text
            Label.Text = Library:FormatFeatureText(Text, Toggle.Badges)
        end

        table.insert(Toggle.Connections, Button.MouseButton1Click:Connect(function()
            setthreadidentity(8)
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle
        Library:RegisterElementCommand(Toggle, Groupbox, Info)

        function Toggle:Destroy()
            setthreadidentity(8)
            Toggle.Destroyed = true

            if Toggle.Command then
                Toggle.Command:Destroy()
            end

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then
                Toggle.TooltipTable:Destroy()
            end

            if Button then
                Button:Destroy()
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddInput(Idx, Info)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        if typeof(Info) == "table" and (typeof(Info.VerifyValue) == "function" and Info.Finished ~= true) then
            Info.Finished = true
        end

        Info = Library:Validate(Info, Templates.Input)

        local Groupbox = self
        local Container = Groupbox.Container

        local Input = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Finished = Info.Finished,
            Numeric = Info.Numeric,
            ClearTextOnFocus = Info.ClearTextOnFocus,
            ClearTextOnBlur = Info.ClearTextOnBlur,
            Placeholder = Info.Placeholder,
            AllowEmpty = Info.AllowEmpty,
            EmptyReset = Info.EmptyReset,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,
            VerifyValue = Info.VerifyValue,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Input",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 39),
            Visible = Input.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Input.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local Box = New("TextBox", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus,
            PlaceholderText = Input.Placeholder,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = Input.Value,
            TextEditable = not Input.Disabled,
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local BoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Box,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Box,
            })
        )

        function Input:UpdateColors()
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Input.Disabled and 0.8 or 0
            Box.TextTransparency = Input.Disabled and 0.8 or 0
            BoxStroke.Transparency = Input.Disabled and 0.5 or 0

            Box.BackgroundColor3 = Input.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
            Library.Registry[Box].BackgroundColor3 = Input.Disabled and "BackgroundColor" or "MainColor"
        end

        function Input:OnChanged(Func)
            setthreadidentity(8)
            Input.Changed = Func
        end

        function Input:RunChanged()
            setthreadidentity(8)
            if Input.Disabled then
                return
            end

            Library:SafeCallback(Input.Callback, Input.Value)
            Library:SafeCallback(Input.Changed, Input.Value)
        end

        function Input:SetValue(Text)
            setthreadidentity(8)
            if not Input.AllowEmpty and Trim(Text) == "" then
                Text = Input.EmptyReset
            end

            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength)
            end

            if Input.Numeric then
                if #tostring(Text) > 0 and not tonumber(Text) then
                    Text = Input.Value
                end
            end

            if typeof(Info.VerifyValue) == "function" and (Text ~= Input.EmptyReset and Info.VerifyValue(Text) ~= true) then
                Text = Input.EmptyReset
            end

            Input.Value = Text
            Box.Text = Text

            Input:RunChanged()
        end

        function Input:SetDisabled(Disabled: boolean)
            setthreadidentity(8)
            Input.Disabled = Disabled

            if Input.TooltipTable then
                Input.TooltipTable.Disabled = Input.Disabled
            end

            Box.ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus
            Box.TextEditable = not Input.Disabled
            Input:UpdateColors()
        end

        function Input:SetVisible(Visible: boolean)
            setthreadidentity(8)
            Input.Visible = Visible

            Holder.Visible = Input.Visible
            Groupbox:Resize()
        end

        function Input:SetText(Text: string)
            setthreadidentity(8)
            Input.Text = Text
            Label.Text = Text
        end

        if Input.Finished then
            table.insert(Input.Connections, Box.FocusLost:Connect(function(Enter)
                setthreadidentity(8)
                if not Enter then
                    if Input.ClearTextOnBlur then
                        Box.Text = Input.Value
                    end

                    return
                end

                Input:SetValue(Box.Text)
            end))
        else
            table.insert(Input.Connections, Box:GetPropertyChangedSignal("Text"):Connect(function()
                setthreadidentity(8)
                if Box.Text == Input.Value then return end

                Input:SetValue(Box.Text)
            end))
        end

        table.insert(Input.Connections, Box.Focused:Connect(function()
            setthreadidentity(8)
            if Input.Disabled then
                return
            end

            Library.Registry[BoxStroke].Color = "AccentColor"
            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        table.insert(Input.Connections, Box.FocusLost:Connect(function()
            setthreadidentity(8)
            if Input.Disabled then
                return
            end

            Library.Registry[BoxStroke].Color = "OutlineColor"
            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()
        end))

        if typeof(Input.Tooltip) == "string" or typeof(Input.DisabledTooltip) == "string" then
            Input.TooltipTable = Library:AddTooltip(Input.Tooltip, Input.DisabledTooltip, Box)
            Input.TooltipTable.Disabled = Input.Disabled
        end

        Groupbox:Resize()

        Input.Holder = Holder
        table.insert(Groupbox.Elements, Input)

        Input.Default = Input.Value
        if typeof(Info.VerifyValue) == "function" and (Input.Default ~= Input.EmptyReset and Info.VerifyValue(Input.Default) ~= true) then
            Input:SetValue(Input.EmptyReset)
            Input.Default = Input.EmptyReset
        end

        Input:UpdateColors()
        Options[Idx] = Input

        function Input:Destroy()
            setthreadidentity(8)
            Input.Destroyed = true

            if Input.Connections then
                for _, Connection in Input.Connections do
                    Connection:Disconnect()
                end
            end

            if Input.TooltipTable then
                Input.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Input)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Input
    end

    function Funcs:AddSlider(Idx, Info)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Slider)

        local Groupbox = self
        local Container = Groupbox.Container

        local Slider = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Min = Info.Min,
            Max = Info.Max,

            Prefix = Info.Prefix,
            Suffix = Info.Suffix,
            Compact = Info.Compact,
            Rounding = Info.Rounding,
            HideMax = Info.HideMax,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            AllowRightClickInput = Info.AllowRightClickInput,

            Type = "Slider",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Compact and 15 or 33),
            Visible = Slider.Visible,
            Parent = Container,
        })

        local SliderLabel
        if not Info.Compact then
            SliderLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Text = Slider.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
        end

        local Bar = New("TextButton", {
            Active = not Slider.Disabled,
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 15),
            Text = "",
            Parent = Holder,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Bar,
        })

        local DisplayLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            ZIndex = Bar.ZIndex + 2,
            Parent = Bar,
        })
        New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = "DarkColor",
            LineJoinMode = Enum.LineJoinMode.Miter,
            Parent = DisplayLabel,
        })

        local InputTextBox
        local InputTextBoxStroke
        if Info.AllowRightClickInput then
            InputTextBox = New("TextBox", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = "",
                TextSize = 14,
                ZIndex = Bar.ZIndex + 3,
                Visible = false,
                ClearTextOnFocus = false,
                Parent = Bar,
            })
            InputTextBoxStroke = New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = InputTextBox,
            })
        end

        local Fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0.5, 1),
            ZIndex = Bar.ZIndex + 1,
            Parent = Bar,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Bar,
            })
        )

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Fill,
            })
        )

        function Slider:UpdateColors()
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            if SliderLabel then
                SliderLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            end
            DisplayLabel.TextTransparency = Slider.Disabled and 0.8 or 0

            if Info.AllowRightClickInput then
                InputTextBox.TextTransparency = Slider.Disabled and 0.8 or 0
            end

            Fill.BackgroundColor3 = Slider.Disabled and Library.Scheme.OutlineColor or Library.Scheme.AccentColor
            Library.Registry[Fill].BackgroundColor3 = Slider.Disabled and "OutlineColor" or "AccentColor"
        end

        function Slider:Display()
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            local CustomDisplayText = nil
            if Info.FormatDisplayValue then
                CustomDisplayText = Info.FormatDisplayValue(Slider, Slider.Value)
            end

            if CustomDisplayText then
                DisplayLabel.Text = tostring(CustomDisplayText)
            else
                if Info.Compact then
                    DisplayLabel.Text =
                        string.format("%s: %s%s%s", Slider.Text, Slider.Prefix, Slider.Value, Slider.Suffix)
                elseif Info.HideMax then
                    DisplayLabel.Text = string.format("%s%s%s", Slider.Prefix, Slider.Value, Slider.Suffix)
                else
                    DisplayLabel.Text = string.format(
                        "%s%s%s/%s%s%s",
                        Slider.Prefix,
                        Slider.Value,
                        Slider.Suffix,
                        Slider.Prefix,
                        Slider.Max,
                        Slider.Suffix
                    )
                end
            end

            local X = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
            Fill.Size = UDim2.fromScale(X, 1)
        end

        function Slider:OnChanged(Func)
            setthreadidentity(8)
            Slider.Changed = Func
        end

        function Slider:SetMax(Value)
            setthreadidentity(8)
            assert(Value > Slider.Min, "Max value cannot be less than the current min value.")

            Slider:SetValue(math.clamp(Slider.Value, Slider.Min, Value))
            Slider.Max = Value
            Slider:Display()
        end

        function Slider:SetMin(Value)
            setthreadidentity(8)
            assert(Value < Slider.Max, "Min value cannot be greater than the current max value.")

            Slider:SetValue(math.clamp(Slider.Value, Value, Slider.Max))
            Slider.Min = Value
            Slider:Display()
        end

        function Slider:RunChanged()
            setthreadidentity(8)
            if Slider.Disabled then
                return
            end

            Library:SafeCallback(Slider.Callback, Slider.Value)
            Library:SafeCallback(Slider.Changed, Slider.Value)
        end

        function Slider:SetValue(Str)
            setthreadidentity(8)
            local Num = tonumber(Str)
            if not Num or Num == Slider.Value then
                return
            end

            Num = math.clamp(Num, Slider.Min, Slider.Max)

            Slider.Value = Num
            Slider:Display()

            Slider:RunChanged()
        end

        function Slider:SetDisabled(Disabled: boolean)
            setthreadidentity(8)
            Slider.Disabled = Disabled

            if Slider.TooltipTable then
                Slider.TooltipTable.Disabled = Slider.Disabled
            end

            Bar.Active = not Slider.Disabled
            Slider:UpdateColors()
        end

        function Slider:SetVisible(Visible: boolean)
            setthreadidentity(8)
            Slider.Visible = Visible

            Holder.Visible = Slider.Visible
            Groupbox:Resize()
        end

        function Slider:SetText(Text: string)
            setthreadidentity(8)
            Slider.Text = Text
            if SliderLabel then
                SliderLabel.Text = Text
                return
            end
            Slider:Display()
        end

        function Slider:SetPrefix(Prefix: string)
            setthreadidentity(8)
            Slider.Prefix = Prefix
            Slider:Display()
        end

        function Slider:SetSuffix(Suffix: string)
            setthreadidentity(8)
            Slider.Suffix = Suffix
            Slider:Display()
        end

        if Info.AllowRightClickInput then
            local LastValidText = ""
            table.insert(Slider.Connections, InputTextBox:GetPropertyChangedSignal("Text"):Connect(function()
                setthreadidentity(8)
                local Text = InputTextBox.Text
                local AsNum = tonumber(Text)

                if #tostring(Text) > 0 and not AsNum and Text ~= "-" then
                    InputTextBox.Text = LastValidText
                else
                    if Slider.Rounding == 0 and Text:find("%.") then
                        InputTextBox.Text = LastValidText
                        return
                    end

                    local DecimalPos = Text:find("%.")
                    if DecimalPos and Slider.Rounding > 0 then
                        local Decimals = #Text - DecimalPos
                        if Decimals > Slider.Rounding then
                            InputTextBox.Text = LastValidText
                            return
                        end
                    end

                    LastValidText = Text

                    if AsNum then
                        if AsNum > Slider.Max then
                            InputTextBox.Text = tostring(Slider.Max)
                        elseif AsNum < Slider.Min then
                            InputTextBox.Text = tostring(Slider.Min)
                        end
                    end
                end
            end))

            table.insert(Slider.Connections, InputTextBox.FocusLost:Connect(function()
                setthreadidentity(8)
                InputTextBox.Visible = false
                DisplayLabel.Visible = true

                local Num = tonumber(InputTextBox.Text)
                if not Num then
                    return
                end

                Num = Round(Num, Slider.Rounding)
                Slider:SetValue(Num)
            end))

            table.insert(Slider.Connections, InputTextBox.Focused:Connect(function()
                setthreadidentity(8)
                if Slider.Disabled then
                    return
                end

                Library.Registry[InputTextBoxStroke].Color = "AccentColor"
                TweenService:Create(InputTextBoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(Slider.Connections, InputTextBox.FocusLost:Connect(function()
                setthreadidentity(8)
                if Slider.Disabled then
                    return
                end

                Library.Registry[InputTextBoxStroke].Color = "DarkColor"
                TweenService:Create(InputTextBoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.DarkColor,
                }):Play()
            end))
        end

        local LastTap = 0
        table.insert(Slider.Connections, Bar.InputBegan:Connect(function(Input: InputObject)
            setthreadidentity(8)
            local ValidInput = IsClickInput(Input) or Input.UserInputType == Enum.UserInputType.MouseButton2
            if not ValidInput or Slider.Disabled then
                return
            end

            if Info.AllowRightClickInput then
                local IsRightClick = Input.UserInputType == Enum.UserInputType.MouseButton2
                local IsDoubleTap = false

                if Library.IsMobile and Input.UserInputType == Enum.UserInputType.Touch then
                    if tick() - LastTap < 0.3 then
                        IsDoubleTap = true
                    end

                    LastTap = tick()
                end

                if IsRightClick or IsDoubleTap then
                    InputTextBox.Text = tostring(Slider.Value)
                    InputTextBox.Visible = true
                    DisplayLabel.Visible = false

                    task.spawn(InputTextBox.CaptureFocus, InputTextBox)
                    return
                end
            end

            if not IsClickInput(Input) then
                return
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = false
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = false
            end

            while IsDragInput(Input) and not Slider.Destroyed do
                local Location = Mouse.X
                local Scale = math.clamp((Location - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)

                local OldValue = Slider.Value
                Slider.Value = Round(Slider.Min + ((Slider.Max - Slider.Min) * Scale), Slider.Rounding)

                Slider:Display()
                if Slider.Value ~= OldValue then
                    Slider:RunChanged()
                end

                RunService.RenderStepped:Wait()
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = true
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = true
            end
        end))

        if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
            Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
            Slider.TooltipTable.Disabled = Slider.Disabled
        end

        Slider:UpdateColors()
        Slider:Display()
        Groupbox:Resize()

        Slider.Holder = Holder
        table.insert(Groupbox.Elements, Slider)

        Slider.Default = Slider.Value

        Options[Idx] = Slider

        function Slider:Destroy()
            setthreadidentity(8)
            Slider.Destroyed = true

            if Slider.Connections then
                for _, Connection in Slider.Connections do
                    Connection:Disconnect()
                end
            end

            if Slider.TooltipTable then
                Slider.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Slider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Slider
    end

    function Funcs:AddDropdown(Idx, Info)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Dropdown)

        local Groupbox = self
        local Container = Groupbox.Container

        if Info.SpecialType == "Player" then
            Info.Values = GetPlayers(Info.ExcludeLocalPlayer)
            Info.AllowNull = true
        elseif Info.SpecialType == "Team" then
            Info.Values = GetTeams()
            Info.AllowNull = true
        end

        local Dropdown = {
            Connections = {},
            Destroyed = false,

            Text = typeof(Info.Text) == "string" and Info.Text or nil,

            Value = Info.Multi and {} or nil,
            Values = Info.Values,
            DisabledValues = Info.DisabledValues,
            ValueImages = Info.ValueImages,

            Multi = Info.Multi,
            DragSelect = Info.Multi and not Library.IsMobile and Info.DragSelect == true,
            SelectionControls = Info.Multi and Info.SelectionControls == true,
            Prioritize = Info.Multi and Info.Prioritize == true,
            PriorityButtonsPosition = Info.PriorityButtonsPosition == "Left" and "Left" or "Right",
            AutoSizeDropdown = Info.AutoSizeDropdown == true,
            MaxDropdownWidth = Info.MaxDropdownWidth,
            Priority = {},

            SpecialType = Info.SpecialType,
            ExcludeLocalPlayer = Info.ExcludeLocalPlayer,
            EnablePlayerImages = Info.EnablePlayerImages,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Dropdown",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Dropdown.Text and 39 or 21),
            Visible = Dropdown.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Dropdown.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = not not Info.Text,
            ZIndex = 3,
            Parent = Holder,
        })

        local DisplayContainer = New("TextButton", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = "",
            TextTransparency = 1,
            ZIndex = 2,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 4),
            Parent = DisplayContainer,
        })

        local DisplayStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = DisplayContainer,
        })

        local DropdownCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = DisplayContainer,
        }); table.insert(Library.SpecificCorners, DropdownCorner)

        local DisplayImage = New("ImageLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(-4, 3),
            Size = UDim2.fromOffset(16, 16),
            Image = "",
            ImageTransparency = 1,
            ZIndex = 2,
            Parent = DisplayContainer,
        })

        local DisplayButton = New("TextButton", {
            Active = not Dropdown.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Text = "---",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = DisplayContainer,
        })

        local ArrowImage = New("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(16, 16),
            Parent = DisplayContainer,
        })
        if ArrowIcon then
            Library:ApplyLucideIcon(ArrowImage, ArrowIcon)
        end

        local SearchBox
        if Info.Searchable then
            SearchBox = New("TextBox", {
                BackgroundTransparency = 1,
                PlaceholderText = "Search...",
                Position = UDim2.fromOffset(-8, 0),
                Size = UDim2.new(1, -12, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = false,
                Parent = DisplayButton,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                Parent = SearchBox,
            })

            table.insert(Dropdown.Connections, SearchBox.Focused:Connect(function()
                setthreadidentity(8)
                Library.Registry[DisplayStroke].Color = "AccentColor"
                TweenService:Create(DisplayStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(Dropdown.Connections, SearchBox.FocusLost:Connect(function()
                setthreadidentity(8)
                Library.Registry[DisplayStroke].Color = "OutlineColor"
                TweenService:Create(DisplayStroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        local GetValueImage = function(Value, RawValue)
            setthreadidentity(8)
            if not Value then
                return nil
            end

            local ValueImage = nil
            if Dropdown.SpecialType == "Player" and Dropdown.EnablePlayerImages == true then
                local PlayerValue = Value
                if typeof(PlayerValue) ~= "Instance" and RawValue ~= nil then
                    PlayerValue = RawValue
                end

                if typeof(PlayerValue) == "Instance" and PlayerValue:IsA("Player") then
                    ValueImage = { Url = string.format("rbxthumb://type=AvatarHeadShot&id=%s&w=48&h=48", tostring(PlayerValue.UserId)) }
                end
            end

            if Dropdown.ValueImages then
                local IconRef = Dropdown.ValueImages[Value]
                if IconRef == nil and RawValue ~= nil then
                    IconRef = Dropdown.ValueImages[RawValue]
                end

                if IconRef then
                    ValueImage = Library:GetCustomIcon(IconRef)
                end
            end

            return ValueImage
        end

        local CachedContentWidth = nil

        local function CalculateMenuWidth()
            setthreadidentity(8)
            local width = DisplayContainer.AbsoluteSize.X / Library.DPIScale

            if not Dropdown.AutoSizeDropdown then
                return width
            end

            if CachedContentWidth == nil then
                local isDictionary = not IsSequentialArray(Dropdown.Values)
                local controlWidth = Dropdown.Prioritize and 46 or 16
                local contentWidth = 0

                for key, rawValue in Dropdown.Values do
                    local formattedValue = tostring(Info.FormatListValue and Info.FormatListValue(rawValue) or rawValue)
                    local textWidth = Library:GetTextBounds(formattedValue, DisplayButton.FontFace, 14)
                    local value = isDictionary and key or rawValue
                    local imageWidth = GetValueImage(value, rawValue) and 20 or 0

                    contentWidth = math.max(contentWidth, textWidth + controlWidth + imageWidth)
                end

                CachedContentWidth = contentWidth
            end

            width = math.max(width, CachedContentWidth)

            local camera = workspace.CurrentCamera
            local viewportWidth = camera and camera.ViewportSize.X or DisplayContainer.AbsoluteSize.X
            local maximumWidth = math.max(
                DisplayContainer.AbsoluteSize.X / Library.DPIScale,
                math.min(viewportWidth / Library.DPIScale - 16, Dropdown.MaxDropdownWidth)
            )

            return math.min(width, maximumWidth)
        end

        local function CalculateMenuOffset()
            setthreadidentity(8)
            if not Dropdown.AutoSizeDropdown then
                return { 0.5, DisplayContainer.AbsoluteSize.Y + 1.5 }
            end

            local menuWidth = CalculateMenuWidth() * Library.DPIScale
            local camera = workspace.CurrentCamera
            local viewportWidth = camera and camera.ViewportSize.X or DisplayContainer.AbsolutePosition.X + menuWidth
            local centeredPosition = DisplayContainer.AbsolutePosition.X
                + (DisplayContainer.AbsoluteSize.X - menuWidth) / 2
            local clampedPosition = math.clamp(
                centeredPosition,
                8,
                math.max(8, viewportWidth - menuWidth - 8)
            )

            return {
                clampedPosition - DisplayContainer.AbsolutePosition.X,
                DisplayContainer.AbsoluteSize.Y + 4,
            }
        end

        local MenuTable
        MenuTable = Library:AddContextMenu(
            DisplayContainer,
            function()
                setthreadidentity(8)
                return UDim2.fromOffset(CalculateMenuWidth(), 0)
            end,
            CalculateMenuOffset,
            2,
            function(Active: boolean)
                setthreadidentity(8)
                DisplayButton.TextTransparency = (Active and SearchBox) and 1 or 0

                ArrowImage.ImageTransparency = Active and 0 or 0.5
                ArrowImage.Rotation = Active and 180 or 0

                if SearchBox then
                    SearchBox.Text = ""
                    SearchBox.Visible = Active
                end

                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)

                DropdownCorner.TopLeftRadius = Half
                DropdownCorner.TopRightRadius = Half
                DropdownCorner.BottomRightRadius = Active and Zero or Half
                DropdownCorner.BottomLeftRadius = Active and Zero or Half

                local MenuCorner = MenuTable and MenuTable.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Zero
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end,
            false,
            Dropdown.AutoSizeDropdown and nil or "bottom",
            "Dropdown"
        )
        Dropdown.Menu = MenuTable

        local ItemHeight = 21
        local HeaderHeight = Dropdown.SelectionControls and 29 or 0
        local PoolSize = math.max(1, Info.MaxVisibleDropdownItems + 2)
        local Pool = {}
        local FilteredEntries = {}

        if Dropdown.SelectionControls then
            local Header = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, HeaderHeight),
                Parent = MenuTable.Menu,
            })

            local SelectAllButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromOffset(4, 4),
                Size = UDim2.new(0.5, -6, 0, 20),
                Text = "Select All",
                TextSize = 12,
                Parent = Header,
            })

            local UnselectAllButton = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = "MainColor",
                Position = UDim2.new(1, -4, 0, 4),
                Size = UDim2.new(0.5, -6, 0, 20),
                Text = "Unselect All",
                TextSize = 12,
                Parent = Header,
            })

            for _, button in { SelectAllButton, UnselectAllButton } do
                local corner = New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = button,
                })
                table.insert(Library.Corners, corner)

                New("UIStroke", {
                    Color = "OutlineColor",
                    Parent = button,
                })
            end

            New("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = "OutlineColor",
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, 0, 0, 1),
                Parent = Header,
            })

            table.insert(Dropdown.Connections, SelectAllButton.Activated:Connect(function()
                setthreadidentity(8)
                local SelectAll = rawget(Dropdown, "SelectAll")
                if typeof(SelectAll) == "function" then
                    SelectAll(Dropdown)
                end
            end))
            table.insert(Dropdown.Connections, UnselectAllButton.Activated:Connect(function()
                setthreadidentity(8)
                local UnselectAll = rawget(Dropdown, "UnselectAll")
                if typeof(UnselectAll) == "function" then
                    UnselectAll(Dropdown)
                end
            end))
        end

        function Dropdown:RecalculateListSize(Count)
            setthreadidentity(8)
            local ItemCount = Count or #FilteredEntries
            local Y = HeaderHeight + math.clamp(ItemCount * ItemHeight, 0, Info.MaxVisibleDropdownItems * ItemHeight)

            MenuTable.Menu.CanvasSize = UDim2.fromOffset(0, HeaderHeight + ItemCount * ItemHeight)

            MenuTable:SetSize(function()
                setthreadidentity(8)
                return UDim2.fromOffset(CalculateMenuWidth(), Y)
            end)
        end

        function Dropdown:UpdateColors()
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Dropdown.Disabled and 0.8 or 0
            DisplayButton.TextTransparency = Dropdown.Disabled and 0.8 or 0
            DisplayImage.ImageTransparency = Dropdown.Disabled and 0.8 or 0
            ArrowImage.ImageTransparency = Dropdown.Disabled and 0.8 or MenuTable.Active and 0 or 0.5
        end

        function Dropdown:Display()
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            local Str = ""
            local ValueImage = nil
            local IsDictionary = not IsSequentialArray(Dropdown.Values)

            if Info.Multi then
                for Key, RawValue in Dropdown.Values do
                    local Value = IsDictionary and Key or RawValue

                    if Dropdown.Value[Value] then
                        if not ValueImage then
                            ValueImage = GetValueImage(Value, RawValue)
                        end

                        Str = Str
                            .. (Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(RawValue)) or tostring(RawValue))
                            .. ", "
                    end
                end

                Str = Str:sub(1, #Str - 2)
            else
                local DisplayValue = Dropdown.Value
                if IsDictionary and Dropdown.Value ~= nil then
                    DisplayValue = Dropdown.Values[Dropdown.Value]
                end

                ValueImage = GetValueImage(Dropdown.Value, DisplayValue)
                Str = DisplayValue and tostring(DisplayValue) or ""

                if Str ~= "" and Info.FormatDisplayValue then
                    Str = tostring(Info.FormatDisplayValue(Str))
                end
            end

            if #Str > 25 then
                Str = Str:sub(1, 22) .. "..."
            end

            DisplayButton.Text = (Str == "" and "---" or Str)

            if ValueImage then
                Library:ApplyLucideIcon(DisplayImage, ValueImage)
                DisplayImage.ImageTransparency = 0
            else
                DisplayImage.Image = ""
                DisplayImage.ImageTransparency = 1
            end

            DisplayButton.Size = ValueImage and UDim2.new(1, -8, 0, 21) or UDim2.new(1, 0, 0, 21)
            DisplayButton.Position = ValueImage and UDim2.fromOffset(14, 0) or UDim2.fromOffset(0, 0)
        end

        function Dropdown:OnChanged(Func)
            setthreadidentity(8)
            Dropdown.Changed = Func
        end

        function Dropdown:GetActiveValues(ReturnCount)
            setthreadidentity(8)
            local Table = {}

            if Info.Multi then
                if Dropdown.Prioritize then
                    for _, Value in Dropdown.Priority do
                        if Dropdown.Value[Value] then
                            table.insert(Table, Value)
                        end
                    end
                else
                    for Value in Dropdown.Value do
                        table.insert(Table, Value)
                    end
                end
            else
                if Dropdown.Value then
                    table.insert(Table, Dropdown.Value)
                end
            end

            return ReturnCount == true and GetTableSize(Table) or Table
        end

        local DragSelecting = false
        local DragStartIndex = nil
        local DragPrevMin = nil
        local DragPrevMax = nil
        local DragLastIndex = nil
        local DragInitialValues = {}
        local DragInputEndedConn = nil
        local DragInputChangedConn = nil

        local function SynchronizePriority()
            setthreadidentity(8)
            if not Dropdown.Prioritize then
                return
            end

            local existingValues = {}
            local isDictionary = not IsSequentialArray(Dropdown.Values)

            for key, rawValue in Dropdown.Values do
                existingValues[isDictionary and key or rawValue] = true
            end

            local priority = {}
            for _, value in Dropdown.Priority do
                if existingValues[value] then
                    priority[#priority + 1] = value
                    existingValues[value] = nil
                end
            end

            for key, rawValue in Dropdown.Values do
                local value = isDictionary and key or rawValue
                if existingValues[value] then
                    priority[#priority + 1] = value
                    existingValues[value] = nil
                end
            end

            Dropdown.Priority = priority
        end

        local function RecomputeFilteredEntries()
            setthreadidentity(8)
            local Values = Dropdown.Values
            local DisabledValues = Dropdown.DisabledValues
            local IsDictionary = not IsSequentialArray(Values)

            --// Fuzzy-match dropdown values the same way the sidebar search
            --// does, so e.g. "clr" can find "Clear Inventory" in a list \\--
            local SearchQuery = SearchBox and NormalizeSearch(SearchBox.Text:lower()) or ""
            local IsSearching = SearchQuery ~= ""

            local EnabledList, DisabledList = {}, {}
            local Pending = {}

            SynchronizePriority()

            for Key, RawValue in Values do
                local Value = IsDictionary and Key or RawValue

                local FormattedValue = tostring(Info.FormatListValue and Info.FormatListValue(RawValue) or RawValue)

                local MatchScore = 0
                if IsSearching then
                    local Matched, Score = FuzzyScore(FormattedValue:lower(), SearchQuery)
                    if not Matched then
                        continue
                    end
                    MatchScore = Score
                end

                local IsDisabled = table.find(DisabledValues, Value) ~= nil
                    or (RawValue ~= nil and RawValue ~= Value and table.find(DisabledValues, RawValue) ~= nil)

                local Entry = {
                    Value = Value,
                    RawValue = RawValue,
                    FormattedValue = FormattedValue,
                    IsDisabled = IsDisabled,
                    ValueImage = GetValueImage(Value, RawValue),
                    SortKey = Key,
                    MatchScore = MatchScore,
                    Order = #Pending + 1,
                }

                table.insert(Pending, Entry)
            end

            if IsSearching then
                --// Best matches first; ties fall back to original order \\--
                table.sort(Pending, function(A, B)
                    setthreadidentity(8)
                    if A.MatchScore ~= B.MatchScore then
                        return A.MatchScore > B.MatchScore
                    end
                    return A.Order < B.Order
                end)
            elseif not IsDictionary then
                table.sort(Pending, function(A, B)
                    setthreadidentity(8)
                    return A.SortKey < B.SortKey
                end)
            end

            if Dropdown.Prioritize then
                local priorityIndexes = {}
                for index, value in Dropdown.Priority do
                    priorityIndexes[value] = index
                end

                table.sort(Pending, function(first, second)
                    setthreadidentity(8)
                    return (priorityIndexes[first.Value] or math.huge) < (priorityIndexes[second.Value] or math.huge)
                end)
            end

            table.clear(FilteredEntries)
            if Dropdown.Prioritize then
                for _, Entry in Pending do
                    table.insert(FilteredEntries, Entry)
                end
            else
                for _, Entry in Pending do
                    if Entry.IsDisabled then
                        table.insert(DisabledList, Entry)
                    else
                        table.insert(EnabledList, Entry)
                    end
                end

                for _, Entry in EnabledList do
                    table.insert(FilteredEntries, Entry)
                end
                for _, Entry in DisabledList do
                    table.insert(FilteredEntries, Entry)
                end
            end
        end

        local function GetFirstVisibleIndex()
            setthreadidentity(8)
            local Total = #FilteredEntries
            if Total <= PoolSize then
                return 1
            end

            local MaxFirst = Total - PoolSize + 1
            local ScrollY = math.max(0, MenuTable.Menu.CanvasPosition.Y / Library.DPIScale - HeaderHeight)
            local Index = math.floor(ScrollY / ItemHeight) + 1
            return math.clamp(Index, 1, MaxFirst)
        end

        function Dropdown:RefreshPool()
            setthreadidentity(8)
            local Total = #FilteredEntries
            local First = GetFirstVisibleIndex()

            for SlotIndex, Row in Pool do
                local DataIndex = First + SlotIndex - 1
                local Entry = FilteredEntries[DataIndex]

                Row.Entry = Entry
                Row.Index = Entry and DataIndex or nil

                if not Entry then
                    Row.Container.Visible = false
                    Row.UpButton.Visible = false
                    Row.DownButton.Visible = false
                    continue
                end

                Row.Container.Visible = true
                local rowY = HeaderHeight + (DataIndex - 1) * ItemHeight
                Row.Container.Position = UDim2.fromOffset(0, rowY)

                local IsLast = DataIndex == Total
                Row.Corner.BottomRightRadius = IsLast and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)
                Row.Corner.BottomLeftRadius = IsLast and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)

                Row.Button.Text = Entry.FormattedValue

                local priorityEnabled = Info.Multi and Info.Prioritize == true
                local priorityWidth = priorityEnabled and 40 or 0
                local priorityOnLeft = priorityEnabled and Dropdown.PriorityButtonsPosition == "Left"

                if Entry.ValueImage then
                    Row.Image.Visible = true
                    Library:ApplyLucideIcon(Row.Image, Entry.ValueImage)
                    Row.Image.Position = UDim2.fromOffset(priorityOnLeft and 44 or 4, 3)
                    Row.Button.Size = UDim2.new(1, -18 - priorityWidth, 0, ItemHeight)
                    Row.Button.Position = UDim2.fromOffset(18 + (priorityOnLeft and 40 or 0), 0)
                else
                    Row.Image.Visible = false
                    Row.Button.Size = UDim2.new(1, -priorityWidth, 0, ItemHeight)
                    Row.Button.Position = UDim2.fromOffset(priorityOnLeft and 40 or 0, 0)
                end

                Row.UpButton.Visible = priorityEnabled
                Row.DownButton.Visible = priorityEnabled
                Row.UpButton.Position = priorityOnLeft and UDim2.fromOffset(4, rowY + 4) or UDim2.new(1, -36, 0, rowY + 4)
                Row.DownButton.Position = priorityOnLeft and UDim2.fromOffset(23, rowY + 4) or UDim2.new(1, -17, 0, rowY + 4)

                Row:UpdateButton()
            end
        end

        function Dropdown:RunChanged()
            setthreadidentity(8)
            if Dropdown.Disabled then
                return
            end

            Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
        end

        function Dropdown:MovePriority(Value, Direction)
            setthreadidentity(8)
            if not Dropdown.Prioritize or Direction == 0 then
                return false
            end

            SynchronizePriority()

            local currentIndex = table.find(Dropdown.Priority, Value)
            if not currentIndex then
                return false
            end

            local targetIndex = math.clamp(currentIndex + (Direction < 0 and -1 or 1), 1, #Dropdown.Priority)
            if currentIndex == targetIndex then
                return false
            end

            Dropdown.Priority[currentIndex], Dropdown.Priority[targetIndex] = Dropdown.Priority[targetIndex], Dropdown.Priority[currentIndex]
            Dropdown:BuildDropdownList()
            Dropdown:RunChanged()

            return true
        end

        function Dropdown:SelectAll()
            setthreadidentity(8)
            if not Info.Multi then
                return
            end

            local isDictionary = not IsSequentialArray(Dropdown.Values)
            for key, rawValue in Dropdown.Values do
                local value = isDictionary and key or rawValue
                local isDisabled = table.find(Dropdown.DisabledValues, value) ~= nil
                    or (rawValue ~= value and table.find(Dropdown.DisabledValues, rawValue) ~= nil)

                if not isDisabled then
                    Dropdown.Value[value] = true
                end
            end

            Dropdown:Display()
            Dropdown:RefreshPool()
            Library:UpdateDependencyBoxes()
            Dropdown:RunChanged()
        end

        function Dropdown:UnselectAll()
            setthreadidentity(8)
            if not Info.Multi then
                return
            end

            table.clear(Dropdown.Value)

            Dropdown:Display()
            Dropdown:RefreshPool()
            Library:UpdateDependencyBoxes()
            Dropdown:RunChanged()
        end

        local function StopDragSelect()
            setthreadidentity(8)
            DragSelecting = false
            DragStartIndex = nil
            DragPrevMin = nil
            DragPrevMax = nil
            DragLastIndex = nil
            table.clear(DragInitialValues)

            if DragInputEndedConn then
                DragInputEndedConn:Disconnect()
                DragInputEndedConn = nil
            end

            if DragInputChangedConn then
                DragInputChangedConn:Disconnect()
                DragInputChangedConn = nil
            end
        end

        local DragActiveCount = 0

        local function ApplyDragIndex(Index, InRange)
            setthreadidentity(8)
            local Entry = FilteredEntries[Index]
            if not Entry or Entry.IsDisabled then
                return
            end

            local Try = DragInitialValues[Entry.Value]
            if InRange then
                Try = not Try
            end

            local WantActive = Try and true or false
            local IsActive = Dropdown.Value[Entry.Value] and true or false
            if WantActive == IsActive then
                return
            end

            if not WantActive and DragActiveCount == 1 and not Info.AllowNull then
                return
            end

            Dropdown.Value[Entry.Value] = WantActive and true or nil
            DragActiveCount += WantActive and 1 or -1
        end

        local function ApplyDragRange(From, To, InRange)
            setthreadidentity(8)
            for Index = From, To do
                ApplyDragIndex(Index, InRange)
            end
        end

        local function UpdateDrag(CurrentIndex)
            setthreadidentity(8)
            if CurrentIndex == nil or CurrentIndex == DragLastIndex then
                return
            end

            DragLastIndex = CurrentIndex

            local Min = math.min(DragStartIndex, CurrentIndex)
            local Max = math.max(DragStartIndex, CurrentIndex)
            DragActiveCount = Dropdown:GetActiveValues(true)

            if DragPrevMin == nil then
                ApplyDragRange(Min, Max, true)
            else
                if DragPrevMin < Min then
                    ApplyDragRange(DragPrevMin, Min - 1, false)
                end
                if DragPrevMax > Max then
                    ApplyDragRange(Max + 1, DragPrevMax, false)
                end
                if Min < DragPrevMin then
                    ApplyDragRange(Min, DragPrevMin - 1, true)
                end
                if Max > DragPrevMax then
                    ApplyDragRange(DragPrevMax + 1, Max, true)
                end
            end

            DragPrevMin = Min
            DragPrevMax = Max

            for _, OtherRow in Pool do
                OtherRow:UpdateButton()
            end
        end

        local function CreatePoolRow()
            setthreadidentity(8)
            local Row = {
                Entry = nil,
                Index = nil
            }

            local Container = New("Frame", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Visible = false,
                Parent = MenuTable.Menu,
            })

            local Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Container,
            }); table.insert(Library.SpecificCorners, Corner)

            local Image = New("ImageLabel", {
                BackgroundTransparency = 1,
                Image = "",
                ImageTransparency = 0.5,
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.fromOffset(4, 3),
                Visible = false,
                Parent = Container,
            })

            local Button = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Text = "",
                TextSize = Dropdown.AutoSizeDropdown and 13 or 14,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                Parent = Button,
            })

            local UpIcon = Library:GetIcon("arrow-up") or PriorityUpIcon
            local DownIcon = Library:GetIcon("arrow-down") or PriorityDownIcon
            local PriorityButtonZIndex = MenuTable.Menu.ZIndex + 20

            local UpButton = New("ImageButton", {
                BackgroundTransparency = 1,
                Image = UpIcon and UpIcon.Url or "",
                ImageColor3 = "FontColor",
                ImageRectOffset = UpIcon and UpIcon.ImageRectOffset or Vector2.zero,
                ImageRectSize = UpIcon and UpIcon.ImageRectSize or Vector2.zero,
                Size = UDim2.fromOffset(13, 13),
                Visible = false,
                ZIndex = PriorityButtonZIndex,
                Parent = MenuTable.Menu,
            })

            local DownButton = New("ImageButton", {
                BackgroundTransparency = 1,
                Image = DownIcon and DownIcon.Url or "",
                ImageColor3 = "FontColor",
                ImageRectOffset = DownIcon and DownIcon.ImageRectOffset or Vector2.zero,
                ImageRectSize = DownIcon and DownIcon.ImageRectSize or Vector2.zero,
                Size = UDim2.fromOffset(13, 13),
                Visible = false,
                ZIndex = PriorityButtonZIndex,
                Parent = MenuTable.Menu,
            })

            Row.Container = Container
            Row.Corner = Corner
            Row.Image = Image
            Row.Button = Button
            Row.UpButton = UpButton
            Row.DownButton = DownButton

            function Row:UpdateButton()
                setthreadidentity(8)
                local Entry = Row.Entry
                if not Entry then
                    return
                end

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Entry.Value]
                else
                    Selected = Dropdown.Value == Entry.Value
                end

                Row.Selected = Selected and true or false

                Container.BackgroundTransparency = Selected and 0 or 1
                Button.TextTransparency = Entry.IsDisabled and 0.8 or Selected and 0 or 0.5

                if Entry.ValueImage then
                    Image.ImageTransparency = Entry.IsDisabled and 0.8 or Selected and 0 or 0.5
                end

                if Dropdown.Prioritize then
                    local priorityIndex = table.find(Dropdown.Priority, Entry.Value)
                    local upTransparency = priorityIndex == 1 and 0.8 or 0.2
                    local downTransparency = priorityIndex == #Dropdown.Priority and 0.8 or 0.2

                    UpButton.ImageTransparency = upTransparency
                    DownButton.ImageTransparency = downTransparency
                end
            end

            table.insert(Dropdown.Connections, UpButton.Activated:Connect(function()
                setthreadidentity(8)
                if Row.Entry then
                    Dropdown:MovePriority(Row.Entry.Value, -1)
                end
            end))

            table.insert(Dropdown.Connections, DownButton.Activated:Connect(function()
                setthreadidentity(8)
                if Row.Entry then
                    Dropdown:MovePriority(Row.Entry.Value, 1)
                end
            end))

            table.insert(Dropdown.Connections, Button.MouseButton1Click:Connect(function()
                setthreadidentity(8)
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled or DragSelecting then
                    return
                end

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Entry.Value]
                else
                    Selected = Dropdown.Value == Entry.Value
                end

                local Try = not Selected
                if not (Dropdown:GetActiveValues(true) == 1 and not Try and not Info.AllowNull) then
                    Selected = Try
                    if Info.Multi then
                        Dropdown.Value[Entry.Value] = Selected and true or nil
                    else
                        Dropdown.Value = Selected and Entry.Value or nil
                    end

                    for _, OtherRow in Pool do
                        OtherRow:UpdateButton()
                    end
                end

                Row:UpdateButton()
                Dropdown:Display()

                Library:UpdateDependencyBoxes()
                Dropdown:RunChanged()
            end))

            table.insert(Dropdown.Connections, Button.MouseEnter:Connect(function()
                setthreadidentity(8)
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if Row.Selected then
                    return
                end

                TweenService:Create(Container, Library.TweenInfo, {
                    BackgroundTransparency = 0.85,
                }):Play()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.25,
                }):Play()

                if Image then
                    TweenService:Create(Image, Library.TweenInfo, {
                        ImageTransparency = 0.25,
                    }):Play()
                end
            end))

            table.insert(Dropdown.Connections, Button.MouseLeave:Connect(function()
                setthreadidentity(8)
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if Row.Selected then
                    return
                end

                TweenService:Create(Container, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.5,
                }):Play()

                if Image then
                    TweenService:Create(Image, Library.TweenInfo, {
                        ImageTransparency = 0.5,
                    }):Play()
                end
            end))

            table.insert(Dropdown.Connections, Button.InputBegan:Connect(function(StartInput)
                setthreadidentity(8)
                if not (Info.Multi and Dropdown.DragSelect and not Library.IsMobile) then
                    return
                end

                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if not IsMouseInput(StartInput) then
                    return
                end

                DragSelecting = true
                DragStartIndex = Row.Index
                table.clear(DragInitialValues)

                for _, FilteredEntry in FilteredEntries do
                    DragInitialValues[FilteredEntry.Value] = Dropdown.Value[FilteredEntry.Value]
                end

                UpdateDrag(Row.Index)

                if DragInputEndedConn then DragInputEndedConn:Disconnect() end
                if DragInputChangedConn then DragInputChangedConn:Disconnect() end

                DragInputChangedConn = Library:GiveSignal(UserInputService.InputChanged:Connect(function(ChangeInput)
                    setthreadidentity(8)
                    if not IsMovementInput(ChangeInput) and ChangeInput ~= StartInput then
                        return
                    end

                    local Pos = ChangeInput.Position
                    for _, OtherRow in Pool do
                        if OtherRow.Entry and Library:MouseIsOverFrame(OtherRow.Button, Pos) then
                            UpdateDrag(OtherRow.Index)
                            break
                        end
                    end
                end))

                DragInputEndedConn = Library:GiveSignal(UserInputService.InputEnded:Connect(function(EndInput)
                    setthreadidentity(8)
                    if EndInput ~= StartInput and not (IsMouseInput(EndInput) and EndInput.UserInputType == StartInput.UserInputType) then
                        return
                    end

                    Dropdown:Display()
                    Library:UpdateDependencyBoxes()
                    Dropdown:RunChanged()

                    StopDragSelect()
                end))

                table.insert(Dropdown.Connections, DragInputEndedConn)
                table.insert(Dropdown.Connections, DragInputChangedConn)
            end))

            return Row
        end

        function Dropdown:BuildDropdownList()
            setthreadidentity(8)
            StopDragSelect()

            RecomputeFilteredEntries()

            MenuTable.Menu.CanvasPosition = Vector2.new(0, 0)

            Dropdown:RefreshPool()
            Dropdown:RecalculateListSize(#FilteredEntries)
        end

        for _ = 1, PoolSize do
            table.insert(Pool, CreatePoolRow())
        end

        table.insert(Dropdown.Connections, MenuTable.Menu:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            setthreadidentity(8)
            Dropdown:RefreshPool()
        end))

        local function ValueExists(Val)
            setthreadidentity(8)
            if IsSequentialArray(Dropdown.Values) then
                for _, Existing in Dropdown.Values do
                    if Existing == Val then
                        return true
                    end
                end

                return false
            end

            return Dropdown.Values[Val] ~= nil
        end

        function Dropdown:SetValue(Value)
            setthreadidentity(8)
            if Info.Multi then
                if typeof(Value) == "string" then
                    Value = if Value == "" then {} else { [Value] = true }
                end

                local Table = {}
                local SelectedOrder = {}

                for Val, Active in Value or {} do
                    if typeof(Active) ~= "boolean" then
                        if ValueExists(Active) then
                            Table[Active] = true
                            table.insert(SelectedOrder, Active)
                        end
                    elseif Active and ValueExists(Val) then
                        Table[Val] = true
                        table.insert(SelectedOrder, Val)
                    end
                end

                Dropdown.Value = Table

                if Dropdown.Prioritize and #SelectedOrder > 0 then
                    local selectedSet = {}
                    local Priority = {}

                    for _, Val in SelectedOrder do
                        if not selectedSet[Val] then
                            table.insert(Priority, Val)
                            selectedSet[Val] = true
                        end
                    end
                    for _, Val in Dropdown.Priority do
                        if not selectedSet[Val] then
                            table.insert(Priority, Val)
                            selectedSet[Val] = true
                        end
                    end

                    Dropdown.Priority = Priority
                    SynchronizePriority()
                end
            else
                if ValueExists(Value) then
                    Dropdown.Value = Value
                elseif not Value then
                    Dropdown.Value = nil
                end
            end

            Dropdown:Display()
            for _, Row in Pool do
                Row:UpdateButton()
            end

            if not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
            end

            Dropdown:RunChanged()
        end

        function Dropdown:SetValues(Values)
            setthreadidentity(8)
            Dropdown.Values = Values
            CachedContentWidth = nil

            local Changed = false
            if Info.Multi then
                for Val in Dropdown.Value do
                    if not ValueExists(Val) then
                        Dropdown.Value[Val] = nil
                        Changed = true
                    end
                end

            elseif Dropdown.Value ~= nil and not ValueExists(Dropdown.Value) then
                Dropdown.Value = nil
                Changed = true
            end

            Dropdown:BuildDropdownList()
            Dropdown:Display()

            if Changed and not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if Changed then
                Dropdown:RunChanged()
            end
        end

        function Dropdown:SetPriority(Values)
            setthreadidentity(8)
            if not Dropdown.Prioritize or typeof(Values) ~= "table" then
                return
            end

            local Priority = {}
            local Added = {}

            for _, Value in Values do
                if ValueExists(Value) and not Added[Value] then
                    table.insert(Priority, Value)
                    Added[Value] = true
                end
            end
            for _, Value in Dropdown.Priority do
                if ValueExists(Value) and not Added[Value] then
                    table.insert(Priority, Value)
                    Added[Value] = true
                end
            end

            Dropdown.Priority = Priority
            Dropdown:BuildDropdownList()
            Dropdown:RunChanged()
        end

        function Dropdown:UpdateKeys(Renames)
            setthreadidentity(8)
            if typeof(Renames) ~= "table" then
                return false
            end

            local Changed = false
            if IsSequentialArray(Dropdown.Values) then
                for Index, OldValue in Dropdown.Values do
                    local NewValue = Renames[OldValue]
                    if NewValue ~= nil and NewValue ~= OldValue then
                        Dropdown.Values[Index] = NewValue
                        Changed = true
                    end
                end
            else
                for OldValue, NewValue in Renames do
                    if NewValue ~= nil and NewValue ~= OldValue and Dropdown.Values[OldValue] ~= nil then
                        Dropdown.Values[NewValue] = Dropdown.Values[OldValue]
                        Dropdown.Values[OldValue] = nil
                        Changed = true
                    end
                end
            end

            if not Changed then
                return false
            end

            if Info.Multi then
                for OldValue, NewValue in Renames do
                    if Dropdown.Value[OldValue] then
                        Dropdown.Value[OldValue] = nil
                        Dropdown.Value[NewValue] = true
                    end
                end
            elseif Dropdown.Value ~= nil and Renames[Dropdown.Value] ~= nil then
                Dropdown.Value = Renames[Dropdown.Value]
            end

            for PriorityIndex, OldValue in Dropdown.Priority do
                local NewValue = Renames[OldValue]
                if NewValue ~= nil then
                    Dropdown.Priority[PriorityIndex] = NewValue
                end
            end

            CachedContentWidth = nil
            Dropdown:BuildDropdownList()
            Dropdown:Display()

            return true
        end

        function Dropdown:UpdateKey(OldValue, NewValue)
            setthreadidentity(8)
            if OldValue == nil or NewValue == nil then
                return false
            end

            return Dropdown:UpdateKeys({ [OldValue] = NewValue })
        end

        function Dropdown:AddValues(Values)
            setthreadidentity(8)
            if typeof(Values) ~= "table" and typeof(Values) ~= "string" then
                return
            end

            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            if IsDictionary then
                if typeof(Values) == "string" then
                    Dropdown.Values[Values] = Values

                elseif IsSequentialArray(Values) then
                    for _, Val in Values do
                        Dropdown.Values[Val] = Val
                    end

                else
                    for Key, Val in Values do
                        Dropdown.Values[Key] = Val
                    end
                end
            else
                if typeof(Values) == "table" then
                    for _, Val in Values do
                        table.insert(Dropdown.Values, Val)
                    end
                else
                    table.insert(Dropdown.Values, Values)
                end
            end

            CachedContentWidth = nil
            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabledValues(DisabledValues)
            setthreadidentity(8)
            Dropdown.DisabledValues = DisabledValues
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddDisabledValues(DisabledValues)
            setthreadidentity(8)
            if typeof(DisabledValues) == "table" then
                for _, val in DisabledValues do
                    table.insert(Dropdown.DisabledValues, val)
                end
            elseif typeof(DisabledValues) == "string" then
                table.insert(Dropdown.DisabledValues, DisabledValues)
            else
                return
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetValueImages(ValueImages)
            setthreadidentity(8)
            if typeof(ValueImages) ~= "table" then
                return
            end

            Dropdown.ValueImages = ValueImages
            CachedContentWidth = nil
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddValueImages(ValueImages)
            setthreadidentity(8)
            if typeof(ValueImages) ~= "table" then
                return
            end

            for key, val in ValueImages do
                Dropdown.ValueImages[key] = val
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabled(Disabled: boolean)
            setthreadidentity(8)
            Dropdown.Disabled = Disabled

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable.Disabled = Dropdown.Disabled
            end

            MenuTable:Close()
            DisplayButton.Active = not Dropdown.Disabled
            Dropdown:UpdateColors()

            Library:UpdateDependencyBoxes()
        end

        function Dropdown:SetVisible(Visible: boolean)
            setthreadidentity(8)
            Dropdown.Visible = Visible

            Holder.Visible = Dropdown.Visible
            Groupbox:Resize()
        end

        function Dropdown:SetText(Text: string)
            setthreadidentity(8)
            Dropdown.Text = Text
            Holder.Size = UDim2.new(1, 0, 0, Text and 39 or 21)

            Label.Text = Text and Text or ""
            Label.Visible = not not Text
        end

        function Dropdown:SetDragSelect(Value: boolean)
            setthreadidentity(8)
            if not Info.Multi or Library.IsMobile then
                Value = false
            end

            Dropdown.DragSelect = Value == true
            Dropdown:BuildDropdownList()
        end

        local ToggleDropdown = function()
            setthreadidentity(8)
            if Dropdown.Disabled then
                return
            end

            MenuTable:Toggle()
        end

        table.insert(Dropdown.Connections, DisplayContainer.MouseButton1Click:Connect(ToggleDropdown))
        table.insert(Dropdown.Connections, DisplayButton.MouseButton1Click:Connect(ToggleDropdown))

        if SearchBox then
            table.insert(Dropdown.Connections, SearchBox:GetPropertyChangedSignal("Text"):Connect(Dropdown.BuildDropdownList))
        end

        local Defaults = (function()
            setthreadidentity(8)
            local Resolved = {}
            local Default = Info.Default
            if Default == nil then
                return Resolved
            end

            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            local function ResolveOne(Candidate)
                setthreadidentity(8)
                if IsDictionary then
                    return Dropdown.Values[Candidate] ~= nil and Candidate or nil
                end

                for _, Existing in Dropdown.Values do
                    if Existing == Candidate then
                        return Existing
                    end
                end

                return nil
            end

            local DefaultType = typeof(Default)
            if DefaultType == "string" then
                local Value = ResolveOne(Default)
                if Value ~= nil then
                    table.insert(Resolved, Value)
                end

            elseif DefaultType == "table" then
                for _, Candidate in Default do
                    local Value = ResolveOne(Candidate)
                    if Value ~= nil then
                        table.insert(Resolved, Value)
                    end
                end

            elseif Dropdown.Values[Default] ~= nil then
                table.insert(Resolved, IsDictionary and Default or Dropdown.Values[Default])
            end

            return Resolved
        end)()

        for _, SelectValue in Defaults do
            if Info.Multi then
                Dropdown.Value[SelectValue] = true
            else
                Dropdown.Value = SelectValue
                break
            end
        end

        if typeof(Dropdown.Tooltip) == "string" or typeof(Dropdown.DisabledTooltip) == "string" then
            Dropdown.TooltipTable = Library:AddTooltip(Dropdown.Tooltip, Dropdown.DisabledTooltip, DisplayContainer)
            Dropdown.TooltipTable.Disabled = Dropdown.Disabled
        end

        Dropdown:UpdateColors()
        Dropdown:Display()
        Dropdown:BuildDropdownList()
        Groupbox:Resize()

        Dropdown.Holder = Holder
        table.insert(Groupbox.Elements, Dropdown)

        Dropdown.Default = Defaults
        Dropdown.DefaultValues = Dropdown.Values

        Options[Idx] = Dropdown

        function Dropdown:Destroy()
            setthreadidentity(8)
            Dropdown.Destroyed = true

            StopDragSelect()

            if Dropdown.Connections then
                for _, Connection in Dropdown.Connections do
                    Connection:Disconnect()
                end
            end

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable:Destroy()
            end

            if MenuTable then
                MenuTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Dropdown)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Dropdown
    end

    function Funcs:AddESPPreview(Idx: string, _Info: { [string]: any }?): any
        setthreadidentity(8)
        assert(type(Idx) == "string" and Options[Idx] == nil, "ESP preview requires a unique option index")
        if self.Destroyed then return nil end

        local Info = _Info or {}
        local Definitions = Info.Definitions or {}
        assert(type(Definitions) == "table", "ESP Definitions must be a table")
        local DrawingProvider = Info.Drawing or getgenv().Drawing
        assert(DrawingProvider and type(DrawingProvider.new) == "function", "Load Z-WareDrawing.lua before AddESPPreview")
        local Groupbox = self
        local Height = math.max(300, Info.Height or 500)
        local Sides = { "Left", "Top", "Right", "Bottom" }
        local Teams = { "Enemies", "Allies", "Local" }
        local BoxTypes = { "None", "2D Box", "3D Box", "Bounding Box" }
        local Profiles, ProfileControls = {}, {}
        local Defaults
        local Accent = Info.AccentColor or Library.Scheme.AccentColor
        local Preview = {
            Type = "ESPPreview", Destroyed = false, Visible = Info.Visible ~= false, Height = Height,
            Connections = {}, Items = {}, ItemOrder = {}, Value = {},
            Callback = Info.Callback, Changed = nil, Team = "Enemies", Revision = 0,
            Bindings = {}, Trackers = {}, DataProvider = nil,
            ProfileSettings = table.clone(Info.Settings or { Enabled = true }), ApplyingProfile = false,
            AnimationTime = 0,
            Data = { Name = "Z-Ware User", Health = 65, MaxHealth = 100, Distance = 25, Ammo = 18, MaxAmmo = 30, Weapon = "AK-47", HitChance = 78 },
            ModelColor = Info.ModelColor or Color3.fromRGB(190, 194, 201),
            ModelTransparency = 0, ModelStyle = "Solid", Rotation = 0, Zoom = 1,
        }
        local Holder = New("Frame", {
            Name = Idx, BackgroundColor3 = "BackgroundColor",
            Size = UDim2.new(1, 0, 0, Height), Visible = Preview.Visible, Parent = Groupbox.Container,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Holder })
        local Toolbar = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -16, 0, 30), Position = UDim2.fromOffset(8, 7), Parent = Holder })
        local Stage = New("Frame", {
            BackgroundTransparency = 1, ClipsDescendants = true,
            Position = UDim2.fromOffset(0, 42), Size = UDim2.new(1, 0, 1, -66), Parent = Holder,
        })
        local ViewportFrame = New("ViewportFrame", {
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
            Ambient = Color3.fromRGB(185, 185, 195), LightColor = Color3.new(1, 1, 1),
            LightDirection = Vector3.new(-1, -1, -1), ZIndex = 1, Parent = Stage,
        })
        local ChamsViewport = New("ViewportFrame", {
            Name = "ChamsFill", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false,
            Ambient = Color3.new(1, 1, 1), LightColor = Color3.new(), ZIndex = 2, Parent = Stage,
        })
        local HoverLayer = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = Stage })
        local DrawingClip = New("Frame", { BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = Stage })
        local Hint = New("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.new(0, 6, 1, -23), Size = UDim2.new(1, -12, 0, 18),
            Text = "Drag items · Right click to edit · Drag model to rotate", TextSize = 10,
            TextColor3 = Color3.fromRGB(113, 117, 130), TextTruncate = Enum.TextTruncate.AtEnd, Parent = Holder,
        })
        local World = Instance.new("WorldModel")
        World.Parent = ViewportFrame
        local Camera = Instance.new("Camera")
        Camera.FieldOfView = 35
        Camera.Parent = ViewportFrame
        ViewportFrame.CurrentCamera = Camera
        ChamsViewport.CurrentCamera = Camera
        local ChamsWorld = Instance.new("WorldModel")
        ChamsWorld.Parent = ChamsViewport

        local function Connect(signal: RBXScriptSignal, callback: (...any) -> ()): RBXScriptConnection
            local connection = signal:Connect(function(...: any)
                setthreadidentity(8)
                callback(...)
            end)
            table.insert(Preview.Connections, connection)
            return connection
        end

        local function Button(parent: Instance, text: string, position: UDim2, size: UDim2): TextButton
            local button = New("TextButton", {
                BackgroundColor3 = "MainColor", BackgroundTransparency = 0.25,
                Position = position, Size = size, Text = text, TextSize = 12, Parent = parent,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = button })
            return button
        end

        local TeamButtons = {}
        for index, team in Teams do
            local button = Button(Toolbar, team, UDim2.new((index - 1) * 0.25, 0, 0, 0), UDim2.new(0.25, -4, 1, 0))
            button.TextScaled = true
            New("UITextSizeConstraint", { MinTextSize = 8, MaxTextSize = 12, Parent = button })
            button.TextColor3 = if team == Preview.Team then Accent else Library.Scheme.FontColor
            TeamButtons[team] = button
        end
        local ItemsButton = Button(Toolbar, "Items", UDim2.new(0.75, 0, 0, 0), UDim2.new(0.18, -4, 1, 0))
        local ExpandButton = Button(Toolbar, "+", UDim2.new(0.93, 0, 0, 0), UDim2.new(0.07, 0, 1, 0))

        local function CreateBlankR6(): Model
            local model = Instance.new("Model")
            model.Name = "R6 Dummy blank"
            local definitions = {
                { "HumanoidRootPart", Vector3.new(2, 2, 1), Vector3.zero },
                { "Torso", Vector3.new(2, 2, 1), Vector3.zero },
                { "Head", Vector3.new(2, 1, 1), Vector3.new(0, 1.5, 0) },
                { "Left Arm", Vector3.new(1, 2, 1), Vector3.new(-1.5, 0, 0) },
                { "Right Arm", Vector3.new(1, 2, 1), Vector3.new(1.5, 0, 0) },
                { "Left Leg", Vector3.new(1, 2, 1), Vector3.new(-0.5, -2, 0) },
                { "Right Leg", Vector3.new(1, 2, 1), Vector3.new(0.5, -2, 0) },
            }
            for _, definition in definitions do
                local part = Instance.new("Part")
                part.Name, part.Size = definition[1], definition[2]
                part.CFrame = CFrame.new(definition[3])
                part.Anchored, part.CanCollide, part.CastShadow = true, false, false
                part.TopSurface, part.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
                part.Color = Preview.ModelColor
                part.Transparency = if part.Name == "HumanoidRootPart" then 1 else 0
                part.Parent = model
            end
            local head = model:FindFirstChild("Head")
            local mesh = Instance.new("SpecialMesh")
            mesh.MeshType, mesh.Scale, mesh.Parent = Enum.MeshType.Head, Vector3.new(1.25, 1.25, 1.25), head
            local humanoid = Instance.new("Humanoid")
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            humanoid.RequiresNeck = false
            humanoid.Parent = model
            model.PrimaryPart = model:FindFirstChild("HumanoidRootPart")
            for _, joint in {
                { "RootJoint", "HumanoidRootPart", "Torso", Vector3.zero, Vector3.zero },
                { "Neck", "Torso", "Head", Vector3.new(0, 1, 0), Vector3.new(0, -0.5, 0) },
                { "Left Shoulder", "Torso", "Left Arm", Vector3.new(-1, 0.5, 0), Vector3.new(0.5, 0.5, 0) },
                { "Right Shoulder", "Torso", "Right Arm", Vector3.new(1, 0.5, 0), Vector3.new(-0.5, 0.5, 0) },
                { "Left Hip", "Torso", "Left Leg", Vector3.new(-0.5, -1, 0), Vector3.new(0, 1, 0) },
                { "Right Hip", "Torso", "Right Leg", Vector3.new(0.5, -1, 0), Vector3.new(0, 1, 0) },
            } do
                local motor = Instance.new("Motor6D")
                motor.Name = joint[1]
                motor.Part0, motor.Part1 = model:FindFirstChild(joint[2]), model:FindFirstChild(joint[3])
                motor.C0, motor.C1, motor.Parent = CFrame.new(joint[4]), CFrame.new(joint[5]), motor.Part0
            end
            return model
        end

        local Model = CreateBlankR6()
        Model.Parent = World
        local ModelParts = {}
        local ChamsModel
        local BasePivot = CFrame.new()
        local ModelSize = Vector3.new(4, 5, 1)
        local ModelCenter = Vector3.new(0, -0.5, 0)
        local Drag = nil
        local Pointer = nil
        local Hovered = nil
        local Selected = nil
        local PopupPoint = Vector2.zero
        local Expanded = false
        local OriginalParent = Holder.Parent
        local Fullscreen = nil
        local SuppressCallback = false
        local RefreshSettings: () -> ()
        local RefreshChips: () -> ()
        local RebuildChips: (() -> ())?
        local SettingsMenu: any
        local ItemsMenu: any

        local function ReadModel(): ()
            if ChamsModel then ChamsModel:Destroy(); ChamsModel, Preview.ChamsObject = nil, nil end
            ChamsViewport.Visible = false
            table.clear(ModelParts)
            for _, descendant in Model:GetDescendants() do
                if descendant:IsA("Script") or descendant:IsA("LocalScript") then
                    descendant:Destroy()
                elseif descendant:IsA("BasePart") and descendant.Name == "HumanoidRootPart" then
                    descendant.Anchored, descendant.CanCollide, descendant.Transparency = true, false, 1
                elseif descendant:IsA("BasePart") then
                    descendant.Anchored, descendant.CanCollide = true, false
                    table.insert(ModelParts, descendant)
                end
            end
            local bounds, size = Model:GetBoundingBox()
            ModelSize, ModelCenter, BasePivot = size, bounds.Position, Model:GetPivot()
        end

        function Preview:ResolveChamsAppearance(): any
            local settings = self.ProfileSettings
            local material = if self.ModelStyle == "Neon" then Enum.Material.Neon else Enum.Material.SmoothPlastic
            local appearance = { Enabled = settings.Chams == true, Material = material, Color = self.ModelColor, Transparency = self.ModelTransparency }
            if not appearance.Enabled then return appearance end
            local fill = (if settings.VisibleColor then Color3.fromHex(settings.VisibleColor) else self.ModelColor):Lerp(Color3.new(1, 1, 1), 0.15)
            local phase = 0.5 + 0.5 * math.sin(self.AnimationTime * (settings.EffectSpeed or 4))
            local opacity = math.clamp((settings.VisibleOpacity or 25) / 100, 0, 1)
            if settings.Effect == "Pulse" then
                fill = fill:Lerp(Color3.new(1, 1, 1), phase * 0.45)
            elseif settings.Effect == "Breathe" then
                fill = fill:Lerp(Color3.new(), (1 - phase) * 0.3)
                opacity = math.max(0, opacity - (1 - phase) * 0.25)
            elseif settings.Effect == "Rainbow" then
                fill = Color3.fromHSV(self.AnimationTime * (settings.EffectSpeed or 4) * 0.08 % 1, 0.75, 1):Lerp(Color3.new(1, 1, 1), 0.15)
            end
            local selected = ({ ForceField = Enum.Material.ForceField, Plastic = Enum.Material.Plastic, Glass = Enum.Material.Glass, Neon = Enum.Material.Neon })[settings.Material]
            if selected then appearance.Material, appearance.Color = selected, fill end
            appearance.FillColor, appearance.FillTransparency = fill, 1 - opacity * (1 - self.ModelTransparency)
            return appearance
        end

        function Preview:UpdateModelAppearance(): ()
            local appearance = self:ResolveChamsAppearance()
            for _, part in ModelParts do
                if part.Color ~= appearance.Color then part.Color = appearance.Color end
                if part.Material ~= appearance.Material then part.Material = appearance.Material end
                if part.Transparency ~= appearance.Transparency then part.Transparency = appearance.Transparency end
            end
            ChamsViewport.Visible = appearance.Enabled and appearance.FillTransparency < 1
            if not ChamsViewport.Visible then return end
            if not ChamsModel then
                ChamsModel = Model:Clone()
                ChamsModel.Name = "PreviewChamsFill"
                for _, descendant in ChamsModel:GetDescendants() do
                    if descendant:IsA("BasePart") then
                        descendant.Anchored, descendant.CanCollide, descendant.CastShadow = true, false, false
                        descendant.Color, descendant.Material, descendant.Reflectance = Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, 0
                        descendant.Transparency = if descendant.Name == "HumanoidRootPart" then 1 else 0
                        descendant.LocalTransparencyModifier = 0
                        if descendant:IsA("MeshPart") then descendant.TextureID = "" end
                    elseif descendant:IsA("SpecialMesh") then
                        descendant.TextureId, descendant.VertexColor = "", Vector3.new(1, 1, 1)
                    elseif descendant:IsA("Decal") or descendant:IsA("Texture") or descendant:IsA("SurfaceAppearance")
                        or descendant:IsA("BodyColors") or descendant:IsA("Clothing") or descendant:IsA("ShirtGraphic") then
                        descendant:Destroy()
                    end
                end
                ChamsModel.Parent = ChamsWorld
                self.ChamsObject = ChamsModel
            end
            ChamsViewport.ImageColor3, ChamsViewport.ImageTransparency = appearance.FillColor, appearance.FillTransparency
            ChamsModel:PivotTo(Model:GetPivot())
        end

        local function ApplyModel(): ()
            Preview:UpdateModelAppearance()
        end

        local function Scale(_context: any?): number
            if _context then return _context.Scale end
            local scale = 1
            local ancestor: Instance? = Stage
            while ancestor do
                local component = ancestor:FindFirstChildOfClass("UIScale")
                if component then scale *= component.Scale end
                ancestor = ancestor.Parent
            end
            return math.max(0.01, scale)
        end

        local function MousePoint(): Vector2
            return Vector2.new(Mouse.X, Mouse.Y)
        end

        local function Contains(rect: any, point: Vector2): boolean
            return rect ~= nil and point.X >= rect.X and point.X <= rect.X + rect.Width
                and point.Y >= rect.Y and point.Y <= rect.Y + rect.Height
        end

        local function IsShown(): boolean
            if Preview.Destroyed or Library.Unloaded or not Preview.Visible or Library.Toggled == false then return false end
            local ancestor: Instance? = Holder
            while ancestor do
                if ancestor:IsA("GuiObject") and not ancestor.Visible then return false end
                if ancestor:IsA("ScreenGui") and not ancestor.Enabled then return false end
                ancestor = ancestor.Parent
            end
            return Holder:IsDescendantOf(ScreenGui) and Stage.AbsoluteSize.X > 5 and Stage.AbsoluteSize.Y > 5
        end

        local function Notify(itemId: string?): ()
            Preview.Revision += 1
            Preview.Value = Preview:GetValue()
            if SuppressCallback then return end
            local config = Preview:GetConfig()
            Library:SafeCallback(Preview.Callback, config, itemId, Preview)
            Library:SafeCallback(Preview.Changed, config, itemId, Preview)
        end

        local function CreateDrawing(item: any, key: string, className: string, _context: any?): any
            if item.Drawings[key] then return item.Drawings[key] end
            local object = DrawingProvider.new(className)
            object.Visible = false
            local frame = if type(object) == "table" then rawget(object, "_frame") else nil
            if typeof(frame) == "Instance" and frame:IsA("GuiObject") then
                frame.Parent = if _context then _context.Layer else DrawingClip
                item.UsesGui = true
            end
            item.Drawings[key] = object
            return object
        end

        local function Draw(item: any, key: string, className: string, properties: { [string]: any }, _context: any?): any
            local object = CreateDrawing(item, key, className, _context)
            -- Z-WareDrawing insets filled squares by their outline thickness too.
            if className == "Square" and properties.Filled == true and item.UsesGui then properties.Thickness = 0 end
            local scale = if item.UsesGui and not _context then Scale() else 1
            local origin = if _context then Vector2.zero elseif item.UsesGui then Stage.AbsolutePosition else -select(1, GuiService:GetGuiInset())
            for property, value in properties do
                if property == "Position" or property == "From" or property == "To" then
                    object[property] = (value - origin) / scale
                elseif property == "Size" and typeof(value) == "Vector2" then
                    object.Size = value / scale
                elseif property == "Size" or property == "Thickness" then
                    object[property] = value / scale
                else
                    object[property] = value
                end
            end
            object.Transparency = 1 - (item.ResolvedTransparency or item.Transparency)
            object.Visible = true
            return object
        end

        local function SetHover(item: any): ()
            if Hovered == item then return end
            if Hovered then
                if Hovered.Tween then Hovered.Tween:Cancel(); Hovered.Tween:Destroy() end
                Hovered.Tween = TweenService:Create(Hovered.Hover, TweenInfo.new(0.16), { BackgroundTransparency = 1 })
                Hovered.Tween:Play()
            end
            Hovered = item
            if item then
                if item.Tween then item.Tween:Cancel(); item.Tween:Destroy() end
                item.Tween = TweenService:Create(item.Hover, TweenInfo.new(0.16), { BackgroundTransparency = 0.83 })
                item.Tween:Play()
            end
        end

        function Preview:AddItem(itemId: string, definition: { [string]: any }): any
            assert(type(itemId) == "string" and self.Items[itemId] == nil, "Duplicate ESP item")
            assert(definition.Callback == nil or type(definition.Callback) == "function", "ESP Callback must be a function")
            local item = {
                Id = itemId, Label = definition.Label or itemId, Group = definition.Group or "Flags", DataKey = definition.DataKey,
                Kind = definition.Kind or "Text", Text = definition.Text or definition.Label or itemId,
                TemplateText = definition.Text or definition.Label or itemId,
                Enabled = definition.Enabled == true, Side = definition.Side or "Right",
                Order = definition.Order or (#self.ItemOrder + 1), Color = definition.Color or Color3.fromRGB(224, 226, 232),
                Transparency = definition.Transparency or 0, Size = definition.Size or 12,
                Outline = definition.Outline ~= false, Background = definition.Background == true,
                BackgroundColor = definition.BackgroundColor or Color3.fromRGB(20, 22, 29),
                Thickness = definition.Thickness or 2, Format = "Absolute", BoxType = definition.BoxType or "Bounding Box", Drawings = {},
                Hover = New("Frame", { BackgroundColor3 = Accent, BackgroundTransparency = 1, Visible = false, ZIndex = 2, Parent = HoverLayer }),
            }
            assert(table.find(Sides, item.Side), "Invalid ESP item side")
            assert(table.find(BoxTypes, item.BoxType), "Invalid ESP box type")
            New("UICorner", { CornerRadius = UDim.new(0, 3), Parent = item.Hover })
            self.Items[itemId] = item
            if definition.Callback then self.Bindings[itemId] = definition.Callback end
            table.insert(self.ItemOrder, itemId)
            if RebuildChips then RebuildChips() end
            if RefreshChips then RefreshChips() end
            if Defaults then Defaults.Items[itemId] = self:CloneConfig(self:GetConfig().Items[itemId]) end
            if self.GetConfig then Notify(itemId) end
            return item
        end

        for index, definition in Definitions do
            assert(type(definition) == "table", "Each ESP definition must be a table")
            local settings = table.clone(definition)
            local itemId = settings.Id or definition[1]
            settings.Label = settings.Label or definition[2]
            settings.Group = settings.Group or definition[3]
            settings.Kind = settings.Kind or definition[4]
            settings.Side = settings.Side or definition[5]
            settings.Text = settings.Text or definition[6]
            if settings.Enabled == nil then settings.Enabled = definition[7] == true end
            settings.Callback = settings.Callback or definition[8]
            settings.Order = settings.Order or index
            settings.DataKey = settings.DataKey or ({ Name = "Name", Distance = "Distance", WeaponText = "Weapon", HitChance = "HitChance" })[itemId]
            Preview:AddItem(itemId, settings)
        end

        function Preview:CloneConfig(value: any): any
            if typeof(value) == "Color3" then return value:ToHex() end
            if type(value) ~= "table" then return value end
            local result = {}
            for key, child in value do result[key] = self:CloneConfig(child) end
            return result
        end

        function Preview:GetConfig(): { [string]: any }
            local config = { Version = 2, Items = {}, Settings = self:CloneConfig(self.ProfileSettings), ModelColor = self.ModelColor:ToHex(), ModelTransparency = self.ModelTransparency, ModelStyle = self.ModelStyle }
            for _, itemId in self.ItemOrder do
                local item = self.Items[itemId]
                config.Items[itemId] = {
                    Enabled = item.Enabled, Side = item.Side, Order = item.Order, Color = item.Color:ToHex(),
                    Transparency = item.Transparency, Size = item.Size, Outline = item.Outline,
                    Background = item.Background, BackgroundColor = item.BackgroundColor:ToHex(),
                    Thickness = item.Thickness, Format = item.Format, BoxType = item.BoxType, Text = item.Text,
                }
            end
            return config
        end

        function Preview:NormalizeProfile(config: { [string]: any }, team: string): { [string]: any }
            local result = self:CloneConfig(Defaults)
            if team ~= "Enemies" then result.Settings.Enabled = false end
            for key, value in config do
                if key == "Settings" then
                    for setting, selection in value do result.Settings[setting] = self:CloneConfig(selection) end
                elseif key == "Items" then
                    for itemId, properties in value do
                        if not self.Items[itemId] then continue end
                        local item = result.Items[itemId] or self:GetConfig().Items[itemId]
                        for property, selection in properties do item[property] = self:CloneConfig(selection) end
                        result.Items[itemId] = item
                    end
                elseif key ~= "Profiles" and key ~= "Team" then result[key] = self:CloneConfig(value) end
            end
            return result
        end

        function Preview:GetProfile(team: string): { [string]: any }
            assert(table.find(Teams, team), "Expected Enemies, Allies or Local")
            if team == self.Team then return self:GetConfig() end
            return self:NormalizeProfile(Profiles[team] or {}, team)
        end

        function Preview:GetValue(): { [string]: any }
            local profiles = {}
            for _, team in Teams do profiles[team] = self:GetProfile(team) end
            return { Version = 2, Team = self.Team, Profiles = profiles }
        end

        function Preview:SetSettings(settings: { [string]: any }): ()
            for key, value in settings do self.ProfileSettings[key] = self:CloneConfig(value) end
            self:ApplyProfileControls()
            Notify(nil)
        end

        function Preview:ApplyProfileControls(): ()
            if self.ApplyingProfile then return end
            self.ApplyingProfile = true
            local success, message = pcall(function(): ()
                for key, binding in ProfileControls do
                    local control, value = binding.Control, self.ProfileSettings[key]
                    if control.Type == "ColorPicker" then
                        if control.Value:ToHex() ~= value then control:SetValueRGB(Color3.fromHex(value)) end
                    elseif control.Value ~= value then control:SetValue(self:CloneConfig(value)) end
                end
            end)
            self.ApplyingProfile = false
            assert(success, message)
        end

        function Preview:BindProfileControls(controls: { [string]: any }): ()
            for key, control in controls do
                assert(not ProfileControls[key], `Profile control already bound: {key}`)
                local default = self:CloneConfig(control.Value)
                if Defaults.Settings[key] == nil then Defaults.Settings[key] = default end
                if self.ProfileSettings[key] == nil then self.ProfileSettings[key] = self:CloneConfig(default) end
                local binding = { Control = control, Previous = control.Changed }
                binding.Handler = function(value: any): ()
                    if self.ApplyingProfile or self.Destroyed then return end
                    self.ProfileSettings[key] = self:CloneConfig(value)
                    Notify(nil)
                    Library:SafeCallback(binding.Previous, value)
                end
                ProfileControls[key] = binding
                control:OnChanged(binding.Handler)
            end
            self:ApplyProfileControls()
            Notify(nil)
        end

        function Preview:SetItem(itemId: string, properties: { [string]: any }): ()
            local item = assert(self.Items[itemId], `Unknown ESP item: {itemId}`)
            for property, value in properties do
                if property == "Side" then
                    assert(table.find(Sides, value), "Side must be Left, Top, Right or Bottom")
                    item.Side = value
                elseif property == "Color" or property == "BackgroundColor" then
                    assert(typeof(value) == "Color3", "ESP colors must be Color3 values")
                    item[property] = value
                elseif property == "Transparency" then item.Transparency = math.clamp(value, 0, 1)
                elseif property == "Size" then item.Size = math.clamp(value, 8, 24)
                elseif property == "Thickness" then item.Thickness = math.clamp(value, 1, 8)
                elseif property == "Order" then item.Order = math.max(1, value)
                elseif property == "Enabled" or property == "Outline" or property == "Background" then
                    assert(type(value) == "boolean", "ESP switches must be booleans")
                    item[property] = value
                elseif property == "Text" then item.Text = tostring(value)
                elseif property == "Format" then
                    assert(value == "Absolute" or value == "Percent", "Invalid value format")
                    item.Format = value
                elseif property == "BoxType" then
                    assert(table.find(BoxTypes, value), "Invalid ESP box type")
                    item.BoxType = value
                end
            end
            if RefreshChips then RefreshChips() end
            if Selected == item and SettingsMenu and SettingsMenu.Active then RefreshSettings() end
            Notify(itemId)
        end

        function Preview:SetValue(config: { [string]: any }): ()
            assert(type(config) == "table", "Expected an ESP configuration")
            if type(config.Profiles) == "table" then
                for _, team in Teams do Profiles[team] = self:NormalizeProfile(config.Profiles[team] or {}, team) end
                self.Team = if table.find(Teams, config.Team) then config.Team else "Enemies"
                self:SetValue(Profiles[self.Team])
                return
            end
            SuppressCallback = true
            local success, message = pcall(function()
                if config.Settings then self.ProfileSettings = self:NormalizeProfile({ Settings = config.Settings }, self.Team).Settings end
                if config.ModelColor then self.ModelColor = Color3.fromHex(config.ModelColor) end
                if config.ModelTransparency then self.ModelTransparency = math.clamp(config.ModelTransparency, 0, 1) end
                if config.ModelStyle == "Solid" or config.ModelStyle == "Neon" then self.ModelStyle = config.ModelStyle end
                for itemId, properties in config.Items or {} do
                    if not self.Items[itemId] then continue end
                    local values = table.clone(properties)
                    if self.Items[itemId].Kind == "Box" and values.BoxType == nil then values.BoxType = "Bounding Box" end
                    if type(values.Color) == "string" then values.Color = Color3.fromHex(values.Color) end
                    if type(values.BackgroundColor) == "string" then values.BackgroundColor = Color3.fromHex(values.BackgroundColor) end
                    self:SetItem(itemId, values)
                end
                ApplyModel()
                self:ApplyProfileControls()
            end)
            for team, button in TeamButtons do button.TextColor3 = if team == self.Team then Accent else Library.Scheme.FontColor end
            SuppressCallback = false
            assert(success, message)
            Notify(nil)
        end

        function Preview:OnChanged(callback: (...any) -> ()): ()
            self.Changed = callback
        end

        function Preview:SetData(data: { [string]: any }): ()
            for key, value in data do
                if self.Data[key] == nil then continue end
                if type(self.Data[key]) == "number" then
                    assert(type(value) == "number" and value == value and math.abs(value) < math.huge, "Expected a finite preview value")
                else
                    assert(type(value) == "string", "Expected preview text")
                end
                self.Data[key] = value
            end
        end

        function Preview:SetModelColor(color: Color3, _transparency: number?): ()
            assert(typeof(color) == "Color3", "Expected a model Color3")
            self.ModelColor = color
            if _transparency then self.ModelTransparency = math.clamp(_transparency, 0, 1) end
            ApplyModel()
            Notify(nil)
        end

        function Preview:SetModelStyle(style: string): ()
            assert(style == "Solid" or style == "Neon", "Model style must be Solid or Neon")
            self.ModelStyle = style
            ApplyModel()
            Notify(nil)
        end

        function Preview:SetObject(object: Model): ()
            assert(typeof(object) == "Instance" and object:IsA("Model"), "Expected an R6 model")
            assert(object:FindFirstChild("Torso") and object:FindFirstChild("Head"), "Expected R6 Torso and Head")
            assert(object.Archivable, "Preview model must be Archivable")
            local replacement = object:Clone()
            Model:Destroy()
            Model = replacement
            Model.Parent = World
            ReadModel()
            ApplyModel()
            self.Object = Model
        end

        function Preview:MoveItem(itemId: string, side: string, _index: number?): ()
            local item = assert(self.Items[itemId], "Unknown ESP item")
            assert(table.find(Sides, side), "Invalid ESP item side")
            local ordered = {}
            for _, otherId in self.ItemOrder do
                local other = self.Items[otherId]
                if other ~= item and other.Enabled and other.Side == side
                    and (other.Kind == "Bar") == (item.Kind == "Bar")
                    and other.Kind ~= "Box" and other.Kind ~= "Skeleton" and other.Kind ~= "Hitboxes"
                then table.insert(ordered, other) end
            end
            table.sort(ordered, function(first: any, second: any): boolean
                if first.Order == second.Order then return first.Id < second.Id end
                return first.Order < second.Order
            end)
            table.insert(ordered, math.clamp(_index or (#ordered + 1), 1, #ordered + 1), item)
            item.Side = side
            for index, other in ordered do other.Order = index end
            Notify(itemId)
        end

        Defaults = Preview:GetConfig()
        function Preview:Reset(): ()
            self:SetValue(self:NormalizeProfile({}, self.Team))
            self.Rotation, self.Zoom = 0, 1
        end

        local function MenuOffset(): { number }
            local scale = Library.DPIScale
            local size = ScreenGui.AbsoluteSize
            return {
                math.clamp(PopupPoint.X, 8, math.max(8, size.X - 344 * scale)) - Holder.AbsolutePosition.X,
                math.clamp(PopupPoint.Y, 8, math.max(8, size.Y - 548 * scale)) - Holder.AbsolutePosition.Y,
            }
        end
        local function MenuSize(): UDim2
            return UDim2.fromOffset(336, math.min(540, math.max(120, ScreenGui.AbsoluteSize.Y / Library.DPIScale - 24)))
        end
        SettingsMenu = Library:AddContextMenu(Holder, MenuSize, MenuOffset, nil, nil, false, nil, "Dropdown")
        ItemsMenu = Library:AddContextMenu(Holder, MenuSize, MenuOffset, nil, nil, false, nil, "Dropdown")
        local Settings = New("ScrollingFrame", {
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.fromOffset(0, 540),
            ScrollBarThickness = 3, ScrollBarImageColor3 = Accent, Parent = SettingsMenu.Menu,
        })
        local ItemList = New("ScrollingFrame", {
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.fromOffset(0, 550),
            ScrollBarThickness = 3, ScrollBarImageColor3 = Accent, Parent = ItemsMenu.Menu,
        })
        local SettingsTitle = New("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 8), Size = UDim2.fromOffset(278, 22),
            Text = "Element", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = Settings,
        })
        local CloseSettings = Button(Settings, "×", UDim2.fromOffset(302, 8), UDim2.fromOffset(22, 22))
        Connect(CloseSettings.Activated, function(): () SettingsMenu:Close() end)
        local Saturation = Button(Settings, "", UDim2.fromOffset(12, 40), UDim2.fromOffset(312, 174))
        Saturation.BackgroundTransparency = 0
        local White = New("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), Parent = Saturation })
        New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = White })
        New("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = White })
        local Black = New("Frame", { BackgroundColor3 = Color3.new(), Size = UDim2.fromScale(1, 1), Parent = White })
        New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = Black })
        New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = Black })
        local ColorCursor = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Size = UDim2.fromOffset(10, 10), ZIndex = 5, Parent = Saturation })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ColorCursor })
        New("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, Parent = ColorCursor })
        local Hue = Button(Settings, "", UDim2.fromOffset(12, 226), UDim2.fromOffset(312, 9))
        Hue.BackgroundColor3, Hue.BackgroundTransparency = Color3.new(1, 1, 1), 0
        local hueKeys = {}
        for index = 0, 6 do table.insert(hueKeys, ColorSequenceKeypoint.new(index / 6, Color3.fromHSV(index / 6, 1, 1))) end
        New("UIGradient", { Color = ColorSequence.new(hueKeys), Parent = Hue })
        local HueCursor = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(5, 15), BackgroundColor3 = Color3.new(1, 1, 1), Parent = Hue })
        New("UICorner", { CornerRadius = UDim.new(0, 2), Parent = HueCursor })
        local Alpha = Button(Settings, "", UDim2.fromOffset(12, 249), UDim2.fromOffset(312, 9))
        Alpha.BackgroundTransparency = 0
        local AlphaGradient = New("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(55, 55, 64), Accent), Parent = Alpha })
        local AlphaCursor = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(5, 15), BackgroundColor3 = Color3.new(1, 1, 1), Parent = Alpha })
        New("UICorner", { CornerRadius = UDim.new(0, 2), Parent = AlphaCursor })
        local Hex = New("TextBox", { BackgroundColor3 = Color3.fromRGB(31, 32, 41), Position = UDim2.fromOffset(12, 272), Size = UDim2.fromOffset(212, 25), TextSize = 12, ClearTextOnFocus = false, Parent = Settings })
        New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Hex })
        local Opacity = New("TextBox", { BackgroundColor3 = Color3.fromRGB(31, 32, 41), Position = UDim2.fromOffset(232, 272), Size = UDim2.fromOffset(92, 25), TextSize = 12, ClearTextOnFocus = false, Parent = Settings })
        New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Opacity })
        local BackgroundButton = Button(Settings, "", UDim2.fromOffset(12, 309), UDim2.fromOffset(312, 26))
        local OutlineButton = Button(Settings, "", UDim2.fromOffset(12, 341), UDim2.fromOffset(312, 26))
        local SideButton = Button(Settings, "", UDim2.fromOffset(12, 373), UDim2.fromOffset(312, 26))
        local FormatButton = Button(Settings, "", UDim2.fromOffset(12, 405), UDim2.fromOffset(312, 26))
        local Smaller = Button(Settings, "−", UDim2.fromOffset(12, 437), UDim2.fromOffset(34, 26))
        local SizeLabel = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(48, 437), Size = UDim2.fromOffset(128, 26), TextSize = 12, Parent = Settings })
        local Larger = Button(Settings, "+", UDim2.fromOffset(178, 437), UDim2.fromOffset(34, 26))
        local EnabledButton = Button(Settings, "", UDim2.fromOffset(220, 437), UDim2.fromOffset(104, 26))
        local SampleText = New("TextBox", { BackgroundColor3 = Color3.fromRGB(31, 32, 41), Position = UDim2.fromOffset(12, 475), Size = UDim2.fromOffset(312, 26), PlaceholderText = "Preview text", TextSize = 12, ClearTextOnFocus = false, Parent = Settings })
        New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = SampleText })
        local ResetItem = Button(Settings, "Reset element", UDim2.fromOffset(12, 509), UDim2.fromOffset(312, 24))
        local BoxTypeButtons = {}
        for index, boxType in BoxTypes do
            local button = Button(Settings, boxType, UDim2.fromOffset(12 + (index - 1) % 2 * 162, 475 + (index - 1) // 2 * 32), UDim2.fromOffset(150, 26))
            button.Visible = false
            BoxTypeButtons[boxType] = button
            Connect(button.Activated, function(): ()
                if Selected and Selected.Kind == "Box" then Preview:SetItem(Selected.Id, { BoxType = boxType }) end
            end)
        end
        local EditHue, EditSaturation, EditValue = 0, 1, 1

        RefreshSettings = function(): ()
            if not Selected then return end
            EditHue, EditSaturation, EditValue = Selected.Color:ToHSV()
            SettingsTitle.Text = Selected.Label
            Saturation.BackgroundColor3 = Color3.fromHSV(EditHue, 1, 1)
            ColorCursor.Position = UDim2.fromScale(EditSaturation, 1 - EditValue)
            HueCursor.Position = UDim2.fromScale(EditHue, 0.5)
            AlphaCursor.Position = UDim2.fromScale(1 - Selected.Transparency, 0.5)
            AlphaGradient.Color = ColorSequence.new(Color3.fromRGB(55, 55, 64), Selected.Color)
            if not Hex:IsFocused() then Hex.Text = `#{Selected.Color:ToHex()}` end
            if not Opacity:IsFocused() then Opacity.Text = `{math.floor((1 - Selected.Transparency) * 100 + 0.5)}%` end
            BackgroundButton.Text = `Background                         {if Selected.Background then "ON" else "OFF"}`
            OutlineButton.Text = `Shadow / outline                   {if Selected.Outline then "ON" else "OFF"}`
            SideButton.Text = `Position                                  {Selected.Side} ›`
            FormatButton.Text = if Selected.Kind == "Box" then `Box Type                              {Selected.BoxType} ›`
                else `Format                                   {Selected.Format} ›`
            local box = Selected.Kind == "Box"
            SampleText.Visible = not box
            ResetItem.Position = UDim2.fromOffset(12, if box then 543 else 509)
            Settings.CanvasSize = UDim2.fromOffset(0, if box then 576 else 540)
            for boxType, button in BoxTypeButtons do
                button.Visible = box
                button.TextColor3 = if Selected.BoxType == boxType then Accent else Library.Scheme.FontColor
            end
            SizeLabel.Text = if Selected.Kind == "Bar" or Selected.Kind == "Box" then `Thickness: {Selected.Thickness}` else `Size: {Selected.Size}`
            EnabledButton.Text = if Selected.Enabled then "Enabled" else "Disabled"
            EnabledButton.TextColor3 = if Selected.Enabled then Accent else Color3.fromRGB(140, 143, 153)
            if not SampleText:IsFocused() then SampleText.Text = Selected.Text end
        end

        local function UpdatePicker(point: Vector2): ()
            if not Selected or not Pointer then return end
            local control = if Pointer == "Hue" then Hue elseif Pointer == "Alpha" then Alpha else Saturation
            local relative = point - control.AbsolutePosition
            local horizontal = math.clamp(relative.X / math.max(1, control.AbsoluteSize.X), 0, 1)
            if Pointer == "Alpha" then Selected.Transparency = 1 - horizontal
            elseif Pointer == "Hue" then EditHue = horizontal
            else
                EditSaturation = horizontal
                EditValue = 1 - math.clamp(relative.Y / math.max(1, control.AbsoluteSize.Y), 0, 1)
            end
            if Pointer ~= "Alpha" then Selected.Color = Color3.fromHSV(EditHue, EditSaturation, EditValue) end
            local preservedHue, preservedSaturation, preservedValue = EditHue, EditSaturation, EditValue
            RefreshSettings()
            EditHue, EditSaturation, EditValue = preservedHue, preservedSaturation, preservedValue
            Saturation.BackgroundColor3 = Color3.fromHSV(EditHue, 1, 1)
            ColorCursor.Position = UDim2.fromScale(EditSaturation, 1 - EditValue)
            HueCursor.Position = UDim2.fromScale(EditHue, 0.5)
            Notify(Selected.Id)
        end
        for name, control in { Saturation = Saturation, Hue = Hue, Alpha = Alpha } do
            Connect(control.InputBegan, function(input: InputObject): ()
                if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
                Pointer = name
                UpdatePicker(if input.UserInputType == Enum.UserInputType.Touch then Vector2.new(input.Position.X, input.Position.Y) else MousePoint())
            end)
        end
        Connect(Hex.FocusLost, function(): ()
            if not Selected then return end
            local value = string.gsub(Hex.Text, "#", "")
            if string.match(value, "^%x%x%x%x%x%x$") then Preview:SetItem(Selected.Id, { Color = Color3.fromHex(value) }) end
            RefreshSettings()
        end)
        Connect(Opacity.FocusLost, function(): ()
            if not Selected then return end
            local value = tonumber(string.gsub(Opacity.Text, "%%", ""))
            if value then Preview:SetItem(Selected.Id, { Transparency = 1 - math.clamp(value, 0, 100) / 100 }) end
            RefreshSettings()
        end)
        Connect(BackgroundButton.Activated, function(): () if Selected then Preview:SetItem(Selected.Id, { Background = not Selected.Background }) end end)
        Connect(OutlineButton.Activated, function(): () if Selected then Preview:SetItem(Selected.Id, { Outline = not Selected.Outline }) end end)
        Connect(SideButton.Activated, function(): ()
            if Selected then Preview:SetItem(Selected.Id, { Side = Sides[(table.find(Sides, Selected.Side) or 1) % #Sides + 1] }) end
        end)
        Connect(FormatButton.Activated, function(): ()
            if not Selected then return end
            if Selected.Kind == "Box" then
                Preview:SetItem(Selected.Id, { BoxType = BoxTypes[(table.find(BoxTypes, Selected.BoxType) or #BoxTypes) % #BoxTypes + 1] })
            else
                Preview:SetItem(Selected.Id, { Format = if Selected.Format == "Absolute" then "Percent" else "Absolute" })
            end
        end)
        local function ChangeSize(amount: number): ()
            if not Selected then return end
            local field = if Selected.Kind == "Bar" or Selected.Kind == "Box" then "Thickness" else "Size"
            Preview:SetItem(Selected.Id, { [field] = Selected[field] + amount })
        end
        Connect(Smaller.Activated, function(): () ChangeSize(-1) end)
        Connect(Larger.Activated, function(): () ChangeSize(1) end)
        Connect(EnabledButton.Activated, function(): () if Selected then Preview:SetItem(Selected.Id, { Enabled = not Selected.Enabled }) end end)
        Connect(SampleText.FocusLost, function(): () if Selected then Preview:SetItem(Selected.Id, { Text = SampleText.Text }) end end)
        Connect(ResetItem.Activated, function(): ()
            if not Selected then return end
            local values = table.clone(Defaults.Items[Selected.Id] or {})
            if values.Color then values.Color = Color3.fromHex(values.Color) end
            if values.BackgroundColor then values.BackgroundColor = Color3.fromHex(values.BackgroundColor) end
            Preview:SetItem(Selected.Id, values)
        end)

        local Chips = {}
        local ChipGroups = {}
        local ChipConnections = {}
        New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 9), Size = UDim2.fromOffset(275, 22), Text = "ESP Items", TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Parent = ItemList })
        local CloseItems = Button(ItemList, "×", UDim2.fromOffset(302, 9), UDim2.fromOffset(22, 22))
        Connect(CloseItems.Activated, function(): () ItemsMenu:Close() end)
        local function BuildChips(): ()
            for _, connection in ChipConnections do
                connection:Disconnect()
                local index = table.find(Preview.Connections, connection)
                if index then table.remove(Preview.Connections, index) end
            end
            for _, group in ChipGroups do group:Destroy() end
            table.clear(ChipConnections)
            table.clear(ChipGroups)
            table.clear(Chips)
            local vertical = 43
            local groups = {}
            for _, itemId in Preview.ItemOrder do
                local groupName = Preview.Items[itemId].Group
                if not table.find(groups, groupName) then table.insert(groups, groupName) end
            end
            for _, groupName in groups do
                local group = New("Frame", { BackgroundColor3 = Color3.fromRGB(20, 21, 28), Position = UDim2.fromOffset(10, vertical), Size = UDim2.fromOffset(316, 100), Parent = ItemList })
                table.insert(ChipGroups, group)
                New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = group })
                New("UIStroke", { Color = Color3.fromRGB(36, 37, 46), Parent = group })
                New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 6), Size = UDim2.fromOffset(290, 20), Text = groupName, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = group })
                local horizontal, row = 12, 32
                for _, itemId in Preview.ItemOrder do
                    local item = Preview.Items[itemId]
                    if item.Group ~= groupName then continue end
                    local width = math.clamp(#item.Label * 6.4 + 20, 44, 150)
                    if horizontal + width > 304 then horizontal, row = 12, row + 30 end
                    local chip = Button(group, item.Label, UDim2.fromOffset(horizontal, row), UDim2.fromOffset(width, 24))
                    local stroke = New("UIStroke", { Color = Accent, Transparency = 0.5, Parent = chip })
                    Chips[itemId] = { Button = chip, Stroke = stroke }
                    table.insert(ChipConnections, Connect(chip.Activated, function(): () Preview:SetItem(itemId, { Enabled = not item.Enabled }) end))
                    table.insert(ChipConnections, Connect(chip.MouseButton2Click, function(): ()
                        Selected, PopupPoint = item, MousePoint()
                        RefreshSettings()
                        SettingsMenu:Open()
                    end))
                    horizontal += width + 7
                end
                group.Size = UDim2.fromOffset(316, row + 34)
                vertical += row + 44
            end
            ItemList.CanvasSize = UDim2.fromOffset(0, vertical + 6)
        end
        RebuildChips = BuildChips
        RefreshChips = function(): ()
            for itemId, chip in Chips do
                local item = Preview.Items[itemId]
                chip.Stroke.Transparency = if item.Enabled then 0.3 else 0.85
                chip.Stroke.Color = if item.Enabled then Accent else Color3.fromRGB(57, 59, 71)
                chip.Button.TextTransparency = if item.Enabled then 0 else 0.5
            end
        end
        BuildChips()
        RefreshChips()
        Connect(ItemsButton.Activated, function(): ()
            PopupPoint = ItemsButton.AbsolutePosition + Vector2.new(0, ItemsButton.AbsoluteSize.Y + 5)
            ItemsMenu:Toggle()
        end)
        function Preview:SetTeam(team: string): ()
            assert(table.find(Teams, team), "Expected Enemies, Allies or Local")
            if team == self.Team then return end
            Profiles[self.Team] = self:GetConfig()
            local config = self:GetProfile(team)
            self.Team = team
            SettingsMenu:Close()
            ItemsMenu:Close()
            self:SetValue(config)
        end
        for team, button in TeamButtons do Connect(button.Activated, function(): () Preview:SetTeam(team) end) end

        function Preview:SetHeight(height: number): ()
            assert(type(height) == "number" and height == height and math.abs(height) < math.huge, "Expected a finite preview height")
            Height = math.max(180, math.floor(height))
            self.Height = Height
            if Expanded then
                Holder.Size = UDim2.fromOffset(620, Height)
                local scale = Holder:FindFirstChildOfClass("UIScale")
                if scale then scale.Scale = math.min(1.5, (ScreenGui.AbsoluteSize.Y - 32) / Height, (ScreenGui.AbsoluteSize.X - 32) / 620) end
            else
                Holder.Size = UDim2.new(1, 0, 0, Height)
            end
            Groupbox:Resize()
        end

        function Preview:SetExpanded(enabled: boolean): ()
            if Expanded == enabled then return end
            Expanded = enabled
            SettingsMenu:Close()
            ItemsMenu:Close()
            if enabled then
                Fullscreen = New("Frame", { BackgroundColor3 = Color3.fromRGB(11, 12, 17), BackgroundTransparency = 0.08, Size = UDim2.fromScale(1, 1), ZIndex = 19, Parent = ScreenGui })
                Holder.Parent = Fullscreen
                Holder.AnchorPoint = Vector2.new(0.5, 0.5)
                Holder.Position = UDim2.fromScale(0.5, 0.5)
                Holder.Size = UDim2.fromOffset(620, Height)
                New("UIScale", { Scale = math.min(1.5, (ScreenGui.AbsoluteSize.Y - 32) / Height, (ScreenGui.AbsoluteSize.X - 32) / 620), Parent = Holder })
            else
                local scale = Holder:FindFirstChildOfClass("UIScale")
                if scale then scale:Destroy() end
                Holder.Parent, Holder.AnchorPoint, Holder.Position = OriginalParent, Vector2.zero, UDim2.fromOffset(0, 0)
                Holder.Size = UDim2.new(1, 0, 0, Height)
                if Fullscreen then Fullscreen:Destroy(); Fullscreen = nil end
            end
            ExpandButton.Text = if enabled then "−" else "+"
            Groupbox:Resize()
        end
        Connect(ExpandButton.Activated, function(): () Preview:SetExpanded(not Expanded) end)

        local function Project(position: Vector3, _context: any?): Vector2
            if _context then
                local projected = _context.Camera:WorldToViewportPoint(position)
                return Vector2.new(projected.X, projected.Y)
            end
            local relative = Camera.CFrame:PointToObjectSpace(position)
            local focal = Stage.AbsoluteSize.Y / (2 * math.tan(math.rad(Camera.FieldOfView / 2)))
            local depth = math.max(0.01, -relative.Z)
            return Stage.AbsolutePosition + Stage.AbsoluteSize / 2 + Vector2.new(relative.X, -relative.Y) * (focal / depth)
        end

        local function ModelRect(): any
            local minimum, maximum = Vector2.new(math.huge, math.huge), Vector2.new(-math.huge, -math.huge)
            for _, part in ModelParts do
                for horizontal = -1, 1, 2 do
                    for vertical = -1, 1, 2 do
                        for depth = -1, 1, 2 do
                            local point = Project(part.CFrame:PointToWorldSpace(part.Size * Vector3.new(horizontal, vertical, depth) / 2))
                            minimum = Vector2.new(math.min(minimum.X, point.X), math.min(minimum.Y, point.Y))
                            maximum = Vector2.new(math.max(maximum.X, point.X), math.max(maximum.Y, point.Y))
                        end
                    end
                end
            end
            return { X = minimum.X, Y = minimum.Y, Width = maximum.X - minimum.X, Height = maximum.Y - minimum.Y }
        end

        local function TextFor(item: any, _context: any?): string
            if _context then return item.ResolvedText or item.Text end
            local data = Preview.Data
            if item.DataKey and item.Text == item.TemplateText then
                local value = data[item.DataKey]
                if item.DataKey == "Distance" then return `{math.floor(value)} m` end
                if item.DataKey == "HitChance" then return `{math.floor(value)}%` end
                return tostring(value)
            end
            return item.Text
        end

        local function Measure(item: any, _context: any?): (number, number)
            local scale = Scale(_context)
            if item.Kind == "Icon" then return item.Size * 4 * scale, (item.Size + 4) * scale end
            local object = CreateDrawing(item, "Text", "Text", _context)
            object.Text = TextFor(item, _context)
            object.Font = 2
            object.Size = item.Size * (if item.UsesGui and not _context then 1 else scale)
            local bounds = object.TextBounds
            return math.max(12, bounds.X * (if item.UsesGui and not _context then scale else 1)) + 8 * scale, (item.Size + 5) * scale
        end

        local function Layout(rect: any, _context: any?): ()
            local scale = Scale(_context)
            local items = if _context then _context.Items else Preview.Items
            for _, side in Sides do
                local bars, labels = {}, {}
                for _, itemId in Preview.ItemOrder do
                    local item = items[itemId]
                    if item.Hover then item.Hover.Visible = false end
                    if not item.Enabled or item.Side ~= side then continue end
                    if item.Kind == "Box" or item.Kind == "Skeleton" or item.Kind == "Hitboxes" then
                        item.Rect = table.clone(rect)
                        if item.Kind == "Box" and item.BoxType == "2D Box" then
                            item.Rect.Width = rect.Height * 0.55
                            item.Rect.X = rect.X + (rect.Width - item.Rect.Width) / 2
                        end
                    elseif item.Kind == "Bar" then table.insert(bars, item)
                    else table.insert(labels, item) end
                end
                local function Sort(first: any, second: any): boolean
                    if first.Id == "Health" then return second.Id ~= "Health" end
                    if second.Id == "Health" then return false end
                    if first.Order == second.Order then return first.Id < second.Id end
                    return first.Order < second.Order
                end
                table.sort(bars, Sort)
                table.sort(labels, Sort)
                local offset = 5 * scale
                for _, item in bars do
                    local thickness = (item.Thickness + 2) * scale
                    local vertical = side == "Left" or side == "Right"
                    item.Rect = {
                        X = if side == "Left" then rect.X - offset - thickness elseif side == "Right" then rect.X + rect.Width + offset else rect.X,
                        Y = if side == "Top" then rect.Y - offset - thickness elseif side == "Bottom" then rect.Y + rect.Height + offset else rect.Y,
                        Width = if vertical then thickness else rect.Width, Height = if vertical then rect.Height else thickness,
                    }
                    offset += thickness + 4 * scale
                    if item.Id == "Health" and not vertical then offset += (item.Size + 4) * scale end
                end
                local cursor = 0
                local columnWidth, rowHeight = 0, 0
                for _, item in labels do
                    local width, height = Measure(item, _context)
                    width = math.min(width, (if _context then _context.ViewportSize.X else Stage.AbsoluteSize.X) * 0.7)
                    item.MeasuredWidth, item.MeasuredHeight = width, height
                    columnWidth, rowHeight = math.max(columnWidth, width), math.max(rowHeight, height)
                end
                for _, item in labels do
                    local vertical = side == "Left" or side == "Right"
                    local width = item.MeasuredWidth
                    local height = if vertical and item.Kind == "Text" then rowHeight else item.MeasuredHeight
                    item.Rect = {
                        X = if side == "Left" then rect.X - offset - columnWidth elseif side == "Right" then rect.X + rect.Width + offset else rect.X + (rect.Width - width) / 2,
                        Y = if side == "Top" then rect.Y - offset - cursor - height elseif side == "Bottom" then rect.Y + rect.Height + offset + cursor else rect.Y + cursor,
                        Width = width, Height = height,
                    }
                    cursor += if vertical then rowHeight else height
                end
            end
        end

        local function Square(item: any, key: string, rect: any, color: Color3, filled: boolean, _thickness: number?, _context: any?): ()
            Draw(item, key, "Square", { Position = Vector2.new(rect.X, rect.Y), Size = Vector2.new(rect.Width, rect.Height), Color = color, Filled = filled, Thickness = _thickness or Scale(_context), ZIndex = 2 }, _context)
        end

        local function Line(item: any, key: string, first: Vector2, second: Vector2, color: Color3, _context: any?, _thickness: number?): ()
            if item.Kind == "Skeleton" or item.Kind == "Box" then
                item.HitLines = item.HitLines or {}
                item.HitLines[key] = { first, second }
            end
            Draw(item, key, "Line", { From = first, To = second, Color = color, Thickness = (_thickness or item.Thickness) * Scale(_context), ZIndex = 3 }, _context)
        end

        function Preview:GetBoxCorners(_context: any?): { Vector2 }?
            local parts = if _context then _context.Parts else ModelParts
            local frame = if _context then _context.RootPart.CFrame else Model:GetPivot()
            local minimum, maximum = Vector3.new(math.huge, math.huge, math.huge), Vector3.new(-math.huge, -math.huge, -math.huge)
            for _, part in parts do
                for horizontal = -1, 1, 2 do
                    for vertical = -1, 1, 2 do
                        for depth = -1, 1, 2 do
                            local point = frame:PointToObjectSpace(part.CFrame:PointToWorldSpace(part.Size * Vector3.new(horizontal, vertical, depth) / 2))
                            minimum, maximum = minimum:Min(point), maximum:Max(point)
                        end
                    end
                end
            end
            if minimum.X == math.huge then return nil end
            local camera = if _context then _context.Camera else Camera
            local corners = {}
            for _, offset in {
                Vector3.new(0, 0, 0), Vector3.new(1, 0, 0), Vector3.new(1, 1, 0), Vector3.new(0, 1, 0),
                Vector3.new(0, 0, 1), Vector3.new(1, 0, 1), Vector3.new(1, 1, 1), Vector3.new(0, 1, 1),
            } do
                local point = frame:PointToWorldSpace(minimum + (maximum - minimum) * offset)
                if camera.CFrame:PointToObjectSpace(point).Z >= -0.05 then return nil end
                table.insert(corners, Project(point, _context))
            end
            return corners
        end

        function Preview:RenderBox(item: any, _context: any?): ()
            local boxType, rect = item.BoxType or "Bounding Box", item.Rect
            item.HitLines, item.BoxRect = nil, nil
            if boxType == "None" then return end
            local color, scale = item.ResolvedColor or item.Color, Scale(_context)
            if boxType == "3D Box" then
                local corners = self:GetBoxCorners(_context)
                if not corners then return end
                for index, edge in {
                    { 1, 2 }, { 2, 3 }, { 3, 4 }, { 4, 1 }, { 5, 6 }, { 6, 7 }, { 7, 8 }, { 8, 5 },
                    { 1, 5 }, { 2, 6 }, { 3, 7 }, { 4, 8 },
                } do
                    if item.Outline then Line(item, `BoxOutline{index}`, corners[edge[1]], corners[edge[2]], Color3.new(), _context, item.Thickness + 2) end
                    Line(item, `BoxEdge{index}`, corners[edge[1]], corners[edge[2]], color, _context)
                end
                return
            end
            if boxType == "2D Box" then
                local width = rect.Height * 0.55
                rect = { X = rect.X + (rect.Width - width) / 2, Y = rect.Y, Width = width, Height = rect.Height }
            end
            item.BoxRect = rect
            if item.Outline then Square(item, "Outline", rect, Color3.new(), false, (item.Thickness + 2) * scale, _context) end
            Square(item, "Box", rect, color, false, item.Thickness * scale, _context)
        end

        local function RenderItem(item: any, _context: any?): ()
            local rect, scale = item.Rect, Scale(_context)
            local color = item.ResolvedColor or item.Color
            local model = if _context then _context.Character else Model
            local parts = if _context then _context.Parts else ModelParts
            if not rect then return end
            if item.Kind == "Box" and item.BoxType == "None" then item.HitLines, item.BoxRect = nil, nil; return end
            local position = Vector2.new(rect.X, rect.Y)
            if item.Background then Square(item, "Background", rect, item.BackgroundColor, true, nil, _context) end
            if item.Kind == "Text" then
                local lateral = item.Side == "Left" or item.Side == "Right"
                local textPosition = position + Vector2.new(if lateral then 4 * scale else rect.Width / 2, (rect.Height - item.Size * scale) / 2)
                textPosition = Vector2.new(math.floor(textPosition.X + 0.5), math.floor(textPosition.Y + 0.5))
                Draw(item, "Text", "Text", { Text = TextFor(item, _context), Position = textPosition, Center = not lateral, Color = color, Size = item.Size * scale, Font = 2, Outline = item.Outline, ZIndex = 4 }, _context)
            elseif item.Kind == "Bar" then
                local health = item.Id == "Health"
                local data = Preview.Data
                local value = item.ResolvedValue or (if health then data.Health elseif item.Id == "Ammo" then data.Ammo else 80)
                local maximum = item.ResolvedMaximum or (if health then math.max(1, data.MaxHealth) elseif item.Id == "Ammo" then math.max(1, data.MaxAmmo) else 100)
                local ratio = math.clamp(value / maximum, 0, 1)
                local vertical = item.Side == "Left" or item.Side == "Right"
                local track = { X = math.floor(rect.X + 0.5), Y = math.floor(rect.Y + 0.5) }
                track.Width = math.max(1, math.floor(rect.X + rect.Width + 0.5) - track.X)
                track.Height = math.max(1, math.floor(rect.Y + rect.Height + 0.5) - track.Y)
                local inset = math.min(math.max(1, math.floor(scale + 0.5)), (track.Width - 1) // 2, (track.Height - 1) // 2)
                local length = (if vertical then track.Height else track.Width) - inset * 2
                Square(item, "Track", track, Color3.fromRGB(36, 38, 47), true, nil, _context)
                local segments = math.min(if health then 24 else 1, length)
                for index = 1, segments do
                    local lower = math.floor(((index - 1) / segments) * length + 0.5)
                    local upper = math.floor(math.min(ratio, index / segments) * length + 0.5)
                    if upper <= lower then continue end
                    local fill = {
                        X = track.X + inset, Y = track.Y + inset,
                        Width = track.Width - inset * 2, Height = track.Height - inset * 2,
                    }
                    if vertical then
                        fill.Y += length - upper
                        fill.Height = upper - lower
                    else
                        fill.X += lower
                        fill.Width = upper - lower
                    end
                    Square(item, `Fill{index}`, fill, if health then Color3.fromRGB(255, 74, 86):Lerp(color, upper / length) else color, true, nil, _context)
                end
                if health then
                    Draw(item, "Value", "Text", {
                        Text = if item.Format == "Percent" then `{math.floor(ratio * 100)}%` else tostring(math.floor(value)),
                        Position = position + Vector2.new(rect.Width / 2, if item.Side == "Bottom" then rect.Height + 2 * scale else -(item.Size + 3) * scale), Center = true,
                        Color = Color3.new(1, 1, 1), Size = item.Size * scale, Font = 2, Outline = item.Outline, ZIndex = 4,
                    }, _context)
                end
            elseif item.Kind == "Box" then
                Preview:RenderBox(item, _context)
            elseif item.Kind == "Icon" then
                local points = item.ResolvedSegments or (if item.Id == "WeaponIcon" then {
                    { 0.05, 0.4, 0.18, 0.4 }, { 0.18, 0.4, 0.24, 0.25 }, { 0.24, 0.25, 0.66, 0.25 },
                    { 0.4, 0.25, 0.43, 0.05 }, { 0.66, 0.25, 0.7, 0.4 }, { 0.7, 0.4, 0.96, 0.4 },
                    { 0.46, 0.4, 0.4, 0.75 }, { 0.55, 0.4, 0.65, 0.72 }, { 0.18, 0.4, 0.08, 0.7 },
                } elseif item.Id == "WeaponBomb" then {
                    { 0.35, 0.2, 0.65, 0.2 }, { 0.35, 0.2, 0.35, 0.85 }, { 0.65, 0.2, 0.65, 0.85 },
                    { 0.35, 0.85, 0.65, 0.85 }, { 0.43, 0.2, 0.43, 0.05 }, { 0.43, 0.05, 0.6, 0.05 },
                } elseif item.Id == "WeaponDefuser" then {
                    { 0.25, 0.08, 0.75, 0.85 }, { 0.75, 0.08, 0.25, 0.85 },
                    { 0.18, 0.25, 0.35, 0.4 }, { 0.82, 0.25, 0.65, 0.4 },
                    { 0.25, 0.08, 0.4, 0.05 }, { 0.75, 0.08, 0.6, 0.05 },
                } else {
                    { 0.2, 0.2, 0.8, 0.2 }, { 0.8, 0.2, 0.8, 0.4 }, { 0.8, 0.4, 0.45, 0.4 },
                    { 0.45, 0.4, 0.4, 0.8 }, { 0.4, 0.8, 0.25, 0.8 }, { 0.25, 0.8, 0.3, 0.4 },
                })
                for index, coordinates in points do
                    Line(item, `Icon{index}`, position + Vector2.new(coordinates[1] * rect.Width, coordinates[2] * rect.Height), position + Vector2.new(coordinates[3] * rect.Width, coordinates[4] * rect.Height), color, _context)
                end
            elseif item.Kind == "Skeleton" then
                local torso, head = model:FindFirstChild("Torso"), model:FindFirstChild("Head")
                if torso and torso:IsA("BasePart") and head and head:IsA("BasePart") then
                    Line(item, "Spine", Project(head.Position, _context), Project(torso.Position - torso.CFrame.UpVector * 0.8, _context), color, _context)
                    for _, name in { "Left Arm", "Right Arm", "Left Leg", "Right Leg" } do
                        local part = model:FindFirstChild(name)
                        if not part or not part:IsA("BasePart") then continue end
                        local upper = part.Position + part.CFrame.UpVector * part.Size.Y * 0.4
                        Line(item, name .. "Joint", Project(torso.Position, _context), Project(upper, _context), color, _context)
                        Line(item, name .. "Bone", Project(upper, _context), Project(part.Position - part.CFrame.UpVector * part.Size.Y * 0.4, _context), color, _context)
                    end
                else
                    for index, names in {
                        { "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
                        { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
                        { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
                        { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
                        { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
                    } do
                        local first, second = model:FindFirstChild(names[1]), model:FindFirstChild(names[2])
                        if first and first:IsA("BasePart") and second and second:IsA("BasePart") then
                            Line(item, `Joint{index}`, Project(first.Position, _context), Project(second.Position, _context), color, _context)
                        end
                    end
                end
            elseif item.Kind == "Hitboxes" then
                for index, part in parts do
                    local point = Project(part.Position, _context)
                    Square(item, `Hitbox{index}`, { X = point.X - 5 * scale, Y = point.Y - 5 * scale, Width = 10 * scale, Height = 10 * scale }, color, false, nil, _context)
                end
            end
        end

        function Preview:BindItem(itemId: string, provider: (ESPContext) -> ESPItemResult?): () -> ()
            assert(self.Items[itemId], `Unknown ESP item: {itemId}`)
            assert(type(provider) == "function", "Expected an ESP item provider")
            self.Bindings[itemId] = provider
            return function(): ()
                if self.Bindings[itemId] == provider then self.Bindings[itemId] = nil end
            end
        end

        function Preview:SetDataProvider(provider: ((ESPContext) -> { [string]: any })?): ()
            assert(provider == nil or type(provider) == "function", "Expected an ESP data provider")
            self.DataProvider = provider
        end

        function Preview:TrackPlayers(_options: { [string]: any }?): any
            assert(not self.Destroyed, "Cannot attach players to a destroyed preview")
            local options = _options or {}
            local tracker = {
                Enabled = options.Enabled ~= false, Destroyed = false, Updating = false,
                IncludeLocalPlayer = options.IncludeLocalPlayer == true, TeamCheck = options.TeamCheck == true,
                MaxDistance = options.MaxDistance or math.huge, TextScale = math.clamp(options.TextScale or 1, 0.5, 2),
                Chams = options.Chams == true, Filter = options.Filter,
                Targets = {}, Connections = {}, Errors = {},
            }
            local layer = New("ScreenGui", {
                Name = Idx .. "Players", DisplayOrder = ScreenGui.DisplayOrder - 1,
                ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            })
            ParentUI(layer)
            tracker.Layer = layer

            local function HideTarget(target: any): ()
                target.Visible = false
                for _, item in target.Items do
                    for _, object in item.Drawings do object.Visible = false end
                end
                if target.Highlight then target.Highlight.Enabled = false end
            end

            local function DisconnectAll(connections: { RBXScriptConnection }): ()
                for _, connection in connections do connection:Disconnect() end
                table.clear(connections)
            end

            local function AttachCharacter(target: any, character: Model?): ()
                DisconnectAll(target.CharacterConnections)
                HideTarget(target)
                target.Character, target.Parts, target.RemovingCharacter = character, nil, nil
                if not character then return end
                for _, signal in { character.ChildAdded, character.ChildRemoved } do
                    table.insert(target.CharacterConnections, signal:Connect(function(): () target.Parts = nil end))
                end
            end

            local function RemovePlayer(player: Player): ()
                local target = tracker.Targets[player]
                if not target then return end
                target.Removed = true
                HideTarget(target)
                DisconnectAll(target.Connections)
                DisconnectAll(target.CharacterConnections)
                for _, item in target.Items do
                    for _, object in item.Drawings do object:Remove() end
                end
                if target.Highlight then target.Highlight:Destroy() end
                tracker.Targets[player] = nil
            end

            local function AddPlayer(player: Player): ()
                if tracker.Destroyed or tracker.Targets[player] or (player == LocalPlayer and not tracker.IncludeLocalPlayer) then return end
                local target = { Player = player, Items = {}, Connections = {}, CharacterConnections = {}, Revision = -1, Visible = false }
                tracker.Targets[player] = target
                table.insert(target.Connections, player.CharacterAdded:Connect(function(character: Model): ()
                    setthreadidentity(8)
                    AttachCharacter(target, character)
                end))
                table.insert(target.Connections, player.CharacterRemoving:Connect(function(character: Model): ()
                    setthreadidentity(8)
                    if target.Character == character then
                        AttachCharacter(target, nil)
                        target.RemovingCharacter = character
                    end
                end))
                AttachCharacter(target, player.Character)
            end

            local function ProviderError(key: string, message: any): ()
                local previous = tracker.Errors[key]
                if previous and os.clock() - previous < 5 then return end
                tracker.Errors[key] = os.clock()
                warn(`[Z-Ware ESP / {key}] {tostring(message)}`)
            end

            local function CallProvider(provider: (...any) -> ...any, context: any, key: string): (boolean, any)
                local success, value = pcall(provider, context)
                if not success then ProviderError(key, value) end
                return success, value
            end

            local function IsFinite(value: any): boolean
                return type(value) == "number" and value == value and math.abs(value) < math.huge
            end

            local function DefaultValue(item: any, context: any): any
                local supplied = context.Data[item.Id]
                if supplied ~= nil then return supplied end
                if item.Id == "Name" then return context.Player.DisplayName or context.Player.Name end
                if item.Id == "Distance" then return `{math.floor(context.Distance)} m` end
                if item.Id == "Health" then return { Value = context.Humanoid.Health, Max = context.Humanoid.MaxHealth } end
                if item.Kind == "Box" or item.Kind == "Skeleton" or item.Kind == "Hitboxes" then return true end
                if item.Id == "WeaponText" or item.Id == "WeaponIcon" then
                    local tool = context.Character:FindFirstChildOfClass("Tool")
                    return if tool then tool.Name else nil
                end
                return nil
            end

            local function ResolveItem(item: any, context: any): ()
                if not item.ConfigEnabled then item.Enabled = false; return end
                local provider = Preview.Bindings[item.Id]
                local success, value = true, nil
                if provider then success, value = CallProvider(provider, context, item.Id)
                else value = DefaultValue(item, context) end
                item.Enabled = false
                item.ResolvedText, item.ResolvedValue, item.ResolvedMaximum = nil, nil, nil
                item.ResolvedColor, item.ResolvedTransparency, item.ResolvedSegments = nil, nil, nil
                if not success or value == nil or value == false then return end
                if type(value) == "table" then
                    if value.Visible == false then return end
                    if value.Text ~= nil then item.ResolvedText = tostring(value.Text) end
                    if IsFinite(value.Value) then item.ResolvedValue = value.Value end
                    if value.Max ~= nil then
                        if not IsFinite(value.Max) or value.Max <= 0 then ProviderError(item.Id, "Bar Max must be a positive finite number"); return end
                        item.ResolvedMaximum = value.Max
                    end
                    if typeof(value.Color) == "Color3" then item.ResolvedColor = value.Color end
                    if IsFinite(value.Transparency) then item.ResolvedTransparency = math.clamp(value.Transparency, 0, 1) end
                    if value.Segments ~= nil then
                        if type(value.Segments) ~= "table" or #value.Segments > 64 then ProviderError(item.Id, "Expected up to 64 icon segments"); return end
                        for _, segment in value.Segments do
                            if type(segment) ~= "table" or #segment ~= 4 then ProviderError(item.Id, "Icon segments require four coordinates"); return end
                            for _, coordinate in segment do
                                if not IsFinite(coordinate) or coordinate < 0 or coordinate > 1 then ProviderError(item.Id, "Icon coordinates must be between 0 and 1"); return end
                            end
                        end
                        item.ResolvedSegments = value.Segments
                    end
                elseif type(value) == "string" then item.ResolvedText = value
                elseif IsFinite(value) then item.ResolvedText, item.ResolvedValue = tostring(value), value
                elseif value ~= true then ProviderError(item.Id, "Unsupported item provider result"); return end
                if item.Kind == "Bar" then
                    if not item.ResolvedValue then return end
                    item.ResolvedMaximum = item.ResolvedMaximum or 100
                elseif item.Kind == "Text" and item.ResolvedText == "" then return end
                item.Enabled = true
            end

            local function SyncItems(target: any, team: string): ()
                if target.Revision == Preview.Revision and target.Team == team then return end
                local config = Preview:GetProfile(team)
                for _, itemId in Preview.ItemOrder do
                    local definition = Preview.Items[itemId]
                    local settings = config.Items[itemId] or Defaults.Items[itemId] or Preview:GetConfig().Items[itemId]
                    local item = target.Items[itemId]
                    if not item then
                        item = { Id = itemId, Kind = definition.Kind, Drawings = {}, Text = definition.Text }
                        target.Items[itemId] = item
                    end
                    for key, value in settings do
                        item[key] = if key == "Color" or key == "BackgroundColor" then Color3.fromHex(value) else value
                    end
                    if item.Kind == "Box" then item.BoxType = settings.BoxType or "Bounding Box" end
                    item.ConfigEnabled = settings.Enabled
                end
                target.Config, target.Revision, target.Team = config, Preview.Revision, team
            end

            local function WorldBounds(target: any, camera: Camera): any
                local minimum, maximum = Vector2.new(math.huge, math.huge), Vector2.new(-math.huge, -math.huge)
                for _, part in target.Parts do
                    for horizontal = -1, 1, 2 do
                        for vertical = -1, 1, 2 do
                            for depth = -1, 1, 2 do
                                local world = part.CFrame:PointToWorldSpace(part.Size * Vector3.new(horizontal, vertical, depth) / 2)
                                local projected = camera:WorldToViewportPoint(world)
                                if projected.Z <= 0.1 then return nil end
                                minimum = Vector2.new(math.min(minimum.X, projected.X), math.min(minimum.Y, projected.Y))
                                maximum = Vector2.new(math.max(maximum.X, projected.X), math.max(maximum.Y, projected.Y))
                            end
                        end
                    end
                end
                local size = camera.ViewportSize
                if maximum.X < 0 or maximum.Y < 0 or minimum.X > size.X or minimum.Y > size.Y then return nil end
                if minimum.X == math.huge or maximum.X - minimum.X < 1 or maximum.Y - minimum.Y < 1 then return nil end
                return { X = minimum.X, Y = minimum.Y, Width = maximum.X - minimum.X, Height = maximum.Y - minimum.Y }
            end

            local function RenderPlayer(target: any, camera: Camera, origin: Vector3, deltaTime: number): ()
                local player = target.Player
                if player.Character == target.RemovingCharacter then return end
                if player.Character ~= target.Character then AttachCharacter(target, player.Character) end
                local character = target.Character
                if not character or not character.Parent then return end
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
                if not humanoid or not root or not root:IsA("BasePart") or humanoid.Health <= 0 then return end
                local team = if player == LocalPlayer then "Local" elseif LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team then "Allies" else "Enemies"
                SyncItems(target, team)
                local settings = target.Config.Settings
                if settings.Enabled == false then return end
                local distance = (origin - root.Position).Magnitude
                if distance > math.min(tracker.MaxDistance, settings.MaxDistance or math.huge) then return end
                if (tracker.TeamCheck or settings.TeamCheck) and team == "Allies" then return end
                if not target.Parts then
                    target.Parts = {}
                    for _, child in character:GetChildren() do
                        if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" and child.Transparency < 1 then table.insert(target.Parts, child) end
                    end
                end
                local rect = WorldBounds(target, camera)
                if not rect then return end
                local context = {
                    Player = player, Character = character, Humanoid = humanoid, RootPart = root,
                    Camera = camera, Distance = distance, Team = team, DeltaTime = deltaTime, Data = {},
                    Items = target.Items, Parts = target.Parts, Scale = settings.TextScale or tracker.TextScale, Layer = layer, ViewportSize = camera.ViewportSize,
                }
                if Preview.DataProvider then
                    local success, data = CallProvider(Preview.DataProvider, context, "DataProvider")
                    if not success or type(data) ~= "table" then return end
                    context.Data = data
                end
                if tracker.Filter then
                    local success, allowed = CallProvider(tracker.Filter, context, "Filter")
                    if not success or allowed ~= true then return end
                end
                if tracker.Destroyed or target.Removed or target.Character ~= character then return end
                SyncItems(target, team)
                for _, itemId in Preview.ItemOrder do ResolveItem(target.Items[itemId], context) end
                if tracker.Destroyed or target.Removed or target.Character ~= character then return end
                Layout(rect, context)
                for _, itemId in Preview.ItemOrder do
                    local item = target.Items[itemId]
                    if item.Enabled then RenderItem(item, context) end
                end
                target.Visible, target.Bounds = true, rect
                if tracker.Chams and settings.Chams ~= false then
                    if not target.Highlight then
                        target.Highlight = Instance.new("Highlight")
                        target.Highlight.Parent = layer
                    end
                    target.Highlight.Adornee = character
                    target.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    target.Highlight.FillColor = Color3.fromHex(target.Config.ModelColor)
                    target.Highlight.OutlineColor = target.Highlight.FillColor
                    target.Highlight.FillTransparency = target.Config.ModelTransparency
                    target.Highlight.OutlineTransparency, target.Highlight.Enabled = 0.2, true
                end
            end

            function tracker:SetEnabled(enabled: boolean): ()
                self.Enabled = enabled
                if not enabled then for _, target in self.Targets do HideTarget(target) end end
            end

            function tracker:SetIncludeLocalPlayer(enabled: boolean): ()
                self.IncludeLocalPlayer = enabled
                if enabled then AddPlayer(LocalPlayer) else RemovePlayer(LocalPlayer) end
            end

            function tracker:GetStats(): { [string]: number }
                local counts = { Players = 0, Visible = 0 }
                for _, target in self.Targets do
                    counts.Players += 1
                    if target.Visible then counts.Visible += 1 end
                end
                return counts
            end

            function tracker:Destroy(): ()
                if self.Destroyed then return end
                self.Destroyed = true
                DisconnectAll(self.Connections)
                local players = {}
                for player in self.Targets do table.insert(players, player) end
                for _, player in players do RemovePlayer(player) end
                layer:Destroy()
                local index = table.find(Preview.Trackers, self)
                if index then table.remove(Preview.Trackers, index) end
            end

            table.insert(tracker.Connections, Players.PlayerAdded:Connect(function(player: Player): () setthreadidentity(8); AddPlayer(player) end))
            table.insert(tracker.Connections, Players.PlayerRemoving:Connect(function(player: Player): () setthreadidentity(8); RemovePlayer(player) end))
            for _, player in Players:GetPlayers() do AddPlayer(player) end
            table.insert(tracker.Connections, RunService.RenderStepped:Connect(function(deltaTime: number): ()
                setthreadidentity(8)
                if tracker.Destroyed or tracker.Updating then return end
                for _, target in tracker.Targets do HideTarget(target) end
                if not tracker.Enabled or Library.Unloaded then return end
                local camera = workspace.CurrentCamera
                if not camera then return end
                local localCharacter = LocalPlayer.Character
                local localRoot = if localCharacter then localCharacter:FindFirstChild("HumanoidRootPart") else nil
                local origin = if localRoot and localRoot:IsA("BasePart") then localRoot.Position else camera.CFrame.Position
                tracker.Updating = true
                for _, target in tracker.Targets do
                    local success, message = pcall(RenderPlayer, target, camera, origin, deltaTime)
                    if not success then
                        HideTarget(target)
                        ProviderError(target.Player.Name, message)
                    end
                end
                tracker.Updating = false
            end))
            table.insert(self.Trackers, tracker)
            return tracker
        end

        local function Hit(point: Vector2): any
            local ancestor: Instance? = Stage
            while ancestor do
                if ancestor:IsA("GuiObject") and ancestor.ClipsDescendants and not Library:MouseIsOverFrame(ancestor, point) then return nil end
                ancestor = ancestor.Parent
            end
            local found = nil
            for _, itemId in Preview.ItemOrder do
                local item = Preview.Items[itemId]
                if not item.Enabled or (not (item.Kind == "Box" and item.BoxType == "3D Box") and not Contains(item.Rect, point)) then continue end
                if item.Kind == "Box" then
                    if item.BoxType == "None" then continue end
                    if item.BoxType == "3D Box" then
                        local nearEdge = false
                        for _, segment in item.HitLines or {} do
                            local direction = segment[2] - segment[1]
                            local progress = math.clamp((point - segment[1]):Dot(direction) / math.max(0.01, direction:Dot(direction)), 0, 1)
                            if (point - segment[1] - direction * progress).Magnitude <= 5 * Scale() then nearEdge = true; break end
                        end
                        if not nearEdge then continue end
                    else
                        local rect = item.BoxRect or item.Rect
                        if not Contains(rect, point) then continue end
                        local edge = math.min(point.X - rect.X, rect.X + rect.Width - point.X, point.Y - rect.Y, rect.Y + rect.Height - point.Y)
                        if edge > 5 * Scale() then continue end
                    end
                elseif item.Kind == "Skeleton" then
                    local nearBone = false
                    for _, segment in item.HitLines or {} do
                        local direction = segment[2] - segment[1]
                        local progress = math.clamp((point - segment[1]):Dot(direction) / math.max(0.01, direction:Dot(direction)), 0, 1)
                        if (point - segment[1] - direction * progress).Magnitude <= 5 * Scale() then nearBone = true; break end
                    end
                    if not nearBone then continue end
                elseif item.Kind == "Hitboxes" then
                    local nearHitbox = false
                    for _, part in ModelParts do
                        local relative = point - Project(part.Position)
                        if math.max(math.abs(relative.X), math.abs(relative.Y)) <= 8 * Scale() then nearHitbox = true; break end
                    end
                    if not nearHitbox then continue end
                end
                if found == nil or item.Rect.Width * item.Rect.Height < found.Rect.Width * found.Rect.Height then found = item end
            end
            return found
        end

        local function DropSide(point: Vector2, rect: any): string
            local center = Vector2.new(rect.X + rect.Width / 2, rect.Y + rect.Height / 2)
            local relative = point - center
            if math.abs(relative.X / math.max(1, rect.Width)) > math.abs(relative.Y / math.max(1, rect.Height)) then
                return if relative.X < 0 then "Left" else "Right"
            end
            return if relative.Y < 0 then "Top" else "Bottom"
        end

        local function MoveDragged(point: Vector2): ()
            if not Drag then return end
            if Drag.Model then
                Preview.Rotation = Drag.Rotation + (point.X - Drag.Start.X) * 0.6
                return
            end
            if (point - Drag.Start).Magnitude < 4 * Scale() and not Drag.Moved then return end
            Drag.Moved = true
            local side = DropSide(point, Preview.Bounds)
            local siblings = {}
            for _, itemId in Preview.ItemOrder do
                local other = Preview.Items[itemId]
                if other == Drag.Item or not other.Enabled or other.Side ~= side or not other.Rect then continue end
                if (other.Kind == "Bar") ~= (Drag.Item.Kind == "Bar") then continue end
                if other.Kind == "Box" or other.Kind == "Skeleton" or other.Kind == "Hitboxes" then continue end
                table.insert(siblings, other)
            end
            table.sort(siblings, function(first: any, second: any): boolean return first.Order < second.Order end)
            local index = 1
            for _, other in siblings do
                local middle = other.Rect.Y + other.Rect.Height / 2
                if side == "Top" then
                    if point.Y < middle then index += 1 end
                elseif point.Y > middle then index += 1 end
            end
            local signature = `{side}:{index}`
            if Drag.Signature ~= signature then
                Drag.Signature = signature
                Preview:MoveItem(Drag.Item.Id, side, index)
            end
        end

        Connect(UserInputService.InputBegan, function(input: InputObject): ()
            if not IsShown() or UserInputService:GetFocusedTextBox() then return end
            local primary = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
            local secondary = input.UserInputType == Enum.UserInputType.MouseButton2
            if not primary and not secondary then
                if input.KeyCode == Enum.KeyCode.Escape and Expanded then Preview:SetExpanded(false) end
                return
            end
            if CurrentMenu then return end
            local point = if input.UserInputType == Enum.UserInputType.Touch then Vector2.new(input.Position.X, input.Position.Y) else MousePoint()
            if not Library:MouseIsOverFrame(Stage, point) then return end
            local item = Hit(point)
            if secondary and item then
                Selected, PopupPoint = item, point
                RefreshSettings()
                SettingsMenu:Open()
            elseif primary and item then
                Drag = { Item = item, Start = point, Moved = false }
            elseif primary then
                Drag = { Model = true, Start = point, Rotation = Preview.Rotation }
            end
        end)
        Connect(UserInputService.InputChanged, function(input: InputObject): ()
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local point = if input.UserInputType == Enum.UserInputType.Touch then Vector2.new(input.Position.X, input.Position.Y) else MousePoint()
                if Pointer then UpdatePicker(point) end
                if Drag and IsShown() then MoveDragged(point) end
            elseif input.UserInputType == Enum.UserInputType.MouseWheel and IsShown() and not CurrentMenu and Library:MouseIsOverFrame(Stage, MousePoint()) then
                Preview.Zoom = math.clamp(Preview.Zoom + input.Position.Z * 0.05, 0.6, 1.25)
            end
        end)
        Connect(UserInputService.InputEnded, function(input: InputObject): ()
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if Drag and Drag.Item and Drag.Moved then Notify(Drag.Item.Id) end
                Drag, Pointer = nil, nil
            end
        end)

        Connect(RunService.RenderStepped, function(deltaTime: number): ()
            Preview.AnimationTime += deltaTime
            for _, itemId in Preview.ItemOrder do
                local item = Preview.Items[itemId]
                for _, object in item.Drawings do object.Visible = false end
                item.Hover.Visible = false
            end
            if not IsShown() then
                Drag, Pointer = nil, nil
                SetHover(nil)
                SettingsMenu:Close()
                ItemsMenu:Close()
                return
            end
            local aspect = Stage.AbsoluteSize.X / Stage.AbsoluteSize.Y
            local extent = math.max(ModelSize.Y, ModelSize.X / math.max(0.4, aspect))
            local distance = extent / (2 * math.tan(math.rad(Camera.FieldOfView / 2)) * 0.64 * Preview.Zoom) + ModelSize.Z
            Camera.CFrame = CFrame.lookAt(ModelCenter + Vector3.new(0, 0, -distance), ModelCenter)
            Model:PivotTo(CFrame.new(ModelCenter) * CFrame.Angles(0, math.rad(Preview.Rotation), 0) * CFrame.new(-ModelCenter) * BasePivot)
            Preview:UpdateModelAppearance()
            local rect = ModelRect()
            Preview.Bounds = rect
            Layout(rect)
            local hovered = if CurrentMenu then nil elseif Drag and Drag.Item then Drag.Item else Hit(MousePoint())
            SetHover(hovered)
            if not Drag then
                Hint.Text = if hovered then `{hovered.Label} · Drag to move · Right click to edit` else "Drag items · Right click to edit · Drag model to rotate"
            elseif Drag.Item then Hint.Text = `Move {Drag.Item.Label} · {Drag.Item.Side}` end
            for _, itemId in Preview.ItemOrder do
                local item = Preview.Items[itemId]
                if not item.Enabled then continue end
                local itemRect = item.Rect
                if itemRect then
                    local scale = Scale()
                    item.Hover.Position = UDim2.fromOffset((itemRect.X - Stage.AbsolutePosition.X) / scale, (itemRect.Y - Stage.AbsolutePosition.Y) / scale)
                    item.Hover.Size = UDim2.fromOffset(itemRect.Width / scale, itemRect.Height / scale)
                    item.Hover.Visible = true
                end
                RenderItem(item)
            end
        end)

        function Preview:SetVisible(visible: boolean): ()
            self.Visible, Holder.Visible = visible, visible
            if not visible then SettingsMenu:Close(); ItemsMenu:Close() end
            Groupbox:Resize()
        end

        function Preview:Destroy(): ()
            if self.Destroyed then return end
            self.Destroyed = true
            for index = #self.Trackers, 1, -1 do self.Trackers[index]:Destroy() end
            for _, connection in self.Connections do connection:Disconnect() end
            table.clear(self.Connections)
            for _, binding in ProfileControls do
                if binding.Control.Changed == binding.Handler then binding.Control:OnChanged(binding.Previous) end
            end
            table.clear(ProfileControls)
            for _, item in self.Items do
                if item.Tween then item.Tween:Cancel(); item.Tween:Destroy() end
                for _, object in item.Drawings do object:Remove() end
                table.clear(item.Drawings)
            end
            SettingsMenu:Destroy()
            ItemsMenu:Destroy()
            if Fullscreen then Fullscreen:Destroy() else Holder:Destroy() end
            local index = table.find(Groupbox.Elements, self)
            if index and not Groupbox.Destroyed then table.remove(Groupbox.Elements, index) end
            if Options[Idx] == self then Options[Idx] = nil end
            if not Groupbox.Destroyed and not Library.Unloaded then Groupbox:Resize() end
        end

        ReadModel()
        ApplyModel()
        if Info.Object then Preview:SetObject(Info.Object) end
        if Info.Data then Preview:SetData(Info.Data) end
        if Info.Items then
            for itemId, properties in Info.Items do Preview:SetItem(itemId, properties) end
        end
        Preview.Holder, Preview.Base, Preview.ViewportFrame, Preview.Object = Holder, Holder, ViewportFrame, Model
        Preview.ChamsViewportFrame = ChamsViewport
        Preview.SettingsMenu, Preview.ItemsMenu = SettingsMenu, ItemsMenu
        Preview.Value = Preview:GetValue()
        Options[Idx] = Preview
        table.insert(Groupbox.Elements, Preview)
        Groupbox:Resize()
        return Preview
    end

    function Funcs:AddViewport(Idx, Info)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Viewport)

        local Groupbox = self
        local Container = Groupbox.Container

        local Dragging, Pinching = false, false
        local LastMousePos, LastPinchDist = nil, 0

        local ViewportObject = Info.Object
        if Info.Clone and typeof(Info.Object) == "Instance" then
            if Info.Object.Archivable then
                ViewportObject = ViewportObject:Clone()
            else
                Info.Object.Archivable = true
                ViewportObject = ViewportObject:Clone()
                Info.Object.Archivable = false
            end
        end

        local Viewport = {
            Connections = {},
            Destroyed = false,
            Hovered = false,
            ScrollStates = {},

            Object = ViewportObject :: PVInstance,
            Camera = if not Info.Camera then Instance.new("Camera") else Info.Camera,
            Interactive = Info.Interactive,
            Clickable = Info.Clickable,
            ToggleSelection = Info.ToggleSelection,
            Selected = Info.Selected,
            Callback = Info.Callback,
            Text = Info.Text,
            RichText = Info.RichText,
            AutoFocus = Info.AutoFocus,
            Visible = Info.Visible,
            Type = "Viewport",
        }

        assert(
            typeof(Viewport.Object) == "Instance" and (Viewport.Object:IsA("BasePart") or Viewport.Object:IsA("Model")),
            "Instance must be a BasePart or Model."
        )

        assert(
            typeof(Viewport.Camera) == "Instance" and Viewport.Camera:IsA("Camera"),
            "Camera must be a valid Camera instance."
        )

        local function GetModelSize(model)
            setthreadidentity(8)
            if model:IsA("BasePart") then
                return model.Size
            end

            return select(2, model:GetBoundingBox())
        end

        local function FocusCamera()
            setthreadidentity(8)
            local ModelSize = GetModelSize(Viewport.Object)
            local MaxExtent = math.max(ModelSize.X, ModelSize.Y, ModelSize.Z)
            local CameraDistance = MaxExtent * 2
            local ModelPosition = (Viewport.Object :: PVInstance):GetPivot().Position

            Viewport.Camera.CFrame = CFrame.new(ModelPosition + Vector3.new(0, MaxExtent / 2, CameraDistance), ModelPosition)
        end

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Viewport.Visible,
            Parent = Container,
        })

        local Box = New("TextButton", {
            Active = Viewport.Interactive or Viewport.Clickable,
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ViewportFrame = New("ViewportFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = Box,
            CurrentCamera = Viewport.Camera,
            Active = false,
        })

        local TextLabel = New("TextLabel", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 0.12,
            Position = UDim2.fromScale(0, 1),
            RichText = Viewport.RichText,
            Size = UDim2.new(1, 0, 0, 30),
            Text = Viewport.Text or "",
            TextSize = Info.TextSize,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = Viewport.Text ~= nil,
            ZIndex = Box.ZIndex + 2,
            Parent = Box,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            Parent = TextLabel,
        })

        local function UpdateSelection()
            setthreadidentity(8)
            local ColorName = if Viewport.Selected then "AccentColor" else "OutlineColor"
            local RegistryEntry = Library.Registry[Box]

            if RegistryEntry then
                RegistryEntry.BorderColor3 = ColorName
            end

            Box.BorderColor3 = Library.Scheme[ColorName]
        end

        function Viewport:SetScrollLocked(locked: boolean): ()
            setthreadidentity(8)
            if locked then
                if Viewport.Destroyed then return end
                local ancestor = Groupbox.Container
                while ancestor do
                    if ancestor:IsA("ScrollingFrame") and Viewport.ScrollStates[ancestor] == nil then
                        Viewport.ScrollStates[ancestor] = ancestor.ScrollingEnabled
                        ancestor.ScrollingEnabled = false
                    end
                    ancestor = ancestor.Parent
                end
            else
                for scrollingFrame, enabled in Viewport.ScrollStates do
                    scrollingFrame.ScrollingEnabled = enabled
                end
                table.clear(Viewport.ScrollStates)
            end
        end

        table.insert(Viewport.Connections, Box.MouseEnter:Connect(function()
            setthreadidentity(8)
            if Viewport.Destroyed or Library.Unloaded then return end
            Viewport.Hovered = true
            if Viewport.Clickable then
                TweenService:Create(Box, Library.TweenInfo, {
                    BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 1),
                }):Play()
            end

            if Viewport.Interactive then
                Viewport:SetScrollLocked(true)
            end
        end))

        table.insert(Viewport.Connections, Box.MouseLeave:Connect(function()
            setthreadidentity(8)
            Viewport.Hovered = false
            if Viewport.Clickable then
                TweenService:Create(Box, Library.TweenInfo, {
                    BackgroundColor3 = Library.Scheme.MainColor,
                }):Play()
            end

            Viewport:SetScrollLocked(false)
        end))

        table.insert(Viewport.Connections, Box.InputBegan:Connect(function(input)
            setthreadidentity(8)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 or (input.UserInputType == Enum.UserInputType.Touch and not Pinching) then
                Dragging = true
                LastMousePos = input.Position
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputEnded:Connect(function(input)
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputChanged:Connect(function(input)
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Dragging or Pinching then
                return
            end

            if
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            then
                local MouseDelta = input.Position - LastMousePos
                LastMousePos = input.Position

                local Position = (Viewport.Object :: PVInstance):GetPivot().Position
                local Camera = Viewport.Camera

                local RotationY = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -MouseDelta.X * 0.01)
                Camera.CFrame = CFrame.new(Position) * RotationY * CFrame.new(-Position) * Camera.CFrame

                local RotationX = CFrame.fromAxisAngle(Camera.CFrame.RightVector, -MouseDelta.Y * 0.01)
                local PitchedCFrame = CFrame.new(Position) * RotationX * CFrame.new(-Position) * Camera.CFrame

                if PitchedCFrame.UpVector.Y > 0.1 then
                    Camera.CFrame = PitchedCFrame
                end
            end
        end))

        table.insert(Viewport.Connections, Box.InputChanged:Connect(function(input)
            setthreadidentity(8)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local ZoomAmount = input.Position.Z * 2
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * ZoomAmount
            end
        end))

        table.insert(Viewport.Connections, UserInputService.TouchPinch:Connect(function(touchPositions, _, _, state)
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Library:MouseIsOverFrame(ViewportFrame, touchPositions[1]) then
                return
            end

            if state == Enum.UserInputState.Begin then
                Pinching = true
                Dragging = false
                LastPinchDist = (touchPositions[1] - touchPositions[2]).Magnitude
            elseif state == Enum.UserInputState.Change then
                local currentDist = (touchPositions[1] - touchPositions[2]).Magnitude
                local delta = (currentDist - LastPinchDist) * 0.1
                LastPinchDist = currentDist
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * delta
            elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                Pinching = false
            end
        end))

        table.insert(Viewport.Connections, Box.Activated:Connect(function()
            setthreadidentity(8)
            if not Viewport.Clickable then
                return
            end

            if Viewport.ToggleSelection then
                Viewport:SetSelected(not Viewport.Selected)
            end

            Library:SafeCallback(Viewport.Callback, Viewport, Viewport.Selected)
        end))

        ;(Viewport.Object :: PVInstance).Parent = ViewportFrame
        if Viewport.AutoFocus then
            FocusCamera()
        end

        function Viewport:SetObject(Object: Instance, Clone: boolean?)
            setthreadidentity(8)
            assert(Object, "Object cannot be nil.")

            if Clone then
                Object = Object:Clone()
            end

            if Viewport.Object then
                Viewport.Object:Destroy()
            end

            Viewport.Object = Object
            ;(Viewport.Object :: PVInstance).Parent = ViewportFrame

            Groupbox:Resize()
        end

        function Viewport:SetHeight(Height: number)
            setthreadidentity(8)
            assert(Height > 0, "Height must be greater than 0.")

            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Viewport:Focus()
            setthreadidentity(8)
            if not Viewport.Object then
                return
            end

            FocusCamera()
        end

        function Viewport:SetCamera(Camera: Instance)
            setthreadidentity(8)
            assert(
                Camera and typeof(Camera) == "Instance" and Camera:IsA("Camera"),
                "Camera must be a valid Camera instance."
            )

            Viewport.Camera = Camera
            ViewportFrame.CurrentCamera = Camera
        end

        function Viewport:SetInteractive(Interactive: boolean)
            setthreadidentity(8)
            Viewport.Interactive = Interactive
            Box.Active = Interactive or Viewport.Clickable
            if not Interactive then
                Dragging, Pinching = false, false
            end
            Viewport:SetScrollLocked(Interactive and Viewport.Hovered)
        end

        function Viewport:SetClickable(Clickable: boolean)
            setthreadidentity(8)
            Viewport.Clickable = Clickable
            Box.Active = Clickable or Viewport.Interactive
        end

        function Viewport:SetSelected(Selected: boolean)
            setthreadidentity(8)
            Viewport.Selected = Selected
            UpdateSelection()
        end

        function Viewport:SetText(Text: string?, RichText: boolean?)
            setthreadidentity(8)
            assert(Text == nil or typeof(Text) == "string", "Viewport text must be a string or nil.")

            Viewport.Text = Text
            TextLabel.Text = Text or ""
            TextLabel.Visible = Text ~= nil

            if RichText ~= nil then
                Viewport.RichText = RichText
                TextLabel.RichText = RichText
            end
        end

        function Viewport:SetCallback(Callback: ((any, boolean) -> ())?)
            setthreadidentity(8)
            assert(Callback == nil or typeof(Callback) == "function", "Viewport callback must be a function or nil.")
            Viewport.Callback = Callback
        end

        function Viewport:SetVisible(Visible: boolean)
            setthreadidentity(8)
            Viewport.Visible = Visible
            if not Visible then
                Viewport.Hovered = false
                Dragging, Pinching = false, false
                Viewport:SetScrollLocked(false)
            end

            Holder.Visible = Viewport.Visible
            Groupbox:Resize()
        end

        UpdateSelection()
        Groupbox:Resize()

        Viewport.Holder = Holder
        Viewport.Base = Box
        Viewport.ViewportFrame = ViewportFrame
        Viewport.TextLabel = TextLabel
        table.insert(Groupbox.Elements, Viewport)

        Options[Idx] = Viewport

        function Viewport:Destroy()
            setthreadidentity(8)
            if Viewport.Destroyed then return end
            Viewport.Destroyed = true
            Viewport:SetScrollLocked(false)

            if Viewport.Connections then
                for _, Connection in Viewport.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Viewport)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Viewport
    end

    function Funcs:AddImage(Idx, Info)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Image)

        local Groupbox = self
        local Container = Groupbox.Container

        local Image = {
            Connections = {},
            Destroyed = false,

            Image = Info.Image,
            Color = Info.Color,
            RectOffset = Info.RectOffset,
            RectSize = Info.RectSize,
            Height = Info.Height,
            ScaleType = Info.ScaleType,
            Transparency = Info.Transparency,
            BackgroundTransparency = Info.BackgroundTransparency,

            Visible = Info.Visible,
            Type = "Image",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Image.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            BackgroundTransparency = Image.BackgroundTransparency,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ImageProperties = {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ImageTransparency = Image.Transparency,
            ImageColor3 = Image.Color,
            ScaleType = Image.ScaleType,
            Parent = Box,
        }

        local Icon = Library:GetCustomIcon(Image.Image)
        assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        ImageProperties.Image = Icon.Url
        ImageProperties.ImageRectOffset = Icon.ImageRectOffset
        ImageProperties.ImageRectSize = Icon.ImageRectSize

        local ImageLabel = New("ImageLabel", ImageProperties)

        function Image:SetHeight(Height: number)
            setthreadidentity(8)
            assert(Height > 0, "Height must be greater than 0.")

            Image.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Image:SetImage(NewImage: string)
            setthreadidentity(8)
            assert(typeof(NewImage) == "string", "Image must be a string.")

            local Icon = Library:GetCustomIcon(NewImage)
            assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            Image.RectOffset = Icon.ImageRectOffset
            Image.RectSize = Icon.ImageRectSize

            Library:ApplyLucideIcon(ImageLabel, Icon)
            Image.Image = Icon.Url
        end

        function Image:SetColor(Color: Color3)
            setthreadidentity(8)
            assert(typeof(Color) == "Color3", "Color must be a Color3 value.")

            ImageLabel.ImageColor3 = Color
            Image.Color = Color
        end

        function Image:SetRectOffset(RectOffset: Vector2)
            setthreadidentity(8)
            assert(typeof(RectOffset) == "Vector2", "RectOffset must be a Vector2 value.")

            ImageLabel.ImageRectOffset = RectOffset
            Image.RectOffset = RectOffset
        end

        function Image:SetRectSize(RectSize: Vector2)
            setthreadidentity(8)
            assert(typeof(RectSize) == "Vector2", "RectSize must be a Vector2 value.")

            ImageLabel.ImageRectSize = RectSize
            Image.RectSize = RectSize
        end

        function Image:SetScaleType(ScaleType: Enum.ScaleType)
            setthreadidentity(8)
            assert(
                typeof(ScaleType) == "EnumItem" and ScaleType:IsA("ScaleType"),
                "ScaleType must be a valid Enum.ScaleType."
            )

            ImageLabel.ScaleType = ScaleType
            Image.ScaleType = ScaleType
        end

        function Image:SetTransparency(Transparency: number)
            setthreadidentity(8)
            assert(typeof(Transparency) == "number", "Transparency must be a number between 0 and 1.")
            assert(Transparency >= 0 and Transparency <= 1, "Transparency must be between 0 and 1.")

            ImageLabel.ImageTransparency = Transparency
            Image.Transparency = Transparency
        end

        function Image:SetVisible(Visible: boolean)
            setthreadidentity(8)
            Image.Visible = Visible

            Holder.Visible = Image.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Image.Holder = Holder
        table.insert(Groupbox.Elements, Image)

        Options[Idx] = Image

        function Image:Destroy()
            setthreadidentity(8)
            Image.Destroyed = true

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Image)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Image
    end

    function Funcs:AddVideo(Idx, Info)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Video)

        local Groupbox = self
        local Container = Groupbox.Container

        local Video = {
            Connections = {},
            Destroyed = false,

            Video = Info.Video,
            Looped = Info.Looped,
            Playing = Info.Playing,
            Volume = Info.Volume,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "Video",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Video.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local VideoFrameInstance = New("VideoFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Video = Video.Video,
            Looped = Video.Looped,
            Volume = Video.Volume,
            Parent = Box,
        })

        VideoFrameInstance.Playing = Video.Playing

        function Video:SetHeight(Height: number)
            setthreadidentity(8)
            assert(Height > 0, "Height must be greater than 0.")

            Video.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Video:SetVideo(NewVideo: string)
            setthreadidentity(8)
            assert(typeof(NewVideo) == "string", "Video must be a string.")

            VideoFrameInstance.Video = NewVideo
            Video.Video = NewVideo
        end

        function Video:SetLooped(Looped: boolean)
            setthreadidentity(8)
            assert(typeof(Looped) == "boolean", "Looped must be a boolean.")

            VideoFrameInstance.Looped = Looped
            Video.Looped = Looped
        end

        function Video:SetVolume(Volume: number)
            setthreadidentity(8)
            assert(typeof(Volume) == "number", "Volume must be a number between 0 and 10.")

            VideoFrameInstance.Volume = Volume
            Video.Volume = Volume
        end

        function Video:SetPlaying(Playing: boolean)
            setthreadidentity(8)
            assert(typeof(Playing) == "boolean", "Playing must be a boolean.")

            VideoFrameInstance.Playing = Playing
            Video.Playing = Playing
        end

        function Video:Play()
            setthreadidentity(8)
            VideoFrameInstance.Playing = true
            Video.Playing = true
        end

        function Video:Pause()
            setthreadidentity(8)
            VideoFrameInstance.Playing = false
            Video.Playing = false
        end

        function Video:SetVisible(Visible: boolean)
            setthreadidentity(8)
            Video.Visible = Visible

            Holder.Visible = Video.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Video.Holder = Holder
        Video.VideoFrame = VideoFrameInstance
        table.insert(Groupbox.Elements, Video)

        Options[Idx] = Video

        function Video:Destroy()
            setthreadidentity(8)
            Video.Destroyed = true

            if Video.Connections then
                for _, Connection in Video.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Video)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Video
    end

    function Funcs:AddList(Info)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.List)

        local Groupbox = self
        local Container = Groupbox.Container
        local BodyHeight = math.max(40, Info.Height)
        local InitialCollapsed = Info.DisableCollapsing ~= true and Info.Collapsed == true

        local Holder = New("Frame", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.new(1, 0, 0, 0),
            Visible = Info.Visible,
            Parent = Container,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, math.max(2, Library.CornerRadius - 1)),
                Parent = Holder,
            })
        )
        Library:AddOutline(Holder)

        local Header = New("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Text = "",
            Parent = Holder,
        })

        local HeaderIcon
        local ParsedIcon = Library:GetCustomIcon(Info.IconName)
        if ParsedIcon then
            HeaderIcon = New("ImageLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                ImageColor3 = ParsedIcon.Custom and "WhiteColor" or "AccentColor",
                Position = UDim2.new(0, 8, 0.5, 0),
                Size = UDim2.fromOffset(17, 17),
                Parent = Header,
            })
            Library:ApplyLucideIcon(HeaderIcon, ParsedIcon)
        end

        local HeaderLabel = New("TextLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, HeaderIcon and 31 or 8, 0.5, 0),
            Size = UDim2.new(1, HeaderIcon and -63 or -40, 0, 18),
            Text = Info.Name,
            TextSize = 14,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Header,
        })

        local CollapseArrow = New("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            ImageColor3 = "FontColor",
            ImageTransparency = 0.35,
            Position = UDim2.new(1, -8, 0.5, 0),
            Rotation = InitialCollapsed and 0 or 180,
            Size = UDim2.fromOffset(16, 16),
            Visible = Info.DisableCollapsing ~= true,
            Parent = Header,
        })
        if ArrowIcon then
            Library:ApplyLucideIcon(CollapseArrow, ArrowIcon, CollapseArrow.Rotation)
        end

        local HeaderLine = Library:MakeLine(Holder, {
            Position = UDim2.fromOffset(0, 32),
            Size = UDim2.new(1, 0, 0, 1),
        })

        local ListContainer = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromScale(0, 0),
            Position = UDim2.fromOffset(0, 33),
            ScrollBarImageColor3 = "AccentColor",
            ScrollBarThickness = 3,
            Size = UDim2.new(1, 0, 0, BodyHeight),
            Visible = not InitialCollapsed,
            Parent = Holder,
        })
        local ListLayout = New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = ListContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 7),
            PaddingLeft = UDim.new(0, 7),
            PaddingRight = UDim.new(0, 7),
            PaddingTop = UDim.new(0, 7),
            Parent = ListContainer,
        })

        local List = {
            Connections = {},
            Destroyed = false,

            Type = "List",
            Text = Info.Name,
            Name = Info.Name,
            Visible = Info.Visible,
            Collapsed = InitialCollapsed,
            Height = BodyHeight,

            Holder = Holder,
            Container = ListContainer,
            Elements = {},
            Tab = Groupbox.Tab,
            SubTab = Groupbox.SubTab,
            Parent = Groupbox,
        }

        function List:Resize()
            setthreadidentity(8)
            if List.Destroyed then return end

            ListContainer.Size = UDim2.new(1, 0, 0, List.Height)
            Holder.Size = UDim2.new(1, 0, 0, if List.Collapsed then 32 else 33 + List.Height)
            HeaderLine.Visible = not List.Collapsed
            Groupbox:Resize()
        end

        function List:SetCollapsed(Collapsed: boolean)
            setthreadidentity(8)
            if Info.DisableCollapsing == true then return end

            List.Collapsed = Collapsed
            ListContainer.Visible = not Collapsed

            local Rotation = if Collapsed then 0 else 180
            if Library.Animations and Library.Animations.Groupbox then
                TweenService:Create(CollapseArrow, Library.GroupboxTweenInfo, { Rotation = Rotation }):Play()
            else
                CollapseArrow.Rotation = Rotation
            end

            List:Resize()
        end

        function List:ToggleCollapsed()
            setthreadidentity(8)
            List:SetCollapsed(not List.Collapsed)
        end

        function List:SetHeight(Height: number)
            setthreadidentity(8)
            assert(typeof(Height) == "number" and Height >= 40, "List height must be at least 40 pixels.")

            List.Height = Height
            List:Resize()
        end

        function List:SetText(Text: string)
            setthreadidentity(8)
            assert(typeof(Text) == "string", "List text must be a string.")

            List.Text = Text
            List.Name = Text
            HeaderLabel.Text = Text
        end

        function List:SetVisible(Visible: boolean)
            setthreadidentity(8)
            List.Visible = Visible
            Holder.Visible = Visible
            Groupbox:Resize()
        end

        function List:Clear()
            setthreadidentity(8)
            for _, Element in table.clone(List.Elements) do
                if Element.Destroy then
                    Element:Destroy()
                end
            end
            table.clear(List.Elements)
            List:Resize()
        end

        function List:GetElements(): { any }
            setthreadidentity(8)
            return table.clone(List.Elements)
        end

        table.insert(List.Connections, ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            setthreadidentity(8)
            ListContainer.CanvasSize = UDim2.fromOffset(0, ListLayout.AbsoluteContentSize.Y + 14)
        end))

        if Info.DisableCollapsing ~= true then
            table.insert(List.Connections, Header.Activated:Connect(function()
                setthreadidentity(8)
                List:ToggleCollapsed()
            end))
        end

        setmetatable(List, BaseList)
        table.insert(Groupbox.Elements, List)

        function List:Destroy()
            setthreadidentity(8)
            if List.Destroyed then return end

            List.Destroyed = true
            List:Clear()

            for _, Connection in List.Connections do
                Connection:Disconnect()
            end
            table.clear(List.Connections)

            if Holder then
                Holder:Destroy()
            end

            local ElementIndex = table.find(Groupbox.Elements, List)
            if ElementIndex then
                table.remove(Groupbox.Elements, ElementIndex)
            end

            Groupbox:Resize()
        end

        List:Resize()
        return List
    end

    function Funcs:AddUIPassthrough(Idx, Info)
        setthreadidentity(8)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.UIPassthrough)

        local Groupbox = self
        local Container = Groupbox.Container

        assert(Info.Instance, "Instance must be provided.")
        assert(
            typeof(Info.Instance) == "Instance" and Info.Instance:IsA("GuiBase2d"),
            "Instance must inherit from GuiBase2d."
        )
        assert(typeof(Info.Height) == "number" and Info.Height > 0, "Height must be a number greater than 0.")

        local Passthrough = {
            Connections = {},
            Destroyed = false,

            Instance = Info.Instance,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "UIPassthrough",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Passthrough.Visible,
            Parent = Container,
        })

        Passthrough.Instance.Parent = Holder

        Groupbox:Resize()

        function Passthrough:SetHeight(Height: number)
            setthreadidentity(8)
            assert(typeof(Height) == "number" and Height > 0, "Height must be a number greater than 0.")

            Passthrough.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Passthrough:SetInstance(Instance: Instance)
            setthreadidentity(8)
            assert(Instance, "Instance must be provided.")
            assert(
                typeof(Instance) == "Instance" and Instance:IsA("GuiBase2d"),
                "Instance must inherit from GuiBase2d."
            )

            if Passthrough.Instance then
                Passthrough.Instance.Parent = nil
            end

            Passthrough.Instance = Instance
            Passthrough.Instance.Parent = Holder
        end

        function Passthrough:SetVisible(Visible: boolean)
            setthreadidentity(8)
            Passthrough.Visible = Visible

            Holder.Visible = Passthrough.Visible
            Groupbox:Resize()
        end

        Passthrough.Holder = Holder
        table.insert(Groupbox.Elements, Passthrough)

        Options[Idx] = Passthrough

        function Passthrough:Destroy()
            setthreadidentity(8)
            Passthrough.Destroyed = true

            if Passthrough.Connections then
                for _, Connection in Passthrough.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Passthrough)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Passthrough
    end

    function Funcs:AddDependencyBox()
        setthreadidentity(8)
        if self.Destroyed then return nil end

        local Groupbox = self
        local Container = Groupbox.Container

        local DepboxContainer
        local DepboxList

        do
            DepboxContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            DepboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepboxContainer,
            })
        end

        local Depbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            Holder = DepboxContainer,
            Container = DepboxContainer,

            Elements = {},
            DependencyBoxes = {}
        }

        function Depbox:Resize()
            setthreadidentity(8)
            DepboxContainer.Size = UDim2.new(1, 0, 0, DepboxList.AbsoluteContentSize.Y / Library.DPIScale)
            Groupbox:Resize()
        end

        function Depbox:Update(CancelSearch)
            setthreadidentity(8)
            for _, Dependency in Depbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Disabled then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                end

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    end
                end
            end

            Depbox.Visible = true
            DepboxContainer.Visible = true
            if not Library.Searching then
                task.defer(function()
                    setthreadidentity(8)
                    Depbox:Resize()
                end)
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        table.insert(Depbox.Connections, DepboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            setthreadidentity(8)
            if not Depbox.Visible then
                return
            end

            Depbox:Resize()
        end))

        function Depbox:SetupDependencies(Dependencies)
            setthreadidentity(8)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            Depbox.Dependencies = Dependencies
            Depbox:Update()
        end

        table.insert(Depbox.Connections, DepboxContainer:GetPropertyChangedSignal("Visible"):Connect(function()
            setthreadidentity(8)
            Depbox:Resize()
        end))

        setmetatable(Depbox, BaseGroupbox)

        table.insert(Groupbox.DependencyBoxes, Depbox)
        table.insert(Library.DependencyBoxes, Depbox)

        function Depbox:Destroy()
            setthreadidentity(8)
            Depbox.Destroyed = true

            if Depbox.Connections then
                for _, Connection in Depbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in Depbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in Depbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepboxContainer then
                DepboxContainer:Destroy()
            end

            local ElemIdx = table.find(Groupbox.DependencyBoxes, Depbox)
            if ElemIdx then
                table.remove(Groupbox.DependencyBoxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, Depbox)
            if LibIdx then
                table.remove(Library.DependencyBoxes, LibIdx)
            end
        end

        return Depbox
    end

    function Funcs:AddDependencyGroupbox()
        setthreadidentity(8)
        if self.Destroyed then return nil end

        local Groupbox = self
        local Tab = Groupbox.Tab
        local BoxHolder = Groupbox.BoxHolder

        local DepGroupboxContainer
        local DepGroupboxList

        do
            DepGroupboxContainer = New("Frame", {
                BackgroundColor3 = "BackgroundColor",
                Size = UDim2.fromScale(1, 0),
                Visible = false,
                Parent = BoxHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = DepGroupboxContainer,
                })
            )
            Library:AddOutline(DepGroupboxContainer)

            DepGroupboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepGroupboxContainer,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 7),
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                PaddingTop = UDim.new(0, 7),
                Parent = DepGroupboxContainer,
            })
        end

        local DepGroupbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            BoxHolder = BoxHolder,
            Holder = DepGroupboxContainer,
            Container = DepGroupboxContainer,

            Tab = Tab,
            Elements = {},
            DependencyBoxes = {},
        }

        function DepGroupbox:Resize()
            setthreadidentity(8)
            DepGroupboxContainer.Size = UDim2.new(1, 0, 0, (DepGroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 18)
        end

        function DepGroupbox:Update(CancelSearch)
            setthreadidentity(8)
            for _, Dependency in DepGroupbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Disabled then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                end

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    end
                end
            end

            DepGroupbox.Visible = true
            if not Library.Searching then
                DepGroupboxContainer.Visible = true
                DepGroupbox:Resize()
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function DepGroupbox:SetupDependencies(Dependencies)
            setthreadidentity(8)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            DepGroupbox.Dependencies = Dependencies
            DepGroupbox:Update()
        end

        setmetatable(DepGroupbox, BaseGroupbox)

        table.insert(Tab.DependencyGroupboxes, DepGroupbox)
        table.insert(Library.DependencyBoxes, DepGroupbox :: any)

        function DepGroupbox:Destroy()
            setthreadidentity(8)
            DepGroupbox.Destroyed = true

            if DepGroupbox.Connections then
                for _, Connection in DepGroupbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in DepGroupbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in DepGroupbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepGroupboxContainer then
                DepGroupboxContainer:Destroy()
            end

            local ElemIdx = table.find(Tab.DependencyGroupboxes, DepGroupbox)
            if ElemIdx then
                table.remove(Tab.DependencyGroupboxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, DepGroupbox)
            if LibIdx then
                table.remove(Library.DependencyBoxes, LibIdx)
            end
        end

        return DepGroupbox
    end

    local ListMethods = {
        "AddDivider",
        "AddLabel",
        "AddButton",
        "AddCheckbox",
        "AddToggle",
        "AddInput",
        "AddSlider",
        "AddDropdown",
        "AddViewport",
        "AddESPPreview",
        "AddImage",
        "AddVideo",
    }

    local ListFuncs = {}
    for _, MethodName in ListMethods do
        ListFuncs[MethodName] = Funcs[MethodName]
    end

    BaseList.__index = ListFuncs
    BaseList.__namecall = function(_, Key, ...)
        setthreadidentity(8)
        return ListFuncs[Key](...)
    end

    BaseGroupbox.__index = Funcs
    BaseGroupbox.__namecall = function(_, Key, ...)
        setthreadidentity(8)
        return Funcs[Key](...)
    end
end

function Library:SetFont(FontFace)
    setthreadidentity(8)
    if typeof(FontFace) == "EnumItem" then
        FontFace = Font.fromEnum(FontFace :: any)
    end

    Library.Scheme.Font = FontFace
    Library:UpdateColorsUsingRegistry()
end

function Library:SetBackgroundImage(Image: string | number)
    setthreadidentity(8)
    assert(typeof(Image) == "string" or typeof(Image) == "number", "Expected string/number got " .. typeof(Image))

    Library.Scheme.BackgroundImage = Image
    if Library.Window then
        Library.Window:SetBackgroundImage(Image)
    end

    Library:UpdateColorsUsingRegistry()
end

function Library:EscapeNotificationText(text: any): string
    local escaped = string.gsub(tostring(text), "&", "&amp;")
    escaped = string.gsub(escaped, "<", "&lt;")
    escaped = string.gsub(escaped, ">", "&gt;")
    escaped = string.gsub(escaped, '"', "&quot;")
    return escaped
end

function Library:GetNotificationColor(color: any): Color3
    if typeof(color) == "Color3" then return color end
    if type(color) == "string" then
        local schemeColor = GetSchemeValue(color)
        if typeof(schemeColor) == "Color3" then return schemeColor end
        local hex = string.match(color, "^#?(%x%x%x%x%x%x)$")
        if hex then return Color3.fromHex(hex) end
    end
    return Library.Scheme.AccentColor
end

function Library:FormatNotificationSegments(segments: { any }): string
    assert(type(segments) == "table", "Notification segments must be a table")
    local formatted = table.create(#segments)
    for _, segment in segments do
        local text = Library:EscapeNotificationText(if type(segment) == "table" then segment.Text or "" else segment)
        if type(segment) == "table" then
            if segment.Bold then text = "<b>" .. text .. "</b>" end
            if segment.Color then
                text = string.format('<font color="#%s">%s</font>', Library:GetNotificationColor(segment.Color):ToHex(), text)
            end
        end
        table.insert(formatted, text)
    end
    return table.concat(formatted)
end

function Library:UpdateNotificationPositions(_snap: boolean?): ()
    setthreadidentity(8)
    local horizontal = if string.lower(Library.NotifySide) == "left" then 0 else 1
    local vertical = 0
    for _, frame in NotifyOrder do
        local notification = Library.Notifications[frame]
        if not notification or notification.Destroyed or not notification.Ready or not frame.Parent then continue end
        local position = UDim2.new(horizontal, 0, 0, vertical)
        if _snap or not notification.PositionInitialized then
            notification:CancelTween("Position")
            frame.Position = position
            notification.PositionInitialized = true
        elseif frame.Position ~= position then
            notification:Tween("Position", frame, Library.NotifyTweenInfo, { Position = position })
        end
        vertical += frame.Size.Y.Offset + (if notification.Style == "Compact" then 5 else 8)
    end
end

function Library:SetNotifySide(side: string): ()
    setthreadidentity(8)
    assert(type(side) == "string" and (string.lower(side) == "left" or string.lower(side) == "right"), "NotifySide must be Left or Right")
    Library.NotifySide = side
    local isLeft = string.lower(side) == "left"
    NotificationArea.AnchorPoint = Vector2.new(if isLeft then 0 else 1, 0)
    NotificationArea.Position = if isLeft then UDim2.fromOffset(6, 6) else UDim2.new(1, -6, 0, 6)
    for frame in Library.Notifications do
        if frame.Parent then frame.AnchorPoint = NotificationArea.AnchorPoint end
    end
    Library:UpdateNotificationPositions(true)
end

function Library:Notify(...: any): any
    setthreadidentity(8)
    if Library.Unloaded then return nil end
    local first = select(1, ...)
    local info = if type(first) == "table" then first else { Description = first, Time = select(2, ...), SoundId = select(3, ...), Volume = select(4, ...) }
    local requestedStyle = info.Style or (if info.Title ~= nil or info.BigIcon then "Classic" else Library.NotifyStyle or "Compact")
    local compact = string.lower(tostring(requestedStyle)) == "compact"
    local data = {
        Style = if compact then "Compact" else "Classic",
        Title = if info.Title ~= nil then tostring(info.Title) else nil,
        Description = tostring(info.Description or info.Text or ""),
        TitleColor = info.TitleColor, DescriptionColor = info.DescriptionColor,
        Time = if info.Time ~= nil then info.Time else 5,
        Persist = info.Persist == true, RichText = info.RichText ~= false or info.Segments ~= nil,
        Steps = if type(info.Steps) == "number" and info.Steps > 0 then info.Steps else nil,
        Callback = if type(info.Callback) == "function" then info.Callback else nil,
        Closable = info.Closable == true, Icon = info.Icon, BigIcon = info.BigIcon, IconColor = info.IconColor,
        SoundId = info.SoundId, Volume = tonumber(info.Volume) or 3,
        Destroyed = false, Disposed = false, Ready = false, LayoutRevision = 0,
        Tasks = {}, Tweens = {}, Connections = {},
    }
    local frame = New("Frame", {
        AnchorPoint = Vector2.new(if string.lower(Library.NotifySide) == "left" then 0 else 1, 0),
        BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0), Visible = false, Parent = NotificationArea,
    })
    local holder = New("CanvasGroup", {
        BackgroundColor3 = "MainColor", BackgroundTransparency = if compact then 0.08 else 0,
        BorderSizePixel = 0, GroupTransparency = 1, Size = UDim2.fromScale(1, 1),
        ZIndex = 201, Parent = frame,
    })
    local corner = New("UICorner", { CornerRadius = UDim.new(0, if compact then 14 else Library.CornerRadius), Parent = holder })
    local outline, shadow = Library:AddOutline(holder)
    if compact then outline.Transparency = 0.3; shadow.Transparency = 0.75 end
    local description = New("TextLabel", {
        BackgroundTransparency = 1, Text = "", TextColor3 = info.DescriptionColor or "FontColor",
        TextSize = if compact then 13 else 14, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, Parent = holder,
    })
    description.RichText = data.RichText
    local title
    if data.Title and not compact then
        title = New("TextLabel", {
            BackgroundTransparency = 1, Text = data.Title, TextColor3 = info.TitleColor or "FontColor", TextSize = 15,
            TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, Parent = holder,
        })
        title.RichText = data.RichText
    end
    local icon, iconSize
    local parsedIcon = if info.BigIcon or info.Icon then Library:GetCustomIcon(info.BigIcon or info.Icon) else nil
    if parsedIcon then
        iconSize = if compact then 14 elseif info.BigIcon then 24 else 16
        icon = New("ImageLabel", {
            BackgroundTransparency = 1, Size = UDim2.fromOffset(iconSize, iconSize),
            ImageColor3 = info.IconColor or (if info.BigIcon then "AccentColor" else "FontColor"), Parent = holder,
        })
        Library:ApplyLucideIcon(icon, parsedIcon)
    end
    local close
    if data.Closable then
        close = New("ImageButton", {
            Name = "Close", BackgroundTransparency = 1, Image = CloseIcon and CloseIcon.Url or "",
            ImageColor3 = "FontColor", ImageRectOffset = CloseIcon and CloseIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = CloseIcon and CloseIcon.ImageRectSize or Vector2.zero, ImageTransparency = 0.5,
            Size = UDim2.fromOffset(14, 14), Parent = holder,
        })
    end
    local showTimer = data.Steps ~= nil or (if info.ShowTimer ~= nil then info.ShowTimer == true else not compact and not data.Persist and typeof(data.Time) ~= "Instance")
    local timer = New("Frame", {
        BackgroundColor3 = "BackgroundColor", BorderSizePixel = 0, Size = UDim2.new(1, -24, 0, 2),
        Visible = showTimer, Parent = holder,
    })
    local fill = New("Frame", {
        BackgroundColor3 = "AccentColor", BorderSizePixel = 0,
        Size = UDim2.fromScale(if data.Steps or typeof(data.Time) == "Instance" then 0 else 1, 1), Parent = timer,
    })
    data.Frame, data.Holder, data.Label, data.TimerFill = frame, holder, description, fill

    function data:CancelTween(key: string): ()
        local tween = self.Tweens[key]
        if not tween then return end
        self.Tweens[key] = nil
        tween:Cancel()
        tween:Destroy()
    end

    function data:Tween(key: string, object: Instance, tweenInfo: TweenInfo, properties: { [string]: any }): ()
        self:CancelTween(key)
        local tween = TweenService:Create(object, tweenInfo, properties)
        self.Tweens[key] = tween
        tween:Play()
    end

    function data:Connect(signal: RBXScriptSignal, callback: (...any) -> ()): ()
        table.insert(self.Connections, signal:Connect(function(...: any): ()
            setthreadidentity(8)
            callback(...)
        end))
    end

    function data:CancelTask(key: string): ()
        local thread = self.Tasks[key]
        self.Tasks[key] = nil
        if thread and thread ~= coroutine.running() and coroutine.status(thread) ~= "dead" then task.cancel(thread) end
    end

    function data:GetText(): string
        local text = if self.Segments then Library:FormatNotificationSegments(self.Segments) else self.Description
        if compact and self.Title then
            if not self.RichText then return self.Title .. "  " .. text end
            local heading = "<b>" .. Library:EscapeNotificationText(self.Title) .. "</b>"
            if self.TitleColor then heading = string.format('<font color="#%s">%s</font>', Library:GetNotificationColor(self.TitleColor):ToHex(), heading) end
            return heading .. "  " .. text
        end
        return text
    end

    function data:Resize(): ()
        setthreadidentity(8)
        if self.Destroyed then return end
        self.LayoutRevision += 1
        local revision = self.LayoutRevision
        local padding, vertical = if compact then 12 else 10, if compact then 6 else 8
        local iconWidth, closeWidth = if icon then iconSize + 8 else 0, if close then 22 else 0
        local maximum = math.max(1, math.min(tonumber(info.MaxWidth) or (if compact then Library.NotifyMaxWidth or 860 else 300), (ScreenGui.AbsoluteSize.X - 12) / Library.DPIScale))
        local available = math.max(1, maximum - padding * 2 - iconWidth - closeWidth)
        local text = self:GetText()
        local width, height = Library:GetTextBounds(if self.RichText then text else Library:EscapeNotificationText(text), description.FontFace, description.TextSize, available)
        local titleWidth, titleHeight = 0, 0
        if title then
            titleWidth, titleHeight = Library:GetTextBounds(if self.RichText then self.Title else Library:EscapeNotificationText(self.Title), title.FontFace, title.TextSize, available)
        end
        -- Text measurement can yield while a notification is closed or resized again.
        if self.Destroyed or revision ~= self.LayoutRevision then return end
        width, height, titleWidth, titleHeight = math.ceil(width), math.ceil(height), math.ceil(titleWidth), math.ceil(titleHeight)
        local textWidth = math.min(available, math.max(1, width, titleWidth))
        local contentHeight = math.max(height + (if title then titleHeight + 4 else 0), iconSize or 0)
        local totalHeight = math.max(if compact then 28 else 32, contentHeight + vertical * 2 + (if showTimer then 5 else 0))
        local totalWidth = math.min(maximum, math.max(28, textWidth + padding * 2 + iconWidth + closeWidth))
        description.Text = text
        description.Size = UDim2.fromOffset(textWidth, height)
        description.Position = UDim2.fromOffset(padding + iconWidth, vertical + (if title then titleHeight + 4 else math.max(0, (contentHeight - height) / 2)))
        if title then
            title.Text = self.Title
            title.Position = UDim2.fromOffset(padding + iconWidth, vertical)
            title.Size = UDim2.fromOffset(textWidth, titleHeight)
        end
        if icon then icon.Position = UDim2.fromOffset(padding, vertical + (contentHeight - iconSize) / 2) end
        if close then close.Position = UDim2.fromOffset(totalWidth - padding - 14, vertical + math.max(0, (contentHeight - 14) / 2)) end
        timer.Position = UDim2.fromOffset(padding, totalHeight - (if compact then 3 else 6))
        timer.Size = UDim2.fromOffset(math.max(1, totalWidth - padding * 2), 2)
        corner.CornerRadius = UDim.new(0, if compact then math.min(totalHeight / 2, 16) else Library.CornerRadius)
        frame.Size = UDim2.fromOffset(totalWidth, totalHeight)
        if self.Ready then Library:UpdateNotificationPositions() end
    end

    function data:ChangeTitle(text: any): ()
        setthreadidentity(8)
        if self.Destroyed then return end
        self.Title = tostring(text)
        self:Resize()
    end

    function data:ChangeDescription(text: any): ()
        setthreadidentity(8)
        if self.Destroyed then return end
        self.Segments = nil
        if type(text) == "table" then
            self.Segments = table.create(#text)
            for _, segment in text do table.insert(self.Segments, if type(segment) == "table" then table.clone(segment) else segment) end
            self.RichText, description.RichText = true, true
        else
            self.Description = tostring(text)
        end
        self:Resize()
    end

    function data:ChangeStep(_step: number?): ()
        setthreadidentity(8)
        if not self.Destroyed and self.Steps then fill.Size = UDim2.fromScale(math.clamp(_step or 0, 0, self.Steps) / self.Steps, 1) end
    end

    function data:Dispose(): ()
        setthreadidentity(8)
        if self.Disposed then return end
        self.Disposed = true
        for key in self.Tasks do self:CancelTask(key) end
        for key in self.Tweens do self:CancelTween(key) end
        for _, connection in self.Connections do connection:Disconnect() end
        table.clear(self.Connections)
        Library.Notifications[frame] = nil
        for _, descendant in frame:GetDescendants() do Library:RemoveFromRegistry(descendant) end
        Library:RemoveFromRegistry(frame)
        frame:Destroy()
    end

    function data:Destroy(_reason: string?, _immediate: boolean?): ()
        setthreadidentity(8)
        if self.Destroyed then
            if _immediate then self:Dispose() end
            return
        end
        self.Destroyed = true
        for key in self.Tasks do self:CancelTask(key) end
        for key in self.Tweens do self:CancelTween(key) end
        for _, connection in self.Connections do connection:Disconnect() end
        table.clear(self.Connections)
        local index = table.find(NotifyOrder, frame)
        if index then table.remove(NotifyOrder, index) end
        if typeof(self.Time) == "Instance" then pcall(self.Time.Destroy, self.Time) end
        Library:UpdateNotificationPositions()
        if _immediate or Library.Unloaded or not self.Ready then
            self:Dispose()
        else
            self:Tween("Exit", holder, Library.NotifyTweenInfo, {
                GroupTransparency = 1, Position = UDim2.fromOffset(if string.lower(Library.NotifySide) == "left" then -14 else 14, -3),
            })
            self.Tasks.Dispose = task.delay(Library.NotifyTweenInfo.Time, function(): () self:Dispose() end)
        end
        if self.Callback then
            local success, message = pcall(self.Callback, _reason or "script")
            if not success then warn("[Obsidian notification] " .. tostring(message)) end
        end
    end

    Library.Registry[description] = Library.Registry[description] or {}
    Library.Registry[description].Text = function(): string return data:GetText() end
    data:Connect(description:GetPropertyChangedSignal("FontFace"), function(): () data:Resize() end)
    if title then data:Connect(title:GetPropertyChangedSignal("FontFace"), function(): () data:Resize() end) end
    if close then
        data:Connect(close.MouseEnter, function(): () data:Tween("Close", close, Library.TweenInfo, { ImageTransparency = 0 }) end)
        data:Connect(close.MouseLeave, function(): () data:Tween("Close", close, Library.TweenInfo, { ImageTransparency = 0.5 }) end)
        data:Connect(close.Activated, function(): () data:Destroy("user") end)
    end
    if typeof(data.Time) == "Instance" then
        data:Connect(data.Time.Destroying, function(): ()
            data.TimeEnded = true
            if data.Ready and not data.Persist then data:Destroy("timer") end
        end)
    end
    Library.Notifications[frame] = data
    table.insert(NotifyOrder, frame)
    if compact then
        local count = 0
        for _, candidate in NotifyOrder do if Library.Notifications[candidate].Style == "Compact" then count += 1 end end
        local limit = math.max(1, math.floor(tonumber(Library.NotifyLimit) or 8))
        for _, candidate in table.clone(NotifyOrder) do
            if count <= limit then break end
            local notification = Library.Notifications[candidate]
            if notification and notification.Style == "Compact" then notification:Destroy("limit"); count -= 1 end
        end
    end
    if info.Segments then data:ChangeDescription(info.Segments) else data:Resize() end
    if data.Destroyed then return data end
    if Library.Unloaded then data:Destroy("unload", true); return data end
    if data.TimeEnded and not data.Persist then data:Destroy("timer", true); return data end
    data.Ready, frame.Visible = true, true
    holder.Position = UDim2.fromOffset(if string.lower(Library.NotifySide) == "left" then -14 else 14, 3)
    data:Tween("Enter", holder, Library.NotifyTweenInfo, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 })
    Library:UpdateNotificationPositions()
    if not data.Persist and typeof(data.Time) ~= "Instance" then
        data.Tasks.Enter = task.delay(Library.NotifyTweenInfo.Time, function(): ()
            setthreadidentity(8)
            data.Tasks.Enter = nil
            if data.Destroyed then return end
            local duration = math.max(0, tonumber(data.Time) or 5)
            if showTimer and not data.Steps then
                data:Tween("Timer", fill, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), { Size = UDim2.fromScale(0, 1) })
            end
            data.Tasks.Expiry = task.delay(duration, function(): () data:Destroy("timer") end)
        end)
    end
    if data.SoundId then
        New("Sound", {
            SoundId = if typeof(data.SoundId) == "number" then string.format("rbxassetid://%d", data.SoundId) else data.SoundId,
            Volume = data.Volume, PlayOnRemove = true, Parent = SoundService,
        }):Destroy()
    end
    return data
end


function Library:CreateWindow(WindowInfo)
    setthreadidentity(8)
    WindowInfo = Library:Validate(WindowInfo, Templates.Window)
    local ViewportSize: Vector2 = workspace.CurrentCamera.ViewportSize
    if RunService:IsStudio() and ViewportSize.X <= 5 and ViewportSize.Y <= 5 then
        repeat
            ViewportSize = workspace.CurrentCamera.ViewportSize
            task.wait()
        until ViewportSize.X > 5 and ViewportSize.Y > 5
    end

    local MaxX = ViewportSize.X - 64
    local MaxY = ViewportSize.Y - 64

    Library.OriginalMinSize =
        Vector2.new(math.min(Library.OriginalMinSize.X, MaxX), math.min(Library.OriginalMinSize.Y, MaxY))
    Library.MinSize = Vector2.new(math.min(WindowInfo.MinContainerWidth, MaxX), Library.OriginalMinSize.Y)

    WindowInfo.Size = UDim2.fromOffset(
        math.clamp(WindowInfo.Size.X.Offset, Library.MinSize.X, MaxX),
        math.clamp(WindowInfo.Size.Y.Offset, Library.MinSize.Y, MaxY)
    )
    if typeof(WindowInfo.Font) == "EnumItem" then
        WindowInfo.Font = Font.fromEnum(WindowInfo.Font :: any)
    end
    WindowInfo.CornerRadius = math.min(WindowInfo.CornerRadius, 20)

    --// Old Naming \\--
    if WindowInfo.Compact ~= nil then
        WindowInfo.SidebarCompacted = WindowInfo.Compact
    end
    if WindowInfo.SidebarMinWidth ~= nil then
        WindowInfo.MinSidebarWidth = WindowInfo.SidebarMinWidth
    end
    WindowInfo.MinSidebarWidth = math.max(64, WindowInfo.MinSidebarWidth)
    WindowInfo.SidebarCompactWidth = math.max(48, WindowInfo.SidebarCompactWidth)
    WindowInfo.SidebarCollapseThreshold = math.clamp(WindowInfo.SidebarCollapseThreshold, 0.1, 0.9)
    WindowInfo.CompactWidthActivation = math.max(48, WindowInfo.CompactWidthActivation)
    WindowInfo.SnapDistance = math.max(0, WindowInfo.SnapDistance)
    WindowInfo.SnapMargin = math.max(0, WindowInfo.SnapMargin)

    Library.CornerRadius = WindowInfo.CornerRadius
    Library.NotifyStyle = WindowInfo.NotifyStyle
    Library.NotifyLimit = WindowInfo.NotifyLimit
    Library:SetNotifySide(WindowInfo.NotifySide)
    Library.ShowCustomCursor = WindowInfo.ShowCustomCursor
    Library.Scheme.Font = WindowInfo.Font
    Library.ToggleKeybind = WindowInfo.ToggleKeybind
    Library.GlobalSearch = WindowInfo.GlobalSearch
    Library.AnonymousMode = WindowInfo.AnonymousMode == true
    Library.Flags.AnonymousMode = Library.AnonymousMode

    Library.Animations = WindowInfo.Animations
    Library.TabTransitionInfo = TweenInfo.new(
        math.max(0, WindowInfo.TabTransitionTime or 0.22),
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    Library.TabSwipeOffset = math.max(1, WindowInfo.TabSwipeOffset or 26)
    Library.TabSwipeFrom = WindowInfo.TabSwipeFrom or "right"

    local IsDefaultSearchbarSize = WindowInfo.SearchbarSize == UDim2.fromScale(1, 1)
    local MainFrame
    local DividerLine
    local TitleHolder
    local WindowTitle
    local WindowIcon
    local RightWrapper
    local SearchBox
    local CurrentTabInfo
    local CurrentTabLabel
    local CurrentTabDescription
    local ResizeButton
    local Tabs
    local Container
    local BackgroundImage
    local HasBackgroundImage = false
    local BottomBackground
    local FooterLabel
    local TopBar
    local KeyStatusComponent
    local UpdateKeyStatusLayout = function()
        setthreadidentity(8)
    end
    local WindowSnapConfig = {
        Enabled = WindowInfo.Snapping,
        Distance = WindowInfo.SnapDistance,
        Margin = WindowInfo.SnapMargin,
        AvoidCoreGui = WindowInfo.SnapAvoidCoreGui,
    }

    local InitialLeftWidth = math.ceil(WindowInfo.Size.X.Offset * 0.3)
    local IsCompact = WindowInfo.SidebarCompacted
    local LastExpandedWidth = InitialLeftWidth

    do
        Library.KeybindFrame, Library.KeybindContainer = Library:AddDraggableMenu("Keybinds")
        Library.KeybindFrame.AnchorPoint = Vector2.new(0, 0.5)
        Library.KeybindFrame.Position = UDim2.new(0, 6, 0.5, 0)
        Library.KeybindFrame.Visible = false

        MainFrame = New("TextButton", {
            BackgroundColor3 = function()
                setthreadidentity(8)
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
            end,
            Name = "Main",
            Text = "",
            Position = WindowInfo.Position,
            Size = WindowInfo.Size,
            Visible = false,
            Parent = ScreenGui,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = MainFrame,
            })
        )
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = MainFrame,
            })
        )
        Library:AddOutline(MainFrame)
        Library:MakeLine(MainFrame, {
            Position = UDim2.fromOffset(0, 48),
            Size = UDim2.new(1, 0, 0, 1),
        })

        DividerLine = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            Position = UDim2.fromOffset(InitialLeftWidth, 0),
            Size = UDim2.new(0, 1, 1, -21),
            Parent = MainFrame,
            ZIndex = 2
        })

        local BackgroundIcon = Library:GetCustomIcon(WindowInfo.BackgroundImage)
        HasBackgroundImage = BackgroundIcon ~= nil
        BackgroundImage = New("ImageLabel", {
            Active = false,
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromScale(1, 1),
            ScaleType = Enum.ScaleType.Stretch,
            ZIndex = Overlay.ZIndex + 1,
            BackgroundTransparency = 1,
            ImageTransparency = 0.75,
            Visible = false,
            Parent = ScreenGui,
        })
        if BackgroundIcon then
            Library:ApplyLucideIcon(BackgroundImage, BackgroundIcon)
        end

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = BackgroundImage,
            })
        )

        Library:GiveSignal(RunService.RenderStepped:Connect(function()
            setthreadidentity(8)
            if not (BackgroundImage and MainFrame) then
                return
            end

            local ShouldShow = HasBackgroundImage and MainFrame.Visible
            BackgroundImage.Visible = ShouldShow

            if not ShouldShow then
                return
            end

            BackgroundImage.Position = UDim2.fromOffset(
                MainFrame.AbsolutePosition.X,
                MainFrame.AbsolutePosition.Y
            )
            BackgroundImage.Size = UDim2.fromOffset(
                MainFrame.AbsoluteSize.X,
                MainFrame.AbsoluteSize.Y
            )
        end))

        if WindowInfo.Center then
            MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset / 2, 0.5, -MainFrame.Size.Y.Offset / 2)
        end

        --// Top Bar \\-
        TopBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            Parent = MainFrame,
        })
        Library:MakeDraggable(MainFrame, TopBar, false, true, WindowSnapConfig)

        --// Title \\--
        TitleHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, InitialLeftWidth, 1, 0),
            Parent = TopBar,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = TitleHolder,
        })

        if WindowInfo.Icon then
            local Icon = Library:GetCustomIcon(WindowInfo.Icon)
            WindowIcon = New("ImageLabel", {
                Size = WindowInfo.IconSize,
                Parent = TitleHolder,
            })
            if Icon then
                Library:ApplyLucideIcon(WindowIcon, Icon)
            end
        else
            WindowIcon = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = WindowInfo.IconSize,
                Text = WindowInfo.Title:sub(1, 1),
                TextScaled = true,
                Visible = false,
                Parent = TitleHolder,
            })
        end

        local X = Library:GetTextBounds(
            WindowInfo.Title,
            Library.Scheme.Font,
            20,
            TitleHolder.AbsoluteSize.X - (WindowInfo.Icon and WindowInfo.IconSize.X.Offset + 6 or 0) - 12
        )
        WindowTitle = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, X, 1, 0),
            Text = WindowInfo.Title,
            TextSize = 20,
            Parent = TitleHolder,
        })

        --// Top Right Bar \\--
        RightWrapper = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -49, 0.5, 0),
            Size = UDim2.new(1, -InitialLeftWidth - 57 - 1, 1, -16),
            Parent = TopBar,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = RightWrapper,
        })

        CurrentTabInfo = New("Frame", {
            Size = UDim2.fromScale(WindowInfo.DisableSearch and 1 or 0.5, 1),
            Visible = false,
            BackgroundTransparency = 1,
            Parent = RightWrapper,
        })

        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Grow,
            Parent = CurrentTabInfo,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = CurrentTabInfo,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = CurrentTabInfo,
        })

        CurrentTabLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = CurrentTabInfo,
        })

        CurrentTabDescription = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextWrapped = true,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.5,
            Parent = CurrentTabInfo,
        })

        SearchBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            PlaceholderText = "Search",
            Size = WindowInfo.SearchbarSize,
            TextScaled = true,
            Visible = not (WindowInfo.DisableSearch or false),
            Parent = RightWrapper,
        })
        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Shrink,
            Parent = SearchBox,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = SearchBox,
            })
        )
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = SearchBox,
        })
        local SearchBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = SearchBox,
        })

        Library:GiveSignal(SearchBox.Focused:Connect(function()
            setthreadidentity(8)
            Library.Registry[SearchBoxStroke].Color = "AccentColor"
            TweenService:Create(SearchBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        Library:GiveSignal(SearchBox.FocusLost:Connect(function()
            setthreadidentity(8)
            Library.Registry[SearchBoxStroke].Color = "OutlineColor"
            TweenService:Create(SearchBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()
        end))

        local SearchIcon = Library:GetIcon("search")
        if SearchIcon then
            local SearchIconImage = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = SearchBox,
            })
            Library:ApplyLucideIcon(SearchIconImage, SearchIcon)
        end

        if MoveIcon then
            local MoveIconImage = New("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                ImageColor3 = "OutlineColor",
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.fromOffset(28, 28),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = TopBar,
            })
            Library:ApplyLucideIcon(MoveIconImage, MoveIcon)
        end

        --// Bottom Bar \\--
        BottomBackground = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = function()
                setthreadidentity(8)
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20 + WindowInfo.CornerRadius),
            Parent = MainFrame
        })
        Library:MakeLine(MainFrame, {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -20),
            Size = UDim2.new(1, 0, 0, 1),
        })

        local BottomBar = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            Parent = MainFrame,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = BottomBackground,
            })
        )

        --// Footer \\-
        FooterLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = WindowInfo.Footer,
            TextSize = 14,
            TextTransparency = 0.5,
            Parent = BottomBar,
        })

        --// Resize Button \\--
        if WindowInfo.Resizable then
            ResizeButton = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -WindowInfo.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = BottomBar,
            })

            Library:MakeResizable(MainFrame, ResizeButton, function()
                setthreadidentity(8)
                for _, Tab in Library.Tabs do
                    Tab:Resize(true)
                end
            end)
        end

        local WindowResizeIcon = New("ImageLabel", {
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = ResizeButton,
        })
        if ResizeIcon then
            Library:ApplyLucideIcon(WindowResizeIcon, ResizeIcon)
        end

        --// Tabs \\--
        Tabs = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            CanvasSize = UDim2.fromScale(0, 0),
            Position = UDim2.fromOffset(0, 49),
            ScrollBarThickness = 0,
            Size = UDim2.new(0, InitialLeftWidth, 1, -70),
            Parent = MainFrame,
        })
        New("UIListLayout", {
            Parent = Tabs,
        })

        --// Container \\--
        Container = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = function()
                setthreadidentity(8)
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 1)
            end,
            ClipsDescendants = true,
            Name = "Container",
            Position = UDim2.new(1, 0, 0, 49),
            Size = UDim2.new(1, -InitialLeftWidth - 1, 1, -70),
            Parent = MainFrame,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 0),
            Parent = Container,
        })

        Library.WindowContainer = Container
    end

    --// Window Table \\--
    local Window = {}
    local Fading = false

    local function SetUICorner(UICorner, Corner, HalfValue)
        setthreadidentity(8)
        local Current = UICorner[Corner]
        if Current.Offset == 0 and Current.Scale == 0 then
            return
        end

        UICorner[Corner] = HalfValue
    end

    function Window:ChangeTitle(title)
        setthreadidentity(8)
        assert(typeof(title) == "string", "Expected string for title got: " .. typeof(title))

        WindowTitle.Text = title
        WindowInfo.Title = title
    end

    function Window:SetBackgroundImage(Image: string)
        setthreadidentity(8)
        local ValidIcon = false

        if typeof(Image) == "string" then
            local BackgroundIcon = Library:GetCustomIcon(Image)

            if BackgroundIcon then
                ValidIcon = true

                Library:ApplyLucideIcon(BackgroundImage, BackgroundIcon)
            elseif Image:match("http://") or Image:match("https://") then
                local RawFileName = Image:match("(.+)%..+$")
                local _, Domain = Image:match("^(https?://)([^/]+)");

                if RawFileName and Domain then
                    local Extention = string.sub(Image, #RawFileName + 1, #Image)
                    local FileNamePos = RawFileName:gsub("\\", "/"):find("/[^/]*$")
                    local FileName = FileNamePos and Image:sub(FileNamePos + 1) or nil

                    if FileName then
                        ValidIcon = true

                        local AssetName = Domain .. FileName
                        if #AssetName > 255 then
                            local NewLength = 255 - #Domain - #Extention
                            if NewLength < 0 then
                                AssetName = Domain .. Extention
                            else
                                AssetName = Domain .. string.sub(FileName:sub(1, #FileName - #Extention), 1, NewLength) .. Extention
                            end
                        end

                        if CustomImageManagerAssets[FileName] == nil then
                            CustomImageManager.AddAsset(FileName, 0, Image)
                        else
                            CustomImageManager.DownloadAsset(FileName, true)
                        end

                        BackgroundImage.Image = CustomImageManager.GetAsset(FileName)
                        BackgroundImage.ImageRectOffset = Vector2.zero
                        BackgroundImage.ImageRectSize = Vector2.zero
                    end
                end
            end
        end

        if not ValidIcon then
            BackgroundImage.Image = ""
            BackgroundImage.ImageRectOffset = Vector2.zero
            BackgroundImage.ImageRectSize = Vector2.zero
        end

        HasBackgroundImage = ValidIcon
        WindowInfo.BackgroundImage = Image
    end

    function Window:SetFooter(Footer: string)
        setthreadidentity(8)
        assert(typeof(Footer) == "string", "Expected string for footer got: " .. typeof(Footer))

        FooterLabel.Text = Footer
        WindowInfo.Footer = Footer
    end

    function Window:AddKeyStatus(Info: { [string]: any }?): { [string]: any }?
        setthreadidentity(8)
        assert(Info == nil or typeof(Info) == "table", "Expected table for key status got: " .. typeof(Info))

        if KeyStatusComponent and not KeyStatusComponent.Destroyed then
            KeyStatusComponent:SetData(Info or {})
            if Info and Info.SettingsGroupbox then
                Window:AddKeyStatusSettings(Info.SettingsGroupbox, Info.SettingsToggleIndex)
            end
            return KeyStatusComponent
        end

        local ResolvedInfo = Info or {}
        if ResolvedInfo.Provider == nil or string.lower(tostring(ResolvedInfo.Provider)) == "luarmor" then
            ResolvedInfo = Library:GetLuarmorKeyStatus(ResolvedInfo)
        end

        local Data = Library:Validate(ResolvedInfo, Templates.KeyStatus)
        if not Data.Enabled then
            return nil
        end

        local Height = 112
        local RemainingTimeSetAt = os.clock()
        local BaseRemainingTime = Data.RemainingTime
        local LastRemainingSecond = -1
        local RefreshConnection: RBXScriptConnection?

        local Card = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.new(0, 8, 1, -28),
            Size = UDim2.new(0, math.max(Tabs.Size.X.Offset - 16, 0), 0, Height),
            Parent = MainFrame,
        })
        table.insert(Library.Corners, New("UICorner", {
            CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
            Parent = Card,
        }))
        Library:AddOutline(Card)

        local Avatar = New("ImageLabel", {
            BackgroundColor3 = "BackgroundColor",
            Image = "",
            Position = UDim2.fromOffset(10, 10),
            Size = UDim2.fromOffset(42, 42),
            Parent = Card,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Avatar,
        })
        local AvatarStroke = New("UIStroke", {
            Color = Data.StatusColors.Freemium,
            Thickness = 1,
            Parent = Avatar,
        })

        local DisplayNameLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(60, 8),
            Size = UDim2.new(1, -70, 0, 19),
            Text = "",
            TextSize = 14,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Card,
        })
        local UsernameLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(60, 27),
            Size = UDim2.new(1, -70, 0, 16),
            Text = "",
            TextSize = 12,
            TextTransparency = 0.5,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Card,
        })
        local StatusDot = New("Frame", {
            BackgroundColor3 = Data.StatusColors.Freemium,
            Position = UDim2.fromOffset(60, 46),
            Size = UDim2.fromOffset(6, 6),
            Parent = Card,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = StatusDot,
        })
        local StatusLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(71, 41),
            Size = UDim2.new(1, -81, 0, 16),
            Text = "",
            TextSize = 12,
            TextTransparency = 0.25,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Card,
        })

        New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 67),
            Size = UDim2.new(0.5, -10, 0, 16),
            Text = tostring(Data.DurationLabel),
            TextSize = 12,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Card,
        })
        local RemainingLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 67),
            Size = UDim2.new(0.5, -10, 0, 16),
            Text = "",
            TextSize = 12,
            TextTransparency = 0.25,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = Card,
        })

        local ProgressBackground = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.fromOffset(10, 91),
            Size = UDim2.new(1, -20, 0, 7),
            Parent = Card,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = ProgressBackground,
        })
        local ProgressFill = New("Frame", {
            BackgroundColor3 = Data.StatusColors.Freemium,
            Size = UDim2.fromScale(1, 1),
            Parent = ProgressBackground,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = ProgressFill,
        })

        local Component = {
            Type = "KeyStatus",
            Data = Data,
            Container = Card,
            Destroyed = false,
            Visible = true,
        }

        local function FormatRemainingTime(Seconds: number): string
            setthreadidentity(8)
            if Seconds == math.huge then
                return Data.LifetimeText or "Lifetime"
            end

            Seconds = math.max(0, math.floor(Seconds))
            local Days = Seconds // 86400
            local Hours = (Seconds % 86400) // 3600
            local Minutes = (Seconds % 3600) // 60
            local RemainingSeconds = Seconds % 60

            if Days > 0 then
                return string.format("%dd %02dh", Days, Hours)
            elseif Hours > 0 then
                return string.format("%dh %02dm", Hours, Minutes)
            elseif Minutes > 0 then
                return string.format("%dm %02ds", Minutes, RemainingSeconds)
            end

            return string.format("%ds", RemainingSeconds)
        end

        function Component:GetRemainingTime(): number?
            setthreadidentity(8)
            if typeof(Data.GetRemainingTime) == "function" then
                local Success, RemainingTime = pcall(Data.GetRemainingTime, Data)
                if Success and typeof(RemainingTime) == "number" then
                    return RemainingTime
                elseif not Success then
                    warn(`[Obsidian] Key status time provider failed: {RemainingTime}`)
                end
            end

            if typeof(BaseRemainingTime) == "number" then
                if BaseRemainingTime == math.huge then
                    return math.huge
                end

                return math.max(0, BaseRemainingTime - (os.clock() - RemainingTimeSetAt))
            end

            return nil
        end

        function Component:ApplyAnonymousMode(State: boolean)
            setthreadidentity(8)
            assert(typeof(State) == "boolean", "Anonymous mode must be a boolean")

            Data.Anonymous = State
            Avatar.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", State and 0 or Data.UserId)
            DisplayNameLabel.Text = State and "********" or tostring(Data.DisplayName)
            UsernameLabel.Text = State and "@********" or `@{Data.Username}`
        end

        function Component:Refresh(Force: boolean?)
            setthreadidentity(8)
            if Component.Destroyed then
                return
            end

            local RemainingTime = Component:GetRemainingTime()
            local RemainingSecond = if typeof(RemainingTime) == "number" then math.floor(RemainingTime) else -1
            if not Force and RemainingSecond == LastRemainingSecond then
                return
            end
            LastRemainingSecond = RemainingSecond

            local Status = tostring(Data.Status)
            local Expired = typeof(RemainingTime) == "number" and RemainingTime ~= math.huge and RemainingTime <= 0
            local StatusColor = if Expired then Data.StatusColors.Expired else Data.StatusColors[Status] or Library.Scheme.AccentColor
            local Lifetime = Data.Lifetime
            local Progress = 1

            if typeof(RemainingTime) == "number" then
                if RemainingTime == math.huge then
                    RemainingLabel.Text = Data.LifetimeText or "Lifetime"
                elseif Expired then
                    RemainingLabel.Text = "Expired"
                    Progress = 0
                else
                    RemainingLabel.Text = FormatRemainingTime(RemainingTime)
                    if typeof(Lifetime) == "number" and Lifetime > 0 and Lifetime ~= math.huge then
                        Progress = math.clamp(RemainingTime / Lifetime, 0, 1)
                    end
                end
            else
                RemainingLabel.Text = Data.LifetimeText
                    or (if Status == "Developer" or Status == "Premium" then "Expiration unavailable" else "No active key")
            end

            StatusLabel.Text = Expired and "Expired" or Status
            StatusLabel.TextColor3 = StatusColor
            StatusDot.BackgroundColor3 = StatusColor
            AvatarStroke.Color = StatusColor
            ProgressFill.BackgroundColor3 = StatusColor
            ProgressFill.Size = UDim2.fromScale(Progress, 1)
            Component:ApplyAnonymousMode(Library:GetAnonymousMode())
        end

        function Component:SetStatus(Status: string)
            setthreadidentity(8)
            assert(typeof(Status) == "string", "Key status must be a string")
            Data.Status = Status
            Component:Refresh(true)
        end

        function Component:SetRemainingTime(RemainingTime: number?, _Lifetime: number?)
            setthreadidentity(8)
            assert(RemainingTime == nil or typeof(RemainingTime) == "number", "Remaining time must be a number or nil")
            local Lifetime = _Lifetime
            assert(Lifetime == nil or typeof(Lifetime) == "number", "Lifetime must be a number or nil")

            BaseRemainingTime = RemainingTime
            Data.RemainingTime = RemainingTime
            Data.Lifetime = Lifetime or RemainingTime
            RemainingTimeSetAt = os.clock()
            Component:Refresh(true)
        end

        function Component:SetData(NewInfo: { [string]: any })
            setthreadidentity(8)
            assert(typeof(NewInfo) == "table", "Expected table for key status data")

            local UpdatedInfo = NewInfo
            if UpdatedInfo.Provider == nil or string.lower(tostring(UpdatedInfo.Provider)) == "luarmor" then
                UpdatedInfo = Library:GetLuarmorKeyStatus(UpdatedInfo)
            end

            for Key, Value in UpdatedInfo do
                if Key == "StatusColors" and typeof(Value) == "table" then
                    for Status, Color in Value do
                        Data.StatusColors[Status] = Color
                    end
                else
                    Data[Key] = Value
                end
            end

            BaseRemainingTime = Data.RemainingTime
            Data.Lifetime = Data.Lifetime or BaseRemainingTime
            RemainingTimeSetAt = os.clock()
            Component.Visible = Data.Enabled ~= false
            Component:Refresh(true)
            UpdateKeyStatusLayout()
        end

        function Component:SetVisible(Visible: boolean)
            setthreadidentity(8)
            assert(typeof(Visible) == "boolean", "Key status visibility must be a boolean")
            Component.Visible = Visible
            UpdateKeyStatusLayout()
        end

        function Component:SetAnonymous(State: boolean)
            setthreadidentity(8)
            Library:SetAnonymousMode(State)
        end

        function Component:Destroy()
            setthreadidentity(8)
            if Component.Destroyed then
                return
            end

            Component.Destroyed = true
            Component.Visible = false
            UpdateKeyStatusLayout()
            if RefreshConnection and RefreshConnection.Connected then
                RefreshConnection:Disconnect()
            end
            local SignalIndex = table.find(Library.Signals, RefreshConnection)
            if SignalIndex then
                table.remove(Library.Signals, SignalIndex)
            end
            RefreshConnection = nil
            local ComponentIndex = table.find(Library.KeyStatusComponents, Component)
            if ComponentIndex then
                table.remove(Library.KeyStatusComponents, ComponentIndex)
            end
            Card:Destroy()
            KeyStatusComponent = nil
            UpdateKeyStatusLayout = function()
                setthreadidentity(8)
            end
        end

        KeyStatusComponent = Component
        table.insert(Library.KeyStatusComponents, Component)

        UpdateKeyStatusLayout = function()
            setthreadidentity(8)
            local Visible = not Component.Destroyed and Component.Visible and not IsCompact
            Card.Visible = Visible
            Card.Size = UDim2.new(0, math.max(Tabs.Size.X.Offset - 16, 0), 0, Height)
            Tabs.Size = UDim2.new(0, Tabs.Size.X.Offset, 1, Visible and -(70 + Height + 15) or -70)
        end

        if Data.Lifetime == nil and typeof(BaseRemainingTime) == "number" then
            Data.Lifetime = BaseRemainingTime
        end
        if Data.Anonymous then
            Library:SetAnonymousMode(true)
        end

        Component:Refresh(true)
        UpdateKeyStatusLayout()

        local RefreshElapsed = 0
        RefreshConnection = Library:GiveSignal(RunService.Heartbeat:Connect(function(DeltaTime: number)
            setthreadidentity(8)
            if Component.Destroyed then
                return
            end

            RefreshElapsed += DeltaTime
            if RefreshElapsed < 0.25 then
                return
            end

            RefreshElapsed = 0
            Component:Refresh()
        end)) :: RBXScriptConnection

        if Data.SettingsGroupbox then
            Window:AddKeyStatusSettings(Data.SettingsGroupbox, Data.SettingsToggleIndex)
        end

        return Component
    end

    function Window:SetKeyStatus(Info: { [string]: any }): { [string]: any }?
        setthreadidentity(8)
        return Window:AddKeyStatus(Info)
    end

    function Window:GetKeyStatus(): { [string]: any }?
        setthreadidentity(8)
        return KeyStatusComponent
    end

    function Window:SetAnonymousMode(State: boolean)
        setthreadidentity(8)
        Library:SetAnonymousMode(State)
    end

    function Window:AddKeyStatusSettings(Groupbox: { [string]: any }, _ToggleIndex: string?): { [string]: any }
        setthreadidentity(8)
        assert(typeof(Groupbox) == "table" and typeof(Groupbox.AddToggle) == "function", "Expected an Obsidian groupbox")
        local ToggleIndex = _ToggleIndex or "ObsidianAnonymousMode"
        assert(typeof(ToggleIndex) == "string", "Expected string for anonymous mode toggle index")

        local ExistingToggle = Toggles[ToggleIndex]
        if ExistingToggle then
            Library.AnonymousModeToggle = ExistingToggle
            return ExistingToggle
        end

        local Toggle = Groupbox:AddToggle(ToggleIndex, {
            Text = "Anonymous Mode",
            Default = Library:GetAnonymousMode(),
            Tooltip = "Hides your avatar, username and display name in the key status card.",
            Callback = function(Value: boolean)
                setthreadidentity(8)
                Library:SetAnonymousMode(Value)
            end,
        })
        Library.AnonymousModeToggle = Toggle
        return Toggle
    end

    function Window:RegisterCommand(Info: { [string]: any }): { [string]: any }
        setthreadidentity(8)
        assert(typeof(Info) == "table", "Command information must be a table")
        assert(typeof(Info.Name) == "string" and Info.Name ~= "", "Command name must be a non-empty string")
        assert(typeof(Info.Action) == "function", "Command action must be a function")

        local Id = tostring(Info.Id or Info.Name)
        for _, ExistingCommand in Library.Commands do
            if ExistingCommand.Id == Id and not ExistingCommand.Destroyed then
                ExistingCommand.Name = Info.Name
                ExistingCommand.Description = tostring(Info.Description or "")
                ExistingCommand.Keywords = Info.Keywords
                ExistingCommand.Action = Info.Action
                ExistingCommand.Badges = Library:GetFeatureBadges(Info)
                ExistingCommand.Element = Info.Element
                ExistingCommand.Visible = Info.Visible ~= false
                ExistingCommand.Disabled = Info.Disabled == true
                return ExistingCommand
            end
        end

        local Command = {
            Id = Id,
            Name = Info.Name,
            Description = tostring(Info.Description or ""),
            Keywords = Info.Keywords,
            Action = Info.Action,
            Badges = if Info.Badges then Library:GetFeatureBadges(Info) else {},
            Element = Info.Element,
            Visible = Info.Visible ~= false,
            Disabled = Info.Disabled == true,
            Destroyed = false,
        }

        function Command:SetVisible(Visible: boolean)
            setthreadidentity(8)
            assert(typeof(Visible) == "boolean", "Command visibility must be a boolean")
            Command.Visible = Visible
            if Library.CommandPalette and Library.CommandPalette.Visible then
                Library.CommandPalette:Refresh()
            end
        end

        function Command:SetDisabled(Disabled: boolean)
            setthreadidentity(8)
            assert(typeof(Disabled) == "boolean", "Command disabled state must be a boolean")
            Command.Disabled = Disabled
            if Library.CommandPalette and Library.CommandPalette.Visible then
                Library.CommandPalette:Refresh()
            end
        end

        function Command:Destroy()
            setthreadidentity(8)
            if Command.Destroyed then
                return
            end

            Command.Destroyed = true
            local Index = table.find(Library.Commands, Command)
            if Index then
                table.remove(Library.Commands, Index)
            end
            if Library.CommandPalette and Library.CommandPalette.Visible then
                Library.CommandPalette:Refresh()
            end
        end

        table.insert(Library.Commands, Command)
        if Library.CommandPalette and Library.CommandPalette.Visible then
            Library.CommandPalette:Refresh()
        end
        return Command
    end

    Window.AddCommand = Window.RegisterCommand

    function Window:RevealElement(Element: { [string]: any }, Groupbox: { [string]: any })
        setthreadidentity(8)
        if Element.Destroyed or Groupbox.Destroyed then
            return
        end

        local Tab = Groupbox.Tab
        if Tab and typeof(Tab.Show) == "function" then
            Tab:Show()
        end
        if Groupbox.SubTab and typeof(Groupbox.SubTab.Show) == "function" then
            Groupbox.SubTab:Show()
        end
        if Groupbox.Type == "TabboxTab" and typeof(Groupbox.Show) == "function" then
            Groupbox:Show()
        elseif Groupbox.Type == "Groupbox" and Groupbox.Collapsed then
            Groupbox:SetCollapsed(false)
        elseif Groupbox.Type == "List" and Groupbox.Collapsed then
            Groupbox:SetCollapsed(false)
        end

        task.defer(function()
            setthreadidentity(8)
            if Element.Destroyed or not Element.Holder or not Element.Holder.Parent or not Tab then
                return
            end

            local RevealHolder = Element.Holder
            if Groupbox.Type == "List" then
                local ListContainer = Groupbox.Container
                local ListOffset = Element.Holder.AbsolutePosition.Y
                    - ListContainer.AbsolutePosition.Y
                    + ListContainer.CanvasPosition.Y
                    - 7
                ListContainer.CanvasPosition = Vector2.new(ListContainer.CanvasPosition.X, math.max(0, ListOffset))
                RevealHolder = Groupbox.Holder
            end

            for _, Side in Tab.Sides or {} do
                if RevealHolder:IsDescendantOf(Side) then
                    local Offset = RevealHolder.AbsolutePosition.Y - Side.AbsolutePosition.Y + Side.CanvasPosition.Y - 12
                    Side.CanvasPosition = Vector2.new(Side.CanvasPosition.X, math.max(0, Offset))
                    break
                end
            end
        end)
    end

    function Window:CreateCommandPalette(): { [string]: any }?
        setthreadidentity(8)
        if WindowInfo.CommandPalette == false then
            return nil
        elseif Library.CommandPalette and not Library.CommandPalette.Destroyed then
            return Library.CommandPalette
        end

        local Overlay = New("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = "DarkColor",
            BackgroundTransparency = 0.35,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Visible = false,
            ZIndex = 100,
            Parent = MainFrame,
        })
        local Panel = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(0.76, 0, 0, 380),
            ZIndex = 101,
            Parent = Overlay,
        })
        New("UISizeConstraint", {
            MaxSize = Vector2.new(580, 380),
            MinSize = Vector2.new(340, 300),
            Parent = Panel,
        })
        table.insert(Library.Corners, New("UICorner", {
            CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
            Parent = Panel,
        }))
        Library:AddOutline(Panel)

        local Header = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 54),
            ZIndex = 102,
            Parent = Panel,
        })
        Library:MakeLine(Header, {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 102,
        })
        local SearchIcon = Library:GetCustomIcon("search")
        if SearchIcon then
            New("ImageLabel", {
                Image = SearchIcon.Url,
                ImageColor3 = "FontColor",
                ImageRectOffset = SearchIcon.ImageRectOffset,
                ImageRectSize = SearchIcon.ImageRectSize,
                ImageTransparency = 0.4,
                Position = UDim2.fromOffset(15, 15),
                Size = UDim2.fromOffset(24, 24),
                ZIndex = 103,
                Parent = Header,
            })
        end
        local QueryBox = New("TextBox", {
            BackgroundTransparency = 1,
            ClearTextOnFocus = false,
            PlaceholderText = "Search commands and features...",
            Position = UDim2.fromOffset(49, 0),
            Size = UDim2.new(1, -104, 1, 0),
            Text = "",
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 103,
            Parent = Header,
        })
        local ShortcutLabel = New("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = "MainColor",
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(42, 24),
            Text = "ESC",
            TextSize = 11,
            TextTransparency = 0.35,
            ZIndex = 103,
            Parent = Header,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = ShortcutLabel,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = ShortcutLabel,
        })

        local Results = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            CanvasSize = UDim2.fromScale(0, 0),
            Position = UDim2.fromOffset(0, 55),
            ScrollBarThickness = 2,
            Size = UDim2.new(1, 0, 1, -84),
            ZIndex = 102,
            Parent = Panel,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 3),
            Parent = Results,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = Results,
        })

        local EmptyLabel = New("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.55),
            Size = UDim2.new(1, -30, 0, 50),
            Text = "No matching commands",
            TextSize = 14,
            TextTransparency = 0.5,
            Visible = false,
            ZIndex = 103,
            Parent = Panel,
        })
        local Footer = New("TextLabel", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 29),
            Text = "↑↓ Navigate     Enter Run     Esc Close",
            TextSize = 11,
            TextTransparency = 0.5,
            ZIndex = 102,
            Parent = Panel,
        })
        table.insert(Library.Corners, New("UICorner", {
            CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
            Parent = Footer,
        }))

        local Palette = {
            Type = "CommandPalette",
            Container = Overlay,
            Panel = Panel,
            QueryBox = QueryBox,
            Results = Results,
            ResultButtons = {},
            FilteredCommands = {},
            SelectedIndex = 1,
            Visible = false,
            Destroyed = false,
        }

        local function GetCommandSearchText(Command: { [string]: any }): string
            setthreadidentity(8)
            local Keywords = Command.Keywords
            local KeywordText = ""
            if typeof(Keywords) == "string" then
                KeywordText = Keywords
            elseif typeof(Keywords) == "table" then
                KeywordText = table.concat(Keywords, " ")
            end
            return string.lower(`{Command.Name} {Command.Description} {KeywordText} {table.concat(Command.Badges or {}, " ")}`)
        end

        function Palette:Execute(Index: number?)
            setthreadidentity(8)
            local Command = Palette.FilteredCommands[Index or Palette.SelectedIndex]
            if not Command or Command.Disabled or Command.Destroyed then
                return
            end

            Palette:Close()
            task.defer(function()
                setthreadidentity(8)
                Library:SafeCallback(Command.Action, Command)
            end)
        end

        function Palette:SetSelected(Index: number)
            setthreadidentity(8)
            local Count = #Palette.FilteredCommands
            if Count == 0 then
                Palette.SelectedIndex = 0
                return
            end

            Palette.SelectedIndex = (Index - 1) % Count + 1
            for ButtonIndex, Button in Palette.ResultButtons do
                local Selected = ButtonIndex == Palette.SelectedIndex
                Button.BackgroundTransparency = Selected and 0 or 1
                Button.BackgroundColor3 = Selected and Library.Scheme.MainColor or Library.Scheme.BackgroundColor
                Library.Registry[Button].BackgroundColor3 = Selected and "MainColor" or "BackgroundColor"
            end

            local SelectedButton = Palette.ResultButtons[Palette.SelectedIndex]
            if SelectedButton then
                local Top = SelectedButton.AbsolutePosition.Y - Results.AbsolutePosition.Y + Results.CanvasPosition.Y
                local Bottom = Top + SelectedButton.AbsoluteSize.Y
                if Top < Results.CanvasPosition.Y then
                    Results.CanvasPosition = Vector2.new(0, Top)
                elseif Bottom > Results.CanvasPosition.Y + Results.AbsoluteSize.Y then
                    Results.CanvasPosition = Vector2.new(0, Bottom - Results.AbsoluteSize.Y)
                end
            end
        end

        function Palette:Refresh()
            setthreadidentity(8)
            if Palette.Destroyed then
                return
            end

            for _, Button in Palette.ResultButtons do
                Button:Destroy()
            end
            table.clear(Palette.ResultButtons)
            table.clear(Palette.FilteredCommands)

            local Query = string.lower(Trim(QueryBox.Text))
            local RankedCommands = {}

            for Index = #Library.Commands, 1, -1 do
                local Command = Library.Commands[Index]
                if Command.Destroyed or (Command.Element and Command.Element.Destroyed) then
                    table.remove(Library.Commands, Index)
                    continue
                elseif not Command.Visible then
                    continue
                end

                local SearchText = GetCommandSearchText(Command)
                local MatchPosition = if Query == "" then 1 else string.find(SearchText, Query, 1, true)
                if not MatchPosition then
                    continue
                end

                local Name = string.lower(Command.Name)
                local Score = if Query == "" then 3 elseif string.sub(Name, 1, #Query) == Query then 0 elseif string.find(Name, Query, 1, true) then 1 else 2
                table.insert(RankedCommands, { Command = Command, Score = Score, Order = Index })
            end

            table.sort(RankedCommands, function(First, Second)
                setthreadidentity(8)
                if First.Score ~= Second.Score then
                    return First.Score < Second.Score
                end
                return First.Order < Second.Order
            end)

            local MaximumResults = math.max(1, WindowInfo.CommandPaletteMaxResults)
            for Index = 1, math.min(#RankedCommands, MaximumResults) do
                local Command = RankedCommands[Index].Command
                table.insert(Palette.FilteredCommands, Command)

                local Button = New("TextButton", {
                    AutoButtonColor = false,
                    BackgroundColor3 = "BackgroundColor",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 48),
                    Text = "",
                    ZIndex = 103,
                    Parent = Results,
                })
                table.insert(Library.Corners, New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                }))
                local NameLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(12, 5),
                    Size = UDim2.new(1, -24, 0, 20),
                    Text = Library:FormatFeatureText(Command.Name, Command.Badges),
                    TextSize = 14,
                    TextTransparency = Command.Disabled and 0.65 or 0,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 104,
                    Parent = Button,
                })
                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(12, 25),
                    Size = UDim2.new(1, -24, 0, 17),
                    Text = Command.Description,
                    TextSize = 11,
                    TextTransparency = 0.55,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 104,
                    Parent = Button,
                })
                if Command.Disabled then
                    NameLabel.TextTransparency = 0.65
                end

                Library:GiveSignal(Button.MouseButton1Click:Connect(function()
                    setthreadidentity(8)
                    Palette:Execute(Index)
                end))
                Library:GiveSignal(Button.MouseEnter:Connect(function()
                    setthreadidentity(8)
                    Palette:SetSelected(Index)
                end))
                Palette.ResultButtons[Index] = Button
            end

            EmptyLabel.Visible = #Palette.FilteredCommands == 0
            Palette:SetSelected(math.clamp(Palette.SelectedIndex, 1, math.max(#Palette.FilteredCommands, 1)))
        end

        function Palette:Open()
            setthreadidentity(8)
            if Palette.Destroyed or Palette.Visible then
                return
            end

            if not Library.Toggled then
                Window:Toggle(true)
            end
            Palette.Visible = true
            Overlay.Visible = true
            QueryBox.Text = ""
            Palette.SelectedIndex = 1
            Palette:Refresh()
            task.defer(QueryBox.CaptureFocus, QueryBox)
        end

        function Palette:Close()
            setthreadidentity(8)
            if not Palette.Visible then
                return
            end

            Palette.Visible = false
            QueryBox:ReleaseFocus()
            Overlay.Visible = false
        end

        function Palette:Toggle()
            setthreadidentity(8)
            if Palette.Visible then
                Palette:Close()
            else
                Palette:Open()
            end
        end

        function Palette:Destroy()
            setthreadidentity(8)
            if Palette.Destroyed then
                return
            end
            Palette.Destroyed = true
            Overlay:Destroy()
            Library.CommandPalette = nil
        end

        Library:GiveSignal(QueryBox:GetPropertyChangedSignal("Text"):Connect(function()
            setthreadidentity(8)
            Palette.SelectedIndex = 1
            Palette:Refresh()
        end))
        Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject, Processed: boolean)
            setthreadidentity(8)
            if Library.Unloaded then
                return
            end

            if Palette.Visible then
                if Input.KeyCode == Enum.KeyCode.Escape then
                    Palette:Close()
                elseif Input.KeyCode == Enum.KeyCode.Up then
                    Palette:SetSelected(Palette.SelectedIndex - 1)
                elseif Input.KeyCode == Enum.KeyCode.Down then
                    Palette:SetSelected(Palette.SelectedIndex + 1)
                elseif Input.KeyCode == Enum.KeyCode.Return or Input.KeyCode == Enum.KeyCode.KeypadEnter then
                    Palette:Execute()
                end
                return
            end

            if Processed or Input.KeyCode ~= WindowInfo.CommandPaletteKeybind then
                return
            end

            local ControlPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
                or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            if not WindowInfo.CommandPaletteRequireControl or ControlPressed then
                Palette:Open()
            end
        end))
        Library:GiveSignal(Overlay.MouseButton1Click:Connect(function()
            setthreadidentity(8)
            local MousePosition = UserInputService:GetMouseLocation()
            local PanelPosition = Panel.AbsolutePosition
            local PanelSize = Panel.AbsoluteSize
            local InsidePanel = MousePosition.X >= PanelPosition.X
                and MousePosition.X <= PanelPosition.X + PanelSize.X
                and MousePosition.Y >= PanelPosition.Y
                and MousePosition.Y <= PanelPosition.Y + PanelSize.Y
            if not InsidePanel then
                Palette:Close()
            end
        end))

        Library.CommandPalette = Palette
        return Palette
    end

    function Window:OpenCommandPalette()
        setthreadidentity(8)
        local Palette = Window:CreateCommandPalette()
        if Palette then
            Palette:Open()
        end
    end

    function Window:CloseCommandPalette()
        setthreadidentity(8)
        if Library.CommandPalette then
            Library.CommandPalette:Close()
        end
    end

    function Window:SetAlwaysOnTop(Enabled: boolean)
        setthreadidentity(8)
        WindowInfo.AlwaysOnTop = Enabled == true
        SetAlwaysOnTop(Library.ScreenGui, WindowInfo.AlwaysOnTop)
    end

    function Window:SetSnapping(Enabled: boolean, Distance: number?, Margin: number?, AvoidCoreGui: boolean?)
        setthreadidentity(8)
        WindowInfo.Snapping = Enabled == true
        WindowSnapConfig.Enabled = WindowInfo.Snapping

        if Distance then
            WindowInfo.SnapDistance = math.max(0, Distance)
            WindowSnapConfig.Distance = WindowInfo.SnapDistance
        end

        if Margin then
            WindowInfo.SnapMargin = math.max(0, Margin)
            WindowSnapConfig.Margin = WindowInfo.SnapMargin
        end

        if AvoidCoreGui ~= nil then
            WindowInfo.SnapAvoidCoreGui = AvoidCoreGui == true
            WindowSnapConfig.AvoidCoreGui = WindowInfo.SnapAvoidCoreGui
        end
    end

    function Window:SetCornerRadius(Radius: number)
        setthreadidentity(8)
        assert(typeof(Radius) == "number", "Expected number for Radius got: " .. typeof(Radius))
        Radius = math.min(Radius, 20)

        local RadiusHalf = UDim.new(0, Radius / 2)
        local RadiusUDim = UDim.new(0, Radius)
        local HalfCurrent = Library.CornerRadius / 2

        for _, UICorner in Library.Corners do
            if math.abs(UICorner.CornerRadius.Offset - HalfCurrent) < 0.001 then
                UICorner.CornerRadius = RadiusHalf
            else
                UICorner.CornerRadius = RadiusUDim
            end
        end

        for _, UICorner in Library.SpecificCorners do
            SetUICorner(UICorner, "TopRightRadius", RadiusHalf)
            SetUICorner(UICorner, "TopLeftRadius", RadiusHalf)
            SetUICorner(UICorner, "BottomRightRadius", RadiusHalf)
            SetUICorner(UICorner, "BottomLeftRadius", RadiusHalf)
        end

        Library.CornerRadius = Radius
        WindowInfo.CornerRadius = Radius

        ResizeButton.Position = UDim2.new(1, -Radius / 4, 0, 0)
        BottomBackground.Size = UDim2.new(1, 0, 0, 20 + Radius)

        for _, Menu in Library.ContextMenus do
            if Menu.Destroyed then
                continue
            end

            if typeof(Menu.ActiveCallback) ~= "function" then
                continue
            end

            if not Menu.Active then
                local HolderActive = false
                for _, Other in Library.ContextMenus do
                    if Other == Menu then
                        continue
                    end

                    if Other.Active and Other.Holder == Menu.Holder then
                        HolderActive = true
                        break
                    end
                end

                if HolderActive then
                    continue
                end

                Menu.ActiveCallback(false)
                continue
            end

            Menu.ActiveCallback(true)
        end

        for _, Option in Options do
            if Option.Type == "Dropdown" and Option.RefreshPool then
                Option:RefreshPool()
            end
        end

        for _, Tab in Library.Tabs do
            if Tab.IsKeyTab then
                continue
            end

            for _, Tabbox in Tab.Tabboxes do
                Tabbox:UpdateCorners()
            end
            for _, SubTab in Tab.SubTabOrder or {} do
                SubTab:UpdateCorners()
            end
        end
    end

    function Window:SetAnimations(Animations: { [string]: boolean }?, TabTransitionTime: number?, TabSwipeOffset: number?, TabSwipeFrom: ("left" | "right" | "top" | "bottom" | string)?)
        setthreadidentity(8)
        if typeof(Animations) == "table" then
            WindowInfo.Animations = Animations
            Library.Animations = Animations
        end

        if typeof(TabTransitionTime) == "number" then
            local TweenInfo = TweenInfo.new(
                math.max(0, TabTransitionTime or 0.22),
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )

            WindowInfo.TabTransitionInfo = TweenInfo
            Library.TabTransitionInfo = TweenInfo
        end

        if typeof(TabSwipeOffset) == "number" then
            TabSwipeOffset = math.max(1, TabSwipeOffset)

            WindowInfo.TabSwipeOffset = TabSwipeOffset
            Library.TabSwipeOffset = TabSwipeOffset
        end

        if typeof(TabSwipeFrom) == "string" then
            TabSwipeFrom = string.lower(TabSwipeFrom)

            WindowInfo.TabSwipeFrom = TabSwipeFrom
            Library.TabSwipeFrom = TabSwipeFrom
        end
    end

    local function ApplyCompact()
        setthreadidentity(8)
        IsCompact = Window:GetSidebarWidth() == WindowInfo.SidebarCompactWidth
        if WindowInfo.DisableCompactingSnap then
            IsCompact = Window:GetSidebarWidth() <= WindowInfo.CompactWidthActivation
        end

        WindowTitle.Visible = not IsCompact
        if not WindowInfo.Icon then
            WindowIcon.Visible = IsCompact
        end

        for _, Button in Library.TabButtons do
            if not Button.Icon then
                continue
            end

            Button.Label.Visible = not IsCompact
            Button.Padding.PaddingBottom = UDim.new(0, IsCompact and 6 or 11)
            Button.Padding.PaddingLeft = UDim.new(0, IsCompact and 6 or 12)
            Button.Padding.PaddingRight = UDim.new(0, IsCompact and 6 or 12)
            Button.Padding.PaddingTop = UDim.new(0, IsCompact and 6 or 11)
            Button.Icon.SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY
        end

        UpdateKeyStatusLayout()
    end

    function Window:IsSidebarCompacted()
        setthreadidentity(8)
        return IsCompact
    end

    function Window:SetCompact(State)
        setthreadidentity(8)
        Window:SetSidebarWidth(State and WindowInfo.SidebarCompactWidth or LastExpandedWidth)
    end

    function Window:GetSidebarWidth()
        setthreadidentity(8)
        return Tabs.Size.X.Offset
    end

    function Window:SetSidebarWidth(Width)
        setthreadidentity(8)
        Width = math.clamp(Width, 48, MainFrame.Size.X.Offset - WindowInfo.MinContainerWidth - 1)

        DividerLine.Position = UDim2.fromOffset(Width, 0)

        TitleHolder.Size = UDim2.new(0, Width, 1, 0)
        RightWrapper.Size = UDim2.new(1, -Width - 57 - 1, 1, -16)
        Tabs.Size = UDim2.new(0, Width, 1, -70)
        Container.Size = UDim2.new(1, -Width - 1, 1, -70)
        UpdateKeyStatusLayout()

        if WindowInfo.EnableCompacting then
            ApplyCompact()
        end
        if not IsCompact then
            LastExpandedWidth = Width
        end
    end

    function Window:ShowTabInfo(Name, Description)
        setthreadidentity(8)
        CurrentTabLabel.Text = Name
        CurrentTabDescription.Text = Description

        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(0.5, 1)
        end
        CurrentTabInfo.Visible = true
    end

    function Window:HideTabInfo()
        setthreadidentity(8)
        CurrentTabInfo.Visible = false
        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(1, 1)
        end
    end

    function Window:AddTab(...)
        setthreadidentity(8)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
        else
            Name = select(1, ...)
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        local TabButton: TextButton
        local TabLabel
        local TabIcon

        local TabContainer
        local TabLeft
        local TabRight

        Icon = Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = TabButton,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = TabButton,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = TabButton,
                })
                Library:ApplyLucideIcon(TabIcon, Icon)
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            TabLeft = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = TabLeft,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabLeft,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabLeft,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabLeft,
                })
            end

            TabRight = New("ScrollingFrame", {
                AnchorPoint = Vector2.new(1, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromScale(1, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = TabRight,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabRight,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabRight,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabRight,
                })
            end
        end

        -- Sub Tabs
        local SubTabHolder = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            ClipsDescendants = true,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 0, 34),
            Visible = false,
            ZIndex = 3,
            Parent = TabContainer,
        })
        local SubTabHolderCorner = New("UICorner", {
            CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
            Parent = SubTabHolder,
        })
        table.insert(Library.Corners, SubTabHolderCorner)
        Library:AddOutline(SubTabHolder)

        local SubTabButtons = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = SubTabHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Parent = SubTabButtons,
        })

       --// Tab Table \\--
        local Tab = {
            Name = Name,
            Description = Description,

            Tooltip = Tooltip,
            TooltipTable = nil,

            Connections = {},
            Destroyed = false,

            Window = Window,
            Button = TabButton,
            Container = TabContainer,
            Canvas = TabCanvas,
            RootSides = {
                TabLeft,
                TabRight,
            },
            Sides = {
                TabLeft,
                TabRight,
            },
            SubTabs = {},
            SubTabOrder = {},
            ActiveSubTab = nil,
            SubTabHolder = SubTabHolder,
            WarningBox = {
                IsNormal = false,
                LockSize = false,
                Visible = false,
                Title = "WARNING",
                Text = "",
            },

            Groupboxes = {},
            Tabboxes = {},
            DependencyGroupboxes = {},
        }

        --// Warning Box \\--
        local WarningBoxHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 7),
            Size = UDim2.fromScale(1, 0),
            Visible = false,
            ZIndex = 3,
            Parent = TabContainer,
        })

        local WarningBox
        local WarningBoxOutline
        local WarningBoxShadowOutline
        local WarningBoxScrollingFrame
        local WarningTitle
        local WarningStroke
        local WarningText
        do
            WarningBox = New("Frame", {
                BackgroundColor3 = Color3.fromRGB(127, 0, 0),
                Position = UDim2.fromOffset(2, 0),
                Size = UDim2.new(1, -5, 0, 0),
                Parent = WarningBoxHolder,
            })
            Library:AddToRegistry(WarningBox, {
                BackgroundColor3 = function()
                    setthreadidentity(8)
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.BackgroundColor or Color3.fromRGB(127, 0, 0)
                end
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = WarningBox,
                })
            )
            WarningBoxOutline, WarningBoxShadowOutline = Library:AddOutline(WarningBox)
            Library:AddToRegistry(WarningBoxOutline, {
                Color = function()
                    setthreadidentity(8)
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(255, 50, 50)
                end
            })
            Library:AddToRegistry(WarningBoxShadowOutline, {
                Color = function()
                    setthreadidentity(8)
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor or Color3.fromRGB(85, 0, 0)
                end
            })

            WarningBoxScrollingFrame = New("ScrollingFrame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 3,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Parent = WarningBox,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 4),
                Parent = WarningBoxScrollingFrame,
            })

            WarningTitle = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -4, 0, 14),
                Text = "",
                TextColor3 = Color3.fromRGB(255, 50, 50),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = WarningBoxScrollingFrame,
            })
            Library:AddToRegistry(WarningTitle, {
                TextColor3 = function()
                    setthreadidentity(8)
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor or Color3.fromRGB(255, 50, 50)
                end
            })

            WarningStroke = New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = Color3.fromRGB(169, 0, 0),
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningTitle,
            })
            Library:AddToRegistry(WarningStroke, {
                Color = function()
                    setthreadidentity(8)
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(169, 0, 0)
                end
            })

            WarningText = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 16),
                Size = UDim2.new(1, -4, 0, 0),
                Text = "",
                TextSize = 14,
                TextWrapped = true,
                Parent = WarningBoxScrollingFrame,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
            })

            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningText,
            })
        end

        --// Tab Handlers \\--
        function Tab:UpdateWarningBox(Info)
            setthreadidentity(8)
            if typeof(Info.IsNormal) == "boolean" then
                Tab.WarningBox.IsNormal = Info.IsNormal
            end
            if typeof(Info.LockSize) == "boolean" then
                Tab.WarningBox.LockSize = Info.LockSize
            end
            if typeof(Info.Visible) == "boolean" then
                Tab.WarningBox.Visible = Info.Visible
            end
            if typeof(Info.Title) == "string" then
                Tab.WarningBox.Title = Info.Title
            end
            if typeof(Info.Text) == "string" then
                Tab.WarningBox.Text = Info.Text
            end

            WarningBoxHolder.Visible = Tab.WarningBox.Visible
            WarningTitle.Text = Tab.WarningBox.Title
            WarningText.Text = Tab.WarningBox.Text
            Tab:Resize(true)

            WarningBox.BackgroundColor3 = Library.Registry[WarningBox].BackgroundColor3()
            WarningBoxShadowOutline.Color = Library.Registry[WarningBoxShadowOutline].Color()
            WarningBoxOutline.Color = Library.Registry[WarningBoxOutline].Color()
            WarningTitle.TextColor3 = Library.Registry[WarningTitle].TextColor3()
            WarningStroke.Color = Library.Registry[WarningStroke].Color()
        end

        function Tab:RefreshSides()
            setthreadidentity(8)
            local SubTabOffset = SubTabHolder.Visible and 38 or 0
            local WarningOffset = WarningBoxHolder.Visible and WarningBox.Size.Y.Offset + 8 or 0
            local Offset = SubTabOffset + WarningOffset

            WarningBoxHolder.Position = UDim2.fromOffset(0, SubTabOffset + 7)
            for _, Side in Tab.Sides do
                Side.Position = UDim2.new(Side.Position.X.Scale, 0, 0, Offset)
                Side.Size = UDim2.new(0.5, -3, 1, -Offset)
            end
        end

        function Tab:Resize(ResizeWarningBox: boolean?)
            setthreadidentity(8)
            if ResizeWarningBox then
                local MaximumSize = math.floor(TabContainer.AbsoluteSize.Y / 3.25)
                local _, YText = Library:GetTextBounds(
                    WarningText.Text,
                    Library.Scheme.Font,
                    WarningText.TextSize,
                    WarningText.AbsoluteSize.X
                )

                local YBox = 24 + YText
                if Tab.WarningBox.LockSize == true and YBox >= MaximumSize then
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, YBox)
                    YBox = MaximumSize
                else
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
                end

                WarningText.Size = UDim2.new(1, -4, 0, YText)
                WarningBox.Size = UDim2.new(1, -5, 0, YBox + 4)
            end

            Tab:RefreshSides()
        end

        local function GetVisibleSubTabBoundaries()
            setthreadidentity(8)
            local FirstSubTab
            local LastSubTab

            for _, SubTab in Tab.SubTabOrder do
                if SubTab.Destroyed or not SubTab.Visible then
                    continue
                end

                if not FirstSubTab or SubTab.Button.LayoutOrder < FirstSubTab.Button.LayoutOrder then
                    FirstSubTab = SubTab
                end
                if not LastSubTab or SubTab.Button.LayoutOrder >= LastSubTab.Button.LayoutOrder then
                    LastSubTab = SubTab
                end
            end

            return FirstSubTab, LastSubTab
        end

        function Tab:RefreshSubTabs()
            setthreadidentity(8)
            if Tab.Destroyed then
                return
            end

            local FirstSubTab, LastSubTab = GetVisibleSubTabBoundaries()
            local HasVisibleSubTabs = FirstSubTab ~= nil

            SubTabHolder.Visible = HasVisibleSubTabs
            Tab.RootSides[1].Visible = not HasVisibleSubTabs
            Tab.RootSides[2].Visible = not HasVisibleSubTabs

            if not HasVisibleSubTabs then
                if Tab.ActiveSubTab then
                    Tab.ActiveSubTab:Hide()
                end
                Tab.Sides = Tab.RootSides
            elseif not Tab.ActiveSubTab or not Tab.ActiveSubTab.Visible or Tab.ActiveSubTab.Destroyed then
                FirstSubTab:Show()
            end

            for _, SubTab in Tab.SubTabOrder do
                if not SubTab.Destroyed then
                    SubTab:UpdateCorners(FirstSubTab, LastSubTab)
                end
            end
            Tab:RefreshSides()
        end

        function Tab:AddSubTab(...)
            setthreadidentity(8)
            local SubTabInfo

            if select("#", ...) == 1 and typeof(...) == "table" then
                SubTabInfo = select(1, ...)
            else
                SubTabInfo = {
                    Name = select(1, ...),
                    Icon = select(2, ...),
                    Order = select(3, ...),
                }
            end

            local SubTabName = SubTabInfo.Name or "Sub Tab"
            local SubTabIcon = Library:GetCustomIcon(SubTabInfo.Icon)
            local SubTabIndex = #Tab.SubTabOrder + 1
            local StorageIndex = SubTabName

            if Tab.SubTabs[StorageIndex] then
                StorageIndex = `{SubTabName} {SubTabIndex}`
            end

            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 0,
                LayoutOrder = SubTabInfo.Order or SubTabIndex,
                Size = UDim2.fromOffset(0, 34),
                Text = "",
                ZIndex = 3,
                Parent = SubTabButtons,
            })
            local ButtonCorner = New("UICorner", {
                CornerRadius = UDim.new(0, 0),
                Parent = Button,
            })
            table.insert(Library.SpecificCorners, ButtonCorner)

            local ButtonContent = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(0, 18),
                Parent = Button,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 7),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = ButtonContent,
            })

            local ButtonIcon

            if SubTabIcon then
                ButtonIcon = New("ImageLabel", {
                    BackgroundTransparency = 1,
                    Image = SubTabIcon.Url,
                    ImageColor3 = SubTabIcon.Custom and "WhiteColor" or "AccentColor",
                    ImageRectOffset = SubTabIcon.ImageRectOffset,
                    ImageRectSize = SubTabIcon.ImageRectSize,
                    ImageTransparency = 0.5,
                    Size = UDim2.fromOffset(18, 18),
                    ZIndex = 3,
                    Parent = ButtonContent,
                })
            end

            local ButtonLabel = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 18),
                Text = SubTabName,
                TextSize = 15,
                TextTransparency = 0.5,
                ZIndex = 3,
                Parent = ButtonContent,
            })
            local Line = Library:MakeLine(Button, {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, 0, 0, 1),
            })
            local ActiveLine = New("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = "AccentColor",
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, 0, 0, 2),
                Visible = false,
                ZIndex = 4,
                Parent = Button,
            })

            local Canvas = New("CanvasGroup", {
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                GroupTransparency = 0,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = TabContainer,
            })

            local function CreateSide(IsRight: boolean)
                setthreadidentity(8)
                local Side = New("ScrollingFrame", {
                    AnchorPoint = IsRight and Vector2.new(1, 0) or Vector2.zero,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    CanvasSize = UDim2.fromScale(0, 0),
                    Position = IsRight and UDim2.fromScale(1, 0) or UDim2.fromScale(0, 0),
                    ScrollBarImageTransparency = 1,
                    ScrollBarThickness = 0,
                    Size = UDim2.new(0.5, -3, 1, 0),
                    Parent = Canvas,
                })
                New("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    Parent = Side,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 2),
                    PaddingLeft = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                    PaddingTop = UDim.new(0, 2),
                    Parent = Side,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = Side,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = Side,
                })

                return Side
            end

            local SubTab = {
                Type = "SubTab",
                Name = SubTabName,
                StorageIndex = StorageIndex,
                Connections = {},
                Destroyed = false,
                Visible = true,
                Button = Button,
                ButtonCorner = ButtonCorner,
                Canvas = Canvas,
                Groupboxes = {},
                Tabboxes = {},
                Tab = Tab,
                Sides = {
                    CreateSide(false),
                    CreateSide(true),
                },
            }

            function SubTab:UpdateCorners(FirstSubTab, LastSubTab)
                setthreadidentity(8)
                ButtonCorner.CornerRadius = UDim.new(0, 0)
            end

            function SubTab:Show()
                setthreadidentity(8)
                if SubTab.Destroyed or not SubTab.Visible or Tab.ActiveSubTab == SubTab then
                    return
                end
                if Tab.ActiveSubTab then
                    Tab.ActiveSubTab:Hide()
                end

                Button.BackgroundTransparency = 1
                ButtonLabel.TextTransparency = 0
                if ButtonIcon then
                    ButtonIcon.ImageTransparency = 0
                end
                Line.Visible = true
                ActiveLine.Visible = true

                Tab.Sides = SubTab.Sides
                Tab.ActiveSubTab = SubTab
                Library:PlayTabAnimation(Canvas, true)
                Tab:RefreshSides()

                if Library.Searching then
                    Library:UpdateSearch(Library.SearchText)
                end
            end

            function SubTab:Hide()
                setthreadidentity(8)
                if SubTab.Destroyed then
                    return
                end

                Button.BackgroundTransparency = 0
                ButtonLabel.TextTransparency = 0.5
                if ButtonIcon then
                    ButtonIcon.ImageTransparency = 0.5
                end
                Line.Visible = true
                ActiveLine.Visible = false
                Library:PlayTabAnimation(Canvas, false)

                if Tab.ActiveSubTab == SubTab then
                    Tab.ActiveSubTab = nil
                end
            end

            function SubTab:SetVisible(Visible: boolean)
                setthreadidentity(8)
                SubTab.Visible = Visible
                Button.Visible = Visible

                if not Visible and Tab.ActiveSubTab == SubTab then
                    SubTab:Hide()
                end
                Tab:RefreshSubTabs()
            end

            function SubTab:AddGroupbox(Info)
                setthreadidentity(8)
                Info = table.clone(Info)
                Info.SubTab = SubTab
                Info.Parent = Info.Side == 1 and SubTab.Sides[1] or SubTab.Sides[2]
                Info.StorageName = `{StorageIndex}:{#SubTab.Groupboxes + 1}:{Info.Name}`

                return Tab:AddGroupbox(Info)
            end

            function SubTab:AddLeftGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
                setthreadidentity(8)
                return SubTab:AddGroupbox({ Side = 1, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
            end

            function SubTab:AddRightGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
                setthreadidentity(8)
                return SubTab:AddGroupbox({ Side = 2, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
            end

            function SubTab:AddTabbox(Info)
                setthreadidentity(8)
                Info = table.clone(Info)
                Info.SubTab = SubTab
                Info.Parent = Info.Side == 1 and SubTab.Sides[1] or SubTab.Sides[2]
                Info.StorageName = `{StorageIndex}:Tabbox:{#SubTab.Tabboxes + 1}:{tostring(Info.Name)}`

                return Tab:AddTabbox(Info)
            end

            function SubTab:AddLeftTabbox(Name)
                setthreadidentity(8)
                return SubTab:AddTabbox({ Side = 1, Name = Name })
            end

            function SubTab:AddRightTabbox(Name)
                setthreadidentity(8)
                return SubTab:AddTabbox({ Side = 2, Name = Name })
            end

            function SubTab:Destroy()
                setthreadidentity(8)
                if SubTab.Destroyed then
                    return
                end

                SubTab.Destroyed = true

                for _, Connection in SubTab.Connections do
                    Connection:Disconnect()
                end
                table.clear(SubTab.Connections)

                for _, Tabbox in SubTab.Tabboxes do
                    for TabboxIndex, StoredTabbox in Tab.Tabboxes do
                        if StoredTabbox == Tabbox then
                            Tab.Tabboxes[TabboxIndex] = nil
                            break
                        end
                    end
                    Tabbox:Destroy()
                end
                table.clear(SubTab.Tabboxes)

                for _, Groupbox in SubTab.Groupboxes do
                    for GroupboxIndex, StoredGroupbox in Tab.Groupboxes do
                        if StoredGroupbox == Groupbox then
                            Tab.Groupboxes[GroupboxIndex] = nil
                            break
                        end
                    end
                    Groupbox:Destroy()
                end
                table.clear(SubTab.Groupboxes)

                local OrderIndex = table.find(Tab.SubTabOrder, SubTab)
                if OrderIndex then
                    table.remove(Tab.SubTabOrder, OrderIndex)
                end
                Tab.SubTabs[StorageIndex] = nil

                if Tab.ActiveSubTab == SubTab then
                    Tab.ActiveSubTab = nil
                end

                local CornerIndex = table.find(Library.SpecificCorners, ButtonCorner)
                if CornerIndex then
                    table.remove(Library.SpecificCorners, CornerIndex)
                end
                Canvas:Destroy()
                Button:Destroy()
                Tab:RefreshSubTabs()
            end

            table.insert(SubTab.Connections, Button.MouseEnter:Connect(function()
                setthreadidentity(8)
                if Tab.ActiveSubTab ~= SubTab then
                    TweenService:Create(ButtonLabel, Library.TweenInfo, { TextTransparency = 0.25 }):Play()
                    if ButtonIcon then
                        TweenService:Create(ButtonIcon, Library.TweenInfo, { ImageTransparency = 0.25 }):Play()
                    end
                end
            end))
            table.insert(SubTab.Connections, Button.MouseLeave:Connect(function()
                setthreadidentity(8)
                if Tab.ActiveSubTab ~= SubTab then
                    TweenService:Create(ButtonLabel, Library.TweenInfo, { TextTransparency = 0.5 }):Play()
                    if ButtonIcon then
                        TweenService:Create(ButtonIcon, Library.TweenInfo, { ImageTransparency = 0.5 }):Play()
                    end
                end
            end))
            table.insert(SubTab.Connections, Button.MouseButton1Click:Connect(SubTab.Show))

            Tab.SubTabs[StorageIndex] = SubTab
            table.insert(Tab.SubTabOrder, SubTab)
            Tab:RefreshSubTabs()

            return SubTab, StorageIndex
        end

        local function AddTabbox(self, Info)
            setthreadidentity(8)
            Info = Library:Validate(Info, Templates.Tabbox)
            local ParentObj = self
            local OwningSubTab = Info.SubTab or ParentObj.SubTab

            if typeof(Info.Side) == "string" then
                local lowerSide = string.lower(Info.Side)
                if not SideIndex[lowerSide] then
                    error(string.format("Invalid side: %s", Info.Side))
                end

                Info.Side = SideIndex[lowerSide]
            end

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = if ParentObj.Type == "Groupbox" then ParentObj.Container else (Info.Parent or (Info.Side == 1 and TabLeft or TabRight)),
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local TabboxHolder
            local TabboxButtons

            do
                TabboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = TabboxHolder,
                    })
                )
                Library:AddOutline(TabboxHolder)

                TabboxButtons = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    Parent = TabboxHolder,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Parent = TabboxButtons,
                })
            end

            local TotalTabs = 0
            local FirstTab
            local LastTab

            local Tabbox: any = {
                Type = "Tabbox",

                Connections = {},
                Destroyed = false,

                Visible = true,
                ActiveTab = nil,

                BoxHolder = BoxHolder,
                Holder = TabboxHolder,
                Tabs = {},
                SubTab = OwningSubTab,

                ParentBox = if ParentObj.Type == "Groupbox" then ParentObj else nil,
            }

            function Tabbox:UpdateCorners()
                setthreadidentity(8)
                for _, Tab in Tabbox.Tabs do
                    Tab:UpdateCorners()
                end
            end

            function Tabbox:Resize()
                setthreadidentity(8)
                if Tabbox.ActiveTab then
                    Tabbox.ActiveTab:Resize()
                end
            end

            function Tabbox:AddTab(Name, IconName)
                setthreadidentity(8)
                TotalTabs = TotalTabs + 1
                local TabIndex = TotalTabs

                LastTab = TabIndex
                if not FirstTab then
                    FirstTab = TabIndex
                end

                local IsNameEmpty = Name == nil or Trim(tostring(Name)) == ""
                local TabStoringIndex = IsNameEmpty and tostring(TabIndex) or Name

                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 0,
                    Size = UDim2.fromOffset(0, 34),
                    Text = "",
                    Parent = TabboxButtons,
                })

                local ButtonCorner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, WindowInfo.CornerRadius),
                    TopRightRadius = UDim.new(0, WindowInfo.CornerRadius),
                    BottomRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, 0),
                    Parent = Button,
                }); table.insert(Library.SpecificCorners, ButtonCorner)

                local ButtonContent = New("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(0, 16),
                    Parent = Button,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 8),
                    Parent = ButtonContent,
                })

                local ButtonIcon
                local BoxIcon = Library:GetCustomIcon(IconName)
                if BoxIcon then
                    ButtonIcon = New("ImageLabel", {
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        ImageTransparency = 0.5,
                        Size = IsNameEmpty and UDim2.fromOffset(16, 16) or UDim2.fromOffset(18, 18),
                        Parent = ButtonContent,
                    })
                    Library:ApplyLucideIcon(ButtonIcon, BoxIcon)
                end

                local ButtonLabel
                if not IsNameEmpty then
                    ButtonLabel = New("TextLabel", {
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(0, 16),
                        Text = Name,
                        TextSize = 15,
                        TextTransparency = 0.5,
                        Parent = ButtonContent,
                    })
                end

                local Line = Library:MakeLine(Button, {
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 1),
                    Size = UDim2.new(1, 0, 0, 1),
                })

                local Container = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromScale(0, 0),
                    Position = UDim2.fromOffset(0, 35),
                    ScrollBarThickness = 0,
                    Size = UDim2.new(1, 0, 1, -35),
                    Visible = false,
                    Parent = TabboxHolder,
                })
                local List = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = Container,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 7),
                    Parent = Container,
                })

                local Tab = {
                    Type = "TabboxTab",
                    Name = Name,

                    Connections = {},
                    Destroyed = false,

                    ButtonHolder = Button,
                    Container = Container,
                    ButtonCorner = ButtonCorner,

                    Tab = Tab,
                    Tabbox = Tabbox,

                    Elements = {},
                    DependencyBoxes = {},
                }

                function Tab:Show()
                    setthreadidentity(8)
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Hide()
                    end

                    Button.BackgroundTransparency = 1

                    if ButtonLabel then
                        ButtonLabel.TextTransparency = 0
                    end
                    if ButtonIcon then
                        ButtonIcon.ImageTransparency = 0
                    end

                    Line.Visible = false

                    Container.Visible = true

                    Tabbox.ActiveTab = Tab
                    Tab:Resize()
                    Tabbox:RefreshPopOutPlaceholder()
                end

                function Tab:Hide()
                    setthreadidentity(8)
                    Button.BackgroundTransparency = 0

                    if ButtonLabel then
                        ButtonLabel.TextTransparency = 0.5
                    end
                    if ButtonIcon then
                        ButtonIcon.ImageTransparency = 0.5
                    end
                    Line.Visible = true
                    Container.Visible = false

                    Tabbox.ActiveTab = nil
                end

                function Tab:Resize()
                    setthreadidentity(8)
                    if Tabbox.ActiveTab ~= Tab then
                        return
                    end

                    local ContentSize = (List.AbsoluteContentSize.Y / Library.DPIScale) + 14
                    if Tabbox.PoppedOut then
                        ContentSize = math.min(ContentSize, GetPopOutBodyMaxHeight(Tabbox, 35))
                    end

                    TabboxHolder.Size = UDim2.new(1, 0, 0, ContentSize + 35)
                    if ParentObj.Type == "Groupbox" then
                        ParentObj:Resize()
                    end
                end

                function Tab:UpdateCorners()
                    setthreadidentity(8)
                    local Radius = WindowInfo.CornerRadius

                    ButtonCorner.TopLeftRadius = UDim.new(0, TabIndex == FirstTab and Radius or 0)
                    ButtonCorner.TopRightRadius = UDim.new(0, TabIndex == LastTab and Radius or 0)
                end

                function Tab:Destroy()
                    setthreadidentity(8)
                    Tab.Destroyed = true

                    if Tab.Connections then
                        for _, Connection in Tab.Connections do
                            Connection:Disconnect()
                        end
                    end

                    for _, Element in Tab.Elements do
                        if Element.Destroy then
                            Element:Destroy()
                        end
                    end

                    for _, SubDepbox in Tab.DependencyBoxes do
                        if SubDepbox.Destroy then
                            SubDepbox:Destroy()
                        end
                    end

                    if Container then
                        Container:Destroy()
                    end

                    if Button then
                        Button:Destroy()
                    end
                end

                --// Execution \\--
                if not Tabbox.ActiveTab then
                    Tab:Show()
                end

                Button.MouseButton1Click:Connect(Tab.Show)

                setmetatable(Tab, BaseGroupbox)

                Tabbox.Tabs[TabStoringIndex] = Tab
                Tabbox:UpdateCorners()

                return Tab, TabStoringIndex
            end

            Library:MakeBoxPopOut(Tabbox, {
                Enabled = Info.PopOut ~= false,

                Header = TabboxButtons,
                Children = function()
                    setthreadidentity(8)
                    return { TabboxHolder }
                end,

                After = function()
                    setthreadidentity(8)
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Resize()
                    end
                    if ParentObj.Type == "Groupbox" then
                        ParentObj:Resize()
                    end
                end,
            })

            function Tabbox:Destroy()
                setthreadidentity(8)
                if Tabbox.PoppedOut then
                    Tabbox:SetPoppedOut(false)
                end

                Tabbox.Destroyed = true

                if Tabbox.Connections then
                    for _, Connection in Tabbox.Connections do
                        Connection:Disconnect()
                    end
                end

                for _, Tab in Tabbox.Tabs do
                    if Tab.Destroy then
                        Tab:Destroy()
                    end
                end

                if TabboxHolder then
                    TabboxHolder:Destroy()
                end

                if BoxHolder then
                    BoxHolder:Destroy()
                end
            end

            if Info.StorageName or Info.Name then
                Tab.Tabboxes[Info.StorageName or Info.Name] = Tabbox
            else
                table.insert(Tab.Tabboxes, Tabbox)
            end
            if OwningSubTab then
                table.insert(OwningSubTab.Tabboxes, Tabbox)
            end

            return Tabbox
        end

        Tab.AddTabbox = AddTabbox

        --// Deprecated - Use Tab:AddTabbox instead.
        function Tab:AddLeftTabbox(Name)
            setthreadidentity(8)
            return Tab:AddTabbox({ Side = 1, Name = Name })
        end

        --// Deprecated - Use Tab:AddTabbox instead.
        function Tab:AddRightTabbox(Name)
            setthreadidentity(8)
            return Tab:AddTabbox({ Side = 2, Name = Name })
        end

        function Tab:AddGroupbox(Info)
            setthreadidentity(8)
            Info = Library:Validate(Info, Templates.Groupbox)

            if typeof(Info.Side) == "string" then
                local lowerSide = string.lower(Info.Side)
                if not SideIndex[lowerSide] then
                    error(string.format("Invalid side: %s", Info.Side))
                end

                Info.Side = SideIndex[lowerSide]
            end

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = Info.Parent or ((Info.Side == 1) and TabLeft or TabRight),
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local GroupboxHolder

            local GroupboxTop
            local GroupboxLabel
            local GroupboxDescription

            local GroupboxContainer
            local GroupboxList

            local GroupboxCollapseArrow
            local GroupboxLine

            do
                GroupboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = GroupboxHolder,
                    })
                )
                New("UIListLayout", {
                    Parent = GroupboxHolder,
                })
                Library:AddOutline(GroupboxHolder)

                GroupboxTop = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Parent = GroupboxHolder,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 6),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                    Parent = GroupboxTop,
                })

                local BoxIcon = Library:GetCustomIcon(Info.IconName)
                if BoxIcon then
                    local GroupboxHeaderIcon = New("ImageLabel", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        Position = UDim2.fromScale(0, 0.5),
                        Size = UDim2.fromOffset(22, 22),
                        Parent = GroupboxTop,
                    })
                    Library:ApplyLucideIcon(GroupboxHeaderIcon, BoxIcon)
                end

                local RightInset = if Info.DisableCollapsing ~= true then 22 else 0
                local TextsFrame = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(BoxIcon and 24 or 0, 0),
                    Size = UDim2.new(1, -RightInset - (BoxIcon and 24 or 0), 0, 0),
                    Parent = GroupboxTop,
                })
                New("UIListLayout", {
                    Parent = TextsFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 3),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 3),
                    Parent = TextsFrame,
                })

                GroupboxLabel = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Name,
                    TextSize = 15,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextsFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 1),
                    Parent = GroupboxLabel,
                })

                GroupboxDescription = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Description or "",
                    TextSize = 14,
                    TextTransparency = 0.5,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Visible = (Info.Description ~= nil),
                    Parent = TextsFrame,
                })

                GroupboxCollapseArrow = New("ImageButton", {
                    Visible = Info.DisableCollapsing ~= true,
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    ImageColor3 = "WhiteColor",
                    Position = UDim2.fromScale(1, 0.5),
                    Size = UDim2.fromOffset(22, 22),
                    Parent = GroupboxTop,
                })
                if ArrowIcon then
                    Library:ApplyLucideIcon(GroupboxCollapseArrow, ArrowIcon, 180)
                end

                GroupboxLine = Library:MakeLine(GroupboxHolder, {
                    LayoutOrder = 1,
                    Size = UDim2.new(1, 0, 0, 1),
                })

                GroupboxContainer = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromScale(0, 0),
                    LayoutOrder = 2,
                    ScrollBarThickness = 0,
                    Size = UDim2.fromScale(1, 0),
                    Parent = GroupboxHolder,
                })

                GroupboxList = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = GroupboxContainer,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 7),
                    Parent = GroupboxContainer,
                })
            end

            local Groupbox: any = {
                Type = "Groupbox",
                Name = Info.Name,

                Name = Info.Name,
                Description = Info.Description,

                Connections = {},
                Destroyed = false,

                Visible = true,
                Collapsed = false,

                BoxHolder = BoxHolder,
                Holder = GroupboxHolder,
                Container = GroupboxContainer,

                Tab = Tab,
                SubTab = Info.SubTab,
                DependencyBoxes = {},
                Elements = {}
            }

            local ResizeTween
            local CollapseArrowTween

            function Groupbox:Resize()
                setthreadidentity(8)
                if ResizeTween then
                    StopTween(ResizeTween, true)
                    ResizeTween = nil
                end

                local TopSize = (GroupboxTop.AbsoluteSize.Y / Library.DPIScale)
                local ContainerSize = (GroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 14
                if Groupbox.PoppedOut then
                    ContainerSize = math.min(ContainerSize, GetPopOutBodyMaxHeight(Groupbox, TopSize + 1))
                end

                local TargetSize = UDim2.new(1, 0, 0, if Groupbox.Collapsed then TopSize else (TopSize + 1 + ContainerSize))
                GroupboxContainer.Size = UDim2.new(1, 0, 0, ContainerSize)
                GroupboxLine.Visible = not Groupbox.Collapsed

                if Library.Animations and Library.Animations.Groupbox then
                    local TweenInfo = Library.GroupboxTweenInfo or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local Tween = TweenService:Create(GroupboxHolder, TweenInfo, { Size = TargetSize })
                    ResizeTween = Tween

                    local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                        setthreadidentity(8)
                        if Connection then
                            Connection:Disconnect()
                        end

                        if ResizeTween == Tween then
                            StopTween(ResizeTween, true)
                            ResizeTween = nil
                        end
                    end))

                    Tween:Play()
                else
                    GroupboxHolder.Size = TargetSize
                end
            end

            function Groupbox:SetDescription(Description: string | nil)
                setthreadidentity(8)
                GroupboxDescription.Text = Description or ""
                GroupboxDescription.Visible = (Description ~= nil)

                Groupbox:Resize()
            end

            function Groupbox:SetCollapsed(Collapsed: boolean)
                setthreadidentity(8)
                if Info.DisableCollapsing == true then return end
                Groupbox.Collapsed = Collapsed

                if CollapseArrowTween then
                    StopTween(CollapseArrowTween, true)
                    CollapseArrowTween = nil
                end

                local TargetRotation = if Collapsed then 0 else 180

                GroupboxContainer.Visible = not Collapsed
                if Library.Animations and Library.Animations.Groupbox then
                    local TweenInfo = Library.GroupboxTweenInfo or TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    local Tween = TweenService:Create(GroupboxCollapseArrow, TweenInfo, { Rotation = TargetRotation })
                    CollapseArrowTween = Tween

                    local Connection; Connection = Library:GiveSignal(Tween.Completed:Connect(function()
                        setthreadidentity(8)
                        if Connection then
                            Connection:Disconnect()
                        end

                        if CollapseArrowTween == Tween then
                            StopTween(CollapseArrowTween, true)
                            CollapseArrowTween = nil
                        end
                    end))

                    Tween:Play()
                else
                    GroupboxCollapseArrow.Rotation = TargetRotation
                end

                Groupbox:Resize()
            end

            function Groupbox:ToggleCollapsed()
                setthreadidentity(8)
                if Info.DisableCollapsing == true then return end
                Groupbox:SetCollapsed(not Groupbox.Collapsed)
            end

            Library:MakeBoxPopOut(Groupbox, {
                Enabled = Info.PopOut ~= false,

                Header = GroupboxTop,
                Children = function()
                    setthreadidentity(8)
                    local Children = {}
                    for _, Child in BoxHolder:GetChildren() do
                        if Child:IsA("GuiObject") and Child ~= Groupbox.PopOutPlaceholder then
                            table.insert(Children, Child)
                        end
                    end
                    return Children
                end,

                Before = function()
                    setthreadidentity(8)
                    GroupboxCollapseArrow.Visible = false
                end,
                After = function()
                    setthreadidentity(8)
                    GroupboxCollapseArrow.Visible = Info.DisableCollapsing ~= true
                    Groupbox:Resize()
                end
            })

            function Groupbox:Destroy()
                setthreadidentity(8)
                if Groupbox.PoppedOut then
                    Groupbox:SetPoppedOut(false)
                end

                Groupbox.Destroyed = true

                if ResizeTween then
                    StopTween(ResizeTween, true)
                    ResizeTween = nil
                end

                if CollapseArrowTween then
                    StopTween(CollapseArrowTween, true)
                    CollapseArrowTween = nil
                end

                if Groupbox.Connections then
                    for _, Connection in Groupbox.Connections do
                        Connection:Disconnect()
                    end
                end

                for _, Element in Groupbox.Elements do
                    if Element.Destroy then
                        Element:Destroy()
                    end
                end
                table.clear(Groupbox.Elements)

                for _, SubDepbox in Groupbox.DependencyBoxes do
                    if SubDepbox.Destroy then
                        SubDepbox:Destroy()
                    end
                end
                table.clear(Groupbox.DependencyBoxes)

                if GroupboxHolder then
                    GroupboxHolder:Destroy()
                end

                if BoxHolder then
                    BoxHolder:Destroy()
                end
            end

            function Groupbox:SetVisible(Visible: boolean)
                setthreadidentity(8)
                Groupbox.Visible = Visible
                BoxHolder.Visible = Visible
                SyncPopOutVisibility(Groupbox)

                if Visible == true and Library.Searching then
                    Library:UpdateSearch(Library.SearchText)
                end
            end

            function Groupbox:Show()
                setthreadidentity(8)
                Groupbox:SetVisible(true)
            end

            function Groupbox:Hide()
                setthreadidentity(8)
                Groupbox:SetVisible(false)
            end

            if Info.DisableCollapsing ~= true then
                GroupboxCollapseArrow.MouseButton1Click:Connect(function()
                    setthreadidentity(8)
                    Groupbox:ToggleCollapsed()
                end)
            end

            Groupbox.AddTabbox = AddTabbox
            setmetatable(Groupbox, BaseGroupbox)

            Groupbox:Resize()
            Tab.Groupboxes[Info.StorageName or Info.Name] = Groupbox
            if Info.SubTab then
                table.insert(Info.SubTab.Groupboxes, Groupbox)
            end

            if Info.Visible == false then
                Groupbox:Hide()
            end

            if Info.DisableCollapsing ~= true and Info.Collapsed == true then
                Groupbox:SetCollapsed(true)
            end

            return Groupbox
        end

        --// Deprecated - Use Tab:AddGroupbox instead.
        function Tab:AddLeftGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
            setthreadidentity(8)
            return Tab:AddGroupbox({ Side = 1, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
        end

        --// Deprecated - Use Tab:AddGroupbox instead.
        function Tab:AddRightGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
            setthreadidentity(8)
            return Tab:AddGroupbox({ Side = 2, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
        end

        function Tab:Hover(Hovering)
            setthreadidentity(8)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0.25 or 0.5,
                }):Play()
            end
        end

        function Tab:Show()
            setthreadidentity(8)
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Library:PlayTabAnimation(Tab, true)
            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            setthreadidentity(8)
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0.5,
                }):Play()
            end

            Library:PlayTabAnimation(Tab, false)
            Window:HideTabInfo()

            Library.PreviousTab = Tab
            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            setthreadidentity(8)
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetOrder(NewOrder: number)
            setthreadidentity(8)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:SetTooltip(Text: string?)
            setthreadidentity(8)
            Tab.Tooltip = Text

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if typeof(Text) == "string" then
                Tab.TooltipTable = Library:AddTooltip(Text, nil, TabButton)
            end
        end

        function Tab:Destroy()
            setthreadidentity(8)
            Tab.Destroyed = true

            local HolderCornerIndex = table.find(Library.Corners, SubTabHolderCorner)
            if HolderCornerIndex then
                table.remove(Library.Corners, HolderCornerIndex)
            end

            if Tab.Command then
                Tab.Command:Destroy()
            end

            if Tab.Connections then
                for _, Connection in Tab.Connections do
                    Connection:Disconnect()
                end
            end

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            for _, Groupbox in Tab.Groupboxes do
                if Groupbox.Destroy then
                    Groupbox:Destroy()
                end
            end
            table.clear(Tab.Groupboxes)

            for _, Tabbox in Tab.Tabboxes do
                if Tabbox.Destroy then
                    Tabbox:Destroy()
                end
            end
            table.clear(Tab.Tabboxes)

            for _, DepGroupbox in Tab.DependencyGroupboxes do
                if DepGroupbox.Destroy then
                    DepGroupbox:Destroy()
                end
            end

            for Index = #Tab.SubTabOrder, 1, -1 do
                Tab.SubTabOrder[Index]:Destroy()
            end
            table.clear(Tab.SubTabs)
            table.clear(Tab.SubTabOrder)

            if TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        --// Execution \\--
        if typeof(Tooltip) == "string" then
            Tab.TooltipTable = Library:AddTooltip(Tooltip, nil, TabButton)
        end

        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            setthreadidentity(8)
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            setthreadidentity(8)
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        Library.Tabs[Name] = Tab

        Tab.Command = Window:RegisterCommand({
            Id = `Tab:{Name}`,
            Name = `Open {Name}`,
            Description = Description or "Navigate to tab",
            Keywords = { Name, "tab", "navigate", "open" },
            Action = function()
                setthreadidentity(8)
                Tab:Show()
            end,
        })

        return Tab
    end

    function Window:AddKeyTab(...)
        setthreadidentity(8)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
        else
            Name = select(1, ...) or "Tab"
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        Icon = Icon or "key"

        local TabButton: TextButton
        local TabLabel
        local TabIcon

        local TabContainer

        Icon = if Icon == "key" then KeyIcon else Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = TabButton,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = TabButton,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = TabButton,
                })
                Library:ApplyLucideIcon(TabIcon, Icon)
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarThickness = 0,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })
            New("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = TabContainer,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1),
                Parent = TabContainer,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Description = Description,
            IsKeyTab = true,

            Tooltip = Tooltip,
            TooltipTable = nil,

            Elements = {},

            Window = Window,
            Button = TabButton,
            Container = TabContainer
        }

        function Tab:AddKeyBox(Callback)
            setthreadidentity(8)
            assert(typeof(Callback) == "function", "Callback must be a function")

            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.75, 0, 0, 21),
                Parent = TabContainer,
            })

            local Box = New("TextBox", {
                BackgroundColor3 = "MainColor",
                PlaceholderText = "Key",
                Size = UDim2.new(1, -71, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Box,
            })
            local BoxStroke = New("UIStroke", {
                Color = "OutlineColor",
                Parent = Box,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Box,
                })
            )

            Box.Focused:Connect(function()
                setthreadidentity(8)
                Library.Registry[BoxStroke].Color = "AccentColor"
                TweenService:Create(BoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end)

            Box.FocusLost:Connect(function()
                setthreadidentity(8)
                Library.Registry[BoxStroke].Color = "OutlineColor"
                TweenService:Create(BoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end)

            local Button = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0, 63, 1, 0),
                Text = "Execute",
                TextSize = 14,
                TextTransparency = 0.4,
                Parent = Holder,
            })
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Button,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
            )

            Button.MouseEnter:Connect(function()
                setthreadidentity(8)
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0,
                }):Play()
            end)

            Button.MouseLeave:Connect(function()
                setthreadidentity(8)
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.4,
                }):Play()
            end)

            Button.InputBegan:Connect(function(Input)
                setthreadidentity(8)
                if not IsClickInput(Input) then
                    return
                end

                if not Library:MouseIsOverFrame(Button, Input.Position) then
                    return
                end

                Callback(Box.Text)
            end)
        end

        function Tab:Destroy()
            setthreadidentity(8)
            if TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        function Tab:SetOrder(NewOrder: number)
            setthreadidentity(8)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:RefreshSides()
            setthreadidentity(8)
        end
        function Tab:Resize()
            setthreadidentity(8)
        end
        function Tab:UpdateCorners()
            setthreadidentity(8)
        end

        function Tab:Hover(Hovering)
            setthreadidentity(8)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0.25 or 0.5,
                }):Play()
            end
        end

        function Tab:Show()
            setthreadidentity(8)
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end

            Library:PlayTabAnimation(Tab, true)

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            setthreadidentity(8)
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0.5,
                }):Play()
            end

            Library:PlayTabAnimation(Tab, false)
            Window:HideTabInfo()

            Library.PreviousTab = Tab
            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            setthreadidentity(8)
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetTooltip(Text: string?)
            setthreadidentity(8)
            Tab.Tooltip = Text

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if typeof(Text) == "string" then
                Tab.TooltipTable = Library:AddTooltip(Text, nil, TabButton)
            end
        end

        --// Execution \\--
        if typeof(Tooltip) == "string" then
            Tab.TooltipTable = Library:AddTooltip(Tooltip, nil, TabButton)
        end

        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            setthreadidentity(8)
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            setthreadidentity(8)
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        Tab.Container = TabContainer
        setmetatable(Tab, BaseGroupbox)

        Library.Tabs[Name] = Tab

        return Tab
    end

    function Window:AddDialog(Idx, Info)
        setthreadidentity(8)
        Info = Library:Validate(Info, Templates.Dialog)

        local DialogFrame
        local DialogOverlay
        local DialogContainer
        local ButtonsHolder
        local FooterButtonsList = {}

        DialogOverlay = New("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = "DarkColor",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Active = false,
            ZIndex = 9000,
            Visible = true,
            Parent = MainFrame,
        })
        TweenService:Create(DialogOverlay, Library.TweenInfo, {
            BackgroundTransparency = 0.5,
        }):Play()

        DialogFrame = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(300, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 1,
            Parent = DialogOverlay,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = DialogFrame,
            })
        )
        Library:AddOutline(DialogFrame)

        local InnerContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 2,
            Parent = DialogFrame,
        })
        local DialogScale = New("UIScale", {
            Scale = 0.95,
            Parent = DialogFrame,
        })
        TweenService:Create(DialogScale, Library.TweenInfo, {
            Scale = 1
        }):Play()
        local _InnerPadding = New("UIPadding", {
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            Parent = InnerContainer,
        })
        local _InnerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = InnerContainer,
        })

        local HeaderContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = HeaderContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = HeaderContainer,
        })

        local TitleRow = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = HeaderContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TitleRow,
        })

        if Info.Icon then
            local ParsedIcon = Library:GetCustomIcon(Info.Icon)
            if ParsedIcon then
                local IconImg = New("ImageLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(16, 16),
                    ImageColor3 = Info.TitleColor or "FontColor",
                    LayoutOrder = 1,
                    ZIndex = 2,
                    Parent = TitleRow,
                })
                Library:ApplyLucideIcon(IconImg, ParsedIcon)
            end
        end

        local TitleLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Title,
            TextSize = 18,
            TextColor3 = Info.TitleColor or "FontColor",
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = TitleRow,
        })

        local DescriptionLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Description,
            TextSize = 14,
            TextTransparency = Info.DescriptionColor and 0 or 0.2,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Info.DescriptionColor or "FontColor",
            TextWrapped = true,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = HeaderContainer,
        })

        DialogContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 4,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        local _DialogContainerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = DialogContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = DialogContainer,
        })

        local _Sep2 = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            LayoutOrder = 5,
            ZIndex = 2,
            Parent = InnerContainer,
        })

        ButtonsHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 6,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Wraps = true,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ButtonsHolder,
        })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            Parent = ButtonsHolder,
        })

        local Dialog = {
            Destroyed = false,
            Elements = {},
            Container = DialogContainer,
            OutsideClickDismiss = Info.OutsideClickDismiss,
        }

        function Dialog:Resize()
            setthreadidentity(8)
            local MaxWidth = MainFrame.AbsoluteSize.X * 0.75
            local MinWidth = 400

            local TotalButtonWidth = 0
            local ButtonCount = 0
            local HasButtons = false

            for _, BtnWrap in FooterButtonsList do
                HasButtons = true
                ButtonCount = ButtonCount + 1
                TotalButtonWidth = TotalButtonWidth + BtnWrap.Container.Size.X.Offset
            end

            local TargetWidth = MinWidth
            if HasButtons then
                local RequiredWidth = TotalButtonWidth + ((ButtonCount - 1) * 8) + 30
                TargetWidth = math.max(MinWidth, math.min(RequiredWidth, MaxWidth))
            end

            DialogFrame.Size = UDim2.fromOffset(TargetWidth, 0)

            local _DescX, DescY = Library:GetTextBounds(DescriptionLabel.Text, Library.Scheme.Font, 14, TargetWidth - 30)
            DescriptionLabel.Size = UDim2.new(1, 0, 0, DescY)

            local HasElements = false
            for _, v in DialogContainer:GetChildren() do
                if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
                    HasElements = true
                    break
                end
            end
            DialogContainer.Visible = HasElements

            ButtonsHolder.Visible = HasButtons
            _Sep2.Visible = HasButtons
        end

        function Dialog:SetTitle(Title)
            setthreadidentity(8)
            TitleLabel.Text = Title
            Dialog:Resize()
        end

        function Dialog:SetDescription(Description)
            setthreadidentity(8)
            DescriptionLabel.Text = Description
            Dialog:Resize()
        end

        function Dialog:Dismiss()
            setthreadidentity(8)
            if Dialog.Destroyed then
                return
            end

            Dialog.Destroyed = true

            if Library.ActiveDialog == Dialog then
                Library.ActiveDialog = nil
            end

            for Index = #Dialog.Elements, 1, -1 do
                local Element = Dialog.Elements[Index]
                if Element and Element.Destroy then
                    Element:Destroy()
                end
            end
            table.clear(Dialog.Elements)

            local CloseTween = TweenService:Create(DialogScale, Library.TweenInfo, { Scale = 0.95 })
            TweenService:Create(DialogOverlay, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            CloseTween:Play()

            task.delay(Library.TweenInfo.Time, function()
                setthreadidentity(8)
                DialogOverlay:Destroy()
            end)
            Library.Dialogues[Idx] = nil
        end

        DialogOverlay.MouseButton1Click:Connect(function()
            setthreadidentity(8)
            if Info.OutsideClickDismiss then
                Dialog:Dismiss()
            end
        end)

        function Dialog:RemoveFooterButton(ButtonIdx)
            setthreadidentity(8)
            if FooterButtonsList[ButtonIdx] then
                FooterButtonsList[ButtonIdx].Container:Destroy()
                FooterButtonsList[ButtonIdx] = nil
            end
        end

        function Dialog:SetButtonDisabled(ButtonIdx, Disabled)
            setthreadidentity(8)
            if FooterButtonsList[ButtonIdx] and type(FooterButtonsList[ButtonIdx].SetDisabled) == "function" then
                FooterButtonsList[ButtonIdx]:SetDisabled(Disabled)
            end
        end

        function Dialog:SetButtonOrder(ButtonIdx, Order)
            setthreadidentity(8)
            if FooterButtonsList[ButtonIdx] and FooterButtonsList[ButtonIdx].Container then
                FooterButtonsList[ButtonIdx].Container.LayoutOrder = Order
            end
        end

        function Dialog:AddFooterButton(ButtonIdx, ButtonInfo)
            setthreadidentity(8)
            Dialog:RemoveFooterButton(ButtonIdx)

            local WaitTime = ButtonInfo.WaitTime or 0

            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                LayoutOrder = ButtonInfo.Order or 0,
                ZIndex = 2,
                Parent = ButtonsHolder,
            })

            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"

            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                BackgroundTransparency = WaitTime > 0 and 0.5 or 0,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 2,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = TextBtn
                })
            )

            local _BtnPadding = New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or ButtonIdx,
                TextColor3 = TextColor,
                TextTransparency = WaitTime > 0 and 0.5 or 0,
                TextSize = 14,
                ZIndex = 2,
                Parent = TextBtn,
            })

            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ProgressBar
            if WaitTime > 0 then
                ProgressBar = New("Frame", {
                    BackgroundColor3 = "AccentColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -2),
                    Size = UDim2.new(0, 0, 0, 2),
                    ZIndex = 2,
                    Parent = TextBtn,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, Library.CornerRadius),
                        Parent = ProgressBar
                    })
                )
            end

            local IsActive = WaitTime <= 0

            local ButtonWrap = {
                Container = ButtonContainer,
                SetDisabled = function(self, Disabled)
                    setthreadidentity(8)
                    IsActive = not Disabled
                    if Disabled then
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0.5 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0.5 }):Play()
                    else
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0 }):Play()
                    end
                end
            }

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                setthreadidentity(8)
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                setthreadidentity(8)
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                setthreadidentity(8)
                if not IsActive then return end
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Dialog)
                end
                if Info.AutoDismiss then
                    Dialog:Dismiss()
                end
            end)

            if WaitTime > 0 then
                TweenService:Create(ProgressBar, TweenInfo.new(WaitTime, Enum.EasingStyle.Linear), {
                    Size = UDim2.new(1, 0, 0, 2)
                }):Play()

                task.delay(WaitTime, function()
                    setthreadidentity(8)
                    ButtonWrap:SetDisabled(false)
                    if ProgressBar then
                        TweenService:Create(ProgressBar, Library.TweenInfo, {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end)
            end

            FooterButtonsList[ButtonIdx] = ButtonWrap
        end

        for BIdx, BInfo in Info.FooterButtons do
            if type(BIdx) == "number" and BInfo.Id then BIdx = BInfo.Id end
            Dialog:AddFooterButton(BIdx, BInfo)
        end

        setmetatable(Dialog, BaseGroupbox)
        Library.Dialogues[Idx] = Dialog

        Dialog:Resize()

        Library.ActiveDialog = Dialog
        return Dialog
    end

    local GuiProperties = { "BackgroundTransparency" }
    local ImageProperties = { "BackgroundTransparency", "ImageTransparency" }
    local TextProperties = { "BackgroundTransparency", "TextTransparency" }
    local StrokeProperties = { "Transparency" }

    local function FadeInstance(Desc, Properties)
        setthreadidentity(8)
        local Cache = TransparencyCache[Desc]
        if not Cache then
            Cache = {}
            TransparencyCache[Desc] = Cache
        end

        for _, Prop in Properties do
            if not Library.Toggled then
                Cache[Prop] = Desc[Prop]
            end

            if Cache[Prop] ~= nil and Cache[Prop] ~= 1 then
                TweenService:Create(Desc, Library.WindowAnimationInfo, {
                    [Prop] = Library.Toggled and Cache[Prop] or 1,
                }):Play()
            end
        end
    end

    function Window:Toggle(Value: boolean?)
        setthreadidentity(8)
        if Fading then
            return
        end

        if Library.ActiveLoading then
            if Value == true then
                return
            end

            if not Library.Toggled then
                return
            end
        end

        if typeof(Value) == "boolean" then
            Library.Toggled = Value
        else
            Library.Toggled = not Library.Toggled
        end

        if Library.Animations and Library.Animations.ToggleWindow == true then
            local FadeTime = Library.WindowAnimationInfo.Time
            Fading = true

            if Library.Toggled then
                MainFrame.Visible = true
            end

            if Library.Toggled then
                FadeInstance(MainFrame, { "BackgroundTransparency" })
                task.wait(FadeTime / 2)
            else
                task.delay(FadeTime / 2, FadeInstance, MainFrame, { "BackgroundTransparency" })
            end

            for _, Instance in MainFrame:GetDescendants() do
                if Instance == TopBar then
                    continue
                end

                if Instance:IsA("GuiObject") then
                    local ClassName = Instance.ClassName
                    if ClassName == "ImageLabel" or ClassName == "ImageButton" then
                        FadeInstance(Instance, ImageProperties)
                    elseif ClassName == "TextLabel" or ClassName == "TextBox" or ClassName == "TextButton" then
                        FadeInstance(Instance, TextProperties)
                    else
                        FadeInstance(Instance, GuiProperties)
                    end
                elseif Instance.ClassName == "UIStroke" then
                    FadeInstance(Instance, StrokeProperties)
                end
            end

            task.delay(FadeTime, function()
                setthreadidentity(8)
                MainFrame.Visible = Library.Toggled
                Fading = false
            end)
        else
            MainFrame.Visible = Library.Toggled
        end

        if WindowInfo.UnlockMouseWhileOpen then
            ModalElement.Modal = Library.Toggled
        end

        if Library.Toggled and not Library.IsMobile then
            local ShowCursorBinding = Library.ShowCursorBinding
            Library.OriginalMouseIconEnabled = UserInputService.MouseIconEnabled

            pcall(function()
                setthreadidentity(8)
                RunService:UnbindFromRenderStep(ShowCursorBinding)
            end)
            RunService:BindToRenderStep(ShowCursorBinding, Enum.RenderPriority.Last.Value, function()
                setthreadidentity(8)
                UserInputService.MouseIconEnabled = not Library.ShowCustomCursor

                Cursor.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
                Cursor.Visible = Library.ShowCustomCursor

                if Library.Unloaded == true or not (Library.Toggled and ScreenGui and ScreenGui.Parent) then
                    RestoreMouseIcon()
                end
            end)
        elseif not Library.Toggled then
            RestoreMouseIcon()
            TooltipLabel.Visible = false

            for _, Option in Library.Options do
                if Option.Type == "ColorPicker" then
                    Option.ColorMenu:Close()
                    Option.ContextMenu:Close()
                elseif Option.Type == "Dropdown" or Option.Type == "KeyPicker" then
                    Option.Menu:Close()
                end
            end
        end
    end

    function Library:Toggle(Value: boolean?)
        setthreadidentity(8)
        return Window:Toggle(Value)
    end

    if WindowInfo.EnableSidebarResize then
        local Threshold = (WindowInfo.MinSidebarWidth + WindowInfo.SidebarCompactWidth) * WindowInfo.SidebarCollapseThreshold
        local StartPos, StartWidth
        local Dragging = false
        local Changed

        local SidebarGrabber = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(0, 8, 1, 0),
            Text = "",
            Parent = DividerLine,
        })
        SidebarGrabber.MouseEnter:Connect(function()
            setthreadidentity(8)
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library:GetLighterColor(Library.Scheme.OutlineColor),
            }):Play()
        end)
        SidebarGrabber.MouseLeave:Connect(function()
            setthreadidentity(8)
            if Dragging then
                return
            end
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.OutlineColor,
            }):Play()
        end)

        SidebarGrabber.InputBegan:Connect(function(Input: InputObject)
            setthreadidentity(8)
            if not IsClickInput(Input) then
                return
            end

            Library.CantDragForced = true

            StartPos = Input.Position
            StartWidth = Window:GetSidebarWidth()
            Dragging = true

            Changed = Input.Changed:Connect(function()
                setthreadidentity(8)
                if Input.UserInputState ~= Enum.UserInputState.End then
                    return
                end

                Library.CantDragForced = false
                TweenService:Create(DividerLine, Library.TweenInfo, {
                    BackgroundColor3 = Library.Scheme.OutlineColor,
                }):Play()

                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end
            end)
        end)

        Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
            setthreadidentity(8)
            if not Library.Toggled or not (ScreenGui and ScreenGui.Parent) then
                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end

                return
            end

            if Dragging and IsHoverInput(Input) then
                local Delta = Input.Position - StartPos
                local Width = StartWidth + Delta.X

                if WindowInfo.DisableCompactingSnap then
                    Window:SetSidebarWidth(Width)
                    return
                end

                if Width > Threshold then
                    Window:SetSidebarWidth(math.max(Width, WindowInfo.MinSidebarWidth))
                else
                    Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
                end
            end
        end))
    end

    if WindowInfo.KeyStatus == true then
        Window:AddKeyStatus({})
    elseif typeof(WindowInfo.KeyStatus) == "table" then
        Window:AddKeyStatus(WindowInfo.KeyStatus)
    end

    if WindowInfo.CommandPalette then
        Window:CreateCommandPalette()
    end

    Window:SetAlwaysOnTop(WindowInfo.AlwaysOnTop)
    if WindowInfo.EnableCompacting and WindowInfo.SidebarCompacted then
        Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
    end
    if WindowInfo.AutoShow and not Library.ActiveLoading then
        task.spawn(Library.Toggle)
    end

    if Library.IsMobile then
        local ToggleButton = Library:AddDraggableButton("Toggle", function()
            setthreadidentity(8)
            Library:Toggle()
        end, true, true)

        local LockButton = Library:AddDraggableButton("Lock", function(self)
            setthreadidentity(8)
            Library.CantDragForced = not Library.CantDragForced
            self:SetText(Library.CantDragForced and "Unlock" or "Lock")
        end, true, true)

        if WindowInfo.MobileButtonsSide == "Right" then
            ToggleButton.Button.AnchorPoint = Vector2.new(1, 0)
            ToggleButton.Button.Position = UDim2.new(1, -6, 0, 6)

            LockButton.Button.AnchorPoint = Vector2.new(1, 0)
            LockButton.Button.Position = UDim2.new(1, -(ToggleButton.Button.Size.X.Offset + 12), 0, 6)
        else
            ToggleButton.Button.AnchorPoint = Vector2.new(0, 0)
            ToggleButton.Button.Position = UDim2.fromOffset(6, 6)

            LockButton.Button.AnchorPoint = Vector2.new(0, 0)
            LockButton.Button.Position = UDim2.fromOffset(ToggleButton.Button.Size.X.Offset + 12, 6)
        end

        if WindowInfo.ShowMobileButtons == false then
            ToggleButton.Button.Visible = false
            LockButton.Button.Visible = false
        end
    end

    --// Execution \\--
    Library:GiveSignal(SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        setthreadidentity(8)
        Library:UpdateSearch(SearchBox.Text)
    end))

    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
        setthreadidentity(8)
        if Library.Unloaded then
            return
        end

        if Input.KeyCode == Enum.KeyCode.Escape then
            -- Releasing focus from a text input takes priority and never toggles the window --
            local FocusedBox = UserInputService:GetFocusedTextBox()
            if FocusedBox then
                FocusedBox:ReleaseFocus()
                return
            end

            -- Dismiss the topmost dialog before closing any open menu --
            if Library.ActiveDialog and Library.ActiveDialog.OutsideClickDismiss ~= false then
                Library.ActiveDialog:Dismiss()
                return
            end

            if CurrentMenu then
                CurrentMenu:Close()
                return
            end

            return
        end

        if UserInputService:GetFocusedTextBox() then
            return
        end

        if Input.KeyCode == Library.ToggleKeybind then
            Library:Toggle()
        end
    end))

    Library:GiveSignal(UserInputService.WindowFocused:Connect(function()
        setthreadidentity(8)
        Library.IsRobloxFocused = true
    end))
    Library:GiveSignal(UserInputService.WindowFocusReleased:Connect(function()
        setthreadidentity(8)
        Library.IsRobloxFocused = false
    end))

    Window.MainFrame = MainFrame
    Library.Window = Window

    return Window
end

function Library:CreateLoading(LoadingInfo)
    setthreadidentity(8)
    if Library.ActiveLoading then
        warn("Loading GUI already exists, you cannot create multiple Loading GUIs.")
        return Library.ActiveLoading
    end

    LoadingInfo = Library:Validate(LoadingInfo, Templates.Loading)

    local Loading = {
        CurrentStep = LoadingInfo.CurrentStep,
        TotalSteps = LoadingInfo.TotalSteps,

        ShowSidebar = LoadingInfo.ShowSidebar,
        AutoResizeHeight = LoadingInfo.AutoResizeHeight,
        AlwaysOnTop = LoadingInfo.AlwaysOnTop,

        IsError = false,
        Destroyed = false,

        WindowWidth = LoadingInfo.WindowWidth,
        WindowHeight = LoadingInfo.WindowHeight,
        BaseWindowHeight = LoadingInfo.WindowHeight,
        WindowErrorHeight = LoadingInfo.WindowHeight,

        ContentWidth = LoadingInfo.ContentWidth,
        SidebarWidth = LoadingInfo.SidebarWidth,
    }

    --// ScreenGui \\--
    local ScreenGui = New("ScreenGui", {
        Name = "ObsidianLoading",
        DisplayOrder = 999,
        ResetOnSpawn = false
    })
    ParentUI(ScreenGui)
    Loading.ScreenGui = ScreenGui
    SetAlwaysOnTop(ScreenGui, LoadingInfo.AlwaysOnTop)

    ScreenGui.DescendantRemoving:Connect(function(Instance)
        setthreadidentity(8)
        task.defer(function()
            setthreadidentity(8)
            if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
                return
            end

            Library:RemoveFromRegistry(Instance)
        end)
    end)

    --// Main Frame \\--
    local MainFrame = New("TextButton", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = function()
            setthreadidentity(8)
            return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
        end,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(Loading.ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth, Loading.WindowHeight),
        ClipsDescendants = true,
        Text = "",
        AutoButtonColor = false,
        Parent = ScreenGui,
    })
    Library:AddOutline(MainFrame)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = MainFrame }))

    local MainScale = New("UIScale", {
        Scale = Library.IsMobile and 0.8 or 1,
        Parent = MainFrame
    })
    table.insert(Library.Scales, MainScale)
    Library.ScalesOffset[MainScale] = Library.IsMobile and 0.2 or 0

    --// Layout Containers \\--
    local Container = New("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, Loading.ContentWidth, 1, 0),
        Parent = MainFrame,
    })

    local SideBar = New("Frame", {
        Name = "SideBar",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(Loading.ContentWidth, 0),
        Size = UDim2.new(0, Loading.ShowSidebar and Loading.SidebarWidth or 0, 1, 0),
        ClipsDescendants = true,
        Visible = Loading.ShowSidebar,
        Parent = MainFrame,
    })
    local SidebarCorner = New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = SideBar })
    table.insert(Library.Corners, SidebarCorner)

    Library:AddOutline(SideBar)

    local SidebarDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Visible = Loading.ShowSidebar,
        Parent = SideBar,
    })

    --// Top Bar \\--
    local TopBar = New("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = 2,
        Parent = Container,
    })
    Library:MakeDraggable(MainFrame, TopBar, true, true)

    local TitleHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = TopBar,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = TitleHolder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = TitleHolder,
    })

    if LoadingInfo.Icon then
        local Icon = Library:GetCustomIcon(LoadingInfo.Icon)
        local _WindowIcon = New("ImageLabel", {
            Size = LoadingInfo.IconSize,
            Parent = TitleHolder,
        })
        if Icon then
            Library:ApplyLucideIcon(_WindowIcon, Icon)
        end
    else
        local _WindowIcon = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = LoadingInfo.IconSize,
            Text = LoadingInfo.Title:sub(1, 1),
            TextScaled = true,
            Visible = false,
            Parent = TitleHolder,
        })
    end

    local TitleX = Library:GetTextBounds(
        LoadingInfo.Title,
        Library.Scheme.Font,
        20,
        TitleHolder.AbsoluteSize.X - (LoadingInfo.Icon and (LoadingInfo.IconSize.X.Offset + 6) or 0) - 12
    )
    local _WindowTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, TitleX, 1, 0),
        Text = LoadingInfo.Title,
        TextSize = 20,
        Parent = TitleHolder,
    })

    Library:MakeLine(Container, {
        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(1, 0, 0, 1),
    })

    --// Loading Content Elements \\--
    local InnerContent = New("Frame", {
        Name = "InnerContent",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        Parent = Container,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12),
        Parent = InnerContent,
    })

    local IconHolder = New("Frame", {
        Name = "IconHolder",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(64, 64),
        Parent = InnerContent,
    })

    local LoaderIcon = Library:GetCustomIcon(LoadingInfo.LoadingIcon)
    local LoadingIcon = New("ImageLabel", {
        Name = "LoaderIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        ImageColor3 = LoadingInfo.LoadingIconColor or ((LoadingInfo.LoadingIcon == Templates.Loading.LoadingIcon) and "AccentColor" or "WhiteColor"),
        Parent = IconHolder,
    })
    if LoaderIcon then
        Library:ApplyLucideIcon(LoadingIcon, LoaderIcon)
    end

    local RotationTween
    if LoadingInfo.LoadingIconTweenTime > 0 then
        RotationTween = TweenService:Create(
            LoadingIcon,
            TweenInfo.new(LoadingInfo.LoadingIconTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
            { Rotation = 360 }
        )
        RotationTween:Play()
    end

    local MessageLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 18,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    local DescriptionLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 14,
        TextTransparency = 0.5,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    --// Progress Bar \\--
    local SliderBar = New("Frame", {
        BackgroundColor3 = "MainColor",
        Size = UDim2.new(0.7, 0, 0, 15),
        Parent = InnerContent,
    })
    Library:AddOutline(SliderBar)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderBar }))

    local SliderFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = SliderBar,
    })
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderFill }))

    local ProgressLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        TextSize = 14,
        ZIndex = 2,
        Parent = SliderBar,
    })
    New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        Color = "DarkColor",
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = ProgressLabel,
    })

    --// Sidebar Object \\--
    local SidebarScrolling = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = "OutlineColor",
        Parent = SideBar,
    })
    local SidebarList = New("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = SidebarScrolling,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        Parent = SidebarScrolling,
    })

    local SidebarObject = {
        Elements = {},
        DependencyBoxes = {},
        Tabboxes = {},

        BoxHolder = SidebarScrolling,
        Container = SidebarScrolling,

        Resize = function(self)
            setthreadidentity(8)
            SidebarScrolling.CanvasSize = UDim2.fromOffset(0, SidebarList.AbsoluteContentSize.Y + 24)
        end,
        Tab = {
            Elements = {},
            DependencyBoxes = {},
            DependencyGroupboxes = {},
            Tabboxes = {},
        },
    }

    SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        setthreadidentity(8)
        SidebarObject:Resize()
    end)

    setmetatable(SidebarObject, BaseGroupbox)
    Loading.Sidebar = SidebarObject

    --// Error Frame \\--
    local ErrorFrame = New("Frame", {
        Name = "Error",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        ClipsDescendants = true,
        Visible = false,
        Parent = Container,
    })

    local _ErrorTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 15),
        Size = UDim2.new(1, -30, 0, 18),
        Text = "Error",
        TextColor3 = "RedColor",
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ErrorFrame,
    })

    local ErrorLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 39),
        Size = UDim2.new(1, -30, 1, -90),
        Text = "Error Message",
        TextSize = 14,
        TextTransparency = 0.2,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = ErrorFrame,
    })

    local ErrorButtonsDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, -48),
        Size = UDim2.new(1, -30, 0, 1),
        Visible = false,
        Parent = ErrorFrame,
    })

    local ErrorButtonsHolder = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 42),
        Visible = false,
        Parent = ErrorFrame,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ErrorButtonsHolder,
    })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        Parent = ErrorButtonsHolder,
    })

    function Loading:UpdateLayout()
        setthreadidentity(8)
        if Loading.IsError then
            Loading:RecalculateErrorHeight()
        end

        local ShowSidebar = Loading.ShowSidebar
        local FinalWidth = ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth
        local FinalHeight = Loading.IsError and Loading.WindowErrorHeight or Loading.WindowHeight

        if ShowSidebar then
            SideBar.Visible = true
            SidebarDivider.Visible = true
        end

        TweenService:Create(MainFrame, Library.TweenInfo, { Size = UDim2.fromOffset(FinalWidth, FinalHeight) }):Play()
        TweenService:Create(SideBar, Library.TweenInfo, { Position = UDim2.fromOffset(Loading.ContentWidth, 0), Size = UDim2.new(0, ShowSidebar and Loading.SidebarWidth or 0, 1, 0) }):Play()
        TweenService:Create(Container, Library.TweenInfo, { Size = UDim2.new(0, ShowSidebar and Loading.ContentWidth or Loading.WindowWidth, 1, 0) }):Play()

        if not ShowSidebar then
            task.delay(Library.TweenInfo.Time, function()
                setthreadidentity(8)
                if not Loading.ShowSidebar then
                    SideBar.Visible = false
                    SidebarDivider.Visible = false
                end
            end)
        end
    end

    --// Content Page \\--
    function Loading:RecalculateLoadingHeight()
        setthreadidentity(8)
        if not Loading.AutoResizeHeight then
            return
        end

        local RequiredHeight =
              49 -- TopBar
            + 48 -- Padding
            + InnerContent.UIListLayout.AbsoluteContentSize.Y

        Loading.WindowHeight = math.max(Loading.BaseWindowHeight, RequiredHeight)
    end

    function Loading:SetMessage(Text)
        setthreadidentity(8)
        MessageLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetDescription(Text)
        setthreadidentity(8)
        DescriptionLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetLoadingIcon(Icon)
        setthreadidentity(8)
        local IconData = Library:GetCustomIcon(Icon)
        assert(IconData, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        Library:ApplyLucideIcon(LoadingIcon, IconData)
    end

    function Loading:SetLoadingIconTweenTime(TweenTime)
        setthreadidentity(8)
        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        if TweenTime > 0 then
            RotationTween = TweenService:Create(
                LoadingIcon,
                TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
                { Rotation = 360 }
            )
            RotationTween:Play()
        else
            LoadingIcon.Rotation = 0
        end
    end

    function Loading:SetLoadingIconColor(Color)
        setthreadidentity(8)
        LoadingIcon.ImageColor3 = Color
    end

    function Loading:SetCurrentStep(Step)
        setthreadidentity(8)
        Loading.CurrentStep = math.clamp(Step, 0, Loading.TotalSteps)

        local Progress = Loading.CurrentStep / Loading.TotalSteps
        TweenService:Create(SliderFill, Library.TweenInfo, { Size = UDim2.fromScale(Progress, 1) }):Play()

        ProgressLabel.Text = string.format("%d/%d", Loading.CurrentStep, Loading.TotalSteps)
    end

    function Loading:SetTotalSteps(Steps)
        setthreadidentity(8)
        Loading.TotalSteps = Steps
        Loading:SetCurrentStep(Loading.CurrentStep)
    end

    --// Size \\--
    function Loading:SetWindowHeight(Height)
        setthreadidentity(8)
        Loading.WindowHeight = Height
        Loading:UpdateLayout()
    end

    function Loading:SetWindowWidth(Width)
        setthreadidentity(8)
        Loading.WindowWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetContentWidth(Width)
        setthreadidentity(8)
        Loading.ContentWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetSidebarWidth(Width)
        setthreadidentity(8)
        Loading.SidebarWidth = Width
        Loading:UpdateLayout()
    end

    --// Sidebar \\--
    function Loading:ShowSidebarPage(Bool)
        setthreadidentity(8)
        Loading.ShowSidebar = Bool
        Loading:UpdateLayout()
    end

    --// Error Page \\--
    function Loading:ShowErrorPage(Enabled)
        setthreadidentity(8)
        Loading.IsError = Enabled
        InnerContent.Visible = not Enabled
        ErrorFrame.Visible = Enabled

        if Loading.ShowSidebar then
            Loading:ShowSidebarPage(not Enabled)
        else
            Loading:UpdateLayout()
        end
    end

    function Loading:RecalculateErrorHeight()
        setthreadidentity(8)
        local TargetWidth = (Loading.ShowSidebar and Loading.ContentWidth or Loading.WindowWidth) - 30
        local _, ErrorY = Library:GetTextBounds(ErrorLabel.Text, Library.Scheme.Font, 14, TargetWidth)

        ErrorLabel.Size = UDim2.new(1, -30, 0, ErrorY)

        local HasButtons = ErrorButtonsHolder.Visible
        local RequiredHeight =
              49                        -- TopBar
            + 15                        -- Padding Top
            + 18                        -- Title Height
            + 6                         -- Padding between Title and Label
            + ErrorY                    -- Label Height
            + 15                        -- Padding between Label and Buttons
            + (HasButtons and 48 or 0)  -- Buttons Area

        Loading.WindowErrorHeight = RequiredHeight -- math.max(Loading.WindowHeight, RequiredHeight)
    end

    function Loading:SetErrorMessage(Text)
        setthreadidentity(8)
        ErrorLabel.Text = Text
        Loading:UpdateLayout()
    end

    function Loading:SetErrorButtons(Buttons)
        setthreadidentity(8)
        assert(typeof(Buttons) == "table", "Buttons must be a table")

        for _, button in ErrorButtonsHolder:GetChildren() do
            if button:IsA("Frame") then
                button:Destroy()
            end
        end

        local HasButtons = GetTableSize(Buttons) > 0
        ErrorButtonsHolder.Visible = HasButtons
        ErrorButtonsDivider.Visible = HasButtons

        for Idx, ButtonInfo in Buttons do
            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                Parent = ErrorButtonsHolder,
            })

            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"

            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = TextBtn
                })
            )

            New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or Idx,
                TextColor3 = TextColor,
                TextSize = 14,
                Parent = TextBtn,
            })

            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                setthreadidentity(8)
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                setthreadidentity(8)
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                setthreadidentity(8)
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Loading)
                end
            end)
        end

        Loading:UpdateLayout()
    end

    --// Destroy/Continue \\--
    function Loading:Destroy()
        setthreadidentity(8)
        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        ScreenGui:Destroy()
        Loading.Destroyed = true
        Library.ActiveLoading = nil

        if Library.Toggle and Library.Toggled == false and Library.Unloaded ~= true then
            Library:Toggle(true)
        end
    end

    Loading.Continue = Loading.Destroy;

    if Library.Toggle and Library.Toggled and Library.Unloaded ~= true then
        Library:Toggle(false)
    end

    Loading:SetCurrentStep(Loading.CurrentStep)

    Library.ActiveLoading = Loading
    return Loading
end

local function OnPlayerChange()
    setthreadidentity(8)
    if Library.Unloaded then
        return
    end

    local PlayerList, ExcludedPlayerList = GetPlayers(), GetPlayers(true)
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Player" then
            Dropdown:SetValues(Dropdown.ExcludeLocalPlayer and ExcludedPlayerList or PlayerList)
        end
    end
end

local function OnTeamChange()
    setthreadidentity(8)
    if Library.Unloaded then
        return
    end

    local TeamList = GetTeams()
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Team" then
            Dropdown:SetValues(TeamList)
        end
    end
end

Library:GiveSignal(Players.PlayerAdded:Connect(OnPlayerChange))
Library:GiveSignal(Players.PlayerRemoving:Connect(OnPlayerChange))

Library:GiveSignal(Teams.ChildAdded:Connect(OnTeamChange))
Library:GiveSignal(Teams.ChildRemoved:Connect(OnTeamChange))

function Library:Unload()
    setthreadidentity(8)
    Library.Unloaded = true
    for _, notification in table.clone(Library.Notifications) do notification:Destroy("unload", true) end
    table.clear(NotifyOrder)

    --// Disconnect connections
    for Index = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Index)

        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end

    --// Run Unload Callbacks
    for _ = 1, #Library.UnloadSignals do
        local Callback = table.remove(Library.UnloadSignals, 1)

        if Callback then
            Library:SafeCallback(Callback)
        end
    end

    if Library.CommandPalette and Library.CommandPalette.Destroy then
        Library:SafeCallback(Library.CommandPalette.Destroy, Library.CommandPalette)
    end

    for Index = #Library.KeyStatusComponents, 1, -1 do
        local Component = Library.KeyStatusComponents[Index]
        if Component and Component.Destroy then
            Library:SafeCallback(Component.Destroy, Component)
        end
    end

    --// Destroy elements
    for Index = #Library.Tabs, 1, -1 do
        local Tab = table.remove(Library.Tabs, Index)

        if Tab and Tab.Destroy then
            Library:SafeCallback(Tab.Destroy, Tab)
        end
    end

    for Index = #Tooltips, 1, -1 do
        local Tooltip = table.remove(Tooltips, Index)

        if Tooltip and Tooltip.Destroy then
            Library:SafeCallback(Tooltip.Destroy, Tooltip)
        end
    end

    if Library.ActiveLoading then
        Library.ActiveLoading:Destroy()
    end

    if ScreenGui then
        ScreenGui:Destroy()
    end

    --// Clear tables
    table.clear(Library.Registry)

    table.clear(Options)
    table.clear(Toggles)
    table.clear(Buttons)
    table.clear(Labels)
    table.clear(Tooltips)

    table.clear(Library.Tabs)
    table.clear(Library.TabButtons)

    table.clear(Library.Scales)
    table.clear(Library.ScalesOffset)

    table.clear(Library.Corners)
    table.clear(Library.SpecificCorners)
    table.clear(Library.ContextMenus)

    table.clear(Library.Notifications)
    table.clear(Library.Dialogues)
    table.clear(Library.DraggableElements)
    table.clear(Library.KeybindToggles)
    table.clear(Library.DependencyBoxes)
    table.clear(Library.KeyStatusComponents)
    table.clear(Library.Commands)

    table.clear(TransparencyCache)
    table.clear(ActiveTabTweens)

    Library.Toggle = function(...)
        setthreadidentity(8)
    end
    Library.ScreenGui = nil
    Library.Floats = nil
    Library.Overlay = nil
    Library.WindowContainer = nil
    Library.KeybindFrame = nil
    Library.KeybindContainer = nil
    Library.AnonymousModeToggle = nil
    Library.AnonymousMode = false
    Library.Flags.AnonymousMode = false
    Library.CommandPalette = nil

    getgenv().Library = nil
end

getgenv().Library = Library
return Library
