-- Context extraction used only by custom prompts with the {context} placeholder.

local koutil = require("util")

local CustomPromptContext = {}

function CustomPromptContext.getContext(configuration, ui, highlighted_text)
    local previous, following = "", ""
    local context_words = koutil.tableGetValue(configuration, "features", "highlight_context_words") or 50

    if ui.highlight and ui.highlight.getSelectedWordContext then
        local use_fallback_context = true
        if ui.highlight.getSelectedSentence then
            local success, sentence = pcall(function() return ui.highlight:getSelectedSentence() end)
            if success and sentence then
                local word_start, word_end = string.find(sentence, highlighted_text, 1, true)
                if word_start then
                    local sentence_previous = string.sub(sentence, 1, word_start - 1)
                    local sentence_following = string.sub(sentence, word_end + 1)
                    local _, previous_words = string.gsub(sentence_previous, "%S+", "")
                    local _, following_words = string.gsub(sentence_following, "%S+", "")
                    if previous_words >= context_words or following_words >= context_words then
                        previous = sentence_previous
                        following = sentence_following
                        use_fallback_context = false
                    end
                end
            end
        end

        if use_fallback_context then
            local success, context_previous, context_following = pcall(function()
                return ui.highlight:getSelectedWordContext(context_words)
            end)
            if success then
                previous = context_previous or ""
                following = context_following or ""
            end
        end
    end

    return previous .. highlighted_text .. following
end

return CustomPromptContext
