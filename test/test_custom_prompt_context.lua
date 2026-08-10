local helper = require("test.test_helper")
local assert = helper.assert
local CustomPromptContext = require("assistant_custom_prompt_context")

local function test(name, fn)
    return { name = name, fn = fn }
end

local tests = {
    test("uses configured words around a short selected sentence", function()
        local received_words
        local context = CustomPromptContext.getContext({ features = { highlight_context_words = 12 } }, {
            highlight = {
                getSelectedSentence = function() return "The selected word is here." end,
                getSelectedWordContext = function(_, word_count)
                    received_words = word_count
                    return "Previous context. ", " Following context."
                end,
            },
        }, "word")

        assert.equal(received_words, 12)
        assert.equal(context, "Previous context. word Following context.")
    end),

    test("uses a long selected sentence without requesting word context", function()
        local sentence = string.rep("before ", 50) .. "word " .. string.rep("after ", 2)
        local context = CustomPromptContext.getContext({ features = {} }, {
            highlight = { getSelectedSentence = function() return sentence end },
        }, "word")

        assert.equal(context, sentence)
    end),
}

return helper.runTests("custom_prompt_context", tests)
