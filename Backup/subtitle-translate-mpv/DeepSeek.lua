-- 将本文件放在 /Users/c/.config/mpv/scripts/subtitle-translate-mpv/modules/translators 中
-- 导入必要的库
local json = require("cjson")
local mp = require 'mp'
local utils = require 'mp.utils'
local auto = require 'modules.translators.encodings.auto'
local tlib = require 'tablelib'

---@param from string
---@param to string
return function (from, to)
    ---@type TranslationProvider
    return {
        translate = function (value)
            -- DeepSeek 翻译 API 的 URL
            local api_url = "https://api.deepseek.com/v1/chat/completions"

            -- 你的 API 密钥
            local api_key = "sk-5953eec93a7d4c6f8cff9739000d1bae"

            -- 要翻译的文本
            local text_to_translate = value

            -- 构建请求体
            local request_body = {
                    model = "deepseek-chat",
                    messages = {
                      {role = "system",
                      content = "You are a translation assistant, translate the text to Chinese."},
                      {role = "user", content = text_to_translate}
                    },
                    stream = false
            }

            -- 将请求体转换为 JSON 字符串
            local request_body_json = json.encode(request_body)

            -- 构建 curl 命令
            local curl_command = string.format(
                'curl "%s" -H "Authorization: Bearer %s" -H "Content-Type: application/json" -d \'%s\'',
                api_url, api_key, request_body_json)

            local result = mp.command_native({
                name = 'subprocess',
                args = {
                    'sh',
                    '-c',
                    curl_command,
                },
                capture_stdout = true,
                capture_stderr = true,
            })

            if result.status ~= 0 then
                mp.msg.error('[curl] Command failed with status ' .. result.status)
                mp.msg.error('[curl] Error output: ' .. result.stderr)
                return text_to_translate
            end

            local response_data = json.decode(result.stdout)

            if response_data == nil then
                mp.msg.warn('[curl] Got empty response')
                return text_to_translate
            end

            -- 输出响应内容
            for i, message in ipairs(response_data.choices) do
                translated_text = message.message.content

                if translated_text == nil then
                    mp.msg.warn('[curl] Translation failed')
                    return text_to_translate
                end

								mp.msg.warn(translated_text)
                return translated_text
            end
        end,

        get_error = function (err)
            if err.status ~= nil and err.status == -3 then
                return 'curl not reachable in path'
            else
                return utils.format_json(err)
            end
        end,
    }
end
