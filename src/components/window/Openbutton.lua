local OpenButton = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween


local cloneref = (cloneref or clonereference or function(instance) return instance end)


local UserInputService = cloneref(game:GetService("UserInputService"))

-- ── Square size presets ────────────────────────────────────────
-- ใช้ผ่าน Size = "sm" / "md" / "lg" / "xl"  หรือตัวเลขตรง ๆ เช่น Size = 60
local SQUARE_SIZES = {
    sm  = 44,
    md  = 56,
    lg  = 68,
    xl  = 80,
}


function OpenButton.New(Window)
    local OpenButtonMain = {
        Button = nil
    }

    local Icon

    local Title = New("TextLabel", {
        Text = Window.Title,
        TextSize = 17,
        FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
        BackgroundTransparency = 1,
        AutomaticSize = "XY",
    })

    local DragIconData = Creator.Icon("move")
    local Drag = New("Frame", {
        Size = UDim2.new(0,44-8,0,44-8),
        BackgroundTransparency = 1,
        Name = "Drag",
    }, {
        New("ImageLabel", {
            Image = DragIconData and DragIconData[1],
            ImageRectOffset = DragIconData and DragIconData[2] and DragIconData[2].ImageRectPosition,
            ImageRectSize = DragIconData and DragIconData[2] and DragIconData[2].ImageRectSize,
            Size = UDim2.new(0,18,0,18),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            ThemeTag = {
                ImageColor3 = "Icon",
            },
            ImageTransparency = .3,
        })
    })
    local Divider = New("Frame", {
        Size = UDim2.new(0,1,1,0),
        Position = UDim2.new(0,20+16,0.5,0),
        AnchorPoint = Vector2.new(0,0.5),
        BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = .9,
    })

    local Container = New("Frame", {
        Size = UDim2.new(0,0,0,0),
        Position = UDim2.new(0.5,0,0,6+44/2),
        AnchorPoint = Vector2.new(0.5,0.5),
        Parent = Window.Parent,
        BackgroundTransparency = 1,
        Active = true,
        Visible = false,
    })


    local UIScale = New("UIScale", {
        Scale = 1,
    })

    local Button = New("Frame", {
        Size = UDim2.new(0,0,0,44),
        AutomaticSize = "X",
        Parent = Container,
        Active = false,
        BackgroundTransparency = .25,
        ZIndex = 99,
        BackgroundColor3 = Color3.new(0,0,0),
    }, {
        UIScale,
	    New("UICorner", {
            CornerRadius = UDim.new(1,0)
        }),
        New("UIStroke", {
            Thickness = 1,
            ApplyStrokeMode = "Border",
            Color = Color3.new(1,1,1),
            Transparency = 0,
        }, {
            New("UIGradient", {
                Color = ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff"))
            })
        }),
        Drag,
        Divider,

        New("UIListLayout", {
            Padding = UDim.new(0, 4),
            FillDirection = "Horizontal",
            VerticalAlignment = "Center",
        }),

        New("TextButton",{
            AutomaticSize = "XY",
            Active = true,
            BackgroundTransparency = 1,
            Size = UDim2.new(0,0,0,44-(4*2)),
            BackgroundColor3 = Color3.new(1,1,1),
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(1,-4)
            }),
            Icon,
            New("UIListLayout", {
                Padding = UDim.new(0, Window.UIPadding),
                FillDirection = "Horizontal",
                VerticalAlignment = "Center",
            }),
            Title,
            New("UIPadding", {
                PaddingLeft = UDim.new(0,7+4),
                PaddingRight = UDim.new(0,7+4),
            }),
        }),
        New("UIPadding", {
            PaddingLeft = UDim.new(0,4),
            PaddingRight = UDim.new(0,4),
        })
    })

    OpenButtonMain.Button = Button



    function OpenButtonMain:SetIcon(newIcon)
        if Icon then
            Icon:Destroy()
        end
        if newIcon then
            Icon = Creator.Image(
                newIcon,
                Window.Title,
                0,
                Window.Folder,
                "OpenButton",
                true,
                Window.IconThemed
            )
            Icon.Size = UDim2.new(0,22,0,22)
            Icon.LayoutOrder = -1
            Icon.Parent = OpenButtonMain.Button.TextButton
        end
    end

    if Window.Icon then
        OpenButtonMain:SetIcon(Window.Icon)
    end



    Creator.AddSignal(Button:GetPropertyChangedSignal("AbsoluteSize"), function()
        Container.Size = UDim2.new(
            0, Button.AbsoluteSize.X,
            0, Button.AbsoluteSize.Y
        )
    end)

    Creator.AddSignal(Button.TextButton.MouseEnter, function()
        Tween(Button.TextButton, .1, {BackgroundTransparency = .93}):Play()
    end)
    Creator.AddSignal(Button.TextButton.MouseLeave, function()
        Tween(Button.TextButton, .1, {BackgroundTransparency = 1}):Play()
    end)

    local DragModule = Creator.Drag(Container)


    function OpenButtonMain:Visible(v)
        Container.Visible = v
    end

    function OpenButtonMain:SetScale(scale)
        UIScale.Scale = scale
    end

    -- ── Square mode helpers ────────────────────────────────────
    -- เก็บ SquareIcon ที่สร้างโดย applySquare ไว้ลบได้ตอน reset
    local _squareIcon = nil

    local function _applySquare(cfg, sz, radius, strokeColor, strokeThick)
        -- ปิด AutomaticSize ล็อกขนาดเป็น sz x sz
        Button.AutomaticSize = Enum.AutomaticSize.None
        Button.Size          = UDim2.new(0, sz, 0, sz)

        -- ซ่อน layout / padding / drag / divider / textbutton ทั้งหมดของ normal mode
        Button.TextButton.Visible = false
        Drag.Visible              = false
        Divider.Visible           = false

        local listLayout = Button:FindFirstChildOfClass("UIListLayout")
        if listLayout then listLayout.Enabled = false end

        local outerPad = Button:FindFirstChildOfClass("UIPadding")
        if outerPad then
            outerPad.PaddingLeft   = UDim.new(0,0)
            outerPad.PaddingRight  = UDim.new(0,0)
            outerPad.PaddingTop    = UDim.new(0,0)
            outerPad.PaddingBottom = UDim.new(0,0)
        end

        -- corner
        Button.UICorner.CornerRadius = radius

        -- stroke + gradient
        Button.UIStroke.Thickness = strokeThick
        Button.UIStroke.UIGradient.Color = strokeColor

        -- ลบ square icon เก่าถ้ามี
        if _squareIcon then
            _squareIcon:Destroy()
            _squareIcon = nil
        end

        -- สร้าง icon ตรงกลาง
        if cfg.Icon then
            local iconPx = math.floor(sz * 0.48)  -- ~48% ของขนาดปุ่ม
            local img = Instance.new("ImageLabel")
            img.Name                   = "_SquareIcon"
            img.Size                   = UDim2.new(0, iconPx, 0, iconPx)
            img.Position               = UDim2.new(0.5, -iconPx/2, 0.5, -iconPx/2)
            img.BackgroundTransparency = 1
            img.ScaleType              = Enum.ScaleType.Fit
            img.ZIndex                 = 100
            img.Parent                 = Button

            -- โหลด icon ผ่าน Creator.Image เหมือน SetIcon ปกติ
            local loaded = Creator.Image(
                cfg.Icon,
                Window.Title,
                0,
                Window.Folder,
                "OpenButton_sq",
                true,
                Window.IconThemed
            )
            if loaded then
                img.Image             = loaded.Image
                img.ImageRectOffset   = loaded.ImageRectOffset
                img.ImageRectSize     = loaded.ImageRectSize
            else
                img.Image = cfg.Icon  -- fallback: rbxassetid ตรง
            end

            _squareIcon = img
        end

        -- sync Container ด้วยเพราะ AbsoluteSize signal อาจ delay
        Container.Size = UDim2.new(0, sz, 0, sz)
    end

    local function _resetSquare()
        -- คืนสถานะ normal mode
        Button.AutomaticSize      = Enum.AutomaticSize.X
        Button.Size               = UDim2.new(0, 0, 0, 44)
        Button.TextButton.Visible = true
        Drag.Visible              = true
        Divider.Visible           = true

        local listLayout = Button:FindFirstChildOfClass("UIListLayout")
        if listLayout then listLayout.Enabled = true end

        local outerPad = Button:FindFirstChildOfClass("UIPadding")
        if outerPad then
            outerPad.PaddingLeft  = UDim.new(0,4)
            outerPad.PaddingRight = UDim.new(0,4)
        end

        if _squareIcon then
            _squareIcon:Destroy()
            _squareIcon = nil
        end
    end
    -- ──────────────────────────────────────────────────────────

    function OpenButtonMain:Edit(OpenButtonConfig)
        local OpenButtonModule = {
            Title           = OpenButtonConfig.Title,
            Icon            = OpenButtonConfig.Icon,
            Enabled         = OpenButtonConfig.Enabled,
            Position        = OpenButtonConfig.Position,
            OnlyIcon        = OpenButtonConfig.OnlyIcon or false,
            Draggable       = OpenButtonConfig.Draggable or nil,
            OnlyMobile      = OpenButtonConfig.OnlyMobile,
            CornerRadius    = OpenButtonConfig.CornerRadius or UDim.new(1, 0),
            StrokeThickness = OpenButtonConfig.StrokeThickness or 2,
            Scale           = OpenButtonConfig.Scale or 1,
            Color           = OpenButtonConfig.Color
                or ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff")),
            -- NEW
            Style           = OpenButtonConfig.Style,   -- "square" | nil
            Size            = OpenButtonConfig.Size,    -- "sm"/"md"/"lg"/"xl" | number
        }

        if OpenButtonModule.Enabled == false then
            Window.IsOpenButtonEnabled = false
        end

        if OpenButtonModule.OnlyMobile ~= false then
            OpenButtonModule.OnlyMobile = true
        else
            Window.IsPC = false
        end

        -- ── SQUARE MODE ────────────────────────────────────────
        if OpenButtonModule.Style == "square" then
            -- resolve size
            local sz
            if type(OpenButtonModule.Size) == "number" then
                sz = OpenButtonModule.Size
            elseif type(OpenButtonModule.Size) == "string" then
                sz = SQUARE_SIZES[OpenButtonModule.Size] or SQUARE_SIZES.md
            else
                sz = SQUARE_SIZES.md
            end

            -- Draggable = false อัตโนมัติใน square mode (ไม่มี drag handle)
            if DragModule then
                DragModule:Set(false)
            end

            if OpenButtonModule.Position and Container then
                Container.Position = OpenButtonModule.Position
            end

            _applySquare(
                OpenButtonModule,
                sz,
                OpenButtonModule.CornerRadius,
                OpenButtonModule.Color,
                OpenButtonModule.StrokeThickness
            )

            OpenButtonMain:SetScale(OpenButtonModule.Scale)
            return  -- ออกก่อน ไม่ต้องไปทำ normal mode logic
        end

        -- ── NORMAL MODE (เหมือนเดิมทุกอย่าง) ──────────────────
        -- reset square ถ้าเคย square แล้วสลับกลับ
        _resetSquare()

        if OpenButtonModule.Draggable == false and Drag and Divider then
            Drag.Visible = OpenButtonModule.Draggable
            Divider.Visible = OpenButtonModule.Draggable

            if DragModule then
                DragModule:Set(OpenButtonModule.Draggable)
            end
        end

        if OpenButtonModule.Position and Container then
            Container.Position = OpenButtonModule.Position
        end

        if OpenButtonModule.OnlyIcon == true and Title then
            Title.Visible = false
            Button.TextButton.UIPadding.PaddingLeft = UDim.new(0,7)
            Button.TextButton.UIPadding.PaddingRight = UDim.new(0,7)
        elseif OpenButtonModule.OnlyIcon == false then
            Title.Visible = true
            Button.TextButton.UIPadding.PaddingLeft = UDim.new(0,7+4)
            Button.TextButton.UIPadding.PaddingRight = UDim.new(0,7+4)
        end

        if Title then
            if OpenButtonModule.Title then
                Title.Text = OpenButtonModule.Title
                Creator:ChangeTranslationKey(Title, OpenButtonModule.Title)
            elseif OpenButtonModule.Title == nil then
                --Title.Visible = false
            end
        end

        if OpenButtonModule.Icon then
            OpenButtonMain:SetIcon(OpenButtonModule.Icon)
        end

        Button.UIStroke.UIGradient.Color = OpenButtonModule.Color
        if Glow then
            Glow.UIGradient.Color = OpenButtonModule.Color
        end

        Button.UICorner.CornerRadius = OpenButtonModule.CornerRadius
        Button.TextButton.UICorner.CornerRadius = UDim.new(OpenButtonModule.CornerRadius.Scale, OpenButtonModule.CornerRadius.Offset-4)
        Button.UIStroke.Thickness = OpenButtonModule.StrokeThickness

        OpenButtonMain:SetScale(OpenButtonModule.Scale)
    end

    return OpenButtonMain
end



return OpenButton
