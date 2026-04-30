--- @diagnostic disable: invisible, missing-fields
local assert = require("tests.helpers.assert")

local Logger = require("agentic.utils.logger")
local Config = require("agentic.config")

describe("Logger", function()
    local original_print
    local original_debug
    local captured_calls

    before_each(function()
        captured_calls = {}
        original_print = _G.print
        _G.print = function(...)
            local args = { n = select("#", ...), ... }
            table.insert(captured_calls, args)
        end

        original_debug = Config.debug
        Config.debug = true
    end)

    after_each(function()
        _G.print = original_print
        Config.debug = original_debug
    end)

    describe("debug", function()
        it("calls print with a single concatenated string argument", function()
            Logger.debug("first", "second", "third")

            assert.equal(1, #captured_calls)
            assert.equal(1, captured_calls[1].n)
            assert.equal("string", type(captured_calls[1][1]))
            assert.is_true(captured_calls[1][1]:find("first", 1, true) ~= nil)
            assert.is_true(captured_calls[1][1]:find("second", 1, true) ~= nil)
            assert.is_true(captured_calls[1][1]:find("third", 1, true) ~= nil)
        end)

        it("inspects non-string values", function()
            Logger.debug("err:", { foo = 1 })

            assert.equal(1, #captured_calls)
            assert.equal(1, captured_calls[1].n)
            assert.is_true(captured_calls[1][1]:find("foo = 1", 1, true) ~= nil)
        end)

        it("does not call print when Config.debug is false", function()
            Config.debug = false
            Logger.debug("ignored")
            assert.equal(0, #captured_calls)
        end)
    end)
end)
