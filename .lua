local HttpService = game:GetService("HttpService")
local Analytics = {}

local API_URL = "https://palyanitsya.xyz/api/analytics"
local API_KEY = "huesosik_228_pisun"

-- Universal request function - works with executors and regular Roblox
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local function sendData(endpoint, payload)
    local url = API_URL .. endpoint
    local body = HttpService:JSONEncode(payload)
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = API_KEY,
    }

    -- Try executor request first (bypasses Roblox limits)
    if httpRequest then
        local ok, result = pcall(function()
            return httpRequest({
                Url = url,
                Method = "POST",
                Headers = headers,
                Body = body,
            })
        end)
        if ok and result then
            return true, result.StatusCode, result.Body
        end
    end

    -- Fallback to HttpService (only works in Studio with HTTP enabled)
    local ok, err = pcall(function()
        HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson, false, headers)
    end)
    return ok, nil, tostring(err)
end

function Analytics.TrackUsage(scriptName)
    local ok, status, body = sendData("/track", {
        script = scriptName,
        placeId = game.PlaceId,
        timestamp = os.time()
    })
    if not ok then
        warn("[Analytics] TrackUsage failed:", body)
    else
        print("[Analytics] TrackUsage sent for '" .. scriptName .. "' status:", status or "ok")
    end
    return ok
end

function Analytics.SendError(scriptName, reason)
    local ok, status, body = sendData("/error", {
        script = scriptName,
        gameId = game.PlaceId,
        reason = reason,
        timestamp = os.time()
    })
    if not ok then
        warn("[Analytics] SendError failed:", body)
    else
        print("[Analytics] SendError sent for '" .. scriptName .. "' status:", status or "ok")
    end
    return ok
end

return Analytics