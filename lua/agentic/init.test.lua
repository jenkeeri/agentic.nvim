--- @diagnostic disable: invisible, missing-fields, assign-type-mismatch, cast-local-type, param-type-mismatch
local assert = require("tests.helpers.assert")
local spy = require("tests.helpers.spy")

local Config = require("agentic.config")
local Logger = require("agentic.utils.logger")
local SessionRegistry = require("agentic.session_registry")

describe("init.lua public API safety", function()
    local logger_notify_stub
    local original_provider
    local registry_stub

    before_each(function()
        original_provider = Config.provider
        logger_notify_stub = spy.stub(Logger, "notify")

        -- Force the session callback to fire with a fake session so we can
        -- exercise the code path inside the closure.
        registry_stub = spy.stub(SessionRegistry, "get_session_for_tab_page")
        registry_stub:invokes(function(_tab_page_id, callback)
            local fake_session = {
                widget = {
                    show = function() end,
                    hide = function() end,
                    is_open = function()
                        return false
                    end,
                },
                add_file_to_session = function() end,
                add_selection_or_file_to_session = function() end,
            }
            if callback then
                callback(fake_session)
            end
            return fake_session
        end)
    end)

    after_each(function()
        Config.provider = original_provider
        logger_notify_stub:revert()
        registry_stub:revert()
    end)

    describe("add_files_to_context", function()
        it("does not crash when called with nil opts", function()
            local Agentic = require("agentic")
            local ok = pcall(Agentic.add_files_to_context, nil)
            assert.is_true(ok)
        end)

        it("does not crash when called with non-table opts", function()
            local Agentic = require("agentic")
            local ok = pcall(Agentic.add_files_to_context, "not a table")
            assert.is_true(ok)
        end)

        it("notifies user on bad opts", function()
            local Agentic = require("agentic")
            pcall(Agentic.add_files_to_context, nil)
            assert.is_true(logger_notify_stub.call_count >= 1)
        end)
    end)

    describe("new_session", function()
        it("does not assign an unknown provider name to Config", function()
            local Agentic = require("agentic")
            local provider_before = Config.provider

            pcall(Agentic.new_session, { provider = "definitely-not-real" })

            assert.equal(provider_before, Config.provider)
        end)

        it("notifies user when an unknown provider is requested", function()
            local Agentic = require("agentic")
            pcall(Agentic.new_session, { provider = "definitely-not-real" })
            assert.is_true(logger_notify_stub.call_count >= 1)
        end)
    end)
end)

describe("SessionRegistry.sessions table", function()
    it("retains entries across GC (strong references)", function()
        -- The registry must keep sessions alive even when no other Lua
        -- reference exists, so that an active chat is never collected
        -- mid-flight by GC. A weak-valued table would lose entries here.
        local fake_session = { id = "test" }
        SessionRegistry.sessions[99999] = fake_session
        fake_session = nil
        collectgarbage("collect")
        collectgarbage("collect")
        assert.is_not_nil(SessionRegistry.sessions[99999])
        SessionRegistry.sessions[99999] = nil
    end)
end)
