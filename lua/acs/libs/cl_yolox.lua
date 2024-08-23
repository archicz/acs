local rtWidth = 416
local rtHeight = 416
local nextSnap = 0
local snapFPS = 10

require("yolox")
YOLOX.Initialize("yolox_tiny.onnx", 416, 416)
YOLOX.SetMean(0.485, 0.456, 0.406)
YOLOX.SetNormal(0.229, 0.224, 0.225)
YOLOX.SetNMSThreshold(0.5)
YOLOX.SetProbabilityThreshold(0.6)
YOLOX.CreateSession()

local rtTexture = GetRenderTargetEx("somename",
    rtWidth, rtHeight,
	RT_SIZE_NO_CHANGE,
	MATERIAL_RT_DEPTH_SEPARATE,
	bit.bor(2, 256),
	0,
	IMAGE_FORMAT_BGRA8888
)

local rtMaterial = CreateMaterial("rtmaterial", "UnlitGeneric",
{
	["$basetexture"] = rtTexture:GetName(),
	["$translucent"] = "0"
});

local yoloxLabels =
{
    "person",
    "bicycle",
    "car",
    "motorbike",
    "aeroplane",
    "bus",
    "train",
    "truck",
    "boat",
    "traffic light",
    "fire hydrant",
    "stop sign",
    "parking meter",
    "bench",
    "bird",
    "cat",
    "dog",
    "horse",
    "sheep",
    "cow",
    "elephant",
    "bear",
    "zebra",
    "giraffe",
    "backpack",
    "umbrella",
    "handbag",
    "tie",
    "suitcase",
    "frisbee",
    "skis",
    "snowboard",
    "sports ball",
    "kite",
    "baseball bat",
    "baseball glove",
    "skateboard",
    "surfboard",
    "tennis racket",
    "bottle",
    "wine glass",
    "cup",
    "fork",
    "knife",
    "spoon",
    "bowl",
    "banana",
    "apple",
    "sandwich",
    "orange",
    "broccoli",
    "carrot",
    "hot dog",
    "pizza",
    "donut",
    "cake",
    "chair",
    "sofa",
    "pottedplant",
    "bed",
    "diningtable",
    "toilet",
    "tvmonitor",
    "laptop",
    "mouse",
    "remote",
    "keyboard",
    "cell phone",
    "microwave",
    "oven",
    "toaster",
    "sink",
    "refrigerator",
    "book",
    "clock",
    "vase",
    "scissors",
    "teddy bear",
    "hair drier",
    "toothbrush"
}

hook.Add("HUDPaint", "capture_show", function()
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(rtMaterial)
	surface.DrawTexturedRect(0, 0, rtWidth, rtHeight)

    local objects = YOLOX.GetObjects()
    for i = 1, #objects do
        local object = objects[i]

        surface.SetDrawColor(0, 170, 0, 255)
        surface.DrawOutlinedRect(object.x, object.y, object.w, object.h, 1)

        surface.SetDrawColor(0, 170, 0, 255)
        surface.DrawRect(object.x, object.y, object.w, 10)

        draw.SimpleText(yoloxLabels[object.label + 1], "DermaDefault", object.x + 2, object.y - 2, color_white)
    end
end)

hook.Add("PostRender", "capture", function()
    local curTime = CurTime()

    if curTime > nextSnap then
        render.PushRenderTarget(rtTexture)
            render.Clear(0, 0, 0, 255)
            render.ClearDepth()

            cam.Start2D()
                render.RenderView({origin = EyePos(), angles = EyeAngles(), x = 0, y = 0, w = rtWidth, h = rtHeight, fov = 90})
            cam.End2D()
        render.PopRenderTarget()

        YOLOX.AddRenderTarget(rtTexture)
        nextSnap = curTime + (1 / snapFPS)
    end
end)